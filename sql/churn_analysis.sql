-- =====================================================
-- PROJECT: CUSTOMER CHURN ANALYSIS
-- AUTHOR: Abhijeet Kumar Sinha
-- TOOLS: MySQL
-- =====================================================

-- CREATE DATABASE churn_project;
USE churn_project;

-- =====================================================
-- SECTION 1: DATA UNDERSTANDING
-- =====================================================

 # No of Rows & Columns
SELECT COUNT(*) AS total_rows FROM telco_customers;
SELECT COUNT(*) AS total_columns 
FROM information_schema.columns
WHERE table_name = 'telco_customers'
	AND table_schema = 'churn_project';


-- Total Records
SELECT COUNT(*) FROM telco_customers;


-- Distinct Contract Types
SELECT DISTINCT Contract
FROM telco_customers;


-- =====================================================
-- SECTION 2: CHURN ANALYSIS
-- =====================================================

-- Overall Churn Rate
SELECT 
	COUNT(*) AS total_customers,
	SUM(CASE WHEN Churn='Yes' THEN 1
	ELSE 0 END) AS churned_customers
FROM telco_customers;


-- Churn By Gender
SELECT 
	gender,
	ROUND(AVG(CASE WHEN Churn='Yes' THEN 1
	ELSE 0 END)*100, 2) AS churn_rate
FROM telco_customers
GROUP BY gender;


-- Churn By Senior Citizen
SELECT
	CASE WHEN SeniorCitizen = 1 THEN 'Senior'
    ELSE 'Non-Senior' END AS citizen_status,
    COUNT(*) AS total_customers,
    ROUND(AVG(CASE WHEN Churn = 'Yes'
    THEN 1 ELSE 0 END)*100, 2) AS churn_rate
FROM telco_customers
GROUP BY SeniorCitizen;


-- Churn By Contract Type
SELECT 
	Contract,
	COUNT(*) AS total_customers,
	ROUND(AVG(CASE WHEN Churn = 'Yes'
	THEN 1 ELSE 0 END)*100, 2) AS churn_rate
FROM telco_customers
GROUP BY Contract
ORDER BY churn_rate DESC;


-- Churn By Internet Service & Monthly Charges
SELECT 
	InternetService,
	ROUND(AVG(CASE WHEN Churn='Yes'
	THEN 1 ELSE 0 END)*100,2) AS churn_rate
FROM telco_customers
GROUP BY InternetService;


-- =====================================================
-- SECTION 3 — REVENUE ANALYSIS
-- =====================================================

-- Total Revenue
SELECT
	ROUND(SUM(MonthlyCharges),2) AS total_revenue
FROM telco_customers;


-- Revenue Lost Due to Churn
SELECT
	ROUND(SUM(MonthlyCharges),2) AS revenue_lost
FROM telco_customers
WHERE Churn='Yes';


-- Average Monthly Charges
SELECT
	CASE WHEN SeniorCitizen = 1 THEN 'Senior' ELSE 'Non-Senior'
    END AS citizen_status,
    COUNT(*) AS total_customers,
    ROUND(AVG(MonthlyCharges),2) AS avg_monthly_bill,
    ROUND(AVG(CASE WHEN Churn = 'Yes'
    THEN 1 ELSE 0 END)*100, 2) AS churn_rate
FROM telco_customers
GROUP BY SeniorCitizen
ORDER BY churn_rate DESC;


-- =====================================================
-- SECTION 4 — CUSTOMER BEHAVIOR
-- =====================================================

-- Loyalty Duration -- Compared how long loyal customers stay vs. how lg churned customers lasted
SELECT
	CASE WHEN Churn = 'No' THEN 'Stayed (Loyal)'
    WHEN Churn = 'Yes' THEN 'Left (Churned)'
    END AS customer_status,
    ROUND(AVG(tenure),2) AS avg_tenure_months,
    ROUND(AVG(MonthlyCharges),2) AS avg_monthly_bill,
    COUNT(*) AS total_customers
FROM telco_customers
GROUP BY Churn;


-- High Risk Customers -- Identifying customers with sort tenure, high bills, and no long-term contract
SELECT 
	customerID,
	tenure AS months_stayed,
    MonthlyCharges,
    Contract
FROM telco_customers
WHERE tenure < 12 AND MonthlyCharges > 70 AND Contract = 'Month-to-month';


-- Payment Method Analysis -- Checking if the way customers pay affects their loyalty
SELECT
	PaymentMethod,
    ROUND(AVG(CASE WHEN churn = 'Yes'
    THEN 1 ELSE 0 END)*100,2) AS churn_rate
FROM telco_customers
GROUP BY PaymentMethod
ORDER BY churn_rate DESC;    


-- Top Risk Segment -- Pinpointing which combination of service and contract has the highest churn
SELECT 
	Contract, InternetService,
	COUNT(*) AS total_customers,
	ROUND(AVG(CASE WHEN Churn='Yes' THEN 1
	ELSE 0 END)*100,2) AS churn_rate
FROM telco_customers
GROUP BY Contract, InternetService
ORDER BY churn_rate DESC;


-- Customer Segmentation -- Categorizing customers by tenure to identify loyalty level
SELECT 
	CASE WHEN tenure < 12 THEN 'New Customer (<1yr)'
	WHEN tenure BETWEEN 12 AND 48 THEN 'Regular Customer (1-4yrs)'
	ELSE 'Loyal Customer (4yrs+)' END AS customer_segment,
	COUNT(*) AS total_customers,
	ROUND(AVG(CASE WHEN Churn = 'Yes'
	THEN 1 ELSE 0 END)*100,2) AS churn_rate
FROM telco_customers
GROUP BY customer_segment
ORDER BY churn_rate DESC;


-- Revenue By Segment -- Anaalyzing the financial value of each customer loyalty group
SELECT
	CASE WHEN tenure < 12 THEN 'New Customer'
    WHEN tenure BETWEEN 12 AND 48 THEN 'Regular Customer'
    ELSE 'Loyal Customer'
    END AS customer_segment,
    ROUND(SUM(MonthlyCharges),2) AS total_revenue,
    COUNT(*) AS customer_count
FROM telco_customers
GROUP BY customer_segment
ORDER BY total_revenue DESC;


-- High Value Customer Ranking -- Using a wiindow Function to rank every customer by their monthly bill
SELECT
	customerID,
    MonthlyCharges,
    RANK() Over(
    ORDER BY MonthlyCharges DESC
    ) AS spending_rank
FROM telco_customers;


-- Advance Contract Analysis -- Using a CTE to organize churn rate calculation by contract type
WITH churn_data AS (
SELECT
	Contract,
    ROUND(AVG(CASE WHEN Churn='Yes'
    THEN 1 ELSE 0 END)*100,2) AS churn_rate
FROM telco_customers
GROUP BY Contract
)
SELECT * FROM churn_data
ORDER BY churn_rate DESC;