DROP TABLE IF EXISTS sp500_stocks_clean;

CREATE TABLE sp500_stocks_clean AS
SELECT
  date,
  symbol,
  close,
  volume
FROM sp500_stocks
WHERE date IS NOT NULL
  AND symbol IS NOT NULL
  AND close IS NOT NULL
  AND close > 0;