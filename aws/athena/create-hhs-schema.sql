--
-- Create the schema that reads from the HHS source data files.
--
-- We make zero effort here to clean these files or even
-- to parse the data types and treat them as strings unless
-- it's zero effort to coerce them to the right type.
--

DROP DATABASE IF EXISTS covid_hhs_sources CASCADE;

CREATE DATABASE covid_hhs_sources
LOCATION 's3://covid-19-puerto-rico-data/HHS/';


--
-- Covid Tracking Project has more correct data for earlier dates.
--
--
-- Covid Tracking Project has more correct data for earlier dates.
--
CREATE EXTERNAL TABLE covid_hhs_sources.covid_tracking_csv (
    date STRING,
    state STRING,
    death STRING,
    deathConfirmed STRING,
    deathIncrease STRING,
    deathProbable STRING,
    hospitalized STRING,
    hospitalizedCumulative STRING,
    hospitalizedCurrently STRING,
    hospitalizedIncrease STRING,
    inIcuCumulative STRING,
    inIcuCurrently STRING,
    negative STRING,
    negativeIncrease STRING,
    negativeTestsAntibody STRING,
    negativeTestsPeopleAntibody STRING,
    negativeTestsViral STRING,
    onVentilatorCumulative STRING,
    onVentilatorCurrently STRING,
    positive STRING,
    positiveCasesViral STRING,
    positiveIncrease STRING,
    positiveScore STRING,
    positiveTestsAntibody STRING,
    positiveTestsAntigen STRING,
    positiveTestsPeopleAntibody STRING,
    positiveTestsPeopleAntigen STRING,
    positiveTestsViral STRING,
    recovered STRING,
    totalTestEncountersViral STRING,
    totalTestEncountersViralIncrease STRING,
    totalTestResults STRING,
    totalTestResultsIncrease STRING,
    totalTestsAntibody STRING,
    totalTestsAntigen STRING,
    totalTestsPeopleAntibody STRING,
    totalTestsPeopleAntigen STRING,
    totalTestsPeopleViral STRING,
    totalTestsPeopleViralIncrease STRING,
    totalTestsViral STRING,
    totalTestsViralIncrease STRING
) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
LOCATION 's3://covid-19-puerto-rico-data/CovidTracking/'
TBLPROPERTIES (
    "skip.header.line.count"="1"
);


