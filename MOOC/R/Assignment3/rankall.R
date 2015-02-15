rankall <- function(outcome, num="best") {
  ## Read outcome data
  oc <- read.csv("outcome-of-care-measures.csv",colClasses="character")
  valid_outcomes <- c("heart attack","heart failure","pneumonia")
  
  ## Check that state and outcome are valid
  states <- unique(oc$State)
  ## Alphabetize states
  states <- states[order(states)]
  
  if (!outcome %in% valid_outcomes) stop(paste('invalid outcome'))
  
  rank <- num
  if (num == "best") rank<-1
  
  ## For each state, find the hospital of the given rank
  output <- data.frame(hospital=character(),state=character())
  if (outcome == "heart attack") vect=c(2,7,11)
  if (outcome == "heart failure") vect=c(2,7,17)
  if (outcome == "pneumonia") vect=c(2,7,23)
  for (etat in states) {
    hospitals <- oc[oc$State==etat,vect]
    ## remove non-numeric values
    names(hospitals) <- c("name","state","ranker")
    ranks = as.numeric(hospitals$ranker)
    non_numeric <- !is.na(ranks)

    hospitals <- hospitals[non_numeric,]
    ordering <- order(as.numeric(hospitals$ranker),hospitals$name)
    ordered_hospitals = hospitals[ordering,]
    if (num == "worst") rank <- nrow(hospitals)
    if (rank > nrow(hospitals))
      output <- rbind(output,data.frame(hospital=NA,state=etat))
    else
      output <- rbind(output,data.frame(hospital=ordered_hospitals[rank,1],state=etat))
  }
  print(output)
}