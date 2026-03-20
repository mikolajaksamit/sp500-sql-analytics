/*
===============================================================================
Script: 04_golden_cross_trend_strength.sql
Description: Evaluates long-term versus short-term momentum by calculating 
             the 50-day and 200-day Simple Moving Averages (SMA). Extracts 
             the most recent trading day using ROW_NUMBER() and measures 
             the trend strength percentage to identify top Golden Cross setups.
===============================================================================
*/
with avg_prices as(
select date as trading_date,
symbol as company_ticker,
close as close_price,
round(avg(close)over(partition by symbol order by date rows between 49 preceding and current row),2) as "50d_avg",
round(avg(close)over(partition by symbol order by date rows between 199 preceding and current row),2) as "200d_avg",
row_number()over(partition by symbol order by date desc) as rn
from sp500_stocks
)
select 
company_ticker,
"50d_avg",
"200d_avg",
round((("50d_avg"-"200d_avg")/nullif("200d_avg",0))*100.0,2) as trend_strength_pct
from avg_prices
where rn=1 and "200d_avg" > 0
ORDER BY trend_strength_pct desc
limit 20