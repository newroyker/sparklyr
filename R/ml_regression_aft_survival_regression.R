#' Spark ML -- Survival Regression
#'
#' Fit a parametric survival regression model named accelerated failure time (AFT) model (see \href{https://en.wikipedia.org/wiki/Accelerated_failure_time_model}{Accelerated failure time model (Wikipedia)}) based on the Weibull distribution of the survival time.
#'
#' @template roxlate-ml-algo
#' @template roxlate-ml-formula-params
#' @template roxlate-ml-max-iter
#' @template roxlate-ml-tol
#' @template roxlate-ml-intercept
#' @template roxlate-ml-predictor-params
#' @template roxlate-ml-aggregation-depth
#' @param censor_col Censor column name. The value of this column could be 0 or 1. If the value is 1, it means the event has occurred i.e. uncensored; otherwise censored.
#' @param quantile_probabilities Quantile probabilities array. Values of the quantile probabilities array should be in the range (0, 1) and the array should be non-empty.
#' @param quantiles_col Quantiles column name. This column will output quantiles of corresponding quantileProbabilities if it is set.
#'
#' @examples
#' \dontrun{
#'
#' library(survival)
#' library(sparklyr)
#'
#' sc <- spark_connect(master = "local")
#' ovarian_tbl <- sdf_copy_to(sc, ovarian, name = "ovarian_tbl", overwrite = TRUE)
#'
#' partitions <- ovarian_tbl %>%
#'   sdf_random_split(training = 0.7, test = 0.3, seed = 1111)
#'
#' ovarian_training <- partitions$training
#' ovarian_test <- partitions$test
#'
#' sur_reg <- ovarian_training %>%
#'   ml_aft_survival_regression(futime ~ ecog_ps + rx + age + resid_ds, censor_col = "fustat")
#'
#' pred <- ml_predict(sur_reg, ovarian_test)
#' pred
#' }
#'
#' @export
ml_aft_survival_regression <- function(x, formula = NULL, censor_col = "censor",
                                       quantile_probabilities = c(0.01, 0.05, 0.1, 0.25, 0.5,
                                                                  0.75, 0.9, 0.95, 0.99),
                                       fit_intercept = TRUE, max_iter = 100L, tol = 1e-06,
                                       aggregation_depth = 2, quantiles_col = NULL,
                                       features_col = "features", label_col = "label",
                                       prediction_col = "prediction",
                                       uid = random_string("aft_survival_regression_"), ...) {
  check_dots_used()
  UseMethod("ml_aft_survival_regression")
}

#' @export
ml_aft_survival_regression.spark_connection <- function(x, formula = NULL, censor_col = "censor",
                                                        quantile_probabilities = c(0.01, 0.05, 0.1, 0.25, 0.5,
                                                                                   0.75, 0.9, 0.95, 0.99),
                                                        fit_intercept = TRUE, max_iter = 100L, tol = 1e-06,
                                                        aggregation_depth = 2, quantiles_col = NULL,
                                                        features_col = "features", label_col = "label",
                                                        prediction_col = "prediction",
                                                        uid = random_string("aft_survival_regression_"), ...) {

  .args <- list(
    censor_col = censor_col,
    quantile_probabilities = quantile_probabilities,
    fit_intercept = fit_intercept,
    max_iter = max_iter,
    tol = tol,
    aggregation_depth = aggregation_depth,
    quantiles_col = quantiles_col,
    features_col = features_col,
    label_col = label_col,
    prediction_col = prediction_col
  ) %>%
    c(rlang::dots_list(...)) %>%
    validator_ml_aft_survival_regression()

  jobj <- spark_pipeline_stage(
    x, "org.apache.spark.ml.regression.AFTSurvivalRegression", uid,
    features_col = .args[["features_col"]], label_col = .args[["label_col"]],
    prediction_col = .args[["prediction_col"]]
  ) %>% (
    function(obj) {
      do.call(invoke,
              c(obj, "%>%", Filter(function(x) !is.null(x),
                                   list(
                                        list("setFitIntercept", .args[["fit_intercept"]]),
                                        list("setMaxIter", .args[["max_iter"]]),
                                        list("setTol", .args[["tol"]]),
                                        list("setCensorCol", .args[["censor_col"]]),
                                        list("setFitIntercept", .args[["fit_intercept"]]),
                                        list("setQuantileProbabilities", .args[["quantile_probabilities"]]),
                                        jobj_set_param_helper(obj, "setAggregationDepth", .args[["aggregation_depth"]], "2.1.0", 2),
                                        jobj_set_param_helper(obj, "setQuantilesCol", .args[["quantiles_col"]])))))
    })

  new_ml_aft_survival_regression(jobj)
}

