/*
===============================================================================
Script: 08_flash_crash_hero.sql
Description: Identifies the single worst trading day in the S&P 500 index history 
             (Flash Crash). Joins this extreme event with individual stock data 
             to find the 'hero' company that generated the highest positive return 
             while the broader market collapsed. Demonstrates advanced CTE joining 
             and precise NULL handling in sorting.
===============================================================================
*/

with market_crash as (
select date,
(("s&p500" - Lag("s&p500") OVER(ORDER BY date ASC)) / Lag("s&p500") OVER(ORDER BY date ASC)) * 100.0 as index_crash_pct
from sp500_index
order by (("s&p500" - Lag("s&p500") OVER(ORDER BY date ASC)) / Lag("s&p500") OVER(ORDER BY date ASC)) * 100.0
limit 1
), all_stocks_returns as(
select symbol,date, ((close - lag(close) over(partition by symbol order by date asc))/ lag(close) over(partition by symbol order by date asc))*100.0 as hero_return_pct
from sp500_stocks_clean)
select mc.date as crash_date,alr.symbol as company_ticker, round(mc.index_crash_pct::numeric,2) as index_crash_pct,round(hero_return_pct::numeric,2) as hero_return_pct
from market_crash mc
join all_stocks_returns alr on alr.date=mc.date
order by alr.hero_return_pct desc nulls last
limit 1