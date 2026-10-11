CREATE SCHEMA IF NOT EXISTS healthcare;

---Create the PostgreSQL staging table
DROP TABLE IF EXISTS healthcare.diabetic_data_raw;

CREATE TABLE healthcare.diabetic_data_raw (
    encounter_id                  TEXT,
    patient_nbr                    TEXT,
    race                           TEXT,
    gender                         TEXT,
    age                            TEXT,
    weight                         TEXT,
    admission_type_id              TEXT,
    discharge_disposition_id       TEXT,
    admission_source_id            TEXT,
    time_in_hospital               TEXT,
    payer_code                     TEXT,
    medical_specialty              TEXT,
    num_lab_procedures             TEXT,
    num_procedures                 TEXT,
    num_medications                TEXT,
    number_outpatient              TEXT,
    number_emergency               TEXT,
    number_inpatient               TEXT,
    diag_1                         TEXT,
    diag_2                         TEXT,
    diag_3                         TEXT,
    number_diagnoses               TEXT,
    max_glu_serum                  TEXT,
    A1Cresult                      TEXT,
    metformin                      TEXT,
    repaglinide                    TEXT,
    nateglinide                    TEXT,
    chlorpropamide                 TEXT,
    glimepiride                    TEXT,
    acetohexamide                  TEXT,
    glipizide                      TEXT,
    glyburide                      TEXT,
    tolbutamide                    TEXT,
    pioglitazone                   TEXT,
    rosiglitazone                  TEXT,
    acarbose                       TEXT,
    miglitol                       TEXT,
    troglitazone                   TEXT,
    tolazamide                     TEXT,
    examide                        TEXT,
    citoglipton                    TEXT,
    insulin                        TEXT,
    glyburide_metformin            TEXT,
    glipizide_metformin            TEXT,
    glimepiride_pioglitazone       TEXT,
    metformin_rosiglitazone        TEXT,
    metformin_pioglitazone         TEXT,
    change                         TEXT,
    diabetesMed                    TEXT,
    readmitted                     TEXT
);

--Import the CSV into PostgreSQL
-- Run the following command in your terminal to import the CSV file into the PostgreSQL database:
---\copy healthcare.diabetic_data_raw FROM 'C:/Users/Ranjana/patient_readmission_risk_rediction/data/raw/diabetic_data.csv' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

Validate the data import by running a simple query to check the number of rows in the table:

-- Total number of encounters
SELECT COUNT(*) AS total_encounters
FROM healthcare.diabetic_data_raw;

-- Check encounter IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT encounter_id) AS distinct_encounters,
    COUNT(DISTINCT patient_nbr) AS distinct_patients
FROM healthcare.diabetic_data_raw;

-- Check readmission labels
SELECT readmitted, COUNT(*) AS encounters
FROM healthcare.diabetic_data_raw
GROUP BY readmitted
ORDER BY encounters DESC;

-- Check possible missing-value markers
SELECT
    COUNT(*) FILTER (WHERE race = '?') AS unknown_race,
    COUNT(*) FILTER (WHERE weight = '?') AS unknown_weight,
    COUNT(*) FILTER (WHERE payer_code = '?') AS unknown_payer,
    COUNT(*) FILTER (WHERE medical_specialty = '?') AS unknown_specialty
FROM healthcare.diabetic_data_raw;