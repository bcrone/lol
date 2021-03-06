#' Principal Component Analysis (PCA)
#'
#' A function that performs PCA on data.
#'
#' @importFrom irlba irlba
#' @param X \code{[n, d]} the data with \code{n} samples in \code{d} dimensions.
#' @param r the rank of the projection.
#' @param xfm whether to transform the variables before taking the SVD.
#' \itemize{
#' \item{FALSE}{apply no transform to the variables.}
#' \item{'unit'}{unit transform the variables, defaulting to centering and scaling to mean 0, variance 1. See \link[base]{scale} for details and optional args.}
#' \item{'log'}{log-transform the variables, for use-cases such as having high variance in larger values. Defaults to natural logarithm. See \link[base]{log} for details and optional args.}
#' \item{'rank'}{rank-transform the variables. Defalts to breaking ties with the average rank of the tied values. See \link[base]{rank} for details and optional args.}
#' \item{c(opt1, opt2, etc.)}{apply the transform specified in opt1, followed by opt2, etc.}
#' }
#' @param xfm.opts optional arguments to pass to the \code{xfm} option specified. Should be a numbered list of lists, where \code{xfm.opts[[i]]} corresponds to the optional arguments for \code{xfm[i]}. Defaults to the default options for each transform scheme.
#' @param ... trailing args.
#' @return A list containing the following:
#' \item{\code{A}}{\code{[d, r]} the projection matrix from \code{d} to \code{r} dimensions.}
#' \item{\code{d}}{the eigen values associated with the eigendecomposition.}
#' \item{\code{Xr}}{\code{[n, r]} the \code{n} data points in reduced dimensionality \code{r}.}
#' @author Eric Bridgeford
#' @examples
#' library(lolR)
#' data <- lol.sims.rtrunk(n=200, d=30)  # 200 examples of 30 dimensions
#' X <- data$X; Y <- data$Y
#' model <- lol.project.pca(X=X, r=2)  # use pca to project into 2 dimensions
#' @export
lol.project.pca <- function(X, r, xfm=FALSE, xfm.opts=list(), ...) {
  # mean center by the column mean
  d <- dim(X)[2]
  if (r > d) {
    stop(sprintf("The number of embedding dimensions, r=%d, must be lower than the number of native dimensions, d=%d", r, d))
  }
  # subtract means
  Xc  <- sweep(X, 2, colMeans(X), '-')
  svdX <- lol.utils.svd(Xc, xfm=xfm, xfm.opts=xfm.opts, nv=r, nu=0)

  return(list(A=svdX$v, d=svdX$d, Xr=lol.embed(X, svdX$v)))
}

#' A utility to use irlba when necessary
#' @importFrom irlba irlba
#' @param X the data to compute the svd of.
#' @param nu the number of left singular vectors to retain.
#' @param nv the number of right singular vectors to retain.
#' @param t the threshold of percent of singular vals/vecs to use irlba.
#' @param xfm whether to transform the variables before taking the SVD.
#' \itemize{
#' \item{FALSE}{apply no transform to the variables.}
#' \item{'unit'}{unit transform the variables, defaulting to centering and scaling to mean 0, variance 1. See \link[base]{scale} for details and optional args.}
#' \item{'log'}{log-transform the variables, for use-cases such as having high variance in larger values. Defaults to natural logarithm. See \link[base]{log} for details and optional args.}
#' \item{'rank'}{rank-transform the variables. Defalts to breaking ties with the average rank of the tied values. See \link[base]{rank} for details and optional args.}
#' \item{c(opt1, opt2, etc.)}{apply the transform specified in opt1, followed by opt2, etc.}
#' }
#' @param xfm.opts optional arguments to pass to the \code{xfm} option specified. Should be a numbered list of lists, where \code{xfm.opts[[i]]} corresponds to the optional arguments for \code{xfm[i]}. Defaults to the default options for each transform scheme.
#' @return the svd of X.
#' @author Eric Bridgeford
lol.utils.svd <- function(X, xfm=FALSE, xfm.opts=list(), nu=0, nv=0, t=.05) {
  n <- nrow(X)
  d <- ncol(X)
  # scale if desired before taking SVD
  for (i in 1:length(xfm)) {
    sc <- xfm[i]
    if (!(i %in% names(xfm.opts))) {
      xfm.opts[[i]] <- list()
    }
    if (sc == 'unit') {
      X <- do.call(scale, c(list(X), xfm.opts[[i]]))
    } else if (sc == 'log') {
      X <- do.call(log, c(list(X), xfm.opts[[i]]))
    } else if (sc == 'rank') {
      X <- apply(X, c(2), function(x) {do.call(rank, c(list(x), xfm.opts[[i]]))})
    }
  }
  # take svd
  if (nu > t*d | nv > t*d | nu >= d | nv >= d) {
    svdX <- svd(X, nu=nu, nv=nv)
  } else {
    svdX <- irlba(X, nu=nu, nv=nv)
  }
  return(svdX)
}

