#' Suggest Further Analysis using OpenAI API
#'
#' This function suggests further analyses based on the provided data using the OpenAI API.
#' @param data A summary or description of the data.
#' @return A character string with suggestions for further analysis.
#' @examples
#' suggest_further_analysis("The data consists of measurements of various plant species.")
#' @export
suggest_further_analysis <- function(data) {
  library(httr)
  api_key <- Sys.getenv("OPENAI_API_KEY")
  
  if (api_key == "") {
    stop("API key not found. Please set the OPENAI_API_KEY environment variable.")
  }
  
  prompt <- paste("Suggest further analyses for the following data:\n", data)
  
  response <- POST(
    url = "https://api.openai.com/v1/engines/davinci-codex/completions",
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = list(
      prompt = prompt,
      max_tokens = 200
    ),
    encode = "json"
  )
  
  content <- content(response, "parsed")
  suggestions <- content$choices[[1]]$text
  
  return(suggestions)
}
