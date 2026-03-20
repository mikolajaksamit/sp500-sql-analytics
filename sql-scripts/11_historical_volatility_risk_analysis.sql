/*
===============================================================================
Script: 11_historical_volatility_risk_analysis.sql
Description: Performs quantitative risk analysis on the S&P 500. 
             Calculates historical volatility using standard deviation (STDDEV) 
             of daily returns. Filters for high-beta assets that maintain a 
             positive average growth trajectory (AVG > 0).
===============================================================================
*/
with prices as(
select symbol as company_ticker,
(close - lag(close)over(partition by symbol order by date))/lag(close)over(partition by symbol order by date)*100.0 as daily_return_pct
from sp500_stocks_clean
)
select company_ticker,round(stddev(daily_return_pct),2) as price_volatility_index , round(avg(daily_return_pct),2) as avg_daily_return_pct
from prices
where daily_return_pct is not null
group by company_ticker
having AVG(daily_return_pct) > 0
order by price_volatility_index desc
limit 20