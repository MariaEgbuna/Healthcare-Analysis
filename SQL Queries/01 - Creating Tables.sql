-- ========================
-- CREATING SCHEMA
-- ========================
CREATE SCHEMA HealthCare_Schema;

-- ========================
-- PATIENTS TABLE
-- ========================
CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    age INTEGER,
    gender VARCHAR(10),
    blood_type CHAR(3)
);

-- Import `patients.csv` file

-- ========================
-- DOCTORS TABLE
-- ========================
CREATE TABLE doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    doctor_name VARCHAR(100) UNIQUE
);

-- Import `doctors.csv` file

-- ========================
-- HOSPITALS TABLE
-- ========================
CREATE TABLE hospitals (
    hospital_id VARCHAR(15) PRIMARY KEY,
    hospital_name VARCHAR(150) UNIQUE,
    hospital_latitude DECIMAL(9,6),
    hospital_longitude DECIMAL(9,6)
);

-- Import `hospitals.csv` file

-- ========================
-- INSURANCE PROVIDERS TABLE
-- ========================
CREATE TABLE insurance_providers (
    insurance_id VARCHAR(10) PRIMARY KEY,
    insurance_name VARCHAR(50) UNIQUE
);

-- Import `insurance_providers.csv` file

-- ========================
-- ADMISSIONS TABLE
-- ========================
CREATE TABLE admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id VARCHAR(10),
    medical_condition VARCHAR(100),
    date_of_admission DATE,
    doctor_id VARCHAR(10),
    hospital_id VARCHAR(15),
    insurance_id VARCHAR(10),
    billing_amount NUMERIC(12,2),
    room_number INTEGER,
    admission_type VARCHAR(50),
    discharge_date DATE,
    medication VARCHAR(100),
    test_results VARCHAR(50)
);

-- Import `admissions.csv` file

-- ========================
-- CREATING FOREIGN KEYS
-- ========================
ALTER TABLE admissions
ADD CONSTRAINT fk_patient_id
FOREIGN KEY (patient_id)
REFERENCES patients (patient_id);

ALTER TABLE admissions
ADD CONSTRAINT fk_doctor_id
FOREIGN KEY (doctor_id)
REFERENCES doctors (doctor_id);

ALTER TABLE admissions
ADD CONSTRAINT fk_hospital_id
FOREIGN KEY (hospital_id)
REFERENCES hospitals (hospital_id);

ALTER TABLE admissions
ADD CONSTRAINT fk_insurance_id
FOREIGN KEY (insurance_id)
REFERENCES insurance_providers (insurance_id);

-- ========================
-- ADDING A CHECK CONSTRAINT
-- ========================
ALTER TABLE admissions
ADD CONSTRAINT chk_DischargeAfterAdmission
CHECK (discharge_date >= date_of_admission);

-- ========================
-- Adding age Group Column
-- ========================
ALTER TABLE patients
ADD COLUMN age_group;

UPDATE patients
SET age_group = 
    CASE
        -- 1. Teens
        WHEN age > 12 AND age <= 17 THEN '13-17 (Teens)'
        -- 2. Young Adult
        WHEN age >= 18 AND age <= 30 THEN '18-30 (Young Adult)'
        -- 3. Mid Adult
        WHEN age >= 31 AND age <= 45 THEN '31-45 (Mid Adult)'
        -- 4. Mature Adult
        WHEN age >= 46 AND age <= 60 THEN '46-60 (Mature Adult)'
        -- 5. Senior
        WHEN age > 60 AND age <= 90 THEN 'Above 60 (Senior)'
        -- Handle ages outside the 13-89 range
        ELSE 'Others N/A' 
    END;
