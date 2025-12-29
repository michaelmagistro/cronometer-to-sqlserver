-- !!! WARNING: These procedures will DROP and RECREATE the target tables. !!!
-- This is to ensure a clean load of data from the Cronometer export files.
-- Make sure to back up any existing data if necessary before executing these procedures.
-- This script is intended for use with the Cronometer data export files.
-- Ensure all export files are present in the downloads directory before running this script.
-- This file only creates or alters the loading procedures. To execute the loading, run: `EXEC dbo.Load_All_Cronometer_Data @base_path = 'C:\exports\cronometer\';`

USE Cronometer -- !!! WARNING: Change to your target database name if not Cronometer !!!
GO

-- =============================================
-- MAIN LOADING PROCEDURE
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_All_Cronometer_Data @base_path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    PRINT 'Loading Biometrics...'
    EXEC dbo.Load_Biometrics @base_path = @base_path;

    PRINT 'Loading Daily Summary...'
    EXEC dbo.Load_DailySummary @base_path = @base_path;

    PRINT 'Loading Exercises...'
    EXEC dbo.Load_Exercises @base_path = @base_path;

    PRINT 'Loading Fasts...'
    EXEC dbo.Load_Fasts @base_path = @base_path;

    PRINT 'Loading Notes...'
    EXEC dbo.Load_Notes @base_path = @base_path;

    PRINT 'Loading Servings...'
    EXEC dbo.Load_Servings @base_path = @base_path;

    PRINT 'All Cronometer data loaded successfully!'
END
GO

