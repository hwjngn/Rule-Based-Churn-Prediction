/* 
=============================================================================
						CHURN RISK SCORECARD
Purpose: Assigns a risk score to each customer based on key churn drivers 
         identified in 01_analysis_logic.
Score Components & Maximum Points:
   - Number of Products: 60
   - Geography: 20
   - Activity Status: 20
   - Age Group: 10
   - Gender: 10
   - Balance: 5
Maximum Total Score: 125
Risk Categories: Critical, High Risk, Watchlist, Safe
=============================================================================
*/

WITH calculate_risk AS (
	SELECT 
		-- Kept all columns for visualization purposes in PowerBI
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

		-- (1) NUMBER OF PRODUCTS | Max Weight: 60
		-- High number of products (3 or 4) correlates with very high churn (80-100%), so highest score assigned
		CASE 
            WHEN NumOfProducts >= 3 THEN 60 
            WHEN NumOfProducts = 1 THEN 5
            ELSE 0 
        END AS score_products,
        
        -- (2) GEOGRAPHY | Max Weight: 20
        CASE 
            WHEN Geography = 'Germany' THEN 20 
            ELSE 0 
        END AS score_geo,
        
        -- (3) ACTIVITY STATUS | Max Weight: 20
        CASE 
            WHEN IsActiveMember = 0 THEN 20 
            ELSE 0 
        END AS score_activity,
        
        -- (4) AGE GROUP | Max Weight: 10
        CASE
			WHEN age > 60 THEN 5 
            WHEN age > 45 THEN 10 -- High Churn Group
            ELSE 0 
		END AS score_age,
        
        -- (5) GENDER | Max Weight: 10
        CASE 
            WHEN Gender = 'Female' THEN 10 
            ELSE 0 
        END AS score_gender,
        
        -- (6) FINANCE | Max Weight: 5
        CASE
			WHEN Balance > 100000 THEN 5
            ELSE 0
		END AS score_balance
	FROM customer_churn
)

	
SELECT 
	*,
	(score_products + score_age + score_geo + score_activity + score_balance) AS risk_score, -- Total risk score = sum of individual factor scores
	CASE
		-- Risk categories based on total score:
		--   >= 65 → Critical (Action Needed)
		--   45-64 → High Risk
		--   25-44 → Watchlist
		--   < 25 → Safe
		WHEN (score_products + score_age + score_geo + score_activity + score_balance) >= 65 THEN 'Critical (Action Needed)'
		WHEN (score_products + score_age + score_geo + score_activity + score_balance) >= 45 THEN 'High Risk'
		WHEN (score_products + score_age + score_geo + score_activity + score_balance) >= 25 THEN 'Watchlist'
		ELSE 'Safe'
	END AS risk_category
FROM calculate_risk;




