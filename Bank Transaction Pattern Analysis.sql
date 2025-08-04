--Bank Transaction Pattern Analysis (SQL Portfolio Project)
--Project Goal
--Analyze bank transaction data to uncover customer spending patterns, categorize expenses, and flag unusual activity for fraud detection.

--1. Monthly Spending by Category
SELECT 
  c.category,
  DATE_TRUNC('month', t.transaction_date) AS month,
  ROUND(SUM(ABS(t.amount)), 2) AS total_spent
FROM transactions t
JOIN merchants c ON t.merchant_id = c.merchant_id
WHERE t.amount < 0
GROUP BY c.category, month
ORDER BY month, total_spent DESC;

--2. Top 5 Merchants by Transaction Volume
SELECT 
  m.name,
  COUNT(*) AS transaction_count,
  ROUND(SUM(ABS(t.amount)), 2) AS total_amount
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.name
ORDER BY transaction_count DESC
LIMIT 5;

--3. Average Monthly Spending per Customer

SELECT 
  t.customer_id,
  ROUND(AVG(monthly_spent), 2) AS avg_monthly_spent
FROM (
  SELECT 
    customer_id,
    DATE_TRUNC('month', transaction_date) AS month,
    SUM(ABS(amount)) AS monthly_spent
  FROM transactions
  WHERE amount < 0
  GROUP BY customer_id, month
) t
GROUP BY t.customer_id
ORDER BY avg_monthly_spent DESC;

--4. Flag Potential Fraud: Large Transactions (> $10,000)

SELECT 
  customer_id,
  transaction_id,
  transaction_date,
  amount
FROM transactions
WHERE ABS(amount) > 10000
ORDER BY transaction_date DESC;

--5. Spending Pattern Changes Before and After a Date (e.g., 2023-01-01)

WITH before AS (
  SELECT customer_id, AVG(ABS(amount)) AS avg_spent_before
  FROM transactions
  WHERE amount < 0 AND transaction_date < '2023-01-01'
  GROUP BY customer_id
),
after AS (
  SELECT customer_id, AVG(ABS(amount)) AS avg_spent_after
  FROM transactions
  WHERE amount < 0 AND transaction_date >= '2023-01-01'
  GROUP BY customer_id
)
SELECT 
  b.customer_id,
  b.avg_spent_before,
  a.avg_spent_after,
  ROUND(a.avg_spent_after - b.avg_spent_before, 2) AS change_in_spending
FROM before b
JOIN after a ON b.customer_id = a.customer_id
ORDER BY change_in_spending DESC;
