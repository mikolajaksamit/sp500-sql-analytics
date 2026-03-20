/*
===============================================================================
Script: 09_sector_rotation_momentum.sql
Description: Analyzes capital flow and sector rotation within the S&P 500. 
             Calculates daily returns and a 7-day rolling average (Moving Average) 
             for each sector to identify short-term market momentum shifts.
===============================================================================
*/

WITH stock_returns AS (
  SELECT
    sc.sector AS sector_name,
    ss.date   AS trading_date,
    ss.symbol AS company_ticker,
    (ss.close - LAG(ss.close) OVER (PARTITION BY ss.symbol ORDER BY ss.date))
      / NULLIF(LAG(ss.close) OVER (PARTITION BY ss.symbol ORDER BY ss.date), 0) AS daily_return
  FROM sp500_stocks_clean ss
  JOIN sp500_companies sc ON sc.symbol = ss.symbol
),
sector_daily AS (
  SELECT
    sector_name,
    trading_date,
    AVG(daily_return) AS sector_daily_return
  FROM stock_returns
  WHERE daily_return IS NOT NULL
  GROUP BY sector_name, trading_date
)
SELECT
  sector_name,
  trading_date,
  ROUND(sector_daily_return * 100.0, 4) AS sector_daily_return_pct,
  ROUND(
    AVG(sector_daily_return) OVER (
      PARTITION BY sector_name
      ORDER BY trading_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) * 100.0
  , 4) AS sector_7d_avg_return_pct
FROM sector_daily
ORDER BY trading_date DESC, sector_name;