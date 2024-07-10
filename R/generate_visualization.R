#' Generate a Visualization Recommendation and ggplot Code in RMarkdown
#'
#' This function generates a visualization recommendation and the corresponding ggplot code
#' for the given dataset using OpenAI's API. The generated R code with the ggplot is saved in a folder as an .Rmd file.
#'
#' @param data A data frame containing the dataset to analyze.
#' @param api_key Your OpenAI API key as a string.
#' @param output_name The name of the output file for the R code with ggplot.
#' @param additional_prompt Additional instructions for the OpenAI API.
#' @return The generated R code as a string.
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   var1 = rnorm(100),
#'   var2 = rnorm(100),
#'   outcome = sample(c(0, 1), 100, replace = TRUE)
#' )
#' api_key <- "your_openai_api_key"
#' openAIScientist_generate_visualization_rmd(data, api_key, "Visualization")
#' }
#' @importFrom httr POST add_headers content
#' @importFrom utils capture.output
#' @export
openAIScientist_generate_visualization_rmd <- function(data, api_key, output_name = "Visualization", additional_prompt = "") {
  
  cat("Generating data summary...\n")
  
  # Create a data summary
  data_summary <- summary(data)
  data_description <- paste(capture.output(data_summary), collapse = "\n")
  
  # Check if API key is provided
  if (api_key == "") {
    stop("API key not found. Please provide a valid OpenAI API key.")
  }
  
  # Clean up any problematic characters in the data description
  data_description <- gsub("[`*]", "", data_description)
  
  # Construct the prompt
  prompt <- paste(
    "You are provided with the following dataset summary: We are working in R \n\n", 
    data_description,
    "\n\nYour tasks are enlisted below finish all of them one after another \n",
    "- Explain what you are doing ",
    "- Write your R code in Codeblocks with ```r ",
    "- The data is created in the variable `dataset`. Reference it in your code. THIS IS VERY important. DO NOT OVERWRITE THE `dataset` variable (1:1).",
    "- The data is created in the variable `dataset`. Reference it in your code. THIS IS VERY important. DO NOT OVERWRITE THE `dataset` variable (1:1).",
    "- Analyze the data you and write a explenation about it ",
    "- Now create plots with ggplot2 fitting to the analysiation you did before. Describe the plot and why you chose it.\n",
    "- Structure your Response well with # Headers \n",
    "- Write an if statement at the beginning to check if all the needed library is already installed and if not, install it.\n",
    "- Always use the variable names, never use abbreviations.",
    "- Try to ALWAYS cover all variables and correlations in a plot",
    "- For every Plot write a Description and explenation on why this plot fits to the data",
    "- Write an analysis of the data at the beginning",
    "- Do not use grid.arrange",
    "- Follow best practices while using colors for data visualization:\n",
    "  * Use Qualitative palettes for categorical data.\n",
    "  * Use Sequential palettes for numerical data with order.\n",
    "  * Use Diverging palettes for numerical data with a meaningful midpoint.\n",
    "  * Leverage the meaningfulness of color.\n",
    "  * Avoid unnecessary usage of color.\n",
    "  * Be consistent with color across charts.\n",
    "  * Try to not use bright neon colors\n",
    "Think about using: scatter plots, line charts, box plots, heatmaps, bar charts, pie charts, histograms, area charts or barplots depending on the best usecase",
    "Every attribute that can be plotted should be plotted",
    
    additional_prompt,
    "The data is created in the variable `dataset`. Reference it in your code. THIS IS VERY important. DO NOT OVERWRITE THE `dataset` variable (1:1).",
    "Reference the dataset like this:\n",
    "data <- dataset"
  )
  
  cat("Sending request to OpenAI API (this might take a while)...\n")
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", api_key), 'Content-Type' = 'application/json'),
    body = list(
      model = "gpt-4o",
      messages = list(list(role = "user", content = prompt))
    ),
    encode = "json"
  )
  
  content <- content(response, "parsed")
  
  if (!is.null(content$choices)) {
    r_code <- content$choices[[1]]$message$content
    
    # Replace ```r and ```R with ```{r}
    rmd_code <- gsub("```[rR]", "```{r, message=FALSE}", r_code)
    
    # Ensure there is a blank space after each code block
    rmd_code <- gsub("```\\{r, message=FALSE\\}\\n(.+?)\\n```", "```{r, message=FALSE}\\n\\1\\n```\n", rmd_code, perl = TRUE)
    
    # Create a folder for the output RMarkdown file
    time_stamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
    folder_name <- paste0(output_name, "_", time_stamp)
    dir.create(folder_name)
    
    file_path <- file.path(folder_name, paste0(output_name, ".Rmd"))
    
    # Write the header and dataset to the RMarkdown file
    rmd_header <- c(
      "---",
      "output:",
      "  html_document:",
      "    code_folding: hide",
      "---",
      "",
      "# Dataset",
      "```{r, message=FALSE}",
      "dataset <- ", deparse(data),
      "```",
      ""
    )
    
    # Save the RMarkdown code
    writeLines(c(rmd_header, rmd_code), file_path)
    cat(paste("RMarkdown file for visualization saved in:", file_path, "\n"))
    
    # Append additional text at the end of the file
    additional_text <- "\n\n\n---\n\n\n\n\nThis analysis was created with [openAIScientist](https://github.com/noluyorAbi/openaAIScientist).\n\n Made with \u2665 by [noluyorAbi](https://github.com/noluyorAbi) for FortStaSoft @ LMU Munich"
    cat(additional_text, file = file_path, append = TRUE)
    
    # Token usage and cost calculation
    usage <- content$usage
    if (!is.null(usage)) {
      total_tokens <- usage$total_tokens
      total_input_tokens <- usage$prompt_tokens
      total_output_tokens <- usage$completion_tokens
      
      price_per_input_token <- 5.00 / 1e6  # $5 per 1M input tokens
      price_per_output_token <- 15.00 / 1e6  # $15 per 1M output tokens
      
      total_cost <- (total_input_tokens * price_per_input_token) + (total_output_tokens * price_per_output_token)
      cat("Initial call - Total tokens used:", total_tokens, "\n")
      cat("Initial call - Total cost (USD):", total_cost, "\n")
    } else {
      cat("Initial call - Token usage information not available.\n")
    }
    
    return(rmd_code)
  } else {
    cat("Failed to generate visualization. No content returned from OpenAI API.\n")
    return(NULL)
  }
}
