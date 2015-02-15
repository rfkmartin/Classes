complete <- function(directory, id = 1:332) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files
  
  ## 'id' is an integer vector indicating the monitor ID numbers
  ## to be used
  
  ## Return a data frame of the form:
  ## id nobs
  ## 1  117
  ## 2  1041
  ## ...
  ## where 'id' is the monitor ID number and 'nobs' is the
  ## number of complete cases

  output <- data.frame(id=numeric(),nobs=numeric())
  
  for (j in id) {
    filename <- paste0(sprintf("%03d",j),".csv")
    fullfilename <- paste0(directory,"/",filename)
    data = read.csv(file=fullfilename)
    data<-data[complete.cases(data),]
    output <- rbind(output,c(j,length(data[[1]])))
  }
  colnames(output) <- c("id","nobs")
  return(output)
}