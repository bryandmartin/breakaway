\name{breakaway}
\alias{breakaway}
\title{ function for species richness estimation }
\description{This function implements the species richness estimation procedure outlined in Willis & Bunge (2015). The diversity estimate, standard error, estimated model coefficients, model details and plot of the fitted model are returned.}
\usage{breakaway(data, print = TRUE, plot = TRUE, answers = FALSE, force = FALSE)}
\arguments{
  \item{data}{
  	The sample frequency count table for the population of interest. The first row must correspond to the singletons. Acceptable formats include a matrix, data frame, or file path (csv or txt). The standard frequency count table format is used: two columns, the first of which contains the frequency of interest (eg. 1 for singletons, species observed once, 2 for doubletons, species observed twice, etc.) and the second of which contains the number of species observed this many times. Frequencies (first column) should be ordered least to greatest. At least 6 contiguous frequencies are necessary. Do not concatenate large frequencies. See dataset apples for sample formatting.
 }
  \item{print}{
Logical: whether the results should be printed to screen. If \samp{FALSE}, answers should be set to \samp{TRUE} so that results will be returned.
}
  \item{plot}{
Logical: whether the data and model fit should be plotted.
}
  \item{answers}{
Logical: whether the function should return an argument. If \samp{FALSE}, print should be set to \samp{TRUE}.
}
  \item{force}{
Logical: force \samp{breakaway} to run in the presence of frequency count concatenation, i.e. combining all species observed 27 or 28 or 29 or more into frequency count 27. \samp{force=TRUE} will force \samp{breakaway} to fit models in the presence of this. This will generally result in the model being misspecified, and \samp{breakaway}'s diversity estimates cannot be considered reliable in this case. The option \samp{force} issue does not address censoring or small data on the rare end of the frequency count tables, i.e. insufficiently many contiguous frequencies. 
	}
}
\value{
	\item{code}{
		A category representing algorithm behaviour. \samp{code=1} indicates no nonlinear models converged and the transformed WLRM diversity estimate of Rocchetti et. al. (2011) is returned. \samp{code=2} indicates that the iteratively reweighted model converged and was returned. \samp{code=3} indicates that iterative reweighting did not converge but a model based on a simplified variance structure was returned (in this case, the variance of the frequency ratios is assumed to be proportional to the denominator frequency index). Please peruse your fitted model before using your diversity estimate. 
		}
	\item{name}{
		The ``name'' of the selected model. The first integer represents the numerator polynomial degree and the second integer represents the denominator polynomial degree of the model for the frequency ratios. See Willis & Bunge (2015) for details.
		}
	\item{para}{
		Estimated model parameters and standard errors.
		}
	\item{est}{
		The estimate of total (observed plus unobserved) diversity.
		}
	\item{seest}{
		The standard error in the diversity estimate.
		}
	\item{full}{
		The chosen nonlinear model for frequency ratios.
		}
	\item{ci}{
		An asymmetric 95\% confidence interval for diversity.
		}
}
\references{
	Willis, A. and Bunge, J. (2015). Estimating diversity via frequency ratios. \emph{Biometrics}, \bold{71}(4), 1042--1049. 
  
	Rocchetti, I., Bunge, J. and Bohning, D. (2011). Population size estimation based upon ratios of recapture probabilities. \emph{Annals of Applied Statistics}, \bold{5}.
}
\author{Amy Willis}
\note{ \samp{breakaway} presents an estimator of species richness that is well-suited to the high-diversity/microbial setting. However, many microbial datasets display more diversity than the Kemp-type models can permit. In this case, the log-transformed WLRM diversity estimator of Rocchetti et. al. (2011) is returned. The authors' experience suggests that some datasets that require the log-transformed WLRM contain ``false'' diversity, that is, diversity attributable to sequencing errors (via an inflated singleton count). The authors encourage judicious use of diversity estimators when the dataset may contain these errors, and recommend the use of \code{\link{breakaway_nof1}} as an exploratory tool in this case. 
	}
\seealso{ \code{\link{breakaway_nof1}}; \code{\link{apples}} }
\examples{breakaway(apples)
breakaway(apples,plot=FALSE,print=FALSE,answers=TRUE) 
}
\keyword{ diversity }
\keyword{ microbial }
\keyword{ models }
\keyword{ nonlinear }