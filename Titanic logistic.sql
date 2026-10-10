-- ==========================================================
-- TITANIC SURVIVAL PREDICTION USING BIGQUERY ML
-- Model : Logistic Regression
-- Project : gcp-aiml-sandbox-vivek-1234
-- ==========================================================


-- ==========================================================
-- STEP 1 : CREATE DATASET
-- ==========================================================

CREATE SCHEMA IF NOT EXISTS
`gcp-aiml-sandbox-vivek-1234.titanic_ds`
OPTIONS(
  location='US'
);


-- ==========================================================
-- STEP 2 : EXPLORE DATA
-- ==========================================================

SELECT *
FROM `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_train`
LIMIT 10;


SELECT COUNT(*) AS total_rows
FROM `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_train`;


-- ==========================================================
-- STEP 3 : DATA QUALITY CHECK
-- ==========================================================

SELECT

COUNTIF(Age IS NULL) AS age_null,

COUNTIF(Cabin IS NULL) AS cabin_null,

COUNTIF(Embarked IS NULL) AS embarked_null

FROM `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_train`;



-- Target distribution

SELECT

Survived,

COUNT(*) AS total

FROM `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_train`

GROUP BY Survived

ORDER BY Survived;



-- ==========================================================
-- STEP 4 : CREATE CLEAN TRAINING TABLE
-- ==========================================================

CREATE OR REPLACE TABLE
`gcp-aiml-sandbox-vivek-1234.titanic_ds.training_data`

AS

SELECT

Survived,

Pclass,

Sex,

IFNULL(Age,30) AS Age,

SibSp,

Parch,

Fare,

IFNULL(Embarked,'S') AS Embarked

FROM `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_train`;



-- Verify cleaned data

SELECT COUNT(*) AS rowss

FROM `gcp-aiml-sandbox-vivek-1234.titanic_ds.training_data`;



-- ==========================================================
-- STEP 5 : TRAIN LOGISTIC REGRESSION MODEL
-- ==========================================================

CREATE OR REPLACE MODEL
`gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_logistic_model`

OPTIONS(

model_type='logistic_reg',

input_label_cols=['Survived']

)

AS

SELECT *

FROM `gcp-aiml-sandbox-vivek-1234.titanic_ds.training_data`;



-- ==========================================================
-- STEP 6 : EVALUATE MODEL
-- ==========================================================

SELECT *

FROM ML.EVALUATE(

MODEL `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_logistic_model`

);



-- ==========================================================
-- STEP 7 : FEATURE INFORMATION
-- ==========================================================

SELECT *

FROM ML.FEATURE_INFO(

MODEL `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_logistic_model`

);



-- ==========================================================
-- STEP 8 : MODEL COEFFICIENTS
-- ==========================================================

SELECT *

FROM ML.WEIGHTS(

MODEL `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_logistic_model`

)

ORDER BY ABS(weight) DESC;



-- ==========================================================
-- STEP 9 : PREDICT NEW PASSENGERS
-- ==========================================================

SELECT

predicted_Survived,

predicted_Survived_probs,

Pclass,

Sex,

Age,

Fare

FROM ML.PREDICT(

MODEL `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_logistic_model`,

(

SELECT

3 AS Pclass,

'male' AS Sex,

22 AS Age,

1 AS SibSp,

0 AS Parch,

7.25 AS Fare,

'S' AS Embarked

UNION ALL

SELECT

1,

'female',

38,

1,

0,

71.28,

'C'

UNION ALL

SELECT

2,

'female',

26,

0,

0,

13.00,

'S'

)

);



-- ==========================================================
-- STEP 10 : CONFUSION MATRIX
-- ==========================================================

SELECT *

FROM ML.CONFUSION_MATRIX(

MODEL `gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_logistic_model`,

(

SELECT *

FROM `gcp-aiml-sandbox-vivek-1234.titanic_ds.training_data`

)

);



-- ==========================================================
-- STEP 11 : CLEAN UP (OPTIONAL)
-- ==========================================================

DROP MODEL IF EXISTS
`gcp-aiml-sandbox-vivek-1234.titanic_ds.titanic_logistic_model`;

DROP TABLE IF EXISTS
`gcp-aiml-sandbox-vivek-1234.titanic_ds.training_data`;

-- Drop entire dataset

DROP SCHEMA IF EXISTS
`gcp-aiml-sandbox-vivek-1234.titanic_ds`
CASCADE;