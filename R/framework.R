# Source files -----------------------------------------------------------------
set.seed(2017)
library(tidyverse)
library(caret)
library(Metrics)
source_files <- c("feature_selection.R",
                  "list_model.R",
                  "run_models.R")
walk(source_files, ~ source(paste0("R/",.)))

# Read data  -------------------------------------------------------------------

load("data/train.Rdata")
load("data/test.Rdata")

# Feature selection ------------------------------------------------------------

#vector_fs <- list("boruta" = fs_boruta, 
#                  "rf" = fs_rf)

vector_fs <- list("nothing" = fs_null,
                  "boruta" = fs_boruta, 
                  "rf" = fs_rf)

# Preprocess -------------------------------------------------------------------

vector_pp <- list("No preprocess" = NULL, 
                  "Boxcox" = c("BoxCox"), 
                  "Normalize" = c("zv","center","scale"), 
                  "Pca" = c("zv","pca"))

# Model ------------------------------------------------------------------------
# http://topepo.github.io/caret/train-models-by-tag.html
vector_model <- list(
  list("gbm", NULL),
  list("glmboost", NULL),
  list("bayesglm", NULL),
  list("xgbTree",expand.grid(nrounds = c(100,300,500,1000,2000), 
                             max_depth = c(2,4,6) ,
                             eta = c(0.1,0.2),
                             gamma = c(0,1), 
                             colsample_bytree = 1, 
                             min_child_weight = 1, 
                             subsample = 1)),
  list("C5.0",NULL),
  list("rpart",NULL),
  list("rda",NULL)
)

# Create table -----------------------------------------------------------------

list_model <- create_list_model(train,
                                vector_fs,
                                vector_pp,
                                vector_model)

# Run models -------------------------------------------------------------------

metric <- "LogLoss"
fit_model <- run_models(train, list_model, vector_pp, metric)
