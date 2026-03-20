CREATE INDEX IF NOT EXISTS ix_stocks_clean_symbol_date
  ON sp500_stocks_clean(symbol, date);

CREATE INDEX IF NOT EXISTS ix_stocks_clean_date
  ON sp500_stocks_clean(date);