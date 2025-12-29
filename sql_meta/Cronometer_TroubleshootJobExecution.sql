/***************************************************************************************************
 * SQL AGENT JOB DEBUGGING SCRIPT - Cronometer_RefreshDB
 * Purpose: Kill, monitor, and diagnose stuck SQL Agent jobs
 * Usage: Highlight and run each section as needed
 ***************************************************************************************************/

USE msdb;
GO

/********************************* SECTION 1: KILL STUCK JOB ***************************************/
-- Run this section first to kill any stuck job execution
-- This finds and kills the Agent session, then cleans up metadata

DECLARE @SessionID INT;

-- Find the Agent session running the job
SELECT @SessionID = s.session_id
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
WHERE s.program_name LIKE '%SQLAgent%Job%'
   OR (s.program_name LIKE '%SQLAgent%' AND s.login_name = 'NT SERVICE\SQLSERVERAGENT' AND r.command IS NOT NULL);

-- Kill the session if found
IF @SessionID IS NOT NULL
BEGIN
    DECLARE @SQL NVARCHAR(50) = 'KILL ' + CAST(@SessionID AS NVARCHAR(10));
    EXEC sp_executesql @SQL;
    PRINT 'Killed session: ' + CAST(@SessionID AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT 'No active Agent session found';
END

-- Force-stop the job through Agent
EXEC msdb.dbo.sp_stop_job @job_name = 'Cronometer_RefreshDB';

-- Clean up job activity records (marks job as stopped)
UPDATE msdb.dbo.sysjobactivity
SET stop_execution_date = GETDATE(),
    run_requested_date = start_execution_date
WHERE job_id = (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = 'Cronometer_RefreshDB')
    AND stop_execution_date IS NULL;

PRINT '========== KILL SECTION COMPLETE ==========';
GO



/********************************* SECTION 2.1: Nuclear Option ********************************/
-- Nuclear option: Force close ALL activity for this job

UPDATE msdb.dbo.sysjobactivity
SET stop_execution_date = GETDATE()
WHERE job_id = (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = 'Cronometer_RefreshDB');


-- Verify
SELECT TOP 1
    CASE WHEN stop_execution_date IS NULL THEN 'STILL STUCK' ELSE 'CLEARED' END AS Status
FROM msdb.dbo.sysjobactivity
WHERE job_id = (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = 'Cronometer_RefreshDB')
ORDER BY start_execution_date DESC;
GO

/********************************* SECTION 2.2: Nuclear Option 2 ********************************/
-- Restart SQL Server Agent service to clear any stuck jobs

EXEC xp_servicecontrol N'STOP', N'SQLServerAGENT';
WAITFOR DELAY '00:00:03';
EXEC xp_servicecontrol N'START', N'SQLServerAGENT';
WAITFOR DELAY '00:00:03';
PRINT 'Agent restarted - try job now';


/********************************* SECTION 2: VERIFY JOB IS STOPPED ********************************/
-- Run this to confirm the job is no longer running
-- Should show stop_execution_date populated for all recent runs

SELECT 
    j.name AS JobName,
    ja.start_execution_date,
    ja.stop_execution_date,
    DATEDIFF(SECOND, ja.start_execution_date, ISNULL(ja.stop_execution_date, GETDATE())) AS DurationSeconds,
    CASE 
        WHEN ja.stop_execution_date IS NULL THEN '>>> STILL RUNNING <<<'
        ELSE 'Stopped'
    END AS Status
FROM msdb.dbo.sysjobactivity ja
INNER JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
WHERE j.name = 'Cronometer_RefreshDB'
ORDER BY ja.start_execution_date DESC;
GO

/********************************* SECTION 3: START JOB & MONITOR ***********************************/
-- Run this section to start the job and begin monitoring
-- After running this, immediately run SECTION 4 multiple times

EXEC msdb.dbo.sp_start_job @job_name = 'Cronometer_RefreshDB';
PRINT 'Job started at: ' + CONVERT(VARCHAR(30), GETDATE(), 121);
PRINT 'Now run SECTION 4 repeatedly to monitor...';
GO

/********************************* SECTION 4: MONITOR ACTIVE JOB ************************************/
-- Run this section MULTIPLE TIMES (every 3-5 seconds) while job is running
-- This shows real-time what the Agent session is doing

SELECT 
    GETDATE() AS CheckTime,
    s.session_id,
    s.login_name,
    s.program_name,
    DB_NAME(r.database_id) AS database_name,
    r.status,
    r.command,
    r.wait_type,
    r.wait_time / 1000.0 AS wait_time_seconds,
    r.last_wait_type,
    r.cpu_time,
    r.total_elapsed_time / 1000.0 AS elapsed_seconds,
    r.blocking_session_id,
    SUBSTRING(st.text, (r.statement_start_offset/2)+1,
        ((CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE r.statement_end_offset
        END - r.statement_start_offset)/2) + 1) AS current_statement
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st  -- Changed from LEFT JOIN to OUTER APPLY
WHERE s.program_name LIKE '%SQLAgent%'
ORDER BY s.session_id;

-- Also check job activity status
SELECT 
    'Job Activity Status' AS CheckType,
    j.name,
    ja.start_execution_date,
    ja.stop_execution_date,
    DATEDIFF(SECOND, ja.start_execution_date, GETDATE()) AS SecondsRunning
FROM msdb.dbo.sysjobactivity ja
INNER JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
WHERE j.name = 'Cronometer_RefreshDB'
    AND ja.start_execution_date = (
        SELECT MAX(start_execution_date) 
        FROM msdb.dbo.sysjobactivity 
        WHERE job_id = ja.job_id
    );
GO

/********************************* SECTION 5: CHECK JOB HISTORY *************************************/
-- Run this AFTER the job should have completed (wait 20+ seconds)
-- This shows whether Agent recorded the job completion

SELECT TOP 10
    j.name AS JobName,
    jh.step_name,
    jh.run_date,
    jh.run_time,
    jh.run_duration,
    CASE jh.run_status
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'In Progress'
    END AS run_status,
    jh.message
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobhistory jh ON j.job_id = jh.job_id
WHERE j.name = 'Cronometer_RefreshDB'
ORDER BY jh.instance_id DESC;

-- If this returns NO rows, the job completed but history wasn't written (THE BUG)
-- If it shows "In Progress" status, the job is hung
GO

/********************************* SECTION 6: QUICK STATS *******************************************/
-- Run this anytime to get a quick overview of job status

SELECT 
    '=== JOB OVERVIEW ===' AS Section,
    j.name,
    j.enabled,
    SUSER_SNAME(j.owner_sid) AS owner,
    j.date_created,
    j.date_modified
FROM msdb.dbo.sysjobs j
WHERE j.name = 'Cronometer_RefreshDB';

SELECT 
    '=== RECENT ACTIVITY ===' AS Section,
    COUNT(*) AS TotalRuns,
    SUM(CASE WHEN ja.stop_execution_date IS NULL THEN 1 ELSE 0 END) AS StuckRuns,
    MAX(ja.start_execution_date) AS LastStartTime,
    MAX(ja.stop_execution_date) AS LastStopTime
FROM msdb.dbo.sysjobactivity ja
INNER JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
WHERE j.name = 'Cronometer_RefreshDB';

SELECT 
    '=== ACTIVE AGENT SESSIONS ===' AS Section,
    COUNT(*) AS ActiveAgentSessions
FROM sys.dm_exec_sessions s
WHERE s.program_name LIKE '%SQLAgent%'
    AND s.login_name = 'NT SERVICE\SQLSERVERAGENT';
GO

/********************************* SECTION 7: NUCLEAR OPTION ****************************************/
-- Only run this if the job is completely corrupted and won't stop
-- This restarts the SQL Server Agent service (requires sysadmin)

-- EXEC xp_servicecontrol N'STOP', N'SQLServerAGENT';
-- WAITFOR DELAY '00:00:05';
-- EXEC xp_servicecontrol N'START', N'SQLServerAGENT';
-- PRINT 'SQL Server Agent restarted';
GO

/***************************************************************************************************
 * WORKFLOW INSTRUCTIONS:
 * 
 * Normal debugging workflow:
 * 1. Run SECTION 1 (Kill stuck job)
 * 2. Run SECTION 2 (Verify it's stopped)
 * 3. Run SECTION 3 (Start the job)
 * 4. Run SECTION 4 repeatedly every 3-5 seconds (this is KEY - watch the wait_type!)
 * 5. After 20 seconds, run SECTION 5 (Check if history was written)
 * 
 * What to look for in SECTION 4:
 * - wait_type: tells us WHY the job is stuck
 * - current_statement: shows the exact SQL being executed
 * - elapsed_seconds: shows how long it's been running
 * - If wait_type is NULL and statement shows your EXEC, but it's been > 30 seconds = THE BUG
 * 
 * Common wait_types and what they mean:
 * - NULL or WAITFOR: Normal execution
 * - ASYNC_IO_COMPLETION: Waiting on disk I/O (BULK INSERT is slow)
 * - WRITELOG: Waiting to write transaction log
 * - BACKUPIO: Backup operation
 * - If the session DISAPPEARS from SECTION 4 but SECTION 5 shows no history = THE BUG
 ***************************************************************************************************/