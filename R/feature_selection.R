fs_null <- function(train){
  
  names(train)
  
}


fs_boruta <- function(train, include_tentative = TRUE){
  require(Boruta)
  
  features_selected <- Boruta(Y ~ ., data = train, doTrace = 2)$finalDecision
  
  vector_include <- if(include_tentative){
    c("Confirmed", "Tentative")
  } else {
    c("Confirmed")
  }
  
  names(features_selected[features_selected %in% vector_include])
  
}

fs_rf <- function(train){
  require(randomForest)
  
  control <- rfeControl(functions=rfFuncs, method="cv", number=5)
  features_selected <- rfe(x = train[ , names(train) != "Y"],
                           y = train[ , names(train) == "Y"], 
                           sizes=1:ncol(train), 
                           rfeControl=control)
  
  predictors(features_selected)
}
