% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lol.R
\name{lol.project.qoq}
\alias{lol.project.qoq}
\title{Quadratic Optimal QDA (QOQ)}
\usage{
lol.project.qoq(X, Y, r, xfm = FALSE, xfm.opts = list(), ...)
}
\arguments{
\item{X}{\code{[n, d]} the data with \code{n} samples in \code{d} dimensions.}

\item{Y}{\code{[n]} the labels of the samples with \code{K} unique labels.}

\item{r}{the rank of the projection. Note that \code{r >= K}, and \code{r < d}.}

\item{xfm}{whether to transform the variables before taking the SVD.
\itemize{
\item \code{FALSE} apply no transform to the variables.
\item \code{'unit'} unit transform the variables, defaulting to centering and scaling to mean 0, variance 1. See \link[base]{scale} for details and optional args.
\item \code{'log'} log-transform the variables, for use-cases such as having high variance in larger values. Defaults to natural logarithm. See \link[base]{log} for details and optional args.
\item \code{'rank'} rank-transform the variables. Defalts to breaking ties with the average rank of the tied values. See \link[base]{rank} for details and optional args.
\item \code{c(opt1, opt2, etc.)} apply the transform specified in opt1, followed by opt2, etc.
}}

\item{xfm.opts}{optional arguments to pass to the \code{xfm} option specified. Should be a numbered list of lists, where \code{xfm.opts[[i]]} corresponds to the optional arguments for \code{xfm[i]}. Defaults to the default options for each transform scheme.}

\item{...}{trailing args.}
}
\value{
A list containing the following:
\item{\code{A}}{\code{[d, r]} the projection matrix from \code{d} to \code{r} dimensions.}
\item{\code{d}}{the eigen values associated with the eigendecomposition.}
\item{\code{ylabs}}{\code{[K]} vector containing the \code{K} unique, ordered class labels.}
\item{\code{centroids}}{\code{[K, d]} centroid matrix of the \code{K} unique, ordered classes in native \code{d} dimensions.}
\item{\code{priors}}{\code{[K]} vector containing the \code{K} prior probabilities for the unique, ordered classes.}
\item{\code{Xr}}{\code{[n, r]} the \code{n} data points in reduced dimensionality \code{r}.}
\item{\code{cr}}{\code{[K, r]} the \code{K} centroids in reduced dimensionality \code{r}.}
}
\description{
A function for implementing the Quadratic Optimal QDA Projection (QOQ) Algorithm, an intuitive adaptation of the Linear Optimal Low-Rank Projection (LOL).
}
\examples{
library(lolR)
data <- lol.sims.qdtoep(n=200, d=30)  # 200 examples of 30 dimensions
X <- data$X; Y <- data$Y
model <- lol.project.qoq(X=X, Y=Y, r=5)  # use qoq to project into 5 dimensions
}
\author{
Eric Bridgeford
}
