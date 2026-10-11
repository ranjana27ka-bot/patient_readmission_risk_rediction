CREATE TABLE healthcare.patients (
    patient_nbr BIGINT PRIMARY KEY,
    race TEXT,
    gender TEXT,
    age TEXT,
    weight TEXT
);

CREATE TABLE healthcare.encounters (
    encounter_id BIGINT PRIMARY KEY,
    patient_nbr BIGINT NOT NULL
        REFERENCES healthcare.patients(patient_nbr),

    admission_type_id INTEGER,
    discharge_disposition_id INTEGER,
    admission_source_id INTEGER,

    time_in_hospital INTEGER,
    num_lab_procedures INTEGER,
    num_procedures INTEGER,
    num_medications INTEGER,
    number_outpatient INTEGER,
    number_emergency INTEGER,
    number_inpatient INTEGER,
    number_diagnoses INTEGER,

    max_glu_serum TEXT,
    A1Cresult TEXT,
    diag_1 TEXT,
    diag_2 TEXT,
    diag_3 TEXT,
    readmitted TEXT
);

CREATE TABLE healthcare.encounter_diagnoses (
    encounter_id BIGINT NOT NULL
        REFERENCES healthcare.encounters(encounter_id),
    diagnosis_sequence SMALLINT NOT NULL,
    diagnosis_code TEXT,
    PRIMARY KEY (encounter_id, diagnosis_sequence)
);

CREATE INDEX idx_encounters_patient
    ON healthcare.encounters(patient_nbr);

CREATE INDEX idx_encounters_readmitted
    ON healthcare.encounters(readmitted);

--Populate the relational tables from the staging table
-- 1. Patient dimension
INSERT INTO healthcare.patients (
    patient_nbr, race, gender, age, weight
)
SELECT DISTINCT ON (patient_nbr)
    patient_nbr::BIGINT,
    NULLIF(race, '?'),
    NULLIF(gender, '?'),
    NULLIF(age, '?'),
    NULLIF(weight, '?')
FROM healthcare.diabetic_data_raw
WHERE NULLIF(patient_nbr, '') IS NOT NULL
ORDER BY patient_nbr, encounter_id::BIGINT;

-- 2. Encounter fact table
INSERT INTO healthcare.encounters (
    encounter_id,
    patient_nbr,
    admission_type_id,
    discharge_disposition_id,
    admission_source_id,
    time_in_hospital,
    num_lab_procedures,
    num_procedures,
    num_medications,
    number_outpatient,
    number_emergency,
    number_inpatient,
    number_diagnoses,
    max_glu_serum,
    A1Cresult,
    diag_1,
    diag_2,
    diag_3,
    readmitted
)
SELECT
    encounter_id::BIGINT,
    patient_nbr::BIGINT,
    NULLIF(admission_type_id, '?')::INTEGER,
    NULLIF(discharge_disposition_id, '?')::INTEGER,
    NULLIF(admission_source_id, '?')::INTEGER,
    NULLIF(time_in_hospital, '?')::INTEGER,
    NULLIF(num_lab_procedures, '?')::INTEGER,
    NULLIF(num_procedures, '?')::INTEGER,
    NULLIF(num_medications, '?')::INTEGER,
    NULLIF(number_outpatient, '?')::INTEGER,
    NULLIF(number_emergency, '?')::INTEGER,
    NULLIF(number_inpatient, '?')::INTEGER,
    NULLIF(number_diagnoses, '?')::INTEGER,
    NULLIF(max_glu_serum, '?'),
    NULLIF(A1Cresult, '?'),
    NULLIF(diag_1, '?'),
    NULLIF(diag_2, '?'),
    NULLIF(diag_3, '?'),
    readmitted
FROM healthcare.diabetic_data_raw
WHERE NULLIF(encounter_id, '') IS NOT NULL
  AND NULLIF(patient_nbr, '') IS NOT NULL;

-- 3. Normalize the three diagnosis positions
INSERT INTO healthcare.encounter_diagnoses (
    encounter_id, diagnosis_sequence, diagnosis_code
)
SELECT
    e.encounter_id,
    d.diagnosis_sequence,
    d.diagnosis_code
FROM healthcare.encounters e
CROSS JOIN LATERAL (
    VALUES
        (1::SMALLINT, e.diag_1),
        (2::SMALLINT, e.diag_2),
        (3::SMALLINT, e.diag_3)
) AS d(diagnosis_sequence, diagnosis_code)
WHERE d.diagnosis_code IS NOT NULL;

---validate the results
SELECT 'patients' AS table_name, COUNT(*) AS row_count
FROM healthcare.patients

UNION ALL

SELECT 'encounters', COUNT(*)
FROM healthcare.encounters

UNION ALL

SELECT 'encounter_diagnoses', COUNT(*)
FROM healthcare.encounter_diagnoses;