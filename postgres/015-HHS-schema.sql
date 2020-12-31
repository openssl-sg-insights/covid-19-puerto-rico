--
-- The HHS data set puts -999999 in a lot of columns
-- where the rows in question have values below a certain
-- threshold.
CREATE FUNCTION null_nines(x INTEGER)
RETURNS INTEGER AS $$
    SELECT nullif(x, -999999);
$$ LANGUAGE SQL;

CREATE FUNCTION null_nines(x DOUBLE PRECISION)
RETURNS DOUBLE PRECISION AS $$
    SELECT nullif(x, -999999.0);
$$ LANGUAGE SQL;


--
-- Data dictionary here:
--
-- * https://healthdata.gov/covid-19-reported-patient-impact-and-hospital-capacity-facility-data-dictionary
--
CREATE TABLE hhs_hospital_history (
    -- Postgres has a maximum column name length of 63, but some of the
    -- field names in the CSV exceed that. So we've changed the names.
    "hospital_pk" TEXT NOT NULL,
    "collection_week" DATE NOT NULL,
    "state" CHAR(2) NOT NULL,
    "ccn" CHAR(6),
    "hospital_name" TEXT NOT NULL,
    "address" TEXT,
    "city" TEXT,
    "zip" CHAR(5) NOT NULL,
    "hospital_subtype" TEXT,
    "fips_code" CHAR(5),
    "is_metro_micro" BOOLEAN NOT NULL,
    "total_beds_7_day_avg" DOUBLE PRECISION NOT NULL,
    "all_adult_hospital_beds_7_day_avg" DOUBLE PRECISION NOT NULL,
    "all_adult_hospital_inpatient_beds_7_day_avg" DOUBLE PRECISION NOT NULL,
    "inpatient_beds_used_7_day_avg" DOUBLE PRECISION NOT NULL,
    "all_adult_hospital_inpatient_bed_occupied_7_day_avg" DOUBLE PRECISION NOT NULL,
    -- Original name: "total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_avg"
    "total_adult_patients_hospitalized_covid_7_day_avg" DOUBLE PRECISION,
    "total_adult_patients_hospitalized_confirmed_covid_7_day_avg" DOUBLE PRECISION,
    -- Original name: "total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_avg"
    "total_pediatric_patients_hospitalized_covid_7_day_avg" DOUBLE PRECISION,
    "total_pediatric_patients_hospitalized_confirmed_covid_7_day_avg" DOUBLE PRECISION,
    "inpatient_beds_7_day_avg" DOUBLE PRECISION,
    "total_icu_beds_7_day_avg" DOUBLE PRECISION,
    "total_staffed_adult_icu_beds_7_day_avg" DOUBLE PRECISION,
    "icu_beds_used_7_day_avg" DOUBLE PRECISION,
    "staffed_adult_icu_bed_occupancy_7_day_avg" DOUBLE PRECISION,
    -- Original name: "staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_avg"
    "staffed_icu_adult_patients_covid_7_day_avg" DOUBLE PRECISION,
    "staffed_icu_adult_patients_confirmed_covid_7_day_avg" DOUBLE PRECISION,
    "total_patients_hospitalized_confirmed_influenza_7_day_avg" DOUBLE PRECISION,
    "icu_patients_confirmed_influenza_7_day_avg" DOUBLE PRECISION,
    -- Original name: "total_patients_hospitalized_confirmed_influenza_and_covid_7_day_avg"
    "total_patients_hospitalized_confirmed_both_7_day_avg" DOUBLE PRECISION,
    "total_beds_7_day_sum" INTEGER,
    "all_adult_hospital_beds_7_day_sum" INTEGER,
    "all_adult_hospital_inpatient_beds_7_day_sum" INTEGER,
    "inpatient_beds_used_7_day_sum" INTEGER,
    "all_adult_hospital_inpatient_bed_occupied_7_day_sum" INTEGER,
    -- Original name: "total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_sum"
    "total_adult_patients_hospitalized_covid_7_day_sum" INTEGER,
    "total_adult_patients_hospitalized_confirmed_covid_7_day_sum" INTEGER,
    -- Original name: "total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_sum"
    "total_pediatric_patients_hospitalized_covid_7_day_sum" INTEGER,
    "total_pediatric_patients_hospitalized_confirmed_covid_7_day_sum" INTEGER,
    "inpatient_beds_7_day_sum" INTEGER,
    "total_icu_beds_7_day_sum" INTEGER,
    "total_staffed_adult_icu_beds_7_day_sum" INTEGER,
    "icu_beds_used_7_day_sum" INTEGER,
    "staffed_adult_icu_bed_occupancy_7_day_sum" INTEGER,
    -- Original name: "staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_sum"
    "staffed_icu_adult_patients_covid_7_day_sum" INTEGER,
    "staffed_icu_adult_patients_confirmed_covid_7_day_sum" INTEGER,
    "total_patients_hospitalized_confirmed_influenza_7_day_sum" INTEGER,
    "icu_patients_confirmed_influenza_7_day_sum" INTEGER,
    -- Original name: "total_patients_hospitalized_confirmed_influenza_and_covid_7_day_sum"
    "total_patients_hospitalized_confirmed_both_7_day_sum" INTEGER,
    "total_beds_7_day_coverage" INTEGER,
    "all_adult_hospital_beds_7_day_coverage" INTEGER,
    "all_adult_hospital_inpatient_beds_7_day_coverage" INTEGER,
    "inpatient_beds_used_7_day_coverage" INTEGER,
    "all_adult_hospital_inpatient_bed_occupied_7_day_coverage" INTEGER,
    -- Original name: "total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_coverage"
    "total_adult_patients_hospitalized_covid_7_day_coverage" INTEGER,
    "total_adult_patients_hospitalized_confirmed_covid_7_day_coverage" INTEGER,
    -- Original name: "total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_coverage"
    "total_pediatric_patients_hospitalized_covid_7_day_coverage" INTEGER,
    "total_pediatric_patients_hospitalized_confirmed_covid_7_day_coverage" INTEGER,
    "inpatient_beds_7_day_coverage" INTEGER,
    "total_icu_beds_7_day_coverage" INTEGER,
    "total_staffed_adult_icu_beds_7_day_coverage" INTEGER,
    "icu_beds_used_7_day_coverage" INTEGER,
    "staffed_adult_icu_bed_occupancy_7_day_coverage" INTEGER,
    -- Original name: staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_coverage
    "staffed_icu_adult_patients_covid_7_day_coverage" INTEGER,
    "staffed_icu_adult_patients_confirmed_covid_7_day_coverage" INTEGER,
    "total_patients_hospitalized_confirmed_influenza_7_day_coverage" INTEGER,
    "icu_patients_confirmed_influenza_7_day_coverage" INTEGER,
    -- Original name: "total_patients_hospitalized_confirmed_influenza_and_covid_7_day_coverage"
    "total_patients_hospitalized_confirmed_both_7_day_coverage" INTEGER,
    "previous_day_admission_adult_covid_confirmed_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_18-19_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_20-29_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_30-39_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_40-49_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_50-59_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_60-69_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_70-79_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_80+_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_confirmed_unknown_7_day_sum" INTEGER,
    "previous_day_admission_pediatric_covid_confirmed_7_day_sum" INTEGER,
    "previous_day_covid_ED_visits_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_18-19_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_20-29_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_30-39_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_40-49_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_50-59_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_60-69_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_70-79_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_80+_7_day_sum" INTEGER,
    "previous_day_admission_adult_covid_suspected_unknown_7_day_sum" INTEGER,
    "previous_day_admission_pediatric_covid_suspected_7_day_sum" INTEGER,
    "previous_day_total_ED_visits_7_day_sum" INTEGER,
    "previous_day_admission_influenza_confirmed_7_day_sum" INTEGER,
    PRIMARY KEY ("hospital_pk", "collection_week")
);