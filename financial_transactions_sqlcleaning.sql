
/*  PROBLEM STATEMENT: The Finance team exported 5 Years of company transactions
but the 'Amount' Column is a mess, there are white spaces in almost all the columns, 
, some columns have the wrong column type, duplicate issues
etc. making it impossible to do any meaningful analysis*/

select *
from financial_transactions_raw
;

-- STANDARDIZE 'AMOUNT' COLUMN

# 1) Creating a staging of the raw table to make all my changings

create table ft_staging
like financial_transactions_raw
;

# 2) Populating Staging table with raw table content 

insert ft_staging
select *
from financial_transactions_raw
;

select *
from ft_staging
;

select category, 
cast(transaction_date AS DATE)
FROM ft_staging
;

#3 Taking out all dollar signs and all commas
select category, 
replace(replace(amount,'$',''),',','')
from ft_staging
;

UPDATE ft_staging
SET amount = REPLACE(REPLACE(amount,'$',''),',','')
;

#4 Converting all non numeric values to NULL  in 'Amount' Column

SELECT amount -- first Checking for any invalid values in the amount column that are not numeric
FROM ft_staging
WHERE amount NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
;

UPDATE ft_staging -- converting non numerics to Null
SET amount = NULL
WHERE REPLACE(REPLACE(amount,'$',''),',','') NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
;

#5 Changing all entries in 'Amount' Column to 2 decimal places

ALTER TABLE ft_staging 
MODIFY amount DECIMAL(10,2)
;

-- Changed 'transaction_date' to a Date Column

UPDATE ft_staging
SET transaction_date = STR_TO_DATE(transaction_date, '%Y-%m-%d')
;

ALTER TABLE ft_staging
MODIFY transaction_date DATE
;

-- Removed all White spaces

update ft_staging
set transaction_id=trim(transaction_id),
transaction_date=trim(transaction_date),
vendor_name=trim(vendor_name),
category=trim(category),
amount=trim(amount)
;

-- CHECK FOR AND REMOVE DUPLICATES

select *,
row_number ()
over(partition by transaction_date,vendor_name,category,amount) as row_num
from ft_staging
;

with ft_dup as

(
select *,
row_number ()
over(partition by transaction_date,vendor_name,category,amount) as row_num
from ft_staging
)
select *
from ft_dup
where row_num > 1
;

select * -- Checking dups are actually dups
from ft_staging
where vendor_name ='Slack'
;

# Creating another staging table to deal with the duplicates found

CREATE TABLE `ft_staging1` (
  `transaction_id` int DEFAULT NULL,
  `transaction_date` date DEFAULT NULL,
  `vendor_name` text,
  `category` text,
  `amount` decimal(10,2) DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from ft_staging1
;

insert ft_staging1 -- Inserting content into new staging table
select *,
row_number ()
over(partition by transaction_date,vendor_name,category,amount) as row_num
from ft_staging
;

select * -- filtering to see all duplicates in new staging table
from ft_staging1
where row_num >1
;

delete -- Deleting all duplicates
from ft_staging1
where row_num>1
;

select *
from ft_staging1
where amount is null
;

-- AD-HOC CHECKS AND ADJUSTMENTS

# ADDING TRANSACTION YEAR(NEW COLUMN) TO ENABLE ANALYSIS

ALTER TABLE ft_staging1 -- Intoducing a new col called 'transaction_year'
ADD COLUMN transaction_year INT
;

UPDATE ft_staging1 -- populating transaction_year
SET transaction_year = YEAR(transaction_date)
;

SELECT category -- Checking for unusual Characters in text col 'category'
FROM ft_staging1
WHERE category REGEXP '[^A-Za-z ]'
;

SELECT vendor_name -- Checking for unusual characters in text col 'vendor_name'
FROM ft_staging1
WHERE vendor_name REGEXP '[^A-Za-z ]'
;

-- deleting row_num col

ALTER TABLE ft_staging1
DROP COLUMN row_num
;

# ANALYSIS 

/* What is the total spend per category per year
   Display previous year spend per category per year compared to current year,
   What is the difference in yearly spend */

with yearly as -- Created the first CTE selecting the relevant cols from my main table
(
select category, amount, transaction_year
from ft_staging1
),
grouped as( -- cretaed the second CTE outputing total spend per category per year
select category, transaction_year, sum(amount) as total_spend
from yearly
group by category, transaction_year
order by category, transaction_year desc
)
SELECT -- Output from both CTE's the previous year spend and the diffence in yearly spend per cat per year
    category,
    transaction_year,
    total_spend,
    LAG(total_spend, 1) OVER (
        PARTITION BY category
        ORDER BY transaction_year) AS prev_year_spend,
        total_spend-LAG(total_spend, 1) OVER (PARTITION BY category ORDER BY transaction_year) as diff_in_yearly_total_spend
FROM grouped
ORDER BY category, transaction_year
;

-- Output the highest grossing industry category in 2024
with spend as (
select category, transaction_year, sum(amount) as total_spend
from ft_staging1
group by category, transaction_year
order by category, transaction_year desc
)
select category, transaction_year, total_spend
from spend
where transaction_year=2024
order by total_spend desc
;


-- Need a view of 'Marketing' vis-a-vis 'Travel' yearly performance 
with spend_cte as (
select category, transaction_year, sum(amount) as total_spend
from ft_staging1
group by category, transaction_year
order by category, transaction_year desc
)
SELECT
    category,
    transaction_year,
    total_spend
FROM spend_cte
WHERE category IN ('Marketing', 'Travel')
ORDER BY transaction_year, category
;


-- Display the year with the highest total spend

with yearly_spend as (
select category, amount, transaction_year
from ft_staging1
),
spend_yearly AS (
    SELECT
        transaction_year,
        SUM(amount) AS total_spend
    FROM yearly_spend
    GROUP BY transaction_year
)

SELECT 
    transaction_year,
    total_spend
FROM spend_yearly
ORDER BY total_spend DESC
;
