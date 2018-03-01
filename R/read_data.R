library(tidyverse)
library(caret)
library(janitor)

data <- read_delim("data/tfm_web_map.txt", 
           "\t", escape_double = FALSE, trim_ws = TRUE) %>% 
  na.omit()

#Vamos a ver que cadenas de caracteres no se repiten con mucha frencuencia
data %>%
  dplyr::select_if(is_character)  %>%
  map(~ table(.)) 

data_clean <- data %>% 
  select(-V193, # Profesiones
         -V220, # Codigos postales
         -V223, # Tipo de coche
         -V215, # Marca del coche
         -V170,
         -i # Indices
         ) %>% 
  mutate(V183 = as.integer(V183 == "ESPA")) %>% 
  mutate_if(is_character, as.factor) %>% 
  model.matrix(~., data = .) %>% 
  as.data.frame() %>% 
  select(-`(Intercept)`) %>% 
  mutate(Y = factor(Y)) %>% 
  clean_names() %>% 
  rename(Y = y)

levels(data_clean$Y) <- c("no_buy", "buy")
  

set.seed(2017)
down_sampling <- downSample(x = select(data_clean, -Y),
                            y = data_clean$Y,
                            yname = "Y")

##############
save(down_sampling, file = 'data/data.Rdata')
train_index <- createDataPartition(y=down_sampling$Y, p = 0.7, list = FALSE)
train <- down_sampling[train_index,]
##### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
train <- base::sample(train, size = 50)
#####
test <- down_sampling[-train_index,]
save(train, file = 'data/train.Rdata')
save(test, file = 'data/test.Rdata')
