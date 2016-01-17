###############################################################
#                                                             #
#   (c) Victor Maus <vwmaus1@gmail.com>                       #
#       Institute for Geoinformatics (IFGI)                   #
#       University of Muenster (WWU), Germany                 #
#                                                             #
#       Earth System Science Center (CCST)                    #
#       National Institute for Space Research (INPE), Brazil  #
#                                                             #
#                                                             #
#   R Package dtwSat - 2016-16-01                             #
#                                                             #
###############################################################


#' @title Plotting temporal patterns 
#' @author Victor Maus, \email{vwmaus1@@gmail.com}
#' 
#' @description Method for plotting the temporal patterns 
#' 
#' @param x An \code{\link[dtwSat]{twdtw-class}} object or a list of 
#' \code{\link[zoo]{zoo}} objects
#' @param p.names A \link[base]{character} or \link[base]{numeric}
#' vector with the patterns identification. If not declared the function 
#' will plot the paths for all patterns 
#' @docType methods
#' 
#' @return A \link[ggplot2]{ggplot} object
#' 
#' @seealso 
#' \code{\link[dtwSat]{twdtw-class}}, 
#' \code{\link[dtwSat]{twdtw}}, 
#' \code{\link[dtwSat]{plotCostMatrix}},
#' \code{\link[dtwSat]{plotAlignment}},
#' \code{\link[dtwSat]{plotMatch}}, and
#' \code{\link[dtwSat]{plotGroup}}
#'  
#' @examples
#' 
#' weight.fun = logisticWeight(alpha=-0.1, beta=100, theta=0.5)
#' alig = twdtw(x=template, patterns=patterns.list, weight.fun = weight.fun, 
#'         normalize.patterns=TRUE, patterns.length=23, keep=TRUE)
#'        
#' gp1 = plotPatterns(alig)
#' gp1
#' 
#' gp2 = plotPatterns(patterns.list)
#' gp2
#' 
#' 
#' 
#' @export
plotPatterns = function(x, p.names){
  
  # Get temporal patterns
  if(is(x, "twdtw")){
    if(missing(p.names)) {
      p.names = getPatternNames(x)
    } else {
      p.names = getPatternNames(x, p.names)
    }
    x = lapply(p.names, function(p) getInternals(x)[[p]]$pattern)
  }
  
  if(missing(p.names))
    p.names = names(x)
  
  if(any(!unlist(lapply(x[p.names], is.zoo))))
    stop("patterns should be a list of zoo objects")
  
  # Shift dates 
  x = lapply(x[p.names], shiftDate, year=2005)
  
  # Build data.frame
  df.p = do.call("rbind", lapply(p.names, function(p)
    data.frame(Time=index(x[[p]]), x[[p]], Pattern=p)
  ))
  df.p = melt(df.p, id.vars=c("Time","Pattern"))
  
  # Plot temporal patterns
  gp = ggplot(df.p, aes_string(x="Time", y="value", colour="variable") ) + 
    geom_line() + 
    facet_wrap(~Pattern) + 
    scale_x_date(labels = date_format("%b"))
  
  gp
  
}
