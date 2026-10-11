
---create the first analytical cohort with joins, a CTE and a binary readmission target
WITH patient_encounters AS (
    SELECT
        e.encounter_id,
        e.patient_nbr,
        p.race,
        p.gender,
        p.age,
        e.admission_type_id,
        e.discharge_disposition_id,
        e.admission_source_id,
        e.time_in_hospital,
        e.num_lab_procedures,
        e.num_procedures,
        e.num_medications,
        e.number_outpatient,
        e.number_emergency,
        e.number_inpatient,
        e.number_diagnoses,
        e.max_glu_serum,
        e.A1Cresult,
        e.diag_1,
        e.diag_2,
        e.diag_3,
        e.readmitted,

        CASE
            WHEN e.readmitted = '<30' THEN 1
            WHEN e.readmitted IN ('>30', 'NO') THEN 0
            ELSE NULL
        END AS readmitted_within_30_days,

        COUNT(*) OVER (
            PARTITION BY e.patient_nbr
        ) AS encounters_in_dataset,

        ROW_NUMBER() OVER (
            PARTITION BY e.patient_nbr
            ORDER BY e.encounter_id
        ) AS encounter_sequence

    FROM healthcare.encounters e
    INNER JOIN healthcare.patients p
        ON e.patient_nbr = p.patient_nbr
)
SELECT *
FROM patient_encounters
WHERE readmitted_within_30_days IS NOT NULL;

---Export the SQL cohort to CSV

\copy (WITH patient_encounters AS (SELECT e.*, p.race, p.gender, p.age, CASE WHEN e.readmitted = '<30' THEN 1 WHEN e.readmitted IN ('>30', 'NO') THEN 0 ELSE NULL END AS readmitted_within_30_days FROM healthcare.encounters e JOIN healthcare.patients p ON e.patient_nbr = p.patient_nbr) SELECT * FROM patient_encounters WHERE readmitted_within_30_days IS NOT NULL) TO 'C:/Users/Ranjana/patient_readmission_risk_rediction/data/processed/readmission_cohort.csv' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');