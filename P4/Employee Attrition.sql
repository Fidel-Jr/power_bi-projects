SELECT *
FROM attritions_staging;

SELECT years_at_company, COUNT(years_at_company)
FROM attritions_staging
GROUP BY years_at_company
ORDER BY 2 DESC;

SELECT COUNT(DISTINCT(age_range))
FROM attritions_staging;

-- NEDEED TO UPDATE
SELECT DISTINCT(monthly_income_bracket)
FROM attritions_staging;

-- CREATING TABLE AND COPYING DATA TO WORK WITH
CREATE TABLE attritions_staging
LIKE attritions;

INSERT attritions_staging
SELECT *
FROM attritions;

-- ALTERING COLUMN NAMES
ALTER TABLE attritions_staging
RENAME COLUMN `Attrition` to attrition;

-- CHECKING FOR DUPLICATES
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY employee_id, age, gender, years_at_company, job_role, monthly_income, 
work_life_balance, job_satisfaction, performance_rating, number_of_promotions, overtime, distance_from_home,
education_level, marital_status, number_of_dependents, job_level, company_size, company_tenure, remote_work, leadership_opportunities, innovation_opportunities,
company_reputation, employee_recognition, attrition) AS row_num
FROM attritions_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT *
FROM attritions_staging 
WHERE education_level = 'Master’s Degree';

-- STANDARDIZING DATA
UPDATE attritions_staging
SET education_level = 'Bachelor’s Degree'
WHERE education_level = 'Bachelorâ€™s Degree';


SELECT attrition, COUNT(attrition), AVG(monthly_income)
FROM attritions_staging	
GROUP BY attrition;

SELECT AVG(age), gender, AVG(years_at_company), attrition
FROM attritions_staging
GROUP BY attrition, gender;	

SELECT job_satisfaction, COUNT(employee_id)
FROM attritions_staging
GROUP BY job_satisfaction;

SELECT job_satisfaction, COUNT(employee_id), attrition
FROM attritions_staging
GROUP BY job_satisfaction, attrition
ORDER BY 1, 2 DESC;


SELECT work_life_balance, COUNT(employee_id), attrition
FROM attritions_staging
GROUP BY work_life_balance, attrition
ORDER BY 1, 2 DESC;

SELECT job_role, COUNT(attrition)
FROM attritions_staging
GROUP BY job_role;

SELECT job_role, COUNT(employee_id), attrition
FROM attritions_staging
GROUP BY job_role, attrition
ORDER BY 1, 2 DESC;

SELECT (COUNT(attrition) /  14900) * 100 AS Attrition_Rating
FROM attritions_staging
WHERE attrition = 'Left';


ALTER TABLE attritions_staging
ADD COLUMN monthly_income_bracket VARCHAR(100)
AFTER monthly_income;

SELECT MAX(monthly_income)
FROM attritions_staging;

SELECT MIN(monthly_income)
FROM attritions_staging;


UPDATE attritions_staging
SET age_range = CASE
	WHEN age >= 13 AND age <= 18 THEN 'Adolescence'
	WHEN age >= 19 AND age <= 25 THEN 'Young Adult'
    WHEN age >= 26 AND age <= 60 THEN 'Adult'
    WHEN age >= 61 THEN 'Senior'
	ELSE 'Childhood'
END;

UPDATE attritions_staging
SET monthly_income_bracket = CASE
	WHEN monthly_income >= 1000 AND monthly_income <= 3000 THEN '$1,000 - $3,000'
	WHEN monthly_income >= 3001 AND monthly_income <= 5000 THEN '$3,001 - $5,000'
    WHEN monthly_income >= 5001 AND monthly_income <= 8000 THEN '$5,001 - $8,000'
    WHEN monthly_income >= 8001 AND monthly_income <= 12000 THEN '$8,001 - $12,000'
    WHEN monthly_income >= 12001 AND monthly_income <= 15000 THEN '$12,001 - $15,000'
	ELSE '$15,000+'
END;

SELECT job_role, 
((SELECT COUNT(employee_id) AS total_employee_left FROM attritions_staging WHERE attrition = 'Left') /
(SELECT COUNT(employee_id) AS total_employee FROM attritions_staging)) AS Rate
FROM attritions_staging
GROUP BY job_role;

SELECT a.job_role, (Total_Left.Total_Employee_Left / COUNT(a.employee_id)) * 100 AS Attrition_Rate
FROM attritions_staging a

JOIN (
	SELECT job_role, COUNT(employee_id) AS Total_Employee_Left
	FROM attritions_staging
	WHERE attrition = 'Left'
	GROUP BY job_role
) Total_Left
ON a.job_role = Total_Left.job_role
GROUP BY a.job_role
ORDER BY 2 DESC;


SELECT (COUNT(employee_id) / 14900) * 100 AS Attrition_rate
FROM attritions_staging
WHERE attrition = 'Left';
