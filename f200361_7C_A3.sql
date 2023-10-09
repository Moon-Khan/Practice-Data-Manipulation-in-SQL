
--Q1
SELECT a.id,
	a.name,
	a.website,
	a.lat,
	a.long,
	a.primary_poc,
	a.sales_rep_id,
	w.channel,
	w.occurred_at
FROM accounts a
INNER JOIN web_events w 
ON a.id = w.account_id
WHERE (w.channel = 'organic' OR w.channel = 'adwords')
	AND EXTRACT(YEAR FROM w.occurred_at) = '2016'
ORDER BY w.occurred_at DESC;

--Q2
SELECT r.name AS region_name,
	a.name AS account_name,	
	
    CASE
		WHEN o.total_amt_usd = 0 THEN 0
		ELSE o.total_amt_usd / (o.total + 0.01)
		END AS unit_price
FROM orders o
INNER JOIN accounts a 
ON o.account_id = a.id
INNER JOIN sales_reps s 
ON a.sales_rep_id = s.id
INNER JOIN region r 
ON s.region_id = r.id;

--Q3
SELECT r.name as region,
	s.name as sales_rep_name,
	a.name as account_name
FROM 
accounts a INNER JOIN sales_reps s 
ON a.sales_rep_id = s.id
INNER JOIN region r 
ON s.region_id = r.id
WHERE
	r.name='Midwest'
ORDER BY account_name ASC;

--Q4
SELECT r.name as region,	
	s.name as sales_rep_name,
	a.name as account_name
FROM 
accounts a INNER JOIN sales_reps s
ON a.sales_rep_id = s.id
INNER JOIN region r 
ON s.region_id = r.id
WHERE 
	(s.name LIKE 'S%' AND r.name='Midwest')
ORDER BY account_name ASC;

--Q5
SELECT r.name as region,
	s.name as sales_rep_name,
	a.name as account_name
FROM accounts a
INNER JOIN sales_reps s ON a.sales_rep_id = s.id
INNER JOIN region r ON s.region_id = r.id
WHERE (SUBSTRING(s.name, POSITION(' ' IN s.name) + 1) LIKE 'K%'
       AND
	   r.name = 'Midwest')
ORDER BY account_name ASC;


--Q6
SELECT r.name AS region_name,
	a.name AS account_name,
	CASE
	WHEN o.total_amt_usd = 0 THEN 0
	ELSE o.total_amt_usd / (o.total + 0.01)
	END AS unit_price
FROM orders o
INNER JOIN accounts a 
ON o.account_id = a.id
INNER JOIN sales_reps s 
ON a.sales_rep_id = s.id
INNER JOIN region r
ON s.region_id = r.id
WHERE o.standard_qty>100


--Q7
SELECT r.name AS region_name, 
	a.name AS account_name,
	CASE
	WHEN o.total_amt_usd = 0 THEN 0
    ELSE o.total_amt_usd / (o.total + 0.01)
	END AS unit_price
FROM orders o
INNER JOIN accounts a 
ON o.account_id = a.id
INNER JOIN sales_reps s 
ON a.sales_rep_id = s.id
INNER JOIN region r 
ON s.region_id = r.id
WHERE (o.standard_qty>100 AND poster_qty>50)
ORDER BY unit_price ASC;


--Q8
SELECT 
	a.name as account_name,
	w.channel
FROM web_events w 
INNER JOIN accounts a 
ON w.account_id = a.id
WHERE a.id=1001
ORDER BY w.channel;

--Q9
SELECT 
	o.occurred_at,
	a.name as account_name,
	o.total as order_total,
	o.total_amt_usd
FROM orders o 
INNER JOIN accounts a
ON o.account_id= a.id
WHERE EXTRACT(YEAR FROM o.occurred_at)='2015';	

--Q10
SELECT a.name AS account_name,
	w.channel,
	COUNT(*) AS num_of_events
FROM accounts a
INNER JOIN web_events w 
ON a.id = w.account_id
GROUP BY a.name, w.channel
ORDER BY a.name, w.channel;

--Q11
SELECT
	s.name AS sales_rep_name,
	w.channel,
	COUNT(*) AS no_of_times
FROM web_events w
INNER JOIN accounts a 
ON w.account_id = a.id
INNER JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name, w.channel
ORDER BY no_of_times DESC; 

--Q12 (a)
SELECT
    s.name AS sales_rep_name,
    COUNT(*) AS counts_to_manage
FROM accounts a
INNER JOIN sales_reps s ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING COUNT(*) > 5;

--Q12 (b)
SELECT 
	account_id,
	COUNT(*) AS count_orders
FROM orders
GROUP BY account_id
HAVING COUNT(*)=(
	SELECT MAX(order_count)
	FROM (
		SELECT COUNT(id) as order_count
		FROM orders
		GROUP BY account_id
	) table_	
);

--Q12 (c)
SELECT 
	account_id,
	SUM(total_amt_usd) as total_usd
FROM orders
GROUP BY account_id
HAVING SUM(total_amt_usd)>30000;


--Q12 (d)
SELECT 
	account_id,
    SUM(total_amt_usd) AS total_spent
