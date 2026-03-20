/*
===============================================================================
Script: 06_seasonality_monthly_win_rate.sql
Description: Analyzes the historical monthly seasonality of the S&P 500 index.
             Uses temporal extraction and Window Functions to determine 
             start-to-end monthly returns, calculating the historical average 
             and the probability of a positive return (win rate) for each month.
===============================================================================
*/

WITH monthly_data AS (
    SELECT
        EXTRACT(YEAR FROM Date) AS trading_year,
        EXTRACT(MONTH FROM Date) AS trading_month,
        FIRST_VALUE("s&p500") OVER(PARTITION BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date) ORDER BY Date ASC) AS first_value,
        FIRST_VALUE("s&p500") OVER(PARTITION BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date) ORDER BY Date DESC) AS last_value,
        ROW_NUMBER() OVER(PARTITION BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date) ORDER BY Date DESC) AS rn
    FROM sp500_index
), 
monthly_returns AS (
    SELECT 
        trading_month,
        first_value,
        last_value, 
        ((last_value - first_value) / first_value) * 100.0 AS actual_monthly_return
    FROM monthly_data
    WHERE rn = 1
)
SELECT 
    trading_month AS month_of_year,
    AVG(actual_monthly_return) AS historical_avg_return_pct,
    COUNT(*) AS total_occurrences,
    COUNT(*) FILTER(WHERE actual_monthly_return > 0) AS profitable_months,
    ROUND((COUNT(*) FILTER(WHERE actual_monthly_return > 0) * 100.0) / COUNT(*), 2) AS positive_months_ratio_pct
FROM monthly_returns
GROUP BY trading_month
ORDER BY month_of_year ASC;