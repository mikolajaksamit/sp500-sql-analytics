/*
===============================================================================
Script: 10_all_time_growth_leaders.sql
Description: Calculates the absolute all-time growth percentage for S&P 500 
             companies. Utilizes Window Functions to extract the first and last 
             recorded trading prices, identifying the top 20 historical performers.
===============================================================================
*/

WITH first_last_price AS (
    SELECT 
        sc.symbol AS company_ticker, 
        sc.sector AS sector_name,
        FIRST_VALUE(ss.Close) OVER(PARTITION BY sc.symbol ORDER BY ss.Date ASC) AS first_recorded_price,
        FIRST_VALUE(ss.Close) OVER(PARTITION BY sc.symbol ORDER BY ss.Date DESC) AS last_recorded_price
    FROM sp500_stocks ss 
    JOIN sp500_companies sc ON ss.symbol = sc.symbol 
    WHERE ss.Close IS NOT NULL
)
SELECT DISTINCT
    company_ticker,
    sector_name,
    first_recorded_price,
    last_recorded_price,
    ROUND(((last_recorded_price - first_recorded_price) / first_recorded_price) * 100.0, 2) AS all_time_growth_pct
FROM first_last_price
ORDER BY all_time_growth_pct DESC
LIMIT 20; 