#' Explain Data Analysis Results using OpenAI API
#'
#' This function explains the results of a data analysis using the OpenAI API.
#' @param data_analysis A summary of the data analysis results.
#' @return A character string with the explanation of the results.
#' @examples
#' explain_results("The analysis shows a strong correlation between variables X and Y.")
#' @export
explain_results <- function(data_analysis) {
  library(httr)
  api_key <- Sys.getenv("OPENAI_API_KEY")
  
  if (api_key == "") {
    stop("API key not found. Please set the OPENAI_API_KEY environment variable.")
  }
  
  prompt <- paste("Explain the following data analysis results in simple terms:\n", data_analysis)
  
  response <- POST(
    url = "https://api.openai.com/v1/engines/davinci-codex/completions",
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = list(
      prompt = prompt,
      max_tokens = 150
    ),
    encode = "json"
  )
  
  content <- content(response, "parsed")
  explanation <- content$choices[[1]]$text
  
  return(explanation)
}
