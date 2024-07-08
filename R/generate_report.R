#' Generate Scientific Report using OpenAI API
#'
#' This function generates a scientific report based on a data summary using the OpenAI API.
#' @param data_summary A summary of the data.
#' @return A character string with the generated report.
#' @examples
#' generate_report(summary(iris))
#' @export
generate_report <- function(data_summary) {
  library(httr)
  api_key <- Sys.getenv("OPENAI_API_KEY")
  
  if (api_key == "") {
    stop("API key not found. Please set the OPENAI_API_KEY environment variable.")
  }
  
  prompt <- paste("Generate a detailed scientific report for the following data summary:\n", data_summary)
  
  response <- POST(
    url = "https://api.openai.com/v1/engines/davinci-codex/completions",
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = list(
      prompt = prompt,
      max_tokens = 300
    ),
    encode = "json"
  )
  
  content <- content(response, "parsed")
  report <- content$choices[[1]]$text
  
  return(report)
}
