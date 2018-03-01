# Realizamos la particion del dataset en train y test.
library(caret)
# save(data, file = 'data/data.Rdata')
load('data/data.Rdata')
train_index <- createDataPartition(y=data$Y, p = 0.7, list = FALSE)
train <- data[train_index,]
test <- data[-train_index,]
save(train, file = 'data/train.Rdata')
save(test, file = 'data/test.Rdata')
