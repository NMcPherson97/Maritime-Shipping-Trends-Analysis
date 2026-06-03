-- Preview data
SELECT TOP 10 *
FROM dbo.maritime_trade_2020_2026;

-- Count records
SELECT COUNT(*) AS TotalRows
FROM dbo.maritime_trade_2020_2026;

-- Check for duplicate shipments
SELECT
    Shipment_ID,
    trade_direction,
    trade_category,
    cargo_type,
    Port_of_Loading,
    Port_of_Discharge,
    Departure_Date,
    Total_Voyage_Cost_USD,
    COUNT(*) AS DuplicateCount
FROM dbo.maritime_trade_2020_2026
GROUP BY
    Shipment_ID,
    trade_direction,
    trade_category,
    cargo_type,
    Port_of_Loading,
    Port_of_Discharge,
    Departure_Date,
    Total_Voyage_Cost_USD
HAVING COUNT(*) > 1;

-- Check for missing values in critical columns
SELECT
    SUM(CASE WHEN trade_direction IS NULL THEN 1 ELSE 0 END) AS MissingTradeDirection,
    SUM(CASE WHEN cargo_type IS NULL THEN 1 ELSE 0 END) AS MissingCargoType,
    SUM(CASE WHEN Total_Voyage_Cost_USD IS NULL THEN 1 ELSE 0 END) AS MissingCost
FROM dbo.maritime_trade_2020_2026;

-- Check consistency of critical values
SELECT DISTINCT trade_direction
FROM dbo.maritime_trade_2020_2026;

SELECT DISTINCT cargo_type
FROM dbo.maritime_trade_2020_2026
ORDER BY cargo_type;

SELECT DISTINCT trade_category
FROM dbo.maritime_trade_2020_2026;

-- Check date column
SELECT TOP 100 Departure_Date
FROM dbo.maritime_trade_2020_2026;

-- Review table structure
EXEC sp_help 'dbo.maritime_trade_2020_2026';

-- Validate Total Voyage Cost
SELECT
    MIN(Total_Voyage_Cost_USD) AS MinCost,
    MAX(Total_Voyage_Cost_USD) AS MaxCost,
    AVG(Total_Voyage_Cost_USD) AS AvgCost
FROM dbo.maritime_trade_2020_2026;

-- Validate shipping cost components
SELECT
    MIN(Bunker_Cost_USD) AS MinFuel,
    MAX(Bunker_Cost_USD) AS MaxFuel,
    AVG(Bunker_Cost_USD) AS AvgFuel,
    MIN(Port_Charges_USD) AS MinPort,
    MAX(Port_Charges_USD) AS MaxPort,
    AVG(Port_Charges_USD) AS AvgPort,
    MIN(Insurance_Cost_USD) AS MinInsurance,
    MAX(Insurance_Cost_USD) AS MaxInsurance,
    AVG(Insurance_Cost_USD) AS AvgInsurance,
    MIN(Demurrage_Cost_USD) AS MinDemurrage,
    MAX(Demurrage_Cost_USD) AS MaxDemurrage,
    AVG(Demurrage_Cost_USD) AS AvgDemurrage
FROM dbo.maritime_trade_2020_2026;

-- Check for negative costs
SELECT *
FROM dbo.maritime_trade_2020_2026
WHERE Bunker_Cost_USD < 0
   OR Port_Charges_USD < 0
   OR Insurance_Cost_USD < 0
   OR Demurrage_Cost_USD < 0
   OR Total_Voyage_Cost_USD < 0;

-- Preview derived date fields
SELECT
    Shipment_ID,
    Departure_Date,
    YEAR(Departure_Date) AS ShipmentYear,
    DATEPART(QUARTER, Departure_Date) AS ShipmentQuarter,
    MONTH(Departure_Date) AS ShipmentMonth,
    DATENAME(MONTH, Departure_Date) AS MonthName
FROM dbo.maritime_trade_2020_2026;

-- Check whether analysis columns already exist
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'maritime_trade_2020_2026'
  AND COLUMN_NAME IN ('ShipmentYear','ShipmentQuarter','ShipmentMonth');

-- Add analysis columns ONLY if they don't exist yet
ALTER TABLE dbo.maritime_trade_2020_2026
ADD ShipmentYear INT,
    ShipmentQuarter INT,
    ShipmentMonth INT;

-- Populate analysis columns
UPDATE dbo.maritime_trade_2020_2026
SET
    ShipmentYear = YEAR(Departure_Date),
    ShipmentQuarter = DATEPART(QUARTER, Departure_Date),
    ShipmentMonth = MONTH(Departure_Date);

-- Trade direction distribution
SELECT
    trade_direction,
    COUNT(*) AS ShipmentCount
FROM dbo.maritime_trade_2020_2026
GROUP BY trade_direction
ORDER BY ShipmentCount DESC;

-- Trade category distribution
SELECT
    trade_category,
    COUNT(*) AS ShipmentCount
FROM dbo.maritime_trade_2020_2026
GROUP BY trade_category
ORDER BY ShipmentCount DESC;

-- Cargo type distribution
SELECT
    cargo_type,
    COUNT(*) AS ShipmentCount
FROM dbo.maritime_trade_2020_2026
GROUP BY cargo_type
ORDER BY ShipmentCount DESC;

-- Remove view if it already exists
IF OBJECT_ID('dbo.vw_maritime_trade_analysis', 'V') IS NOT NULL
DROP VIEW dbo.vw_maritime_trade_analysis;
GO

-- Create analysis view
CREATE VIEW dbo.vw_maritime_trade_analysis AS
SELECT
    Shipment_ID,
    trade_direction,
    trade_category,
    cargo_type,
    Port_of_Loading,
    Port_of_Discharge,
    Departure_Date,
    Arrival_Date,
    ShipmentYear,
    ShipmentQuarter,
    ShipmentMonth,
    Cargo_Value_USD,
    Bunker_Cost_USD,
    Port_Charges_USD,
    Insurance_Cost_USD,
    Demurrage_Cost_USD,
    Total_Voyage_Cost_USD
FROM dbo.maritime_trade_2020_2026;
GO

-- Verify final row count
SELECT COUNT(*) AS FinalRowCount
FROM dbo.maritime_trade_2020_2026;

-- Preview cleaned data
SELECT TOP 5 *
FROM dbo.maritime_trade_2020_2026;