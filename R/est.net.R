#===========================================================================
# Estimates stationary networks using non-negative matrix factorization

#' est.net
#' @description Compliment function to FaBiSearch. Estimates sparse stationary networks using non-negative matrix factorization (NMF). Each run of NMF
#' produces an adjacency matrix, and by averaging across all adjacency matrices we generate a consensus matrix where each entry is the probability of two
#' variables or nodes being clustered together.
#'
#' @importFrom NMF nmf
#' @importFrom Rdpack reprompt
#'
#' @param Y A numerical matrix representing the multivariate time series, with the columns representing its components.
#' @param nruns A positive integer, by default is set to 50. It is used to define the number of runs in the NMF function.
#' @param lambda A positive integer or positive real number, which defines the method and cutoff value when estimating an adjacency matrix from the computed
#' consensus matrix. If lambda = a positive integer value, say 6, complete-linkage, hierarchical clustering is applied to the consensus matrix and cutoff at
#' 6 clusters. If lambda = a positive real number, say 0.5, entries in the consensus matrix with a value greater than or equal to 0.5 are labelled adjacent,
#' while entries less than 0.5 are not.
#' @param rank A character string or a positive integer, which defines the rank be used in the optimization procedure to detect the change points.
#' If rank = “optimal”, which is also the default value, then the optimal rank is used. If rank = a positive integer value, say 4, then a predetermined
#' rank is used.
#' @param algtype A character string, which defines the algorithm to be used in the NMF function. By default is set to “brunet” - please see the "Algorithms"
#' section for more information on the available algorithms.
#'
#' @return A matrix (or more specifically, an adjacency matrix) denoting temporal dependencies between variables from \eqn{Y}.
#' @export
#'
#' @section Algorithms:
#' All algorithms available are presented below, please note the "fabisearch" package builds upon the algorithms available in the "NMF" package
#' \insertCite{Gaujoux2010}{fabisearch}:\cr
#'
#' \code{"brunet"} - This algorithm is based on Kullback-Leibler divergence, from \insertCite{Brunet2004a}{fabisearch}. It uses multiplicative updates from
#' \insertCite{NIPS2000_1861}{fabisearch} with some small enhancements.\cr
#'
#' \code{"lee"} - This algorithm is based on Euclidian distances from \insertCite{NIPS2000_1861}{fabisearch}, and uses simple multiplicative updates.\cr
#'
#' \code{"ls-nmf"} - This is the least-squares NMF method from \insertCite{Wang2006}{fabisearch}. This algorithm uses an altered version of the Euclidian
#' distance based, multiplicative updates from \insertCite{NIPS2000_1861}{fabisearch}. It incorporates weights on each entry of the target matrix.\cr
#'
#' \code{"nsNMF"} - This is the nonsmooth NMF method from \insertCite{Pascual-Montano2006}{fabisearch}. This algorithm uses an altered version of the
#' Kullback-Leibler based, multiplicative updates from \insertCite{NIPS2000_1861}{fabisearch}. It includes an intermediate "smoothing" matrix, which is
#' intended to produce sparser factors.\cr
#'
#' \code{"offset"} - This is the offset NMF method from \insertCite{Badea2008}{fabisearch}. This algorithm uses an altered version of the Euclidian
#' distance based, multiplicative updates from \insertCite{NIPS2000_1861}{fabisearch}. It incorporates an intercept which is intended to reflect a common
#' pattern or baseline amongst components.\cr
#'
#' \code{"pe-nmf"} - This is the pattern-expression NMF from \insertCite{Zhang2008}{fabisearch}. This algorithm utilizes multiplicative updates to minimize
#' a Euclidian distance based objective function. It is further regularized such that the basis vectors effectively express patterns.\cr
#'
#' \code{"snmf/r","snmf/l"} - This is the alternating least-squares (ALS) approach from \insertCite{10.1093/bioinformatics/btm134}{fabisearch}. It uses the
#' non-negative, least-squares algorithm from \insertCite{VanBenthem2004}{fabisearch} to alternatingly estimate the basis and coefficent matrices. It
#' utilizes an Euclidian distance based objective function, and is regularized to promote either sparse basis ("snmf/l") or coefficent ("snmf/r") matrices \cr
#'
#' @examples
#' ## Estimating the network for a multivariate dataset, "data" using default settings
#' ## - outputs as an adjacency matrix
#' est.net(data)
#'
#' ## Estimating the network for a multivariate dataset, "data", specifying the number
#' ## of runs to 100 and using hierarchical clustering to generate the adjacency matrix
#' ## with a cutoff value of 7 clusters
#' est.net(data, nruns = 100, lambda = 7)
#'
#' ## Estimating the network for a multivariate dataset, "data", specifying the number
#' ## of runs to 100 and using a cutoff value for the adjacency matrix to enforce
#' ## sparsity, where the cutoff is 0.5
#' est.net(data, nruns = 100, lambda = 0.5)
#'
#' ## Estimating the network for a multivariate dataset, "data", specifying the rank
#' ## beforehand at 4
#' est.net(data, rank = 4)
#'
#' ## Estimating the network for a multivariate dataset, "data", using the least
#' ## square NMF method
#' est.net(data, algtype = "ls-nmf")
#'
#' @author Martin Ondrus, \email{mondrus@ualberta.ca}, Ivor Cribben, \email{cribben@ualberta.ca}
#' @references "Factorized Binary Search: a novel technique for change point detection in multivariate high-dimensional time series networks", Ondrus et al
#' (2021), preprint.
#'
#' \insertAllCited{}

est.net = function(Y, nruns = 50, lambda = 7, rank = "optimal", algtype = "brunet") {

  # Define the Y as a matrix
  Y = as.matrix(Y)

  # If rank has not been specified, then it must be found
  if (rank == "optimal"){
    n.rank = fabisearch:::opt.rank(Y, nruns, algtype)
  } else {
    n.rank = rank
    print(paste("User defined rank:", n.rank))
  }

  # Run NMF on the Y
  nmf.output = nmf(Y, method = algtype, rank = n.rank, nrun = nruns)

  # Save the consensus matrix
  cons.matrix = nmf.output@consensus

  # Branch out different calculations based on method type
  if (lambda > 1){
    # Run hclust and cut the tree at the prespecified n.rank
    hc.out = hclust(dist(cons.matrix))
    ct.out = cutree(hc.out, lambda)

    # Convert ct.out into a matrix factor
    matr.fact = matrix(nrow = lambda, ncol = nrow(cons.matrix))
    for (i in 1:lambda){
       matr.fact[i,] = ct.out == i
    }
    matr.fact = matr.fact*1

    # Construct the adjacency matrix by multiplying the matr.fact and it's
    adj.matrix = t(matr.fact) %*% matr.fact
    diag(adj.matrix) = 0

  } else if (lambda <= 1 && lambda >=0){
    # Any values above lambda assigned 1, equal to or less than lambda assigned 0
    cons.matrix[cons.matrix > lambda] = 1
    cons.matrix[cons.matrix <= lambda] = 0

    # Save the final adjacency matrix
    adj.matrix = cons.matrix
    diag(adj.matrix) = 0
  }

  return(adj.matrix)
}