/*
===============================================================================
Script: 02_maximum_historical_drawdown.sql
Description: Calculates the Maximum Drawdown (MDD) for S&P 500 companies.
             Utilizes Window Functions with unbounded preceding frames to track 
             the rolling All-Time High (ATH) and identifies the top 10 most 
             severe historical percentage drops from peak values.
===============================================================================
*/
with all_time_high as(
select ss.symbol as company_ticker
,ss.date 
,ss.close as close_price
,sc.sector as sector_name
,max(ss.close)over(partition by ss.symbol order by ss.date rows between unbounded preceding and current row) as highest_price
from sp500_stocks_clean ss 
join sp500_companies sc on ss.symbol=sc.symbol 
)
select company_ticker,sector_name,
min(round(((Close_price - highest_price)/highest_price)*100.0,2)) as max_historical_drawdown_pct
from all_time_high 
group by company_ticker,sector_name
order by max_historical_drawdown_pct asc
limit 10