FROM orders
GROUP BY account_id
HAVING SUM(total_amt_usd) = (
    SELECT MAX(total_spent)
    FROM (
        SELECT SUM(total_amt_usd) AS total_spent
        FROM orders
        GROUP BY account_id
    ) table_
);

--Q12 (e)
SELECT 
	account_id,
    SUM(total_amt_usd) AS total_spent
FROM orders
GROUP BY account_id
HAVING SUM(total_amt_usd) = (
    SELECT MIN(total_spent)
    FROM (
        SELECT SUM(total_amt_usd) AS total_spent
        FROM orders
        GROUP BY account_id
    ) table_
);

--Q12 (f)

SELECT 
	account_id,
	COUNT(*) as no_of_times
FROM web_events
WHERE channel='facebook'
GROUP BY account_id
HAVING COUNT(*)>6

--Q12 (g)

SELECT
    account_id,
    COUNT(*) as no_of_times
FROM web_events
WHERE channel = 'facebook'
GROUP BY account_id
HAVING COUNT(*) = (
    SELECT MAX(count_)
    FROM (
        SELECT COUNT(*) as count_
        FROM web_events
        WHERE channel = 'facebook'
        GROUP BY account_id
    ) table_
);


--Q13

SELECT 	
	id,
	account_id,
	SUM(total_amt_usd) as total_order,
	CASE
		WHEN SUM(total_amt_usd) >= 300 THEN 'large'
		ELSE 'small'
		END AS level_of_order
FROM orders
GROUP BY id, account_id;

--Q14

SELECT
    CASE
        WHEN total_items >= 2000 THEN 'At Least 2000'
        WHEN total_items BETWEEN 1000 AND 1999 THEN 'Between 1000 and 2000'
        ELSE 'Less than 1000'
    END AS category,
    COUNT(*) AS order_count
FROM (
    SELECT
        o.id AS order_id,
        SUM(o.standard_qty + o.gloss_qty + o.poster_qty) AS total_items
    FROM orders o
    GROUP BY o.id
) table_
GROUP BY category
ORDER BY category;

--Q15
SELECT
    CASE
        WHEN total_items >= 2000 THEN 'At Least 2000'
        WHEN total_items BETWEEN 1000 AND 1999 THEN 'Between 1000 and 2000'
        ELSE 'Less than 1000'
    END AS category,
    COUNT(*) AS order_count
FROM (
    SELECT
        o.id AS order_id,
        SUM(o.standard_qty + o.gloss_qty + o.poster_qty) AS total_items
    FROM orders o
    GROUP BY o.id
) subquery
GROUP BY category
ORDER BY category;

--Q16
WITH CustomerSpending AS (
    SELECT
        a.id AS account_id,
        a.name AS account_name,
        SUM(CASE WHEN EXTRACT(YEAR FROM o.occurred_at) IN (2016, 2017) THEN o.total_amt_usd ELSE 0 END) AS total_spent
    FROM accounts a
    LEFT JOIN orders o ON a.id = o.account_id
    GROUP BY a.id, a.name
)

SELECT
    cs.account_name,
    SUM(cs.total_spent) AS total_spent,
    CASE
        WHEN SUM(cs.total_spent) > 20000 THEN 'top'
        ELSE 'not top'
    END AS top_status
FROM CustomerSpending cs
GROUP BY cs.account_name
HAVING SUM(cs.total_spent) > 20000
ORDER BY top_status DESC, total_spent DESC;

--Q17
WITH SalesRepOrders AS (
    SELECT
        s.name AS sales_rep_name,
        COUNT(o.id) AS total_orders
    FROM sales_reps s
    LEFT JOIN accounts a ON s.id = a.sales_rep_id
    LEFT JOIN orders o ON a.id = o.account_id
    GROUP BY s.name
)

SELECT
    sro.sales_rep_name,
    sro.total_orders,
    CASE
        WHEN sro.total_orders > 200 THEN 'top'
        ELSE 'not top'
    END AS top_status
FROM SalesRepOrders sro
ORDER BY top_status DESC, sro.total_orders DESC;


--Q18
SELECT 
	EXTRACT(DAY FROM occurred_at) as event_day,
	channel,
	COUNT(*) as no_of_events
FROM web_events
GROUP BY EXTRACT(DAY FROM occurred_at), channel
ORDER BY event_day;

--Q19
SELECT 
    r.name as region_name,
    MAX(o.total_amt_usd) as largest_total_amt_usd,
    COUNT(o.id) as total_orders_placed_in_largest_region
FROM orders o
INNER JOIN accounts a 
ON o.account_id = a.id
INNER JOIN sales_reps s 
ON a.sales_rep_id = s.id
INNER JOIN region r 
ON s.region_id = r.id
GROUP BY r.name
ORDER BY r.name;

--Q20
with total_orders_placed_in_largest_region as
(
	SELECT r.name as region_name,
    MAX(o.total_amt_usd) as largest_total_amt_usd,
    COUNT(o.id) as total_orders_placed_in_largest_region
	FROM orders o
	INNER JOIN accounts a
	ON o.account_id = a.id
	INNER JOIN sales_reps s 
	ON a.sales_rep_id = s.id
	INNER JOIN region r
	ON s.region_id = r.id
	GROUP BY r.name
	ORDER BY r.name
)
SELECT * FROM total_orders_placed_in_largest_region;


