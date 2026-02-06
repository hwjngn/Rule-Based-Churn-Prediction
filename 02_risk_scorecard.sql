WITH calculate_risk AS (
	SELECT 
		CustomerId, 
		Surname,
		CreditScore, 
		Geography, 
		Gender, 
		Age, 
		Tenure, 
		Balance, 
		NumOfProducts, 
		HasCrCard, 
		IsActiveMember, 
		EstimatedSalary, 
		Exited,
		-- (1) NUMBER OF PRODUCTS | Max Weight: 50
		CASE
			WHEN NumOfProducts >= 3 THEN 50
            WHEN NumOfProducts = 1 THEN 10
            ELSE 0 -- 2 products considered 'SAFE/NORMAL'
		END AS score_products,
        
		-- (2) AGE GROUP | Max Weight: 20
        CASE
			WHEN age > 60 THEN 10
            WHEN age > 45 THEN 20 -- High Churn Group
            WHEN age > 30 THEN 10
            ELSE 0 -- young adults considered 'SAFE/NORMAL'
		END AS score_age,
        
        -- (3) GEOGRAPHY | Max Weight: 15
        CASE
			WHEN geography = 'Germany' THEN 15
            ELSE 0 -- other countries considered 'SAFE/NORMAL'
		END AS score_geo,
        
        -- (4) ACTIVITY STATUS | Max Weight: 10
        CASE
			WHEN IsActiveMember = 0 THEN 10
            ELSE 0
        END AS score_activity,
        
        -- (5) FINANCE | Max Weight: 5
        CASE
			WHEN Balance > 100000 THEN 5 -- 
            ELSE 0
		END AS score_balance
	FROM customer_churn
)


SELECT 
	*,
	(score_products + score_age + score_geo + score_activity + score_balance) AS risk_score,
	CASE
		WHEN (score_products + score_age + score_geo + score_activity + score_balance) >= 50 THEN 'Critical (Action Needed)'
		WHEN (score_products + score_age + score_geo + score_activity + score_balance) >= 30 THEN 'High Risk'
		WHEN (score_products + score_age + score_geo + score_activity + score_balance) >= 15 THEN 'Watchlist'
		ELSE 'Safe'
	END AS risk_category
FROM calculate_risk;


