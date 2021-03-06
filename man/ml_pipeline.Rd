% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ml_pipeline.R
\name{ml_pipeline}
\alias{ml_pipeline}
\title{Spark ML -- Pipelines}
\usage{
ml_pipeline(x, ..., uid = random_string("pipeline_"))
}
\arguments{
\item{x}{Either a \code{spark_connection} or \code{ml_pipeline_stage} objects}

\item{...}{\code{ml_pipeline_stage} objects.}

\item{uid}{A character string used to uniquely identify the ML estimator.}
}
\value{
When \code{x} is a \code{spark_connection}, \code{ml_pipeline()} returns an empty pipeline object. When \code{x} is a \code{ml_pipeline_stage}, \code{ml_pipeline()} returns an \code{ml_pipeline} with the stages set to \code{x} and any transformers or estimators given in \code{...}.
}
\description{
Create Spark ML Pipelines
}
