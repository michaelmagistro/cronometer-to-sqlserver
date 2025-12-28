-- =============================================
-- MAIN LOADING PROCEDURE
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_All_Cronometer_Data
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Loading Biometrics...'
    EXEC dbo.Load_Biometrics;

    PRINT 'Loading Daily Summary...'
    EXEC dbo.Load_DailySummary;

    PRINT 'Loading Exercises...'
    EXEC dbo.Load_Exercises;

    PRINT 'Loading Fasts...'
    EXEC dbo.Load_Fasts;

    PRINT 'Loading Notes...'
    EXEC dbo.Load_Notes;

    PRINT 'Loading Servings...'
    EXEC dbo.Load_Servings;

    PRINT 'All Cronometer data loaded successfully!'
END
GO

-- =============================================
-- Load DailySummary
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_DailySummary
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.DailySummary') IS NOT NULL
        DROP TABLE dbo.DailySummary;

    CREATE TABLE dbo.DailySummary (
        [Date] DATETIME2 NOT NULL,
        [Energy_kcal] NVARCHAR(100) NULL,
        [Alcohol_g] NVARCHAR(100) NULL,
        [Ash_g] NVARCHAR(100) NULL,
        [Beta_Hydroxybutyrate_g] NVARCHAR(100) NULL,
        [Caffeine_mg] NVARCHAR(100) NULL,
        [Oxalate_mg] NVARCHAR(100) NULL,
        [Water_g] NVARCHAR(100) NULL,
        [B1_Thiamine_mg] NVARCHAR(100) NULL,
        [B2_Riboflavin_mg] NVARCHAR(100) NULL,
        [B3_Niacin_mg] NVARCHAR(100) NULL,
        [B5_Pantothenic_Acid_mg] NVARCHAR(100) NULL,
        [B6_Pyridoxine_mg] NVARCHAR(100) NULL,
        [B12_Cobalamin_µg] NVARCHAR(100) NULL,
        [Alpha_carotene_µg] NVARCHAR(100) NULL,
        [Beta_Tocopherol_mg] NVARCHAR(100) NULL,
        [Beta_carotene_µg] NVARCHAR(100) NULL,
        [Beta_cryptoxanthin_µg] NVARCHAR(100) NULL,
        [Biotin_µg] NVARCHAR(100) NULL,
        [Choline_mg] NVARCHAR(100) NULL,
        [Delta_Tocopherol_mg] NVARCHAR(100) NULL,
        [Folate_µg] NVARCHAR(100) NULL,
        [Gamma_Tocopherol_mg] NVARCHAR(100) NULL,
        [Lutein_Zeaxanthin_µg] NVARCHAR(100) NULL,
        [Lycopene_µg] NVARCHAR(100) NULL,
        [Retinol_µg] NVARCHAR(100) NULL,
        [Vitamin_A_µg] NVARCHAR(100) NULL,
        [Vitamin_C_mg] NVARCHAR(100) NULL,
        [Vitamin_D_IU] NVARCHAR(100) NULL,
        [Vitamin_E_mg] NVARCHAR(100) NULL,
        [Vitamin_K_µg] NVARCHAR(100) NULL,
        [Calcium_mg] NVARCHAR(100) NULL,
        [Chromium_µg] NVARCHAR(100) NULL,
        [Copper_mg] NVARCHAR(100) NULL,
        [Fluoride_µg] NVARCHAR(100) NULL,
        [Iodine_µg] NVARCHAR(100) NULL,
        [Iron_mg] NVARCHAR(100) NULL,
        [Magnesium_mg] NVARCHAR(100) NULL,
        [Manganese_mg] NVARCHAR(100) NULL,
        [Molybdenum_µg] NVARCHAR(100) NULL,
        [Phosphorus_mg] NVARCHAR(100) NULL,
        [Potassium_mg] NVARCHAR(100) NULL,
        [Selenium_µg] NVARCHAR(100) NULL,
        [Sodium_mg] NVARCHAR(100) NULL,
        [Zinc_mg] NVARCHAR(100) NULL,
        [Allulose_g] NVARCHAR(100) NULL,
        [Carbs_g] NVARCHAR(100) NULL,
        [Fiber_g] NVARCHAR(100) NULL,
        [Fructose_g] NVARCHAR(100) NULL,
        [Galactose_g] NVARCHAR(100) NULL,
        [Glucose_g] NVARCHAR(100) NULL,
        [Lactose_g] NVARCHAR(100) NULL,
        [Maltose_g] NVARCHAR(100) NULL,
        [Starch_g] NVARCHAR(100) NULL,
        [Sucrose_g] NVARCHAR(100) NULL,
        [Sugars_g] NVARCHAR(100) NULL,
        [Added_Sugars_g] NVARCHAR(100) NULL,
        [Sugar_Alcohol_g] NVARCHAR(100) NULL,
        [Net_Carbs_g] NVARCHAR(100) NULL,
        [Fat_g] NVARCHAR(100) NULL,
        [Cholesterol_mg] NVARCHAR(100) NULL,
        [Monounsaturated_g] NVARCHAR(100) NULL,
        [Polyunsaturated_g] NVARCHAR(100) NULL,
        [Saturated_g] NVARCHAR(100) NULL,
        [Trans_Fats_g] NVARCHAR(100) NULL,
        [Omega_3_g] NVARCHAR(100) NULL,
        [Omega_6_g] NVARCHAR(100) NULL,
        [Phytosterol_mg] NVARCHAR(100) NULL,
        [Alanine_g] NVARCHAR(100) NULL,
        [Arginine_g] NVARCHAR(100) NULL,
        [Aspartic_acid_g] NVARCHAR(100) NULL,
        [Cystine_g] NVARCHAR(100) NULL,
        [Glutamic_acid_g] NVARCHAR(100) NULL,
        [Glycine_g] NVARCHAR(100) NULL,
        [Histidine_g] NVARCHAR(100) NULL,
        [Hydroxyproline_g] NVARCHAR(100) NULL,
        [Isoleucine_g] NVARCHAR(100) NULL,
        [Leucine_g] NVARCHAR(100) NULL,
        [Lysine_g] NVARCHAR(100) NULL,
        [Methionine_g] NVARCHAR(100) NULL,
        [Phenylalanine_g] NVARCHAR(100) NULL,
        [Proline_g] NVARCHAR(100) NULL,
        [Protein_g] NVARCHAR(100) NULL,
        [Serine_g] NVARCHAR(100) NULL,
        [Threonine_g] NVARCHAR(100) NULL,
        [Tryptophan_g] NVARCHAR(100) NULL,
        [Tyrosine_g] NVARCHAR(100) NULL,
        [Valine_g] NVARCHAR(100) NULL,
        [Completed] NVARCHAR(10) NULL
    );

    BULK INSERT dbo.DailySummary
    FROM 'C:\exports\cronometer\DailySummary.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIELDQUOTE = '"',
        TABLOCK
    );
END
GO

-- =============================================
-- Load Servings
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Servings
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

    BULK INSERT dbo.Servings
    FROM 'C:\exports\cronometer\servings.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIELDQUOTE = '"',
        TABLOCK
    );
END
GO

-- =============================================
-- Load Exercises
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Exercises
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

    BULK INSERT dbo.Exercises
    FROM 'C:\exports\cronometer\exercises.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,        -- Skip header row
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIELDQUOTE = '"',
        TABLOCK
    );
END
GO

-- =============================================
-- Load Biometrics
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Biometrics
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

    BULK INSERT dbo.Biometrics
    FROM 'C:\exports\cronometer\biometrics.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,                    -- Skip header
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIELDQUOTE = '"',
        TABLOCK
    );
END
GO

-- =============================================
-- Load Notes
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Notes
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

    BULK INSERT dbo.Notes
    FROM 'C:\exports\cronometer\notes.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIELDQUOTE = '"',
        TABLOCK
    );
END
GO

-- =============================================
-- Load Fasts
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Load_Fasts
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

    BULK INSERT dbo.Fasts
    FROM 'C:\exports\cronometer\fasts.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        FIELDQUOTE = '"',
        TABLOCK
    );
END
GO