#' Class PCA
#'
#' A function that performs PCA on the class-centered data. Same as low-rank LDA.
#'
#' @param X \code{[n, d]} the data with \code{n} samples in \code{d} dimensions.
#' @param Y \code{[n]} the labels of the samples with \code{K} unique labels.
#' @param r the rank of the projection.
#' @param xfm whether to transform the variables before taking the SVD.
#' \itemize{
#' \item{FALSE}{apply no transform to the variables.}
#' \item{'unit'}{unit transform the variables, defaulting to centering and scaling to mean 0, variance 1. See \link[base]{scale} for details and optional args.}
#' \item{'log'}{log-transform the variables, for use-cases such as having high variance in larger values. Defaults to natural logarithm. See \link[base]{log} for details and optional args.}
#' \item{'rank'}{rank-transform the variables. Defalts to breaking ties with the average rank of the tied values. See \link[base]{rank} for details and optional args.}
#' \item{c(opt1, opt2, etc.)}{apply the transform specified in opt1, followed by opt2, etc.}
#' }
#' @param xfm.opts optional arguments to pass to the \code{xfm} option specified. Should be a numbered list of lists, where \code{xfm.opts[[i]]} corresponds to the optional arguments for \code{xfm[i]}. Defaults to the default options for each transform scheme.
#' @param ... trailing args.
#' @return A list containing the following:
#' \item{\code{A}}{\code{[d, r]} the projection matrix from \code{d} to \code{r} dimensions.}
#' \item{\code{d}}{the eigen values associated with the eigendecomposition.}
#' \item{\code{ylabs}}{\code{[K]} vector containing the \code{K} unique, ordered class labels.}
#' \item{\code{centroids}}{\code{[K, d]} centroid matrix of the \code{K} unique, ordered classes in native \code{d} dimensions.}
#' \item{\code{priors}}{\code{[K]} vector containing the \code{K} prior probabilities for the unique, ordered classes.}
#' \item{\code{Xr}}{\code{[n, r]} the \code{n} data points in reduced dimensionality \code{r}.}
#' \item{\code{cr}}{\code{[K, r]} the \code{K} centroids in reduced dimensionality \code{r}.}
#' @author Eric Bridgeford
#' @examples
#' library(lolR)
#' data <- lol.sims.rtrunk(n=200, d=30)  # 200 examples of 30 dimensions
#' X <- data$X; Y <- data$Y
#' model <- lol.project.pca(X=X, Y=Y, r=2)  # use cpca to project into 2 dimensions
#' @export
lol.project.cpca <- function(X, Y, r, xfm=FALSE, xfm.opts=list(), ...) {
  # class data
  classdat <- lol.utils.info(X, Y)
  priors <- classdat$priors; centroids <- t(classdat$centroids)
  K <- classdat$K; ylabs <- classdat$ylabs
  n <- classdat$n; d <- classdat$d
  if (r > d) {
    stop(sprintf("The number of embedding dimensions, r=%d, must be lower than the number of native dimensions, d=%d", r, d))
  }

  # subtract column means per-class
  Yidx <- sapply(Y, function(y) which(ylabs == y))
  # form class-conditional data matrix
  Xt <- X - centroids[Yidx,]
  # compute the standard projection but with the pre-centered data.
  svdX <- lol.utils.svd(Xt, xfm=xfm, xfm.opts=xfm.opts, nv=r, nu=0)

  return(list(A=svdX$v, d=svdX$d, centroids=centroids, priors=priors, ylabs=ylabs,
              Xr=lol.embed(X, svdX$v), cr=lol.embed(centroids, svdX$v)))
}
