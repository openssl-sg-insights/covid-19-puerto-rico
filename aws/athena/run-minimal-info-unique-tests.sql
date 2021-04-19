--
-- The `minimal-info-unique-tests` row-per-test dataset.
-- We only run this occasionally for ad-hoc analyses.
--

MSCK REPAIR TABLE covid_pr_sources.minimal_info_unique_tests_parquet_v4;

DROP TABLE IF EXISTS covid_pr_etl.minimal_info_unique_tests;

CREATE TABLE covid_pr_etl.minimal_info_unique_tests WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['bulletin_date'],
    bucket_count = 4
) AS
WITH first_clean AS (
    SELECT
    	date(downloaded_date) AS downloaded_date,
        CAST(from_iso8601_timestamp(downloadedAt) AS TIMESTAMP)
            AS downloaded_at,
        CAST(from_iso8601_timestamp(downloadedAt) AS DATE) - INTERVAL '1' DAY
            AS bulletin_date,
        CAST(date_parse(nullif(collectedDate, ''), '%m/%d/%Y') AS DATE)
            AS raw_collected_date,
        CAST(date_parse(nullif(reportedDate, ''), '%m/%d/%Y') AS DATE)
            AS raw_reported_date,
        date_parse(createdAt, '%m/%d/%Y %H:%i') AS created_at,
        nullif(ageRange, '') AS age_range,
        CASE city
            WHEN '' THEN NULL
            WHEN 'Loiza' THEN 'Loíza'
            WHEN 'Rio Grande' THEN 'Río Grande'
            ELSE city
        END AS municipality,
	    testType AS raw_test_type,
        CASE
            WHEN testType IN (
                'Molecular', 'MOLECULAR'
            ) THEN 'Molecular'
            WHEN testType IN (
                'Antigens', 'ANTIGENO'
            ) THEN 'Antígeno'
            WHEN testType IN (
                'Serological', 'Serological IgG Only', 'Total Antibodies', 'SEROLOGICAL'
            ) THEN 'Serológica'
            ELSE testType
        END AS test_type,
        result,
        COALESCE(result, '') LIKE '%Positive%' AS positive
    FROM covid_pr_sources.minimal_info_unique_tests_parquet_v4
    -- IMPORTANT: This prunes partitions
    WHERE downloaded_date >= cast(date_add('day', -32, current_date) AS VARCHAR)
)
SELECT
    *,
    CASE
	    WHEN test_type IN ('Molecular')
	    THEN CASE
	        -- Null out nonsense collected dates. As of 2021-04-15,
	        -- out of over 1.9M PCR records there were only 267 with
	        -- `raw_collected_date` earlier than March 1 2020 and
	        -- 2,658 with nulls, so we don't really lose much.
	        WHEN raw_collected_date >= DATE '2020-03-01'
	        THEN raw_collected_date
	        -- This was the original method I used to clean up null
	        -- `collected_date` values, but now only for very early
	        -- dates.  Suggested originally by @rafalab; he uses two
	        -- days as the value and says that's the average, but my
	        -- spot check said 2.8 days so I use that.
	        WHEN DATE '2020-03-13' <= raw_reported_date
	                AND raw_reported_date <= DATE '2020-07-01'
	        THEN date_add('day', -3, raw_reported_date)
	    END
	    WHEN test_type IN ('Antígeno')
	    -- As of 2021-04-15, out of 652k antigen test records,
	    -- over 32k have `raw_collected_date` > `raw_reported_date`,
	    -- generally off by one day but some by a handful.  A lot of
	    -- the `raw_collected_date` look handwritten and approximate
	    -- like `2021-02-03 11:25:00` (five minute increments, no
	    -- seconds) while the `raw_reported_date` ones look computer
	    -- generated (second precision values).  I'm going to assume
	    -- that whichever of the two dates is earlier is likelier to
	    -- be right.
	    THEN least(coalesce(raw_collected_date, DATE '9999-12-31'),
	               coalesce(raw_reported_date, DATE '9999-12-31'))
	    ELSE coalesce(raw_collected_date, raw_reported_date, downloaded_date)
    END AS collected_date,
    CASE
	    WHEN test_type IN ('Molecular')
	    THEN CASE
	        WHEN raw_reported_date >= DATE '2020-03-13'
	        THEN raw_reported_date
	        ELSE downloaded_date
	    END
	    WHEN test_type IN ('Antígeno')
	    THEN greatest(coalesce(raw_collected_date, DATE '0001-01-01'),
	                  coalesce(raw_reported_date, DATE '0001-01-01'))
	    ELSE coalesce(raw_reported_date, raw_collected_date, downloaded_date)
    END AS reported_date
