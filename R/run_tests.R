run_tests <- function(fit_model, test, metric){
  
  vector_score_test <- map_dbl(fit_model$model_obj, ~run_test(., test, metric))
  
  fit_model$score_test <- vector_score_test
  
  fit_model

}

run_test <- function(fit_model, test, metric){
  metric(as.double(test$Y), as.double(predict.train(fit_model,test)))
}
