-- STEP 1: Create Dataset

CREATE SCHEMA IF NOT EXISTS `gcp-aiml-sandbox-vivek-1234.house_price_ds`
OPTIONS(location='US');


-- STEP 2: Explore Data

SELECT *
FROM `gcp-aiml-sandbox-vivek-1234.house_price_ds.house_prices`
LIMIT 10;

SELECT COUNT(*) AS total_rows
FROM `gcp-aiml-sandbox-vivek-1234.house_price_ds.house_prices`;

-- STEP 3: Create Training Table

CREATE OR REPLACE TABLE
`gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_training_data`
AS

SELECT
  Score,
  Rank,
  SubmissionCount,
  TeamId,
  LastSubmissionDate
FROM `gcp-aiml-sandbox-vivek-1234.house_price_ds.house_prices`
WHERE Score IS NOT NULL;

-- STEP 4: Train Linear Regression Model
-- Target = Score

CREATE OR REPLACE MODEL
`gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_model`

OPTIONS(
  model_type='linear_reg',
  input_label_cols=['Score']
)

AS

SELECT
  Score,
  Rank,
  SubmissionCount,
  TeamId,
  LastSubmissionDate
FROM `gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_training_data`;


-- STEP 5: Evaluate Model

SELECT *
FROM ML.EVALUATE(
  MODEL `gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_model`
);

-- STEP 6: Feature Information

SELECT *
FROM ML.FEATURE_INFO(
  MODEL `gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_model`
);


-- STEP 7: Model Weights

SELECT *
FROM ML.WEIGHTS(
  MODEL `gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_model`
);


-- STEP 8: Predict New Scores

SELECT
  predicted_Score,
  Rank,
  SubmissionCount,
  TeamId,
  LastSubmissionDate

FROM ML.PREDICT(
  MODEL `gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_model`,
  (
    SELECT
      50 AS Rank,
      12 AS SubmissionCount,
      12345678 AS TeamId,
      TIMESTAMP('2026-08-30 10:00:00 UTC') AS LastSubmissionDate
  )
);

-- ==========================================
-- CLEAN UP BIGQUERY ML RESOURCES
-- ==========================================

-- Delete the Linear Regression model
DROP MODEL IF EXISTS
`gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_model`;

-- Delete the training table
DROP TABLE IF EXISTS
`gcp-aiml-sandbox-vivek-1234.house_price_ds.leaderboard_training_data`;

-- (Optional) Delete the original uploaded table
DROP TABLE IF EXISTS
`gcp-aiml-sandbox-vivek-1234.house_price_ds.house_prices`;

-- (Optional) Delete the entire dataset
DROP SCHEMA IF EXISTS
`gcp-aiml-sandbox-vivek-1234.house_price_ds`
CASCADE;