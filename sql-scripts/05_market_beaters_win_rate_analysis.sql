/*
===============================================================================
Script: 05_market_beaters_win_rate_analysis.sql
Description: Measures the historical performance of individual S&P 500 stocks 
             relative to the broader market index. Uses advanced conditional 
             aggregation (FILTER clause) to calculate the exact win rate 
             percentage of days a stock outperformed the S&P 500.
===============================================================================
*/
with index_returns as(
select date,
("s&p500" - lag("s&p500")over(order by date))/lag("s&p500")over(order by date)*100.0 as  daily_pct_change_index
from sp500_index
)
,stock_returns as (
select date,symbol,
(close-lag(close)over(partition by symbol order by date))/lag(close)over(partition by symbol order by date)*100.0 as daily_pct_change
from sp500_stocks_clean
)
select sr.symbol as company_ticker,
count(*) as total_trading_days,
count(*) filter(where sr.daily_pct_change > ir.daily_pct_change_index) as market_beating_days,
(count(*) filter(where sr.daily_pct_change > ir.daily_pct_change_index)*100.0)/count(*) as win_rate_pct
from stock_returns sr
join index_returns ir on ir.date=sr.date
group by sr.symbol
order by win_rate_pct desc
limit 10