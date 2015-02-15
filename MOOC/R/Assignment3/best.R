best <- function(state, outcome) {
  ## Read outcome data
  oc <- read.csv("outcome-of-care-measures.csv",colClasses="character")
  valid_outcomes <- c("heart attack","heart failure","pneumonia")

  ## Check that state and outcome are valid
  states <- unique(oc$State)
  if (!state %in% states) stop(paste('invalid state'))

  if (!outcome %in% valid_outcomes) stop(paste('invalid outcome'))

  ## Return hospital name in that state with lowest 30-day death
  ## rate
  if (outcome == "heart attack") vect=c(2,7,11)
  if (outcome == "heart failure") vect=c(2,7,17)
  if (outcome == "pneumonia") vect=c(2,7,23)
  hospitals <- oc[oc$State==state,vect]
  names(hospitals) <- c("name","state","ranker")
  ordering <- order(as.numeric(hospitals$ranker))
  ordered_hospitals = hospitals[ordering,]
  print(ordered_hospitals[1,1])
}