FROM first_clean;


DROP TABLE IF EXISTS covid_pr_etl.municipal_tests_cube;

CREATE TABLE covid_pr_etl.municipal_tests_cube WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['downloaded_at'],
    bucket_count = 1
) AS
SELECT
    downloaded_at,
    bulletin_date,
    collected_date,
    reported_date,
    municipality,
    test_type,
    count(*) AS specimens,
    count(*) FILTER (WHERE positive) AS positives
FROM covid_pr_etl.minimal_info_unique_tests
WHERE DATE '2020-03-01' <= collected_date
AND collected_date <= bulletin_date
AND DATE '2020-03-01' <= reported_date
AND reported_date <= bulletin_date
GROUP BY
    downloaded_at,
    bulletin_date,
    collected_date,
    reported_date,
    municipality,
    test_type;


DROP TABLE IF EXISTS covid_pr_etl.municipal_tests_collected_agg;

CREATE TABLE covid_pr_etl.municipal_tests_collected_agg WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['downloaded_at'],
    bucket_count = 1
) AS
SELECT
    downloaded_at,
    bulletin_date,
    collected_date,
    municipality,
    test_type,
    sum(specimens) AS specimens,
    sum(positives) AS positives,
    sum(sum(specimens)) OVER (
        PARTITION BY downloaded_at, bulletin_date, municipality, test_type
        ORDER BY collected_date
    ) AS cumulative_specimens,
    sum(sum(positives)) OVER (
        PARTITION BY downloaded_at, bulletin_date, municipality, test_type
        ORDER BY collected_date
    ) AS cumulative_positives,
    sum(specimens) - coalesce(lag(sum(specimens), 1, 0) OVER (
        PARTITION BY downloaded_at, bulletin_date, municipality, test_type
        ORDER BY collected_date
    ), 0) AS delta_specimens,
    sum(positives) - coalesce(lag(sum(positives), 1, 0) OVER (
            PARTITION BY downloaded_at, bulletin_date, municipality, test_type
            ORDER BY collected_date
        ), 0) AS delta_positives
FROM covid_pr_etl.municipal_tests_cube
GROUP BY
    downloaded_at,
    bulletin_date,
    collected_date,
    municipality,
    test_type;


-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Views
--

CREATE OR REPLACE VIEW covid_pr_etl.municipal_tests_per_capita AS
SELECT
    downloaded_at,
    bulletin_date,
    collected_date,
    municipality,
    population,
    sum(specimens) AS specimens,
    coalesce(sum(specimens) FILTER (
        WHERE test_type = 'Antígeno'
    ), 0) AS antigens,
    coalesce(sum(specimens) FILTER (
        WHERE test_type = 'Molecular'
    ), 0) AS molecular,
    sum(cumulative_specimens) AS cumulative_specimens,
    coalesce(sum(cumulative_specimens) FILTER (
        WHERE test_type = 'Antígeno'
    ), 0) AS cumulative_antigens,
    coalesce(sum(cumulative_specimens) FILTER (
        WHERE test_type = 'Molecular'
    ), 0) AS cumulative_molecular
FROM covid_pr_etl.municipal_tests_collected_agg tests
INNER JOIN covid_pr_sources.acs_2019_5y_municipal_race
    USING (municipality)
WHERE test_type IN ('Antígeno', 'Molecular')
GROUP BY
    downloaded_at,
    bulletin_date,
    municipality,
    collected_date,
    population
ORDER BY
    downloaded_at,
    bulletin_date,
    municipality,
    collected_date;
