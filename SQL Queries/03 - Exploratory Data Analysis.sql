-- 1. What are the most common age groups, genders, and blood types among patients? Are certain groups being admitted more often than others?
SELECT 
	p.age_group,
	p.gender,
    p.blood_type,
    COUNT(a.admission_id) AS total_admissions
FROM patients p
INNER JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY 1,2,3
ORDER BY 4 DESC;
-- Senior Female patients with A+ blood type account for the highest single admission count (4,126), yet the Above 60 (Senior) age group and Female gender lead their respective categories overall.

-- 2. Most diagnosed medical conditions and their distribution across demographic groups
SELECT
    a.medical_condition,
    p.gender,
    p.age_group,
    COUNT(a.admission_id) AS total_cases
FROM admissions a
INNER JOIN patients p ON a.patient_id = p.patient_id
GROUP BY 1,2,3
ORDER BY 4 DESC;
-- The patient cases are highly concentrated in the Above 60 (Senior) age group. The largest specific group being Female with Diabetes (2,654 cases).

-- 3. Average hospital stay duration by condition, hospital, and admission type
SELECT
    a.medical_condition,
    h.hospital_name,
    a.admission_type,
    ROUND(AVG(a.discharge_date - a.date_of_admission), 2) AS avg_length_of_stay
FROM admissions a
INNER JOIN hospitals h ON a.hospital_id = h.hospital_id
WHERE a.discharge_date IS NOT NULL
GROUP BY 1,2,3
ORDER BY 4 DESC;
-- The average length of stay ranges from 13 (12.98) days for Elective Asthma admissions at NewYork-Presbyterian Hospital to a maximum of 17 days for Urgent Asthma admissions at UCSF Medical Center.

-- 4. Average treatment cost per condition, with comparison across hospitals and insurance providers
SELECT
    a.medical_condition,
    h.hospital_name,
    i.insurance_name,
    ROUND(AVG(a.billing_amount), 2) AS avg_treatment_cost
FROM admissions a
INNER JOIN hospitals h ON a.hospital_id = h.hospital_id
INNER JOIN insurance_providers i ON a.insurance_id = i.insurance_id
GROUP BY 1,2,3
ORDER BY 4 DESC;
-- The average treatment cost shows high variability, ranging from a maximum of $32,228.30 for Cigna Cancer patients at Northwestern Memorial Hospital to a minimum of $18,812.09 for Cigna Arthritis patients at Massachusetts General Hospital.

-- 5. Hospital performance: patient volume and outcomes comparison
SELECT
    h.hospital_name,
    COUNT(a.admission_id) AS total_patients_treated,
    COUNT(CASE WHEN a.test_results ILIKE 'Normal' THEN 1 END) AS normal_results,
    COUNT(CASE WHEN a.test_results ILIKE 'Abnormal' THEN 1 END) AS abnormal_results,
    COUNT(CASE WHEN a.test_results ILIKE 'Inconclusive' THEN 1 END) AS inconclusive_results,
    ROUND(100.0 * COUNT(CASE WHEN a.test_results ILIKE 'Normal' THEN 1 END) / COUNT(a.admission_id), 2 ) AS normal_result_percentage
FROM admissions a
INNER JOIN hospitals h ON a.hospital_id = h.hospital_id
GROUP BY 1
ORDER BY 2 DESC;
-- Total Patients Treated: Houston Methodist Hospital treated the largest volume of patients (20,402), while NewYork-Presbyterian Hospital treated the fewest (2,334).
-- Result Concentration: Abnormal Results consistently represent the largest category across all hospitals, significantly outweighing Normal and Inconclusive results.
-- Normal Result Percentage: The percentage of Normal Results is low and consistent across all institutions, clustering around the 10% mark.NewYork-Presbyterian Hospital recorded the highest Normal Result Percentage at 10.75% while Cleveland Clinic recorded the lowest at 9.61%.
-- Inconclusive Results: The volume of Inconclusive Results is substantial; for example, Houston Methodist Hospital reported 7,163 inconclusive results, which is 3.5x its count of normal results.

-- 6. Most commonly prescribed medications per condition and their consistency across hospitals
SELECT
    a.medical_condition,
    a.medication,
    h.hospital_name,
    COUNT(a.admission_id) AS prescriptions_count,
    ROUND( 100.0 * COUNT(a.admission_id) / SUM(COUNT(a.admission_id)) OVER (PARTITION BY a.medical_condition), 2 ) AS usage_percentage_within_condition
FROM admissions a
INNER JOIN hospitals h ON a.hospital_id = h.hospital_id
WHERE a.medication IS NOT NULL AND a.medication <> ''
GROUP BY 1,2,3
ORDER BY 1,4 DESC;
-- Houston Methodist Hospital consistently reports the highest volume and usage percentages for all five medications across Arthritis, Asthma, Cancer, Diabetes, and Obesity cases, often exceeding 6.5% usage per condition/drug combination.

-- 7. Admission types analysis: impact on average stay duration and treatment costs
SELECT
    a.admission_type,
    COUNT(a.admission_id) AS total_admissions,
    ROUND(AVG(a.discharge_date - a.date_of_admission), 2) AS avg_length_of_stay,
    ROUND(AVG(a.billing_amount), 2) AS avg_treatment_cost
FROM admissions a
WHERE a.discharge_date IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
-- Despite similar admission volumes (around 18,500), Elective admissions have the highest average treatment cost ($25,602.23), while Emergency admissions exhibit the longest average length of stay 16 (15.60) days.

-- 8. Insurance provider performance: coverage volume, cost, and outcomes
SELECT
    i.insurance_name,
    COUNT(a.admission_id) AS total_patients_covered,
    ROUND(AVG(a.billing_amount), 2) AS avg_treatment_cost,
    COUNT(CASE WHEN a.test_results ILIKE 'Norm%' THEN 1 END) AS normal_results,
    COUNT(CASE WHEN a.test_results ILIKE 'Abnor%' THEN 1 END) AS abnormal_results,
    COUNT(CASE WHEN a.test_results ILIKE 'Incon%' THEN 1 END) AS inconclusive_results
FROM admissions a
JOIN insurance_providers i ON a.insurance_id = i.insurance_id
GROUP BY 1
ORDER BY 2 DESC;
-- Medicare covers the majority of patients (27,750) and reports the highest number of Abnormal (16,650) and Inconclusive (8,325) results, while Cigna has the highest average treatment cost ($25,727.04).
