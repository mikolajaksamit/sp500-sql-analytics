-- Data Quality Summary
-- Purpose: compare raw vs clean row counts and quantify data dropped due to missing/invalid values.

SELECT
  (SELECT COUNT(*) FROM sp500_stocks)        AS raw_rows,
  (SELECT COUNT(*) FROM sp500_stocks_clean)  AS clean_rows,
  ROUND(
    100.0 * (1 - (SELECT COUNT(*) FROM sp500_stocks_clean)::numeric
                / NULLIF((SELECT COUNT(*) FROM sp500_stocks), 0)),
    2
  ) AS dropped_pct;