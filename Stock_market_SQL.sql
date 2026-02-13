Use stock_market;
-- 1. 📊 Total Market Capitalization
SELECT SUM(st.share_price * st.outstanding_shares) AS total_market_cap
FROM stocks st;

-- 2. 📊 Average Daily Trading Volume
SELECT AVG(dp.volume) AS avg_daily_trading_volume
FROM fact_daily_prices dp;

-- 3. 📊 Volatility (Std Dev of Daily Returns)
SELECT c.ticker,
       STDDEV( (dp.close - dp.open) / dp.open ) AS daily_volatility
FROM fact_daily_prices dp
JOIN dim_company c ON dp.company_id = c.company_id
GROUP BY c.ticker;

-- 4. 📊 Top Performing Sector
SELECT s.sector_name,
       AVG(tp.return_pct) AS avg_sector_return
FROM fact_trades_pnl_kpi tp
JOIN dim_company c ON tp.company_id = c.company_id
JOIN dim_sector s ON c.sector_id = s.sector_id
GROUP BY s.sector_name
ORDER BY avg_sector_return DESC
LIMIT 1;

-- 5. 📊 Portfolio Value
SELECT p.portfolio_name,
       SUM(ps.quantity * dp.close) AS portfolio_value
FROM fact_positions_snapshot ps
JOIN dim_portfolio p ON ps.portfolio_id = p.portfolio_id
JOIN fact_daily_prices dp ON ps.company_id = dp.company_id AND ps.date = dp.date
GROUP BY p.portfolio_name order by portfolio_value desc;

-- 6. 📊 Portfolio Return %
SELECT
               (SUM(current_value) - SUM(initial_value))
                 / SUM(initial_value) * 100 AS portfolio_return_pct
                  FROM stocks;

-- 7.  📊 Dividend Yield
SELECT c.ticker,
       (SUM(fd.dividend_per_share) / AVG(dp.close)) * 100 AS dividend_yield_pct
FROM fact_dividends fd
JOIN dim_company c ON fd.company_id = c.company_id
JOIN fact_daily_prices dp ON fd.company_id = dp.company_id AND fd.date = dp.date
GROUP BY c.ticker;

-- 8. 📊 Sharpe Ratio (assume risk-free rate = 0.02)
SELECT
              (AVG(return_pct) - 0.05) / STDDEV(return_pct) AS sharpe_ratio
                FROM fact_trades_pnl_kpi;

-- 9. 📊 Order Execution Rate
SELECT (COUNT(DISTINCT ft.trade_id) * 1.0 / COUNT(DISTINCT fo.order_id)) * 100 AS order_execution_rate_pct
FROM fact_orders fo
LEFT JOIN fact_trades ft ON fo.order_id = ft.order_id;

-- 10. 📊 Trade Win Rate
SELECT (SUM(CASE WHEN tp.win_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) AS trade_win_rate
FROM fact_trades_pnl_kpi tp;

-- 11. 📊 Trader Performance (P&L)
SELECT t.trader_name,
       SUM(tp.gross_sell_amount - tp.gross_buy_amount) AS trader_pnl
FROM fact_trades_pnl_kpi tp
JOIN dim_trader t ON tp.trader_id = t.trader_id
GROUP BY t.trader_name;