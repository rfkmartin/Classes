corr <- function(directory, threshold = 0) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files
  
  ## 'threshold' is a numeric vector of length 1 indicating the
  ## number of completely observed observations (on all
  ## variables) required to compute the correlation between
  ## nitrate and sulfate; the default is 0
  
  output <- vector()
  
  ## Return a numeric vector of correlations
  for (j in list.files(directory,"csv")) {
    ## filename <- paste0(sprintf("%03d",j),".csv")
    fullfilename <- paste0(directory,"/",j)
    data = read.csv(file=fullfilename)
    data<-data[complete.cases(data),]
    if (length(data[[1]])>threshold) {
      output <- c(output,cor(data[[2]],data[[3]]))
    }
  }
  return(output)
}