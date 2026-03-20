/*
===============================================================================
Script: 07_gaps_and_islands_winning_streaks.sql
Description: Solves the classic 'Gaps & Islands' sequential data problem to 
             identify the longest consecutive daily winning streaks in the 
             S&P 500. Uses a dual ROW_NUMBER() difference technique to group 
             unbroken periods of positive market returns.
===============================================================================
*/
WITH daily_trend AS (
  SELECT 
    date, 
    (
      (
        "s&p500" - Lag("s&p500") OVER(
          ORDER BY 
            date ASC
        )
      ) / Lag("s&p500") OVER(
        ORDER BY 
          date ASC
      )
    ) * 100.0 AS daily_return_pct, 
    CASE WHEN "s&p500" > Lag("s&p500") OVER(
      ORDER BY 
        date ASC
    ) THEN 1 ELSE 0 END AS is_positive 
  FROM 
    sp500_index
) ,
streak_groups as(
select date,daily_return_pct,is_positive,
ROW_NUMBER() OVER(ORDER BY Date) - ROW_NUMBER() OVER(PARTITION BY is_positive ORDER BY Date) AS streak_id
from daily_trend
)
select min(date) as streak_start_date,
max(date) as streak_end_date,
count(*) as consecutive_positive_days,
ROUND(SUM(daily_return_pct)::numeric, 2) AS total_streak_return_pct
from streak_groups
where is_positive = 1
group by streak_id
order by consecutive_positive_days desc
limit 5