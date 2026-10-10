-- ============================================================
-- BIGQUERY ML PROJECT : LOAN DEFAULT PREDICTION
-- Project  : gcp-aiml-sandbox-vivek-1234
-- Dataset  : loan_default_ds
-- Target   : loan_default (0 = No Default, 1 = Default)
-- ============================================================


-- ============================================================
-- STEP 1 : CREATE DATASET (Run only once)
-- ============================================================

CREATE SCHEMA IF NOT EXISTS
`gcp-aiml-sandbox-vivek-1234.loan_default_ds`
OPTIONS(
  location = 'US'
);


-- ============================================================
-- STEP 2 : EXPLORE THE DATASET
-- ============================================================

-- View first 10 rows

SELECT *
FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.loan_default_dataset`
LIMIT 10;


-- Count total rows

SELECT COUNT(*) AS total_rows
FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.loan_default_dataset`;


-- ============================================================
-- STEP 3 : DATA QUALITY CHECK
-- ============================================================

-- Check missing values

SELECT
  COUNTIF(age IS NULL) AS age_null,
  COUNTIF(income IS NULL) AS income_null,
  COUNTIF(credit_score IS NULL) AS credit_score_null,
  COUNTIF(loan_amount IS NULL) AS loan_amount_null,
  COUNTIF(debt_ratio IS NULL) AS debt_ratio_null
FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.loan_default_dataset`;


-- Check target distribution

SELECT
  loan_default,
  COUNT(*) AS total
FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.loan_default_dataset`
GROUP BY loan_default
ORDER BY loan_default;


-- ============================================================
-- STEP 4 : CREATE CLEAN TRAINING TABLE
-- ============================================================

CREATE OR REPLACE TABLE
`gcp-aiml-sandbox-vivek-1234.loan_default_ds.training_data`
AS

SELECT

  age,

  IFNULL(income,50000) AS income,

  IFNULL(credit_score,650) AS credit_score,

  IFNULL(loan_amount,15000) AS loan_amount,

  employment_years,

  debt_ratio,

  account_balance,

  existing_loans,

  education,

  employment_type,

  loan_default

FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.loan_default_dataset`;


-- Verify cleaned table

SELECT COUNT(*) AS rowss
FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.training_data`;


-- ============================================================
-- MODEL 1 : LOGISTIC REGRESSION
-- ============================================================

CREATE OR REPLACE MODEL
`gcp-aiml-sandbox-vivek-1234.loan_default_ds.logistic_model`

OPTIONS(

  model_type = 'logistic_reg',

  input_label_cols = ['loan_default']

)

AS

SELECT *
FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.training_data`;



-- Evaluate Logistic Regression

SELECT *
FROM ML.EVALUATE(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.logistic_model`

);



-- Feature Information

SELECT *
FROM ML.FEATURE_INFO(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.logistic_model`

);



-- Model Coefficients

SELECT *
FROM ML.WEIGHTS(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.logistic_model`

)
ORDER BY ABS(weight) DESC;



-- ============================================================
-- MODEL 2 : RANDOM FOREST CLASSIFIER
-- ============================================================

CREATE OR REPLACE MODEL
`gcp-aiml-sandbox-vivek-1234.loan_default_ds.random_forest_model`

OPTIONS(

  model_type = 'random_forest_classifier',

  input_label_cols = ['loan_default'],

  num_parallel_tree = 100,

  max_tree_depth = 8

)

AS

SELECT *
FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.training_data`;



-- Evaluate Random Forest

SELECT *
FROM ML.EVALUATE(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.random_forest_model`

);



-- Feature Importance

SELECT *
FROM ML.FEATURE_IMPORTANCE(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.random_forest_model`

)
ORDER BY importance_gain DESC;



-- ============================================================
-- MODEL 3 : BOOSTED TREE CLASSIFIER (XGBoost)
-- ============================================================

CREATE OR REPLACE MODEL
`gcp-aiml-sandbox-vivek-1234.loan_default_ds.boosted_tree_model`

OPTIONS(

  model_type = 'boosted_tree_classifier',

  input_label_cols = ['loan_default'],

  max_iterations = 50,

  subsample = 0.8

)

AS

SELECT *
FROM `gcp-aiml-sandbox-vivek-1234.loan_default_ds.training_data`;



-- Evaluate Boosted Tree

SELECT *
FROM ML.EVALUATE(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.boosted_tree_model`

);



-- Feature Importance

SELECT *
FROM ML.FEATURE_IMPORTANCE(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.boosted_tree_model`

)
ORDER BY importance_gain DESC;



-- ============================================================
-- STEP 5 : COMPARE ALL MODELS
-- ============================================================

SELECT

'Logistic Regression' AS model,

accuracy,

precision,

recall,

f1_score,

roc_auc

FROM ML.EVALUATE(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.logistic_model`

)

UNION ALL

SELECT

'Random Forest',

accuracy,

precision,

recall,

f1_score,

roc_auc

FROM ML.EVALUATE(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.random_forest_model`

)

UNION ALL

SELECT

'Boosted Tree',

accuracy,

precision,

recall,

f1_score,

roc_auc

FROM ML.EVALUATE(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.boosted_tree_model`

);



-- ============================================================
-- STEP 6 : PREDICT NEW CUSTOMER
-- ============================================================

SELECT

predicted_loan_default,

predicted_loan_default_probs,

age,

income,

credit_score,

loan_amount

FROM ML.PREDICT(

MODEL `gcp-aiml-sandbox-vivek-1234.loan_default_ds.boosted_tree_model`,

(

SELECT

35 AS age,

65000 AS income,

720 AS credit_score,

18000 AS loan_amount,

8 AS employment_years,

0.32 AS debt_ratio,

22000 AS account_balance,

1 AS existing_loans,

'Graduate' AS education,

'Salaried' AS employment_type

)

);



-- ============================================================
-- STEP 7 : CLEAN UP (Optional)
-- ============================================================

DROP MODEL IF EXISTS
`gcp-aiml-sandbox-vivek-1234.loan_default_ds.logistic_model`;

DROP MODEL IF EXISTS
`gcp-aiml-sandbox-vivek-1234.loan_default_ds.random_forest_model`;

DROP MODEL IF EXISTS
`gcp-aiml-sandbox-vivek-1234.loan_default_ds.boosted_tree_model`;

DROP TABLE IF EXISTS
`gcp-aiml-sandbox-vivek-1234.loan_default_ds.training_data`;

-- Remove entire dataset (Optional)

DROP SCHEMA IF EXISTS
`gcp-aiml-sandbox-vivek-1234.loan_default_ds`
CASCADE;