#' @export
ml_aft_survival_regression.ml_pipeline <- function(x, formula = NULL, censor_col = "censor",
                                                   quantile_probabilities = c(0.01, 0.05, 0.1, 0.25, 0.5,
                                                                              0.75, 0.9, 0.95, 0.99),
                                                   fit_intercept = TRUE, max_iter = 100L, tol = 1e-06,
                                                   aggregation_depth = 2, quantiles_col = NULL,
                                                   features_col = "features", label_col = "label",
                                                   prediction_col = "prediction",
                                                   uid = random_string("aft_survival_regression_"), ...) {

  stage <- ml_aft_survival_regression.spark_connection(
    x = spark_connection(x),
    formula = formula,
    censor_col = censor_col,
    quantile_probabilities = quantile_probabilities,
    fit_intercept = fit_intercept,
    max_iter = max_iter,
    tol = tol,
    aggregation_depth = aggregation_depth,
    quantiles_col = quantiles_col,
    features_col = features_col,
    label_col = label_col,
    prediction_col = prediction_col,
    uid = uid,
    ...
  )
  ml_add_stage(x, stage)
}

#' @export
ml_aft_survival_regression.tbl_spark <- function(x, formula = NULL, censor_col = "censor",
                                                 quantile_probabilities = c(0.01, 0.05, 0.1, 0.25, 0.5,
                                                                            0.75, 0.9, 0.95, 0.99),
                                                 fit_intercept = TRUE, max_iter = 100L, tol = 1e-06,
                                                 aggregation_depth = 2, quantiles_col = NULL,
                                                 features_col = "features", label_col = "label",
                                                 prediction_col = "prediction",
                                                 uid = random_string("aft_survival_regression_"),
                                                 response = NULL, features = NULL, ...) {
  formula <- ml_standardize_formula(formula, response, features)

  stage <- ml_aft_survival_regression.spark_connection(
    x = spark_connection(x),
    formula = NULL,
    censor_col = censor_col,
    quantile_probabilities = quantile_probabilities,
    fit_intercept = fit_intercept,
    max_iter = max_iter,
    tol = tol,
    aggregation_depth = aggregation_depth,
    quantiles_col = quantiles_col,
    features_col = features_col,
    label_col = label_col,
    prediction_col = prediction_col,
    uid = uid,
    ...
  )

  if (is.null(formula)) {
    stage %>%
      ml_fit(x)
  } else {
    ml_construct_model_supervised(
      new_ml_model_aft_survival_regression,
      predictor = stage,
      formula = formula,
      dataset = x,
      features_col = features_col,
      label_col = label_col
    )
  }
}

# Validator
validator_ml_aft_survival_regression <- function(.args) {
  .args[["max_iter"]] <- cast_scalar_integer(.args[["max_iter"]])
  .args[["fit_intercept"]] <- cast_scalar_logical(.args[["fit_intercept"]])
  .args[["tol"]] <- cast_scalar_double(.args[["tol"]])
  .args[["censor_col"]] <- cast_string(.args[["censor_col"]])
  .args[["quantile_probabilities"]] <- cast_double_list(.args[["quantile_probabilities"]])
  .args[["max_iter"]] <- cast_scalar_integer(.args[["max_iter"]])
  .args[["aggregation_depth"]] <- cast_scalar_integer(.args[["aggregation_depth"]])
  .args[["quantiles_col"]] <- cast_nullable_string(.args[["quantiles_col"]])
  .args
}

# Constructors

new_ml_aft_survival_regression <- function(jobj) {
  new_ml_estimator(jobj, class = "ml_aft_survival_regression")
}

new_ml_aft_survival_regression_model <- function(jobj) {
  new_ml_transformer(
    jobj,
    coefficients = read_spark_vector(jobj, "coefficients"),
    intercept = possibly_null(invoke)(jobj, "intercept"),
    scale = invoke(jobj, "scale"),
    quantile_probabilities = invoke(jobj, "getQuantileProbabilities"),
    quantiles_col = possibly_null(invoke)(jobj, "getQuantilesCol"),
    class = "ml_aft_survival_regression_model")
}

#' @rdname ml_aft_survival_regression
#' @template roxlate-ml-old-feature-response
#' @details \code{ml_survival_regression()} is an alias for \code{ml_aft_survival_regression()} for backwards compatibility.
#' @export
ml_survival_regression <- function(x, formula = NULL, censor_col = "censor",
                                   quantile_probabilities = c(0.01, 0.05, 0.1, 0.25, 0.5,
                                                              0.75, 0.9, 0.95, 0.99),
                                   fit_intercept = TRUE, max_iter = 100L, tol = 1e-06,
                                   aggregation_depth = 2, quantiles_col = NULL,
                                   features_col = "features", label_col = "label",
                                   prediction_col = "prediction",
                                   uid = random_string("aft_survival_regression_"),
                                   response = NULL, features = NULL, ...) {
  .Deprecated("ml_aft_survival_regression")
  UseMethod("ml_aft_survival_regression")
}
