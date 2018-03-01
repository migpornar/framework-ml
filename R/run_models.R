run_models <- function(train, list_model, vector_pp, metric){
  
  fit_model <- map(list_model, ~run_model(train , .[[1]], .[[2]], 
                             .[[3]][[1]] , .[[3]][[2]],
                             metric))
  fit_model_df <- enframe(fit_model) %>% 
    select(model_obj = value) %>%  
    mutate(
      model = map_chr(model_obj, ~pluck(.,"method")),
      fs = rep(names(vector_fs), nrow(.) / length(vector_fs)),
      preprocess = rep(names(vector_pp), each = nrow(.) / length(vector_pp)),
      score_train = map_dbl(model_obj,~min(pluck(pluck(.,"results"),metric)))
    )
  
}

run_model <- function(train, fs, pp, model, params, metric){
  
  print(paste0("Running model ", model))
  
  control <- trainControl(method = "cv", 
                          number = 5,
                          classProbs = TRUE, 
                          summaryFunction = LogLosSummary)
  
  generated_formula <- create_formula(fs)
  
  train(
    form = generated_formula,
    data = train,
    method = model,
    preProcess = pp,
    metric = metric,
    trControl = control,
    tuneGrid = params,
    maximize = !(metric == "LogLoss")
  )
  
}

create_formula <- function(fs = '.'){
  
  as.formula(paste("Y", paste(sprintf("`%s`", fs), collapse=" + "), sep=" ~ "))
  
}

LogLosSummary <- function (data, lev = NULL, model = NULL) {
  LogLos <- function(actual, pred, eps = 1e-15) {
    stopifnot(all(dim(actual) == dim(pred)))
    pred[pred < eps] <- eps
    pred[pred > 1 - eps] <- 1 - eps
    -sum(actual * log(pred)) / nrow(pred) 
  }
  if (is.character(data$obs)) data$obs <- factor(data$obs, levels = lev)
  pred <- data[, "pred"]
  obs <- data[, "obs"]
  isNA <- is.na(pred)
  pred <- pred[!isNA]
  obs <- obs[!isNA]
  data <- data[!isNA, ]
  cls <- levels(obs)
  
  if (length(obs) + length(pred) == 0) {
    out <- rep(NA, 2)
  } else {
    pred <- factor(pred, levels = levels(obs))
    require("e1071")
    out <- unlist(e1071::classAgreement(table(obs, pred)))[c("diag",                                                                                                                                                             "kappa")]
    
    probs <- data[, cls]
    actual <- model.matrix(~ obs - 1)
    out2 <- LogLos(actual = actual, pred = probs)
  }
  out <- c(out, out2)
  names(out) <- c("Accuracy", "Kappa", "LogLoss")
  
  if (any(is.nan(out))) out[is.nan(out)] <- NA 
  
  out
}
