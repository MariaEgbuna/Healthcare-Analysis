-- ====================
-- PATIENTS TABLE
-- ====================
SELECT * FROM patients AS p;

-- Number of Patients
SELECT COUNT(p.patient_id) AS "Number of Patients"
FROM patients AS p;
-- 55,500 Patients

-- Gender Distribution
SELECT 
    p.gender AS "Distinct Genders", 
    COUNT(p.gender) AS "Total Count", 
    ROUND( (COUNT(p.gender) * 100.0 / SUM(COUNT(p.gender)) OVER ()), 2) AS "Gender Dist %"
FROM patients AS p 
GROUP BY 1;
-- Female (50%), Male (40%), and Non-binary(10%)

-- Dispersion (How spread out the data is)
SELECT 
    MIN(p.age) AS "Youngest Patient", 
    MAX(p.age) AS "Oldest Patient",
    ROUND(STDDEV(p.age), 2) AS "Std Deviation",
    ROUND(VAR_POP(p.age), 2) AS "Age Variance"
FROM patients AS p;
-- Patient ages range from 13 to 89, with a Standard Deviation of $19.60$ years, indicating a moderate spread around the mean.

-- Age Distribution
SELECT 
    p.age_group AS "Age Groups", 
    COUNT(p.patient_id) AS "Number of Patients",
    ROUND( (COUNT(p.patient_id) * 100.0 / SUM(COUNT(p.patient_id)) OVER ()), 2) AS "Age Group Dist %"
FROM patients AS p
GROUP BY 1
ORDER BY 1 ASC;
-- The patient distribution shows a clear concentration in the Above 60 (Senior) group at 36.70%, with the 13-17 (Teens) group being the least represented at 0.21%.

-- Frequencies of Age Count
SELECT age_freq."Age Count Values", COUNT(*) AS "Frequency of that Count"
FROM
(
	SELECT 
		p.age AS "Ages",
		COUNT(p.*) AS "Age Count Values"
	FROM patients AS p
	GROUP BY 1
) AS age_freq
GROUP BY 1
ORDER BY 1;
-- The analysis reveals a high variability in the counts of patients across different ages, with the count of 836 patients being the most common frequency shared by four distinct ages.

-- ====================
-- DOCTORS TABLE
-- ====================
SELECT * FROM doctors AS d;

-- Number of Doctors
SELECT COUNT(d.doctor_id) AS "Number of Doctors"
FROM doctors AS d;
-- 40,341 Doctors


-- ====================
-- INSURANCE PROVIDERS
-- ====================
SELECT * FROM insurance_providers AS ip;

-- Number of Insurance Providers
SELECT COUNT(ip.insurance_id) AS "Insurance Providers Count"
FROM insurance_providers AS ip;
-- 4 Insurance Providers


-- ====================
-- ADMISSIONS TABLE
-- ====================
SELECT * FROM admissions AS a;

-- Number of admission
SELECT COUNT(a.admission_id) AS "Number of Admissions"
FROM admissions AS a;
-- 55,500 Admissions

-- Total Billing Amount (Revenue)
SELECT ROUND( SUM(a.billing_amount), 2 ) AS "Total Revenue"
FROM admissions AS a;
-- Over a billion dollars ($1,417,432,043.63)

-- Date Range
SELECT 
	MIN(a.date_of_admission) AS "First Admission Date",
	MAX(a.discharge_date) AS "Last Admission Date"
FROM admissions AS a;
-- From 8th of May 2019 to 6th June 2024.

-- Number of patients admitted yearly
SELECT
	CAST(DATE_PART('Year', a.date_of_admission) AS INTEGER) AS "Years",
	COUNT(a.patient_id) AS "Number of Patients"
FROM admissions AS a
GROUP BY 1
ORDER BY 1;
-- The number of patients saw a substantial increase from 2019 (7,387) to 2020 (11,285), generally stabilizing around 11,000 annually until the partial year 2024 (3,854).

-- Admissions Monthly Trends
SELECT 
	CAST(DATE_PART('Year', a.date_of_admission) AS INTEGER) AS "Years",
	CAST(DATE_PART('Month', a.date_of_admission) AS INTEGER) AS "Month Number",
	TO_CHAR(a.date_of_admission, 'Month') AS "Month Name",
	COUNT(a.patient_id) AS "Number of Patients"
FROM admissions AS a
GROUP BY 1,2,3
ORDER BY 1,2;
-- The monthly patient counts show a rapid increase from the minimum of 686 in May 2019 to a maximum of 1,014 in August 2020, then stabilize to a consistent range between 777 and 1,014 for the remainder of the period.

-- Hospitals, Number of Doctors, and Patients
SELECT 
	h.hospital_name AS "Hospitals",
	COUNT(a.doctor_id) AS "Doctor Count",
	COUNT(a.patient_id) AS "Patient Count"
FROM admissions AS a
INNER JOIN hospitals AS h
ON a.hospital_id = h.hospital_id
GROUP BY 1;
-- Patient and doctor counts are equal for all hospitals listed, with Houston Methodist Hospital exhibiting the highest total (20,402) and NewYork-Presbyterian Hospital the lowest total (2,334).

-- Insurance and Users Distribution
SELECT 
	ip.insurance_name AS "Insurance Provider",
	COUNT(a.insurance_id) AS "Policyholders",
	ROUND( (COUNT(a.patient_id) * 100.0 / SUM(COUNT(a.patient_id)) OVER ()), 2) AS "% Rate"
FROM admissions AS a
INNER JOIN insurance_providers AS ip
ON a.insurance_id = ip.insurance_id
GROUP BY 1;
-- Medicare dominates the policyholder distribution with 27,750 policyholders, representing 50% of the total, while Aetna and Cigna share the lowest enrollment with 5,550 policyholders each.

-- Medical Conditions by Genders
SELECT 
	a.medical_condition AS "Medical Conditions",
	COUNT(CASE WHEN p.gender = 'Male' THEN p.gender END ) AS "Male Count",
	COUNT(CASE WHEN p.gender = 'Female' THEN p.gender END ) AS "Female Count",
	COUNT(CASE WHEN p.gender = 'Non-binary' THEN p.gender END ) AS "Non-Binary Count",
	COUNT(a.patient_id) AS "Total Count"
FROM patients AS p
INNER JOIN admissions AS a
ON a.patient_id = p.patient_id
GROUP BY 1;
-- Hypertension and Diabetes have the highest overall count (13,875), while Diabetes exhibits the greatest disparity (7,215 Female vs. 5,550 Male) among the top conditions, and Asthma is uniquely reported as zero for Non-Binary patients.