--
-- https://healthdata.gov/dataset/covid-19-reported-patient-impact-and-hospital-capacity-state-timeseries
--
CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_utilization_timeseries_v2 (
    state STRING,
    date STRING,
    critical_staffing_shortage_today_yes STRING,
    critical_staffing_shortage_today_no STRING,
    critical_staffing_shortage_today_not_reported STRING,
    critical_staffing_shortage_anticipated_within_week_yes STRING,
    critical_staffing_shortage_anticipated_within_week_no STRING,
    critical_staffing_shortage_anticipated_within_week_not_reported STRING,
    hospital_onset_covid STRING,
    hospital_onset_covid_coverage STRING,
    inpatient_beds STRING,
    inpatient_beds_coverage STRING,
    inpatient_beds_used STRING,
    inpatient_beds_used_coverage STRING,
    inpatient_beds_used_covid STRING,
    inpatient_beds_used_covid_coverage STRING,
    previous_day_admission_adult_covid_confirmed STRING,
    previous_day_admission_adult_covid_confirmed_coverage STRING,
    previous_day_admission_adult_covid_suspected STRING,
    previous_day_admission_adult_covid_suspected_coverage STRING,
    previous_day_admission_pediatric_covid_confirmed STRING,
    previous_day_admission_pediatric_covid_confirmed_coverage STRING,
    previous_day_admission_pediatric_covid_suspected STRING,
    previous_day_admission_pediatric_covid_suspected_coverage STRING,
    staffed_adult_icu_bed_occupancy STRING,
    staffed_adult_icu_bed_occupancy_coverage STRING,
    staffed_icu_adult_patients_confirmed_and_suspected_covid STRING,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_coverage STRING,
    staffed_icu_adult_patients_confirmed_covid STRING,
    staffed_icu_adult_patients_confirmed_covid_coverage STRING,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid STRING,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_coverage STRING,
    total_adult_patients_hospitalized_confirmed_covid STRING,
    total_adult_patients_hospitalized_confirmed_covid_coverage STRING,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid STRING,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_coverage STRING,
    total_pediatric_patients_hospitalized_confirmed_covid STRING,
    total_pediatric_patients_hospitalized_confirmed_covid_coverage STRING,
    total_staffed_adult_icu_beds STRING,
    total_staffed_adult_icu_beds_coverage STRING,
    inpatient_beds_utilization STRING,
    inpatient_beds_utilization_coverage STRING,
    inpatient_beds_utilization_numerator STRING,
    inpatient_beds_utilization_denominator STRING,
    percent_of_inpatients_with_covid STRING,
    percent_of_inpatients_with_covid_coverage STRING,
    percent_of_inpatients_with_covid_numerator STRING,
    percent_of_inpatients_with_covid_denominator STRING,
    inpatient_bed_covid_utilization STRING,
    inpatient_bed_covid_utilization_coverage STRING,
    inpatient_bed_covid_utilization_numerator STRING,
    inpatient_bed_covid_utilization_denominator STRING,
    adult_icu_bed_covid_utilization STRING,
    adult_icu_bed_covid_utilization_coverage STRING,
    adult_icu_bed_covid_utilization_numerator STRING,
    adult_icu_bed_covid_utilization_denominator STRING,
    adult_icu_bed_utilization STRING,
    adult_icu_bed_utilization_coverage STRING,
    adult_icu_bed_utilization_numerator STRING,
    adult_icu_bed_utilization_denominator STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/reported_hospital_utilization_timeseries/v2/parquet/';

CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_utilization_timeseries_v3 (
    state STRING,
    date STRING,
    critical_staffing_shortage_today_yes BIGINT,
    critical_staffing_shortage_today_no BIGINT,
    critical_staffing_shortage_today_not_reported BIGINT,
    critical_staffing_shortage_anticipated_within_week_yes BIGINT,
    critical_staffing_shortage_anticipated_within_week_no BIGINT,
    critical_staffing_shortage_anticipated_within_week_not_reported BIGINT,
    hospital_onset_covid BIGINT,
    hospital_onset_covid_coverage BIGINT,
    inpatient_beds BIGINT,
    inpatient_beds_coverage BIGINT,
    inpatient_beds_used BIGINT,
    inpatient_beds_used_coverage BIGINT,
    inpatient_beds_used_covid BIGINT,
    inpatient_beds_used_covid_coverage BIGINT,
    previous_day_admission_adult_covid_confirmed BIGINT,
    previous_day_admission_adult_covid_confirmed_coverage BIGINT,
    previous_day_admission_adult_covid_suspected BIGINT,
    previous_day_admission_adult_covid_suspected_coverage BIGINT,
    previous_day_admission_pediatric_covid_confirmed BIGINT,
    previous_day_admission_pediatric_covid_confirmed_coverage BIGINT,
    previous_day_admission_pediatric_covid_suspected BIGINT,
    previous_day_admission_pediatric_covid_suspected_coverage BIGINT,
    staffed_adult_icu_bed_occupancy BIGINT,
    staffed_adult_icu_bed_occupancy_coverage BIGINT,
    staffed_icu_adult_patients_confirmed_and_suspected_covid BIGINT,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_coverage BIGINT,
    staffed_icu_adult_patients_confirmed_covid BIGINT,
    staffed_icu_adult_patients_confirmed_covid_coverage BIGINT,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid BIGINT,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_coverage BIGINT,
    total_adult_patients_hospitalized_confirmed_covid BIGINT,
    total_adult_patients_hospitalized_confirmed_covid_coverage BIGINT,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid BIGINT,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_coverage BIGINT,
    total_pediatric_patients_hospitalized_confirmed_covid BIGINT,
    total_pediatric_patients_hospitalized_confirmed_covid_coverage BIGINT,
    total_staffed_adult_icu_beds BIGINT,
    total_staffed_adult_icu_beds_coverage BIGINT,
    inpatient_beds_utilization DOUBLE,
    inpatient_beds_utilization_coverage BIGINT,
    inpatient_beds_utilization_numerator BIGINT,
    inpatient_beds_utilization_denominator BIGINT,
    percent_of_inpatients_with_covid DOUBLE,
    percent_of_inpatients_with_covid_coverage BIGINT,
    percent_of_inpatients_with_covid_numerator BIGINT,
    percent_of_inpatients_with_covid_denominator BIGINT,
    inpatient_bed_covid_utilization DOUBLE,
    inpatient_bed_covid_utilization_coverage BIGINT,
    inpatient_bed_covid_utilization_numerator BIGINT,
    inpatient_bed_covid_utilization_denominator BIGINT,
    adult_icu_bed_covid_utilization DOUBLE,
    adult_icu_bed_covid_utilization_coverage BIGINT,
    adult_icu_bed_covid_utilization_numerator BIGINT,
    adult_icu_bed_covid_utilization_denominator BIGINT,
    adult_icu_bed_utilization DOUBLE,
    adult_icu_bed_utilization_coverage BIGINT,
    adult_icu_bed_utilization_numerator BIGINT,
    adult_icu_bed_utilization_denominator BIGINT
    -- There's a bunch more columns that I haven't incorporated yet
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/reported_hospital_utilization_timeseries/v3/parquet/';


--
-- https://healthdata.gov/dataset/covid-19-reported-patient-impact-and-hospital-capacity-state
--
CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_utilization_v2 (
    state CHAR(2),
    critical_staffing_shortage_today_yes STRING,
    critical_staffing_shortage_today_no STRING,
    critical_staffing_shortage_today_not_reported STRING,
    critical_staffing_shortage_anticipated_within_week_yes STRING,
    critical_staffing_shortage_anticipated_within_week_no STRING,
    critical_staffing_shortage_anticipated_within_week_not_reported STRING,
    hospital_onset_covid STRING,
    hospital_onset_covid_coverage STRING,
    inpatient_beds STRING,
    inpatient_beds_coverage STRING,
    inpatient_beds_used STRING,
    inpatient_beds_used_coverage STRING,
    inpatient_beds_used_covid STRING,
    inpatient_beds_used_covid_coverage STRING,
    previous_day_admission_adult_covid_confirmed STRING,
    previous_day_admission_adult_covid_confirmed_coverage STRING,
    previous_day_admission_adult_covid_suspected STRING,
    previous_day_admission_adult_covid_suspected_coverage STRING,
    previous_day_admission_pediatric_covid_confirmed STRING,
    previous_day_admission_pediatric_covid_confirmed_coverage STRING,
    previous_day_admission_pediatric_covid_suspected STRING,
    previous_day_admission_pediatric_covid_suspected_coverage STRING,
    staffed_adult_icu_bed_occupancy STRING,
    staffed_adult_icu_bed_occupancy_coverage STRING,
    staffed_icu_adult_patients_confirmed_and_suspected_covid STRING,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_coverage STRING,
    staffed_icu_adult_patients_confirmed_covid STRING,
    staffed_icu_adult_patients_confirmed_covid_coverage STRING,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid STRING,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_coverage STRING,
    total_adult_patients_hospitalized_confirmed_covid STRING,
    total_adult_patients_hospitalized_confirmed_covid_coverage STRING,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid STRING,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_coverage STRING,
    total_pediatric_patients_hospitalized_confirmed_covid STRING,
    total_pediatric_patients_hospitalized_confirmed_covid_coverage STRING,
    total_staffed_adult_icu_beds STRING,
    total_staffed_adult_icu_beds_coverage STRING,
    inpatient_beds_utilization STRING,
    inpatient_beds_utilization_coverage STRING,
    inpatient_beds_utilization_numerator STRING,
    inpatient_beds_utilization_denominator STRING,
    percent_of_inpatients_with_covid STRING,
    percent_of_inpatients_with_covid_coverage STRING,
    percent_of_inpatients_with_covid_numerator STRING,
    percent_of_inpatients_with_covid_denominator STRING,
    inpatient_bed_covid_utilization STRING,
    inpatient_bed_covid_utilization_coverage STRING,
    inpatient_bed_covid_utilization_numerator STRING,
    inpatient_bed_covid_utilization_denominator STRING,
    adult_icu_bed_covid_utilization STRING,
    adult_icu_bed_covid_utilization_coverage STRING,
    adult_icu_bed_covid_utilization_numerator STRING,
    adult_icu_bed_covid_utilization_denominator STRING,
    adult_icu_bed_utilization STRING,
    adult_icu_bed_utilization_coverage STRING,
    adult_icu_bed_utilization_numerator STRING,
    adult_icu_bed_utilization_denominator STRING,
    reporting_cutoff_start STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/reported_hospital_utilization/v2/parquet/';

CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_utilization_v3 (
    state CHAR(2),
    critical_staffing_shortage_today_yes BIGINT,
    critical_staffing_shortage_today_no BIGINT,
    critical_staffing_shortage_today_not_reported BIGINT,
    critical_staffing_shortage_anticipated_within_week_yes BIGINT,
    critical_staffing_shortage_anticipated_within_week_no BIGINT,
    critical_staffing_shortage_anticipated_within_week_not_reported BIGINT,
    hospital_onset_covid BIGINT,
    hospital_onset_covid_coverage BIGINT,
    inpatient_beds BIGINT,
    inpatient_beds_coverage BIGINT,
    inpatient_beds_used BIGINT,
    inpatient_beds_used_coverage BIGINT,
    inpatient_beds_used_covid BIGINT,
    inpatient_beds_used_covid_coverage BIGINT,
    previous_day_admission_adult_covid_confirmed BIGINT,
    previous_day_admission_adult_covid_confirmed_coverage BIGINT,
    previous_day_admission_adult_covid_suspected BIGINT,
    previous_day_admission_adult_covid_suspected_coverage BIGINT,
    previous_day_admission_pediatric_covid_confirmed BIGINT,
    previous_day_admission_pediatric_covid_confirmed_coverage BIGINT,
    previous_day_admission_pediatric_covid_suspected BIGINT,
    previous_day_admission_pediatric_covid_suspected_coverage BIGINT,
    staffed_adult_icu_bed_occupancy BIGINT,
    staffed_adult_icu_bed_occupancy_coverage BIGINT,
    staffed_icu_adult_patients_confirmed_and_suspected_covid BIGINT,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_coverage BIGINT,
    staffed_icu_adult_patients_confirmed_covid BIGINT,
    staffed_icu_adult_patients_confirmed_covid_coverage BIGINT,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid BIGINT,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_coverage BIGINT,
    total_adult_patients_hospitalized_confirmed_covid BIGINT,
    total_adult_patients_hospitalized_confirmed_covid_coverage BIGINT,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid BIGINT,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_coverage BIGINT,
    total_pediatric_patients_hospitalized_confirmed_covid BIGINT,
    total_pediatric_patients_hospitalized_confirmed_covid_coverage BIGINT,
    total_staffed_adult_icu_beds BIGINT,
    total_staffed_adult_icu_beds_coverage BIGINT,
    inpatient_beds_utilization DOUBLE,
    inpatient_beds_utilization_coverage BIGINT,
    inpatient_beds_utilization_numerator BIGINT,
    inpatient_beds_utilization_denominator BIGINT,
    percent_of_inpatients_with_covid DOUBLE,
    percent_of_inpatients_with_covid_coverage BIGINT,
    percent_of_inpatients_with_covid_numerator BIGINT,
    percent_of_inpatients_with_covid_denominator BIGINT,
    inpatient_bed_covid_utilization DOUBLE,
    inpatient_bed_covid_utilization_coverage BIGINT,
    inpatient_bed_covid_utilization_numerator BIGINT,
    inpatient_bed_covid_utilization_denominator BIGINT,
    adult_icu_bed_covid_utilization DOUBLE,
    adult_icu_bed_covid_utilization_coverage BIGINT,
    adult_icu_bed_covid_utilization_numerator BIGINT,
    adult_icu_bed_covid_utilization_denominator BIGINT,
    adult_icu_bed_utilization DOUBLE,
    adult_icu_bed_utilization_coverage BIGINT,
    adult_icu_bed_utilization_numerator BIGINT,
    adult_icu_bed_utilization_denominator BIGINT,
    reporting_cutoff_start STRING,
    geocoded_state STRING,
    `previous_day_admission_adult_covid_confirmed_18-19` BIGINT,
    `previous_day_admission_adult_covid_confirmed_18-19_coverage` BIGINT
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/reported_hospital_utilization/v3/parquet/';


--
-- https://healthdata.gov/dataset/covid-19-reported-patient-impact-and-hospital-capacity-facility
--
CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_capacity_admissions_facility_level_weekly_average_timeseries_v2 (
    hospital_pk STRING,
    collection_week STRING,
    state CHAR(2),
    ccn CHAR(6),
    hospital_name STRING,
    address STRING,
    city STRING,
    zip CHAR(5),
    hospital_subtype STRING,
    fips_code CHAR(5),
    is_metro_micro STRING,
    total_beds_7_day_avg STRING,
    all_adult_hospital_beds_7_day_avg STRING,
    all_adult_hospital_inpatient_beds_7_day_avg STRING,
    inpatient_beds_used_7_day_avg STRING,
    all_adult_hospital_inpatient_bed_occupied_7_day_avg STRING,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_avg STRING,
    total_adult_patients_hospitalized_confirmed_covid_7_day_avg STRING,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_avg STRING,
    total_pediatric_patients_hospitalized_confirmed_covid_7_day_avg STRING,
    inpatient_beds_7_day_avg STRING,
    total_icu_beds_7_day_avg STRING,
    total_staffed_adult_icu_beds_7_day_avg STRING,
    icu_beds_used_7_day_avg STRING,
    staffed_adult_icu_bed_occupancy_7_day_avg STRING,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_avg STRING,
    staffed_icu_adult_patients_confirmed_covid_7_day_avg STRING,
    total_patients_hospitalized_confirmed_influenza_7_day_avg STRING,
    icu_patients_confirmed_influenza_7_day_avg STRING,
    total_patients_hospitalized_confirmed_influenza_and_covid_7_day_avg STRING,
    total_beds_7_day_sum STRING,
    all_adult_hospital_beds_7_day_sum STRING,
    all_adult_hospital_inpatient_beds_7_day_sum STRING,
    inpatient_beds_used_7_day_sum STRING,
    all_adult_hospital_inpatient_bed_occupied_7_day_sum STRING,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_sum STRING,
    total_adult_patients_hospitalized_confirmed_covid_7_day_sum STRING,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_sum STRING,
    total_pediatric_patients_hospitalized_confirmed_covid_7_day_sum STRING,
    inpatient_beds_7_day_sum STRING,
    total_icu_beds_7_day_sum STRING,
    total_staffed_adult_icu_beds_7_day_sum STRING,
    icu_beds_used_7_day_sum STRING,
    staffed_adult_icu_bed_occupancy_7_day_sum STRING,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_sum STRING,
    staffed_icu_adult_patients_confirmed_covid_7_day_sum STRING,
    total_patients_hospitalized_confirmed_influenza_7_day_sum STRING,
    icu_patients_confirmed_influenza_7_day_sum STRING,
    total_patients_hospitalized_confirmed_influenza_and_covid_7_day_sum STRING,
    total_beds_7_day_coverage STRING,
    all_adult_hospital_beds_7_day_coverage STRING,
    all_adult_hospital_inpatient_beds_7_day_coverage STRING,
    inpatient_beds_used_7_day_coverage STRING,
    all_adult_hospital_inpatient_bed_occupied_7_day_coverage STRING,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_coverage STRING,
    total_adult_patients_hospitalized_confirmed_covid_7_day_coverage STRING,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_coverage STRING,
    total_pediatric_patients_hospitalized_confirmed_covid_7_day_coverage STRING,
    inpatient_beds_7_day_coverage STRING,
    total_icu_beds_7_day_coverage STRING,
    total_staffed_adult_icu_beds_7_day_coverage STRING,
    icu_beds_used_7_day_coverage STRING,
    staffed_adult_icu_bed_occupancy_7_day_coverage STRING,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_coverage STRING,
    staffed_icu_adult_patients_confirmed_covid_7_day_coverage STRING,
    total_patients_hospitalized_confirmed_influenza_7_day_coverage STRING,
    icu_patients_confirmed_influenza_7_day_coverage STRING,
    total_patients_hospitalized_confirmed_influenza_and_covid_7_day_coverage STRING,
    previous_day_admission_adult_covid_confirmed_7_day_sum STRING,
    `previous_day_admission_adult_covid_confirmed_18-19_7_day_sum` STRING,
    `previous_day_admission_adult_covid_confirmed_20-29_7_day_sum` STRING,
    `previous_day_admission_adult_covid_confirmed_30-39_7_day_sum` STRING,
    `previous_day_admission_adult_covid_confirmed_40-49_7_day_sum` STRING,
    `previous_day_admission_adult_covid_confirmed_50-59_7_day_sum` STRING,
    `previous_day_admission_adult_covid_confirmed_60-69_7_day_sum` STRING,
    `previous_day_admission_adult_covid_confirmed_70-79_7_day_sum` STRING,
    `previous_day_admission_adult_covid_confirmed_80+_7_day_sum` STRING,
    previous_day_admission_adult_covid_confirmed_unknown_7_day_sum STRING,
    previous_day_admission_pediatric_covid_confirmed_7_day_sum STRING,
    previous_day_covid_ED_visits_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_7_day_sum STRING,
    `previous_day_admission_adult_covid_suspected_18-19_7_day_sum` STRING,
    `previous_day_admission_adult_covid_suspected_20-29_7_day_sum` STRING,
    `previous_day_admission_adult_covid_suspected_30-39_7_day_sum` STRING,
    `previous_day_admission_adult_covid_suspected_40-49_7_day_sum` STRING,
    `previous_day_admission_adult_covid_suspected_50-59_7_day_sum` STRING,
    `previous_day_admission_adult_covid_suspected_60-69_7_day_sum` STRING,
    `previous_day_admission_adult_covid_suspected_70-79_7_day_sum` STRING,
    `previous_day_admission_adult_covid_suspected_80+_7_day_sum` STRING,
    previous_day_admission_adult_covid_suspected_unknown_7_day_sum STRING,
    previous_day_admission_pediatric_covid_suspected_7_day_sum STRING,
    previous_day_total_ED_visits_7_day_sum STRING,
    previous_day_admission_influenza_confirmed_7_day_sum STRING,
    -- Added on May 3, 2021:
    hhs_ids STRING,
    previous_day_admission_adult_covid_confirmed_7_day_coverage STRING,
    previous_day_admission_pediatric_covid_confirmed_7_day_coverage STRING,
    previous_day_admission_adult_covid_suspected_7_day_coverage STRING,
    previous_day_admission_pediatric_covid_suspected_7_day_coverage STRING,
    previous_week_personnel_covid_vaccinated_doses_administered_7_day_max STRING,
    total_personnel_covid_vaccinated_doses_none_7_day_min STRING,
    total_personnel_covid_vaccinated_doses_one_7_day_max STRING,
    total_personnel_covid_vaccinated_doses_all_7_day_max STRING,
    previous_week_patients_covid_vaccinated_doses_one_7_day_max STRING,
    previous_week_patients_covid_vaccinated_doses_all_7_day_max STRING,
    is_corrected STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/reported_hospital_capacity_admissions_facility_level_weekly_average_timeseries/v2/parquet/'
;

CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_capacity_admissions_facility_level_weekly_average_timeseries_v3 (
    hospital_pk STRING,
    collection_week STRING,
    state CHAR(2),
    ccn CHAR(6),
    hospital_name STRING,
    address STRING,
    city STRING,
    zip BIGINT, -- Must cleanse to digit string
    hospital_subtype STRING,
    fips_code BIGINT, -- Must cleanse to digit string
    is_metro_micro BOOLEAN,
    total_beds_7_day_avg DOUBLE,
    all_adult_hospital_beds_7_day_avg DOUBLE,
    all_adult_hospital_inpatient_beds_7_day_avg DOUBLE,
    inpatient_beds_used_7_day_avg DOUBLE,
    all_adult_hospital_inpatient_bed_occupied_7_day_avg DOUBLE,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_avg DOUBLE,
    total_adult_patients_hospitalized_confirmed_covid_7_day_avg DOUBLE,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_avg DOUBLE,
    total_pediatric_patients_hospitalized_confirmed_covid_7_day_avg DOUBLE,
    inpatient_beds_7_day_avg DOUBLE,
    total_icu_beds_7_day_avg DOUBLE,
    total_staffed_adult_icu_beds_7_day_avg DOUBLE,
    icu_beds_used_7_day_avg DOUBLE,
    staffed_adult_icu_bed_occupancy_7_day_avg DOUBLE,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_avg DOUBLE,
    staffed_icu_adult_patients_confirmed_covid_7_day_avg DOUBLE,
    total_patients_hospitalized_confirmed_influenza_7_day_avg DOUBLE,
    icu_patients_confirmed_influenza_7_day_avg DOUBLE,
    total_patients_hospitalized_confirmed_influenza_and_covid_7_day_avg DOUBLE,
    total_beds_7_day_sum BIGINT,
    all_adult_hospital_beds_7_day_sum BIGINT,
    all_adult_hospital_inpatient_beds_7_day_sum BIGINT,
    inpatient_beds_used_7_day_sum BIGINT,
    all_adult_hospital_inpatient_bed_occupied_7_day_sum BIGINT,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_sum BIGINT,
    total_adult_patients_hospitalized_confirmed_covid_7_day_sum BIGINT,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_sum BIGINT,
    total_pediatric_patients_hospitalized_confirmed_covid_7_day_sum BIGINT,
    inpatient_beds_7_day_sum BIGINT,
    total_icu_beds_7_day_sum BIGINT,
    total_staffed_adult_icu_beds_7_day_sum BIGINT,
    icu_beds_used_7_day_sum BIGINT,
    staffed_adult_icu_bed_occupancy_7_day_sum BIGINT,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_sum BIGINT,
    staffed_icu_adult_patients_confirmed_covid_7_day_sum BIGINT,
    total_patients_hospitalized_confirmed_influenza_7_day_sum BIGINT,
    icu_patients_confirmed_influenza_7_day_sum BIGINT,
    total_patients_hospitalized_confirmed_influenza_and_covid_7_day_sum BIGINT,
    total_beds_7_day_coverage BIGINT,
    all_adult_hospital_beds_7_day_coverage BIGINT,
    all_adult_hospital_inpatient_beds_7_day_coverage BIGINT,
    inpatient_beds_used_7_day_coverage BIGINT,
    all_adult_hospital_inpatient_bed_occupied_7_day_coverage BIGINT,
    total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_coverage BIGINT,
    total_adult_patients_hospitalized_confirmed_covid_7_day_coverage BIGINT,
    total_pediatric_patients_hospitalized_confirmed_and_suspected_covid_7_day_coverage BIGINT,
    total_pediatric_patients_hospitalized_confirmed_covid_7_day_coverage BIGINT,
    inpatient_beds_7_day_coverage BIGINT,
    total_icu_beds_7_day_coverage BIGINT,
    total_staffed_adult_icu_beds_7_day_coverage BIGINT,
    icu_beds_used_7_day_coverage BIGINT,
    staffed_adult_icu_bed_occupancy_7_day_coverage BIGINT,
    staffed_icu_adult_patients_confirmed_and_suspected_covid_7_day_coverage BIGINT,
    staffed_icu_adult_patients_confirmed_covid_7_day_coverage BIGINT,
    total_patients_hospitalized_confirmed_influenza_7_day_coverage BIGINT,
    icu_patients_confirmed_influenza_7_day_coverage BIGINT,
    total_patients_hospitalized_confirmed_influenza_and_covid_7_day_coverage BIGINT,
    previous_day_admission_adult_covid_confirmed_7_day_sum BIGINT,
    `previous_day_admission_adult_covid_confirmed_18-19_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_confirmed_20-29_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_confirmed_30-39_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_confirmed_40-49_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_confirmed_50-59_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_confirmed_60-69_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_confirmed_70-79_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_confirmed_80+_7_day_sum` BIGINT,
    previous_day_admission_adult_covid_confirmed_unknown_7_day_sum BIGINT,
    previous_day_admission_pediatric_covid_confirmed_7_day_sum BIGINT,
    previous_day_covid_ED_visits_7_day_sum BIGINT,
    previous_day_admission_adult_covid_suspected_7_day_sum BIGINT,
    `previous_day_admission_adult_covid_suspected_18-19_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_suspected_20-29_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_suspected_30-39_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_suspected_40-49_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_suspected_50-59_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_suspected_60-69_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_suspected_70-79_7_day_sum` BIGINT,
    `previous_day_admission_adult_covid_suspected_80+_7_day_sum` BIGINT,
    previous_day_admission_adult_covid_suspected_unknown_7_day_sum BIGINT,
    previous_day_admission_pediatric_covid_suspected_7_day_sum BIGINT,
    previous_day_total_ED_visits_7_day_sum BIGINT,
    previous_day_admission_influenza_confirmed_7_day_sum BIGINT,
    -- Added on May 3, 2021:
    geocoded_hospital_address STRING,
    hhs_ids STRING,
    previous_day_admission_adult_covid_confirmed_7_day_coverage BIGINT,
    previous_day_admission_pediatric_covid_confirmed_7_day_coverage BIGINT,
    previous_day_admission_adult_covid_suspected_7_day_coverage BIGINT,
    previous_day_admission_pediatric_covid_suspected_7_day_coverage BIGINT,
    previous_week_personnel_covid_vaccinated_doses_administered_7_day_max BIGINT,
    total_personnel_covid_vaccinated_doses_none_7_day BIGINT,
    total_personnel_covid_vaccinated_doses_one_7_day BIGINT,
    total_personnel_covid_vaccinated_doses_all_7_day BIGINT,
    previous_week_patients_covid_vaccinated_doses_one_7_day BIGINT,
    previous_week_patients_covid_vaccinated_doses_all_7_day BIGINT,
    is_corrected BOOLEAN,
    all_pediatric_inpatient_bed_occupied_7_day_avg DOUBLE,
    all_pediatric_inpatient_bed_occupied_7_day_coverage BIGINT,
    all_pediatric_inpatient_bed_occupied_7_day_sum BIGINT,
    all_pediatric_inpatient_beds_7_day_avg DOUBLE
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/reported_hospital_capacity_admissions_facility_level_weekly_average_timeseries/v3/parquet/'
;


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
-- Community Profile Reports
--

CREATE EXTERNAL TABLE covid_hhs_sources.community_profile_report_county_v2 (
	fips STRING,
	county STRING,
	state STRING,
	fema_region STRING,
	date STRING,
	cases_last_7_days STRING,
	cases_per_100k_last_7_days STRING,
	total_cases STRING,
	cases_pct_change_from_prev_week STRING,
	deaths_last_7_days STRING,
	deaths_per_100k_last_7_days STRING,
	total_deaths STRING,
	deaths_pct_change_from_prev_week STRING,
	test_positivity_rate_last_7_days STRING,
	total_positive_tests_last_7_days STRING,
	total_tests_last_7_days STRING,
	total_tests_per_100k_last_7_days STRING,
	test_positivity_rate_pct_change_from_prev_week STRING,
	total_tests_pct_change_from_prev_week STRING,
	confirmed_covid_hosp_last_7_days STRING,
	confirmed_covid_hosp_per_100_beds_last_7_days STRING,
	confirmed_covid_hosp_per_100_beds_pct_change_from_prev_week STRING,
	suspected_covid_hosp_last_7_days STRING,
	suspected_covid_hosp_per_100_beds_last_7_days STRING,
	suspected_covid_hosp_per_100_beds_pct_change_from_prev_week STRING,
	pct_inpatient_beds_used_avg_last_7_days STRING,
	pct_inpatient_beds_used_abs_change_from_prev_week STRING,
	pct_inpatient_beds_used_covid_avg_last_7_days STRING,
	pct_inpatient_beds_used_covid_abs_change_from_prev_week STRING,
	pct_icu_beds_used_avg_last_7_days STRING,
	pct_icu_beds_used_abs_change_from_prev_week STRING,
	pct_icu_beds_used_covid_avg_last_7_days STRING,
	pct_icu_beds_used_covid_abs_change_from_prev_week STRING,
	pct_vents_used_avg_last_7_days STRING,
	pct_vents_used_abs_change_from_prev_week STRING,
	pct_vents_used_covid_avg_last_7_days STRING,
	pct_vents_used_covid_abs_change_from_prev_week STRING,
	pct_fully_vacc_total_pop STRING,
	pct_fully_vacc_65_and_older STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/covid-19_community_profile_report_county/v2/parquet/';

CREATE EXTERNAL TABLE covid_hhs_sources.community_profile_report_county_v3 (
	fips BIGINT,  -- needs to be cleaned to 5 digit string
	county STRING,
	state STRING,
	fema_region BIGINT,
	date STRING,
	cases_last_7_days BIGINT,
	cases_per_100k_last_7_days DOUBLE,
	total_cases BIGINT,
	cases_pct_change_from_prev_week DOUBLE,
	deaths_last_7_days BIGINT,
	deaths_per_100k_last_7_days DOUBLE,
	total_deaths BIGINT,
	deaths_pct_change_from_prev_week DOUBLE,
	test_positivity_rate_last_7_days DOUBLE,
	total_positive_tests_last_7_days BIGINT,
	total_tests_last_7_days BIGINT,
	total_tests_per_100k_last_7_days DOUBLE,
	test_positivity_rate_pct_change_from_prev_week DOUBLE,
	total_tests_pct_change_from_prev_week DOUBLE,
	confirmed_covid_hosp_last_7_days DOUBLE,
	confirmed_covid_hosp_per_100_beds_last_7_days DOUBLE,
	confirmed_covid_hosp_per_100_beds_pct_change_from_prev_week DOUBLE,
	suspected_covid_hosp_last_7_days DOUBLE,
	suspected_covid_hosp_per_100_beds_last_7_days DOUBLE,
	suspected_covid_hosp_per_100_beds_pct_change_from_prev_week DOUBLE,
	pct_inpatient_beds_used_avg_last_7_days DOUBLE,
	pct_inpatient_beds_used_abs_change_from_prev_week DOUBLE,
	pct_inpatient_beds_used_covid_avg_last_7_days DOUBLE,
	pct_inpatient_beds_used_covid_abs_change_from_prev_week DOUBLE,
	pct_icu_beds_used_avg_last_7_days DOUBLE,
	pct_icu_beds_used_abs_change_from_prev_week DOUBLE,
	pct_icu_beds_used_covid_avg_last_7_days DOUBLE,
	pct_icu_beds_used_covid_abs_change_from_prev_week DOUBLE,

	-- These four ventilators columns seem to have been discontinued
	-- in January 2022. Because they're all null, that's why csv2parquet
	-- infers them all as strings.
	pct_vents_used_avg_last_7_days STRING,
	pct_vents_used_abs_change_from_prev_week STRING,
	pct_vents_used_covid_avg_last_7_days STRING,
	pct_vents_used_covid_abs_change_from_prev_week STRING,

	pct_fully_vacc_total_pop DOUBLE,
	pct_fully_vacc_65_and_older DOUBLE
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/covid-19_community_profile_report_county/v3/parquet/';


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
-- Diagnostic lab testing
--

CREATE EXTERNAL TABLE covid_hhs_sources.diagnostic_lab_testing_v2 (
	state STRING,
	state_name STRING,
	state_fips STRING,
	fema_region STRING,
	overall_outcome STRING,
	date STRING,
	new_results_reported STRING,
	total_results_reported STRING,
	geocoded_state STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/covid-19_diagnostic_lab_testing/v2/parquet/';

CREATE EXTERNAL TABLE covid_hhs_sources.diagnostic_lab_testing_v3 (
	state STRING,
	state_name STRING,
	state_fips BIGINT, -- needs to be cleaned to 5 digit string
	fema_region STRING,
	overall_outcome STRING,
	date STRING,
	new_results_reported BIGINT,
	total_results_reported BIGINT,
	geocoded_state STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/covid-19_diagnostic_lab_testing/v3/parquet/';


-----------------------------------------------------------------------
-----------------------------------------------------------------------
--
-- CDC Covid Tracker county vaccination data, scraped version
--

CREATE EXTERNAL TABLE covid_hhs_sources.vaccination_county_condensed_data_json (
	runid INT,
	Date DATE,
	FIPS STRING,
	StateName STRING,
    StateAbbr STRING,
    County STRING,
    Series_Complete_12Plus INT,
    Census2019_12PlusPop INT,
    Series_Complete_12PlusPop_Pct DOUBLE,
    Series_Complete_18Plus INT,
    Series_Complete_18PlusPop_Pct DOUBLE,
    Series_Complete_65Plus INT,
    Series_Complete_65PlusPop_Pct DOUBLE,
    Series_Complete_Yes INT,
    Series_Complete_Pop_Pct DOUBLE,
    Completeness_pct DOUBLE
) PARTITIONED BY (downloaded_date STRING)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://covid-19-puerto-rico-data/cdc-covid-data-tracker/vaccination_county_condensed_data/jsonl_v1/';


-----------------------------------------------------------------------
-----------------------------------------------------------------------
--
-- CDC Covid Tracker vaccine breakthrough cases and deaths
--
-- https://data.cdc.gov/Public-Health-Surveillance/Rates-of-COVID-19-Cases-or-Deaths-by-Age-Group-and/3rge-nu2a/
--
CREATE EXTERNAL TABLE covid_hhs_sources.rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_v2 (
    outcome STRING,
    month STRING,
    MMWR_week STRING,
    Age_group STRING,
    Vaccine_product STRING,
    Vaccinated_with_outcome STRING,
    Fully_vaccinated_population STRING,
    Unvaccinated_with_outcome STRING,
    Unvaccinated_population STRING,
    Crude_vax_IR STRING,
    Crude_unvax_IR STRING,
    Crude_IRR STRING,
    Age_adjusted_vax_IR STRING,
    Age_adjusted_unvax_IR STRING,
    Age_adjusted_IRR STRING,
    Continuity_correction STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status/v2/parquet/';

CREATE EXTERNAL TABLE covid_hhs_sources.rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_v3 (
    outcome STRING,
    month STRING,
    -- Needs to be cleansed to a string?
    `MMWR week` BIGINT,
    -- Names with spaces will need to be renamed to underscores
    `Age group` STRING,
    `Vaccine product` STRING,
    `Vaccinated with outcome` BIGINT,
    `Fully vaccinated population` DOUBLE,
    `Unvaccinated with outcome` BIGINT,
    `Unvaccinated population` DOUBLE,
    `Crude vax IR` DOUBLE,
    `Crude unvax IR` DOUBLE,
    `Crude IRR` DOUBLE,
    `Age adjusted vax IR` DOUBLE,
    `Age adjusted unvax IR` DOUBLE,
    `Age adjusted IRR` DOUBLE,
    `Continuity correction` BIGINT
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status/v3/parquet/';


--
-- https://data.cdc.gov/Public-Health-Surveillance/Rates-of-COVID-19-Cases-or-Deaths-by-Age-Group-and/ukww-au2k
--
CREATE EXTERNAL TABLE covid_hhs_sources.rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_and_booster_dose_v2 (
    outcome STRING,
    month STRING,
    MMWR_week STRING,
    Age_group STRING,
    Vaccine_product STRING,
    boosted_with_outcome STRING,
    boosted_population STRING,
    primary_series_only_with_outcome STRING,
    primary_series_only_population STRING,
    Unvaccinated_with_outcome STRING,
    Unvaccinated_population STRING,
    crude_booster_ir STRING,
    Crude_primary_series_only_ir STRING,
    Crude_unvax_IR STRING,
    crude_booster_irr STRING,
    Crude_IRR STRING,
    age_adj_booster_ir STRING,
    age_adj_vax_ir STRING,
    age_adj_unvax_ir STRING,
    age_adj_booster_irr STRING,
    age_adj_irr STRING,
    Continuity_correction STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_and_booster_dose/v2/parquet/';

CREATE EXTERNAL TABLE covid_hhs_sources.rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_and_booster_dose_v3 (
    outcome STRING,
    month STRING,
    MMWR_week BIGINT,
    Age_group STRING,
    Vaccine_product STRING,
    boosted_with_outcome BIGINT,
    boosted_population BIGINT,
    primary_series_only_with_outcome BIGINT,
    primary_series_only_population BIGINT,
    Unvaccinated_with_outcome BIGINT,
    Unvaccinated_population DOUBLE,
    crude_booster_ir DOUBLE,
    Crude_primary_series_only_ir DOUBLE,
    Crude_unvax_IR DOUBLE,
    crude_booster_irr DOUBLE,
    Crude_IRR DOUBLE,
    age_adj_booster_ir DOUBLE,
    age_adj_vax_ir DOUBLE,
    age_adj_unvax_ir DOUBLE,
    age_adj_booster_irr DOUBLE,
    age_adj_irr DOUBLE,
    Continuity_correction BIGINT
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_and_booster_dose/v3/parquet/';


--
-- https://data.cdc.gov/Public-Health-Surveillance/Rates-of-COVID-19-Cases-or-Deaths-by-Age-Group-and/ukww-au2k
--
CREATE EXTERNAL TABLE covid_hhs_sources.rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_and_second_booster_dose_v2 (
    outcome STRING,
    month STRING,
    MMWR_week STRING,
    Age_group STRING,
    Vaccine_product STRING,
    one_boosted_with_outcome STRING,
    one_booster_population STRING,
    two_boosted_with_outcome STRING,
    two_booster_population STRING,
    Vaccinated_with_outcome STRING,
    Fully_vaccinated_population STRING,
    Unvaccinated_with_outcome STRING,
    Unvaccinated_population STRING,
    crude_one_booster_ir STRING,
    crude_two_booster_ir STRING,
    Crude_vax_IR STRING,
    Crude_unvax_IR STRING,
    Crude_IRR STRING,
    crude_one_booster_irr STRING,
    crude_two_booster_irr STRING,
    crude_one_two_booster_irr STRING,
    age_adj_one_booster_ir STRING,
    age_adj_two_booster_ir STRING,
    age_adj_vax_ir STRING,
    age_adj_unvax_ir STRING,
    age_adj_one_booster_irr STRING,
    age_adj_two_booster_irr STRING,
    age_adj_vax_irr STRING,
    Continuity_correction STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_and_second_booster_dose/v2/parquet/';

CREATE EXTERNAL TABLE covid_hhs_sources.rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_and_second_booster_dose_v3 (
    outcome STRING,
    month STRING,
    MMWR_week BIGINT,
    Age_group STRING,
    Vaccine_product STRING,
    one_boosted_with_outcome BIGINT,
    one_booster_population BIGINT,
    two_boosted_with_outcome BIGINT,
    two_booster_population BIGINT,
    Vaccinated_with_outcome BIGINT,
    Fully_vaccinated_population BIGINT,
    Unvaccinated_with_outcome BIGINT,
    Unvaccinated_population DOUBLE,
    crude_one_booster_ir DOUBLE,
    crude_two_booster_ir DOUBLE,
    Crude_vax_IR DOUBLE,
    Crude_unvax_IR DOUBLE,
    Crude_IRR DOUBLE,
    crude_one_booster_irr DOUBLE,
    crude_two_booster_irr DOUBLE,
    crude_one_two_booster_irr DOUBLE,
    age_adj_one_booster_ir DOUBLE,
    age_adj_two_booster_ir DOUBLE,
    age_adj_vax_ir DOUBLE,
    age_adj_unvax_ir DOUBLE,
    age_adj_one_booster_irr DOUBLE,
    age_adj_two_booster_irr DOUBLE,
    age_adj_vax_irr DOUBLE,
    Continuity_correction BIGINT
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status_and_second_booster_dose/v3/parquet/';


-----------------------------------------------------------------------
-----------------------------------------------------------------------
--
-- The CDC's Community Levels (a.k.a. the "green map") dataset.
--
-- https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-Community-Levels-by-County/3nnm-4jni/
--
CREATE EXTERNAL TABLE covid_hhs_sources.community_levels_by_county_v2 (
    county STRING,
    county_fips STRING,
    state STRING,
    county_population STRING,
    health_service_area_number STRING,
    health_service_area STRING,
    health_service_area_population STRING,
    covid_inpatient_bed_utilization STRING,
    covid_hospital_admissions_per_100k STRING,
    covid_cases_per_100k STRING,
    -- This is called `covid-19_community_level` (with a dash) in the CSV,
    -- but our Parquet conversion replaces the dash with an underscore.
    covid_19_community_level STRING,
    date_updated STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/united_states_covid_19_community_levels_by_county/v2/parquet/';

CREATE EXTERNAL TABLE covid_hhs_sources.community_levels_by_county_v3 (
    county STRING,
    county_fips BIGINT, -- Needs to be cleansed to string
    state STRING,
    county_population BIGINT,
    health_service_area_number BIGINT,
    health_service_area STRING,
    health_service_area_population BIGINT,
    covid_inpatient_bed_utilization DOUBLE,
    covid_hospital_admissions_per_100k DOUBLE,
    covid_cases_per_100k DOUBLE,
    `covid-19_community_level` STRING,
    date_updated DATE
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/united_states_covid_19_community_levels_by_county/v3/parquet/';


-----------------------------------------------------------------------
-----------------------------------------------------------------------
--
-- The CDC's cases and deaths dataset:
--
-- https://data.cdc.gov/Case-Surveillance/United-States-COVID-19-Cases-and-Deaths-by-State-o/9mfq-cb36
--
CREATE EXTERNAL TABLE covid_hhs_sources.united_states_covid_19_cases_and_deaths_by_state_v3 (
  submission_date STRING,
  state STRING,
  tot_cases BIGINT,
  conf_cases BIGINT,
  prob_cases BIGINT,
  new_case BIGINT,
  pnew_case BIGINT,
  tot_death BIGINT,
  conf_death BIGINT,
  prob_death BIGINT,
  new_death BIGINT,
  pnew_death BIGINT,
  created_at STRING,
  consent_cases STRING,
  consent_deaths STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/united_states_covid_19_cases_and_deaths_by_state/v3/parquet/';


-----------------------------------------------------------------------
-----------------------------------------------------------------------
--
-- The CDC excess deaths dataset:
--
-- https://data.cdc.gov/NCHS/Excess-Deaths-Associated-with-COVID-19/xkkf-xrst
--
CREATE EXTERNAL TABLE covid_hhs_sources.excess_deaths_associated_with_covid_19_v3 (
  `Week Ending Date` DATE,
  `State` STRING,
  `Observed Number` BIGINT,
  `Upper Bound Threshold` BIGINT,
  `Exceeds Threshold` BOOLEAN,
  `Average Expected Count` BIGINT,
  `Excess Estimate` BIGINT,
  `Total Excess Estimate` BIGINT,
  `Percent Excess Estimate` DOUBLE,
  `Year` BIGINT,
  `Type` STRING,
  `Outcome` STRING,
  `Suppress` STRING,
  `Note` STRING
) STORED AS PARQUET
LOCATION 's3://covid-19-puerto-rico-data/HHS/excess_deaths_associated_with_covid_19/v3/parquet/';
