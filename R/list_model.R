create_list_model <- function(train, vector_fs = NULL, vector_pp = NULL, 
                              vector_model = NULL){
  selected_variables <- map(vector_fs, ~ .(train))
  cross3(selected_variables,vector_pp,vector_model)
}
