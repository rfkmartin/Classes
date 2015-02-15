rankhospital <- function(state, outcome, rank) {
  ## Read outcome data
  oc <- read.csv("outcome-of-care-measures.csv",colClasses="character")
  valid_outcomes <- c("heart attack","heart failure","pneumonia")
  
  ## Check that state and outcome are valid
  states <- unique(oc$State)
  if (!state %in% states) stop(paste('invalid state'))
  
  if (!outcome %in% valid_outcomes) stop(paste('invalid outcome'))
  
  if (rank == "best") rank<-1
  
  ## Return hospital name in that state with given rank
  ## 30-day death rate
  if (outcome == "heart attack") vect=c(2,7,11)
  if (outcome == "heart failure") vect=c(2,7,17)
  if (outcome == "pneumonia") vect=c(2,7,23)
  hospitals <- oc[oc$State==state,vect]
  ## remove non-numeric values
  names(hospitals) <- c("name","state","ranker")
  sapply(hospitals,class)
  ranks = as.numeric(hospitals$ranker)
  non_numeric <- !is.na(ranks)
  
  hospitals <- hospitals[non_numeric,]
  ordering <- order(as.numeric(hospitals$ranker),hospitals$name)
  ordered_hospitals = hospitals[ordering,]
  if (rank == "worst") rank <- nrow(hospitals)
  if (rank > nrow(hospitals))
    print(NA)
  else
    print(ordered_hospitals[rank,1])
}