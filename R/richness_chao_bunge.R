#' Chao-Bunge species richness estimator
#' 
#' This function implements the species richness estimation procedure outlined
#' in Chao & Bunge (2002).
#' 
#' 
#' @param input_data An input type that can be processed by \code{convert()} or a \code{phyloseq} object
#' @param cutoff The maximum frequency to use in fitting.
#' @param output Deprecated; only for backwards compatibility
#' @param answers Deprecated; only for backwards compatibility
#'
#' @return An object of class \code{alpha_estimate}, or \code{alpha_estimates} for \code{phyloseq} objects
#' 
#' @author Amy Willis
#' @examples
#' 
#' chao_bunge(apples)
#' 
#' @export
chao_bunge <- function(input_data, 
                       cutoff=10, 
                       output=NULL, answers=NULL) {
  
  my_warnings <- NULL
  
  
  if (class(input_data) == "phyloseq") {
    if (input_data %>% otu_table %>% taxa_are_rows) {
      return(input_data %>% 
        get_taxa %>%
        apply(2, function(x) chao_bunge(make_frequency_count_table(x))) %>%
        alpha_estimates)
    } else {
      return(input_data %>% 
        otu_table %>%
        apply(1, function(x) chao_bunge(make_frequency_count_table(x))) %>%
        alpha_estimates)
    }
  }

  
  my_data <- convert(input_data)
  
  input_data <- my_data
  cc <- sum(input_data[,2])
  
  index  <- 1:max(my_data[,1])
  frequency_index <- rep(0, length(index))
  frequency_index[my_data[,1]] <- my_data[,2]
  f1  <- frequency_index[1]
  n <- sum(frequency_index)
  
  if (min(my_data[, 1]) > cutoff) {
    my_warnings <- c(my_warnings, "cutoff exceeds minimum frequency count index")
    cutoff <- max(my_data[, 1])
  }
  my_data <- my_data[ my_data[,1] <= cutoff, ]
  cutoff <- max(my_data[,1])
  
  d_a <- sum(input_data[input_data[,1] > cutoff, 2])
  k <- 2:cutoff
  m <- 1:cutoff
  numerator <- frequency_index[k]
  denominator <- 1 - f1*sum(m^2*frequency_index[m])/(sum(m*frequency_index[m]))^2 # 
  if (denominator == 0) {
    diversity <- NA
    diversity_se  <- NA
    f0  <- NA
    interval_tmp <- NA
    
    my_warnings <- c(my_warnings, "zero denominator in estimate for f0")
    return(alpha_estimate(estimate = diversity,
                   error = diversity_se,
                   estimand = "richness",
                   name = "Chao-Bunge",
                   interval = interval_tmp,
                   type = "???",
                   model = "Negative Binomial",
                   frequentist = TRUE,
                   parametric = TRUE,
                   reasonable = TRUE,
                   interval_type = "Approximate: log-normal", 
                   warnings = my_warnings,
                   other = list(cutoff = cutoff)))
  }
  diversity  <- d_a + sum(numerator/denominator)
  
  f0 <- diversity - cc
  
  if (diversity >= 0) {
    fs_up_to_cut_off <- frequency_index[m]
    n_tau <- sum(m * fs_up_to_cut_off)
    s_tau <- sum(fs_up_to_cut_off)
    H <- sum(m^2 * fs_up_to_cut_off)
    derivatives <- n_tau * (n_tau^3 + f1 * n_tau * m^2 * 
                              s_tau - n_tau * f1 * H - f1^2 * n_tau * m^2 - 2 * 
                              f1 * H * m * s_tau + 2 * f1^2 * H * m)/(n_tau^2 - 
                                                                        f1 * H)^2
    derivatives[1] <- n_tau * (s_tau - f1) * (f1 * n_tau - 
                                                2 * f1 * H + n_tau * H)/(n_tau^2 - f1 * H)^2
    covariance <- diag(rep(0, cutoff))
    for (i in 1:(cutoff - 1)) {
      covariance[i, (i + 1):cutoff] <- -fs_up_to_cut_off[i] * fs_up_to_cut_off[(i + 
                                                                                  1):cutoff]/diversity
    }
    covariance <- t(covariance) + covariance
    diag(covariance) <- fs_up_to_cut_off * (1 - fs_up_to_cut_off/diversity)
    diversity_se <- c(sqrt(derivatives %*% covariance %*% derivatives))
    
  } else {
    # wlrm <- wlrm_untransformed(input_data, print = F, answers = T)
    # if (is.null(wlrm$est)) {
    #   wlrm <- wlrm_transformed(input_data, print = F, answers = T)
    # } 
    diversity <- NA
    diversity_se  <- NA
    f0  <- NA
    
    my_warnings <- c(my_warnings, "negative richness estimate")
    
  }
  
  # if(output) {
  #   cat("################## Chao-Bunge ##################\n")
  #   cat("\tThe estimate of total diversity is", round(diversity),
  #       "\n \t with std error",round(diversity_se),"\n")
  # }
  # if(answers) {
  #   result <- list()
  #   result$name <- "Chao-Bunge"
  #   result$est <- diversity
  #   result$seest <- as.vector(diversity_se)
  d <- exp(1.96*sqrt(log(1+diversity_se^2/f0)))
  #   result$ci <- c(n+f0/d,n+f0*d)
  #   return(result)
  # }
  
  alpha_estimate(estimate = diversity,
                 error = diversity_se,
                 estimand = "richness",
                 name = "Chao-Bunge",
                 interval = c(n + f0/d, n + f0*d),
                 type = "???",
                 model = "Negative Binomial",
                 frequentist = TRUE,
                 parametric = TRUE,
                 reasonable = TRUE,
                 interval_type = "Approximate: log-normal", 
                 warnings = my_warnings,
                 other = list(cutoff = cutoff))
  
}
