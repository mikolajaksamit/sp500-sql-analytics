/*
===============================================================================
Script: 03_volume_spike_anomaly_detection.sql
Description: Detects significant trading volume anomalies within the S&P 500.
             Calculates a 30-day rolling average volume (excluding the current 
             trading day) and identifies instances where the actual daily volume 
             spikes to at least 5x (500%) the historical average.
===============================================================================
*/
with volume_breakdown as(
select 
date as trading_date
,symbol as company_ticker
,close
,volume as actual_daily_volume
,round(avg(volume)over(partition by symbol order by date rows between 30 preceding and 1 preceding),2) as avg_30d_volume
from sp500_stocks_clean
)
select trading_date,company_ticker, avg_30d_volume,actual_daily_volume,
round((actual_daily_volume/avg_30d_volume),2) as volume_spike_ratio
from volume_breakdown
where avg_30d_volume > 0 and round((actual_daily_volume/avg_30d_volume),2) >= 5.0
order by volume_spike_ratio desc
limit 15