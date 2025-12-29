USE [msdb]
GO

-- Drop the job if it exists
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Cronometer_RefreshDB')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'Cronometer_RefreshDB', @delete_unused_schedule = 1
END
GO

/****** Object:  Job [Cronometer_RefreshDB]    Script Date: Monday/December 29/2025 11:26:24 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: Monday/December 29/2025 11:26:24 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Cronometer_RefreshDB', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Loads Cronometer data from CSV exports - Multi-step with individual logs', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load_Biometrics]    Script Date: Monday/December 29/2025 11:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load_Biometrics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Load_Biometrics @base_path = ''C:\exports\cronometer\'';', 
		@database_name=N'Cronometer', 
		@output_file_name=N'C:\SQLLogs\Cronometer_Step1_Biometrics.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load_DailySummary]    Script Date: Monday/December 29/2025 11:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load_DailySummary', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Load_DailySummary @base_path = ''C:\exports\cronometer\'';', 
		@database_name=N'Cronometer', 
		@output_file_name=N'C:\SQLLogs\Cronometer_Step2_DailySummary.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load_Exercises]    Script Date: Monday/December 29/2025 11:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load_Exercises', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Load_Exercises @base_path = ''C:\exports\cronometer\'';', 
		@database_name=N'Cronometer', 
		@output_file_name=N'C:\SQLLogs\Cronometer_Step3_Exercises.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load_Fasts]    Script Date: Monday/December 29/2025 11:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load_Fasts', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Load_Fasts @base_path = ''C:\exports\cronometer\'';', 
		@database_name=N'Cronometer', 
		@output_file_name=N'C:\SQLLogs\Cronometer_Step4_Fasts.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load_Notes]    Script Date: Monday/December 29/2025 11:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load_Notes', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Load_Notes @base_path = ''C:\exports\cronometer\'';', 
		@database_name=N'Cronometer', 
		@output_file_name=N'C:\SQLLogs\Cronometer_Step5_Notes.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load_Servings]    Script Date: Monday/December 29/2025 11:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load_Servings', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Load_Servings @base_path = ''C:\exports\cronometer\'';', 
		@database_name=N'Cronometer', 
		@output_file_name=N'C:\SQLLogs\Cronometer_Step6_Servings.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'HourlyLoad', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20251229, 
		@active_end_date=99991231, 
		@active_start_time=63000, 
		@active_end_time=213059, 
		@schedule_uid=N'8525356d-02f3-49a9-8f6b-f95f8a192c57'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO







PRINT 'Job created with separate log files:';
PRINT '  - C:\SQLLogs\Cronometer_Step1_Biometrics.log';
PRINT '  - C:\SQLLogs\Cronometer_Step2_DailySummary.log';
PRINT '  - C:\SQLLogs\Cronometer_Step3_Exercises.log';
PRINT '  - C:\SQLLogs\Cronometer_Step4_Fasts.log';
PRINT '  - C:\SQLLogs\Cronometer_Step5_Notes.log';
PRINT '  - C:\SQLLogs\Cronometer_Step6_Servings.log';
GO