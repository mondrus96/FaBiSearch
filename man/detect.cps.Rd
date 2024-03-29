% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/detect.cps.R
\name{detect.cps}
\alias{detect.cps}
\title{Multiple change point detection in the network (or clustering) structure of multivariate high-dimensional time series}
\usage{
detect.cps(
  Y,
  mindist = 35,
  nruns = 50,
  nreps = 100,
  alpha = NULL,
  rank = NULL,
  algtype = "brunet",
  testtype = "t-test",
  ncore = 1
)
}
\arguments{
\item{Y}{An input multivariate time series in matrix format, with variables organized in columns and time points in rows. All entries in Y must be positive.}

\item{mindist}{A positive integer with default value equal to 35. It is used to define the minimum distance acceptable between detected change points.}

\item{nruns}{A positive integer with default value equal to 50. It is used to define the number of runs in the NMF function.}

\item{nreps}{A positive integer with default value equal to 100. It is used to define the number of permutations for the statistical inference procedure.}

\item{alpha}{A positive real number with default value set to NULL. When alpha = NULL, then the p-value calculated for inference on the change
points is returned. If alpha = a positive integer value, say 0.05, then it is used to define the significance level for inference on the change points.}

\item{rank}{A positive integer, which defines the rank used in the optimization procedure to detect the change points. If rank = NULL, which is also the
default value, then the optimal rank is computed. If rank = a positive integer value, say 4, then a predetermined rank is used.}

\item{algtype}{A character string, which defines the algorithm to be used in the NMF function. By default it is set to "brunet". See the "Algorithms" section of
\code{\link[NMF]{nmf}} for more information on the available algorithms.}

\item{testtype}{A character string, which defines the type of statistical test to use during the inference procedure. By default it is set to "t-test". The
other options are "ks" and "wilcox" which correspond to the Kolmogorov-Smirnov and Wilcoxon tests, respectively.}

\item{ncore}{A positive integer with default value equal to 1. It is used to define the number of cores to use in the procedure}
}
\value{
A list with the following components :\cr
\code{rank}: The rank used in the optimization procedure for change point detection.\cr
\code{change_points}: A table of the detected change points where column "T" is the time of the change point and "stat_test" is the result (either a boolean value if alpha = a positive real number, or the p-value if alpha = NULL) of the t-test.\cr
\code{compute_time}: The computational time, saved as a "difftime" object.\cr
}
\description{
This function detects multiple change points in the network (or clustering) structure of multivariate high-dimensional time series using
non-negative matrix factorization and a binary search.
}
\examples{
\donttest{
## Change point detection for a multivariate data set, sim2, using settings:
## rank = 3, mindist = 99, nruns = 2, and nreps = 2
set.seed(123)
detect.cps(sim2, rank = 3, mindist = 99, nruns = 2, nreps = 2)
}

# $rank
# [1] 3
#
# $change_points
#     T stat_test
# 1 101 0.3867274
#
# $compute_time
# Time difference of 0.741534 mins

}
\references{
"Factorized Binary Search: a novel technique for change point detection in multivariate high-dimensional time series networks", Ondrus et al.
(2021), <arXiv:2103.06347>.
}
\author{
Martin Ondrus, \email{mondrus@ualberta.ca}, Ivor Cribben, \email{cribben@ualberta.ca}
}
