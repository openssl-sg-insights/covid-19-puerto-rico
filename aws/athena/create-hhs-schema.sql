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
CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_utilization_timeseries (
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


--
-- https://healthdata.gov/dataset/covid-19-reported-patient-impact-and-hospital-capacity-state
--
CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_utilization (
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

--
-- https://healthdata.gov/dataset/covid-19-reported-patient-impact-and-hospital-capacity-facility
--
CREATE EXTERNAL TABLE covid_hhs_sources.reported_hospital_capacity_admissions_facility_level_weekly_average_timeseries (
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
    previous_day_admission_adult_covid_confirmed_18-19_7_day_sum STRING,
    previous_day_admission_adult_covid_confirmed_20-29_7_day_sum STRING,
    previous_day_admission_adult_covid_confirmed_30-39_7_day_sum STRING,
    previous_day_admission_adult_covid_confirmed_40-49_7_day_sum STRING,
    previous_day_admission_adult_covid_confirmed_50-59_7_day_sum STRING,
    previous_day_admission_adult_covid_confirmed_60-69_7_day_sum STRING,
    previous_day_admission_adult_covid_confirmed_70-79_7_day_sum STRING,
    previous_day_admission_adult_covid_confirmed_80+_7_day_sum STRING,
    previous_day_admission_adult_covid_confirmed_unknown_7_day_sum STRING,
    previous_day_admission_pediatric_covid_confirmed_7_day_sum STRING,
    previous_day_covid_ED_visits_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_18-19_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_20-29_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_30-39_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_40-49_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_50-59_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_60-69_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_70-79_7_day_sum STRING,
    previous_day_admission_adult_covid_suspected_80+_7_day_sum STRING,
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


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
-- Community Profile Reports
--

CREATE EXTERNAL TABLE covid_hhs_sources.community_profile_report_county (
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


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
-- Diagnostic lab testing
--

CREATE EXTERNAL TABLE covid_hhs_sources.diagnostic_lab_testing (
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
CREATE EXTERNAL TABLE covid_hhs_sources.rates_of_covid_19_cases_or_deaths_by_age_group_and_vaccination_status (
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


-----------------------------------------------------------------------
-----------------------------------------------------------------------
--
-- The CDC's Community Levels (a.k.a. the "green map") dataset.
--
-- https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-Community-Levels-by-County/3nnm-4jni/
--
CREATE EXTERNAL TABLE covid_hhs_sources.community_levels_by_county (
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