-- =============================================
-- Load DailySummary
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_DailySummary @base_path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.DailySummary') IS NOT NULL
        DROP TABLE dbo.DailySummary;

    CREATE TABLE dbo.DailySummary (
        [Date] DATETIME2 NOT NULL,
        [Energy_kcal] FLOAT NULL,
        [Alcohol_g] FLOAT NULL,
        [Ash_g] FLOAT NULL,
        [Beta_Hydroxybutyrate_g] FLOAT NULL,
        [Caffeine_mg] FLOAT NULL,
        [Oxalate_mg] FLOAT NULL,
        [Water_g] FLOAT NULL,
        [B1_Thiamine_mg] FLOAT NULL,
        [B2_Riboflavin_mg] FLOAT NULL,
        [B3_Niacin_mg] FLOAT NULL,
        [B5_Pantothenic_Acid_mg] FLOAT NULL,
        [B6_Pyridoxine_mg] FLOAT NULL,
        [B12_Cobalamin_µg] FLOAT NULL,
        [Alpha_carotene_µg] FLOAT NULL,
        [Beta_Tocopherol_mg] FLOAT NULL,
        [Beta_carotene_µg] FLOAT NULL,
        [Beta_cryptoxanthin_µg] FLOAT NULL,
        [Biotin_µg] FLOAT NULL,
        [Choline_mg] FLOAT NULL,
        [Delta_Tocopherol_mg] FLOAT NULL,
        [Folate_µg] FLOAT NULL,
        [Gamma_Tocopherol_mg] FLOAT NULL,
        [Lutein_Zeaxanthin_µg] FLOAT NULL,
        [Lycopene_µg] FLOAT NULL,
        [Retinol_µg] FLOAT NULL,
        [Vitamin_A_µg] FLOAT NULL,
        [Vitamin_C_mg] FLOAT NULL,
        [Vitamin_D_IU] FLOAT NULL,
        [Vitamin_E_mg] FLOAT NULL,
        [Vitamin_K_µg] FLOAT NULL,
        [Calcium_mg] FLOAT NULL,
        [Chromium_µg] FLOAT NULL,
        [Copper_mg] FLOAT NULL,
        [Fluoride_µg] FLOAT NULL,
        [Iodine_µg] FLOAT NULL,
        [Iron_mg] FLOAT NULL,
        [Magnesium_mg] FLOAT NULL,
        [Manganese_mg] FLOAT NULL,
        [Molybdenum_µg] FLOAT NULL,
        [Phosphorus_mg] FLOAT NULL,
        [Potassium_mg] FLOAT NULL,
        [Selenium_µg] FLOAT NULL,
        [Sodium_mg] FLOAT NULL,
        [Zinc_mg] FLOAT NULL,
        [Allulose_g] FLOAT NULL,
        [Carbs_g] FLOAT NULL,
        [Fiber_g] FLOAT NULL,
        [Fructose_g] FLOAT NULL,
        [Galactose_g] FLOAT NULL,
        [Glucose_g] FLOAT NULL,
        [Lactose_g] FLOAT NULL,
        [Maltose_g] FLOAT NULL,
        [Starch_g] FLOAT NULL,
        [Sucrose_g] FLOAT NULL,
        [Sugars_g] FLOAT NULL,
        [Added_Sugars_g] FLOAT NULL,
        [Sugar_Alcohol_g] FLOAT NULL,
        [Net_Carbs_g] FLOAT NULL,
        [Fat_g] FLOAT NULL,
        [Cholesterol_mg] FLOAT NULL,
        [Monounsaturated_g] FLOAT NULL,
        [Polyunsaturated_g] FLOAT NULL,
        [Saturated_g] FLOAT NULL,
        [Trans_Fats_g] FLOAT NULL,
        [Omega_3_g] FLOAT NULL,
        [Omega_6_g] FLOAT NULL,
        [Phytosterol_mg] FLOAT NULL,
        [Alanine_g] FLOAT NULL,
        [Arginine_g] FLOAT NULL,
        [Aspartic_acid_g] FLOAT NULL,
        [Cystine_g] FLOAT NULL,
        [Glutamic_acid_g] FLOAT NULL,
        [Glycine_g] FLOAT NULL,
        [Histidine_g] FLOAT NULL,
        [Hydroxyproline_g] FLOAT NULL,
        [Isoleucine_g] FLOAT NULL,
        [Leucine_g] FLOAT NULL,
        [Lysine_g] FLOAT NULL,
        [Methionine_g] FLOAT NULL,
        [Phenylalanine_g] FLOAT NULL,
        [Proline_g] FLOAT NULL,
        [Protein_g] FLOAT NULL,
        [Serine_g] FLOAT NULL,
        [Threonine_g] FLOAT NULL,
        [Tryptophan_g] FLOAT NULL,
        [Tyrosine_g] FLOAT NULL,
        [Valine_g] FLOAT NULL,
        [Completed] NVARCHAR(10) NULL
    );

    DECLARE @file_path NVARCHAR(1000) = @base_path + N'DailySummary.csv';
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'BULK INSERT dbo.DailySummary FROM ''' + @file_path + N''' WITH (' +
        N'FORMAT = ''CSV'',' +
        N'FIRSTROW = 2,' +
        N'FIELDTERMINATOR = '','',' +
        N'ROWTERMINATOR = ''0x0a'',' +
        N'FIELDQUOTE = ''"'',' +
        N'TABLOCK' +
        N');';
    EXEC(@sql);
END
GO

-- =============================================
-- Load Servings
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Servings @base_path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.Servings') IS NOT NULL
        DROP TABLE dbo.Servings;

    CREATE TABLE dbo.Servings (
        [Day] DATE NOT NULL,
        [Time] TIME NULL,
        [Group] NVARCHAR(100) NOT NULL,
        [Food_Name] NVARCHAR(300) NOT NULL,
        [Amount] NVARCHAR(100) NOT NULL,
        [Energy_kcal] FLOAT NULL,
        [Alcohol_g] FLOAT NULL,
        [Ash_g] FLOAT NULL,
        [Beta_Hydroxybutyrate_g] FLOAT NULL,
        [Caffeine_mg] FLOAT NULL,
        [Oxalate_mg] FLOAT NULL,
        [Water_g] FLOAT NULL,
        [B1_Thiamine_mg] FLOAT NULL,
        [B2_Riboflavin_mg] FLOAT NULL,
        [B3_Niacin_mg] FLOAT NULL,
        [B5_Pantothenic_Acid_mg] FLOAT NULL,
        [B6_Pyridoxine_mg] FLOAT NULL,
        [B12_Cobalamin_µg] FLOAT NULL,
        [Alpha_carotene_µg] FLOAT NULL,
        [Beta_Tocopherol_mg] FLOAT NULL,
        [Beta_carotene_µg] FLOAT NULL,
        [Beta_cryptoxanthin_µg] FLOAT NULL,
        [Biotin_µg] FLOAT NULL,
        [Choline_mg] FLOAT NULL,
        [Delta_Tocopherol_mg] FLOAT NULL,
        [Folate_µg] FLOAT NULL,
        [Gamma_Tocopherol_mg] FLOAT NULL,
        [Lutein_Zeaxanthin_µg] FLOAT NULL,
        [Lycopene_µg] FLOAT NULL,
        [Retinol_µg] FLOAT NULL,
        [Vitamin_A_µg] FLOAT NULL,
        [Vitamin_C_mg] FLOAT NULL,
        [Vitamin_D_IU] FLOAT NULL,
        [Vitamin_E_mg] FLOAT NULL,
        [Vitamin_K_µg] FLOAT NULL,
        [Calcium_mg] FLOAT NULL,
        [Chromium_µg] FLOAT NULL,
        [Copper_mg] FLOAT NULL,
        [Fluoride_µg] FLOAT NULL,
        [Iodine_µg] FLOAT NULL,
        [Iron_mg] FLOAT NULL,
        [Magnesium_mg] FLOAT NULL,
        [Manganese_mg] FLOAT NULL,
        [Molybdenum_µg] FLOAT NULL,
        [Phosphorus_mg] FLOAT NULL,
        [Potassium_mg] FLOAT NULL,
        [Selenium_µg] FLOAT NULL,
        [Sodium_mg] FLOAT NULL,
        [Zinc_mg] FLOAT NULL,
        [Allulose_g] FLOAT NULL,
        [Carbs_g] FLOAT NULL,
        [Fiber_g] FLOAT NULL,
        [Fructose_g] FLOAT NULL,
        [Galactose_g] FLOAT NULL,
        [Glucose_g] FLOAT NULL,
        [Lactose_g] FLOAT NULL,
        [Maltose_g] FLOAT NULL,
        [Starch_g] FLOAT NULL,
        [Sucrose_g] FLOAT NULL,
        [Sugars_g] FLOAT NULL,
        [Added_Sugars_g] FLOAT NULL,
        [Sugar_Alcohol_g] FLOAT NULL,
        [Net_Carbs_g] FLOAT NULL,
        [Fat_g] FLOAT NULL,
        [Cholesterol_mg] FLOAT NULL,
        [Monounsaturated_g] FLOAT NULL,
        [Polyunsaturated_g] FLOAT NULL,
        [Saturated_g] FLOAT NULL,
        [Trans_Fats_g] FLOAT NULL,
        [Omega_3_g] FLOAT NULL,
        [Omega_6_g] FLOAT NULL,
        [Phytosterol_mg] FLOAT NULL,
        [Alanine_g] FLOAT NULL,
        [Arginine_g] FLOAT NULL,
        [Aspartic_acid_g] FLOAT NULL,
        [Cystine_g] FLOAT NULL,
        [Glutamic_acid_g] FLOAT NULL,
        [Glycine_g] FLOAT NULL,
        [Histidine_g] FLOAT NULL,
        [Hydroxyproline_g] FLOAT NULL,
        [Isoleucine_g] FLOAT NULL,
        [Leucine_g] FLOAT NULL,
        [Lysine_g] FLOAT NULL,
        [Methionine_g] FLOAT NULL,
        [Phenylalanine_g] FLOAT NULL,
        [Proline_g] FLOAT NULL,
        [Protein_g] FLOAT NULL,
        [Serine_g] FLOAT NULL,
        [Threonine_g] FLOAT NULL,
        [Tryptophan_g] FLOAT NULL,
        [Tyrosine_g] FLOAT NULL,
        [Valine_g] FLOAT NULL,
        [Category] NVARCHAR(100) NULL
    );

    DECLARE @file_path NVARCHAR(1000) = @base_path + N'servings.csv';
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'BULK INSERT dbo.Servings FROM ''' + @file_path + N''' WITH (' +
        N'FORMAT = ''CSV'',' +
        N'FIRSTROW = 2,' +
        N'FIELDTERMINATOR = '','',' +
        N'ROWTERMINATOR = ''0x0a'',' +
        N'FIELDQUOTE = ''"'',' +
        N'TABLOCK' +
        N');';
    EXEC(@sql);
END
GO

-- =============================================
-- Load Exercises
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Exercises @base_path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.Exercises') IS NOT NULL
        DROP TABLE dbo.Exercises;

    CREATE TABLE dbo.Exercises (
        [Day] DATE NOT NULL,
        [Time] TIME NULL,
        [Group] NVARCHAR(100) NOT NULL,
        [Exercise] NVARCHAR(100) NOT NULL,
        [Minutes] FLOAT NOT NULL,
        [Calories_Burned] FLOAT NOT NULL
    );

    DECLARE @file_path NVARCHAR(1000) = @base_path + N'exercises.csv';
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'BULK INSERT dbo.Exercises FROM ''' + @file_path + N''' WITH (' +
        N'FORMAT = ''CSV'',' +
        N'FIRSTROW = 2,' +
        N'FIELDTERMINATOR = '','',' +
        N'ROWTERMINATOR = ''0x0a'',' +
        N'FIELDQUOTE = ''"'',' +
        N'TABLOCK' +
        N');';
    EXEC(@sql);
END
GO

-- =============================================
-- Load Biometrics
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Biometrics @base_path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.Biometrics') IS NOT NULL
        DROP TABLE dbo.Biometrics;

    CREATE TABLE dbo.Biometrics (
        [Day] DATETIME2 NOT NULL,
        [Time] NVARCHAR(100) NULL,
        [Group] NVARCHAR(100) NOT NULL,
        [Metric] NVARCHAR(100) NOT NULL,
        [Unit] NVARCHAR(100) NOT NULL,
        [Amount] FLOAT NOT NULL
    );

    DECLARE @file_path NVARCHAR(1000) = @base_path + N'biometrics.csv';
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'BULK INSERT dbo.Biometrics FROM ''' + @file_path + N''' WITH (' +
        N'FORMAT = ''CSV'',' +
        N'FIRSTROW = 2,' +
        N'FIELDTERMINATOR = '','',' +
        N'ROWTERMINATOR = ''0x0a'',' +
        N'FIELDQUOTE = ''"'',' +
        N'TABLOCK' +
        N');';
    EXEC(@sql);
END
GO

-- =============================================
-- Load Notes
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Notes @base_path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.Notes') IS NOT NULL
        DROP TABLE dbo.Notes;

    CREATE TABLE dbo.Notes (
        [Day] DATE NOT NULL,
        [Time] TIME NULL,
        [Group] NVARCHAR(100) NOT NULL,
        [Note] VARCHAR(MAX) NOT NULL
    );

    DECLARE @file_path NVARCHAR(1000) = @base_path + N'notes.csv';
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'BULK INSERT dbo.Notes FROM ''' + @file_path + N''' WITH (' +
        N'FORMAT = ''CSV'',' +
        N'FIRSTROW = 2,' +
        N'FIELDTERMINATOR = '','',' +
        N'ROWTERMINATOR = ''0x0a'',' +
        N'FIELDQUOTE = ''"'',' +
        N'TABLOCK' +
        N');';
    EXEC(@sql);
END
GO

-- =============================================
-- Load Fasts
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Fasts @base_path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.Fasts') IS NOT NULL
        DROP TABLE dbo.Fasts;

    CREATE TABLE dbo.Fasts (
        [Name] NVARCHAR(100) NOT NULL,
        [Start] DATETIME2 NOT NULL,
        [End] DATETIME2 NOT NULL,
        [Recurrence] NVARCHAR(100) NOT NULL,
        [Comments] NVARCHAR(MAX) NULL
    );

    DECLARE @file_path NVARCHAR(1000) = @base_path + N'fasts.csv';
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'BULK INSERT dbo.Fasts FROM ''' + @file_path + N''' WITH (' +
        N'FORMAT = ''CSV'',' +
        N'FIRSTROW = 2,' +
        N'FIELDTERMINATOR = '','',' +
        N'ROWTERMINATOR = ''0x0a'',' +
        N'FIELDQUOTE = ''"'',' +
        N'TABLOCK' +
        N');';
    EXEC(@sql);
END
GO