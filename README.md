[WORK IN PROGRESS]

# Rule-Based Customer Retention Engine using SQL & PowerBI.

## Executive Summary
Using a public retail banking churn dataset as a real-world simulation, I developed a proactive Customer Retention Engine in SQL and Power BI to demonstrate how an organization can transition from reactive reporting to forward-looking, risk-based intervention. The solution transforms raw customer behavior into a transparent, weighted risk scorecard that surfaces key attrition drivers such as product concentration, inactivity among high-balance users, and demographic risk patterns. Customers are segmented into clear, actionable risk tiers that mirror how retention strategies would be prioritized in practice. As a result, the approach:

1. Replaced inefficient, random targeting with a prioritized, data-driven Hit List.
2. Achieved a 90% precision rate in the Critical segment, representing a 4.4x lift over the baseline.
3. Enabled the bank to focus limited retention resources on customers most likely to churn, helping protect revenue and improve customer lifetime value.

### Business Problem:
Banks generally spend significantly more to acquire a new customer than to retain an existing one. My stakeholder (e.g., the Bank Manager) needs a tool that doesn't just tell them who left, but who is likely to leave next month so they can intervene with a special offer.

Goal: Reduce customer attrition (churn) by identifying "at-risk" customers before they leave.

### Methodology:
1. Use MySQL queries in MySQL Workbench to extract, clean, and transform customer data, and calculate churn rates for different segments.
2. Build a churn risk scorecard in SQL by assigning weighted points to key factors like number of products, geography, activity status, age, gender, and balance.
3. Create a Power BI dashboard to visualize and track at-risk customers, helping prioritize retention strategies.

### Skills:
SQL: CTEs, Joins, CASE statements, Aggregate functions, Window functions, Data cleaning & transformation
Power BI: DAX formulas, Calculated columns & measures, ETL, Data modeling, Interactive dashboards, Data visualization
