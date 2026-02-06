/*
=============================================================================
							EXPLORATORY ANALYSIS
=============================================================================
*/

-- 1. What is the overall customer churn rate?
SELECT
	SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count, -- In the Exited column, 1 = Churned, 0 = Stayed
	COUNT(*) AS total_accounts,
	ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate
FROM customer_churn;
-- Answer: The Churn Rate is 20.37% (2037 out of 10000 customers are churned).


-- 2. Which country has the highest churn rate?
SELECT geography, 
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count,
    COUNT(*) AS total_accounts,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate
FROM customer_churn
GROUP BY geography
ORDER BY churn_rate DESC;
-- Answer: Germany with 32.44% churn rate (~2x as much as Spain's 16.67% & France's 16.15%).


-- 3. Which age group has the highest churn rate?
SELECT 
	COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
	CASE
		WHEN age > 60 THEN 'old'
        WHEN age > 45 THEN 'mid-life'
        WHEN age > 30 THEN 'adult'
        WHEN age > 15 THEN 'young-adult'
    END as age_group
FROM customer_churn
GROUP BY age_group ORDER BY churn_rate DESC;
-- Answer: Customers aged 46-60 (mid-life) with 51.12% churn rate, followed by ages 61 and older (old), 
-- then ages 31-45 (adults), and then ages 16-30 (young adults) with the least churn.


-- 4. Which gender churns the most?
SELECT
	Gender,
	COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_churn
GROUP BY Gender
ORDER BY churn_rate DESC;
-- Answer: Churn is higher among female customers (25.07%) than male customers (16.46%).


-- 5. Do inactive members churn more than active members?
-- Hypothesis: Yes, inactive members are more likely to churn.
SELECT
	IsActiveMember,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_churn
GROUP BY IsActiveMember
ORDER BY churn_rate DESC;
-- Answer: Same with the hypothesis, churn is higher among inactive members (26.85%) than active members (14.27%).


-- 6. Does account balance influence churn behavior?
-- Hypothesis: Low Value customers churn more than High Value customers.
SELECT
	CASE
		WHEN Balance > 100000 THEN 'High Value'
        ELSE 'Low Value'
	END AS financial_tier,
	COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_churn
GROUP BY Financial_tier;
-- Answer: Contrary to the hypothesis, High Value customers (Balance > 100000) churn more.


-- 7. Does number of products influence churn behavior?
-- Hypothesis: More Products = Stickier Customers (Less Churn)
SELECT 
    NumOfProducts,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_churn
GROUP BY NumOfProducts
ORDER BY NumOfProducts;
-- Answer: Contrary to the hypothesis, customers with more (3-4) products show nearly 100% churn, indicating a very strong driver of churn.
-- Observation: Having 4 products (100% churn rate) indicates automatic closure.


-- 8. Does credit score influence churn behavior?
SELECT 
    CASE 
        WHEN CreditScore > 650 THEN 'High Credit (>650)'
        ELSE 'Low Credit (<=650)'
    END AS credit_tier,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count,
    COUNT(*) AS total_customers,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_churn
GROUP BY credit_tier
ORDER BY churn_rate DESC;
-- Answer: The difference in churn (~2%) is minor, indicating credit score may not be a strong driver of churn

-- 9. Does customer tenure influence churn behavior?
SELECT
	Tenure,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churn_count,
    COUNT(*) AS total_accounts,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as churn_rate
FROM customer_churn
GROUP BY Tenure
ORDER BY Tenure;
-- Answer: Customer tenure shows no consistent trend with churn, suggesting it is a minor indicator.

-- 10. Does customer salary influence churn behavior?
-- Hypothesis: High income customers behave differently than low income customers
SELECT 
    CASE 
        WHEN EstimatedSalary < 50000 THEN 'Low Income (<50k)'
        WHEN EstimatedSalary BETWEEN 50000 AND 100000 THEN 'Mid Income (50k-100k)'
        WHEN EstimatedSalary BETWEEN 100000 AND 150000 THEN 'High Income (100k-150k)'
        ELSE 'Very High Income (>150k)'
    END AS salary_bracket,
    COUNT(*) AS total_customers,
    ROUND(AVG(Exited) * 100, 1) AS churn_rate
FROM customer_churn
GROUP BY salary_bracket
ORDER BY churn_rate DESC;
-- Answer: Contrary to the hypothesis, all salary brackets show ~20% churn, indicating that salary may not be a strong driver of churn.


/* 
=============================================================================
						KEY FINDINGS & SCORING LOGIC
=============================================================================

1. THE "3-PRODUCT" TRAP (Strongest Predictor)
   - Finding: Customers with 3 or 4 products have an 80-100% churn rate.
   - Decision: Assigned highest weight (+60 pts) to immediately flag these as 'Critical'.

2. GEOGRAPHY & GENDER (Intersectional Risk)
   - Finding: Germany has the highest regional churn (32%), and females churn more than males (25% vs 16%).
   - Insight: The "German Female" cohort represents the highest-risk demographic.
   - Decision: Additive scoring applied (+20 for Germany, +10 for Female) to capture cumulative risk.

3. THE "MID-LIFE" CRISIS
   - Finding: Age 45-60 shows a distinct churn spike (~51%).
   - Decision: Targeted age weighting (+10 pts) for this group, rather than a linear age penalty.

4. INACTIVITY (Silent Leavers)
   - Finding: Inactive members are 2x more likely to churn (27% vs 14%).
   - Decision: Significant penalty (+20 pts) applied to inactive users to prioritize engagement campaigns.

5. BALANCE VS. SALARY (Feature Selection)
   - Finding: High Balance (>100k) correlates with higher churn, while Estimated Salary shows no observable correlation.
   - Decision: Balance included as a minor risk factor (+5 pts); Salary excluded to reduce noise.

=============================================================================
*/


