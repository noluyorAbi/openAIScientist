#' @title Clean Markdown Headers
#' @description Cleans markdown content by removing leading whitespace before headers and bullet points,
#'              removing unnecessary '---' above and below headers, ensuring correctly formatted enumerated bullet points,
#'              and ensuring table rows do not have newline characters within cells.
#' @param file_path Character string representing the file path to the markdown file to be cleaned.
#' @return None. The function writes the cleaned markdown content back to the specified file.
clean_md_headers <- function(file_path) {
  lines <- readLines(file_path)
  
  # Remove leading whitespace before headers and bullet points
  cleaned_lines <- gsub("^\\s+(#)", "\\1", lines)
  cleaned_lines <- gsub("^\\s+(-)", "\\1", cleaned_lines)
  
  # Remove '---' above and below headers
  cleaned_lines <- gsub("\n---\n(#)", "\n\\1", cleaned_lines)
  cleaned_lines <- gsub("(#)\n---\n", "\\1\n", cleaned_lines)
  
  # Ensure enumerated bullet points are correctly formatted
  bullet_points_corrected <- gsub("^\\s*([0-9]+)\\.\\s+", "\\1. ", cleaned_lines)
  normal_bullet_points_corrected <- gsub("[-*]\\s+", "\n- ", bullet_points_corrected)
  
  # Ensure table rows do not have newline characters within cells
  table_corrected <- gsub("(\\|)\\s*\\n\\s*(\\|)", "\\1 \\2", normal_bullet_points_corrected)
  
  writeLines(table_corrected, file_path)
}

#' @title Create Markdown File
#' @description Creates a markdown file with the specified analysis content, cleans the headers, and appends additional text.
#' @param analysis Character string representing the content of the analysis to be written to the markdown file.
#' @param output_name Character string representing the base name of the output file and folder. Default is "Analysis".
#' @return None. The function writes the analysis content to a new markdown file.
create_md <- function(analysis, output_name = "Analysis") {
  time_stamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
  folder_name <- paste0(output_name, "_", time_stamp)
  dir.create(folder_name)
  
  file_path <- file.path(folder_name, paste0(output_name, ".md"))
  
  writeLines(analysis, file_path)
  clean_md_headers(file_path)
  
  # Append the specified text at the end of the file
  additional_text <- "\n\n\n---\n\n\n\n\nThis analysis was created with [openAIScientist](https://github.com/noluyorAbi/openaAIScientist).\n\n Made with \u2665 by [noluyorAbi](https://github.com/noluyorAbi) for FortStaSoft @ LMU Munich"
  cat(additional_text, file = file_path, append = TRUE)
}

#' @title Validate and Format Markdown
#' @description Validates and formats markdown content using OpenAI's API to ensure correct markdown syntax.
#' @param md_content Character string representing the markdown content to be validated and formatted.
#' @param api_key Character string representing the API key for accessing OpenAI's API.
#' @return Character string of the formatted markdown content if successful, NULL otherwise.
#' @importFrom httr POST content add_headers
validate_and_format_md <- function(md_content, api_key) {
  # Clean up any problematic characters before sending the prompt
  md_content <- gsub("[`*]", "", md_content)
  
  prompt <- paste(
    "This is a markdown file content. Validate and format it to ensure it is correct markdown syntax:\n\n",
    "Your output should JUST be the Formatted Markdown that is NOT IN A CODEBLOCK.",
    "Do not comment what you changed, I just want the formatted markdown.",
    "Remove EVERY image (.png, .jpg) or <center> Tags in the markdown.",
    "Check if the tables are valid markdown and centered, if not fix it.\n",
    "Check that the bold or italic texts have the correct number of *, else fix it.\n",
    "Make sure that the tables look like this:\n",
    "| Header1 |    Header2    |   Header3   |\n",
    "|:-------:|:-------------:|------------:|\n",
    "|  Cell1  |    Cell2      |       Cell3 |\n\n",
    "Check that the keywords and important parts are highlighted correctly.\n",
    md_content
  )
  
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
    formatted_md <- content$choices[[1]]$message$content
    return(formatted_md)
  } else {
    cat("Failed to validate and format the markdown file. No content returned from OpenAI API.\n")
    return(NULL)
  }
}

#' @title Clean Up Markdown Table
#' @description Cleans up the markdown table by removing lines containing specific problematic patterns.
#' @param md_content Character string representing the markdown content containing tables.
#' @return Character string of the cleaned markdown content.
clean_up_table <- function(md_content) {
  lines <- strsplit(md_content, "\n")[[1]]
  cleaned_lines <- lines
  
  for (i in 1:length(lines)) {
    if (grepl("Length:1000", lines[i]) && grepl("- \\|", lines[i])) {
      cleaned_lines <- cleaned_lines[-i]
    }
  }
  
  cleaned_md <- paste(cleaned_lines, collapse = "\n")
  return(cleaned_md)
}

#' Generate a Comprehensive Scientific Analysis
#'
#' This function generates a comprehensive scientific analysis in markdown format about the given dataset.
#'
#' @param data A data frame containing the dataset to analyze.
#' @param api_key Your OpenAI API key as a string.
#' @param output_name The name of the output markdown file.
#' @param additional_prompt Additional instructions for the OpenAI API.
#' @return The generated analysis as a string.
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   var1 = rnorm(100),
#'   var2 = rnorm(100),
#'   outcome = sample(c(0, 1), 100, replace = TRUE)
#' )
#' api_key <- "your_openai_api_key"
#' openAIScientist_generate_scientific_analysis(data, api_key, "Analysis")
#' }
#' @importFrom httr POST add_headers content
#' @importFrom utils capture.output
#' @export
openAIScientist_generate_scientific_analysis <- function(data, api_key, output_name = "Analysis", additional_prompt = "") {
  
  cat("Generating data summary...\n")
  
  # Create a data summary
  data_summary <- summary(data)
  data_description <- paste(capture.output(data_summary), collapse = "\n")
  
  # Check if API key is provided
  if (api_key == "") {
    stop("API key not found. Please set the OPENAI_API_KEY environment variable.")
  }
  
  # Clean up any problematic characters in the data description
  data_description <- gsub("[`*]", "", data_description)
  
  # Main prompt
  prompt <- paste(
    "Generate a comprehensive scientific analysis in markdown format about the dataset with the following summary statistics:\n\n```\n", 
    data_description, 
    "\n```\nThe analysis should provide a thorough and accurate description of the dataset, including key information, important insights, key observations, and detailed analysis. Use plain text in tables without any * or ` characters. Tables should always be centered using markdown syntax like this:\n\n",
    "| Header1 |    Header2    |   Header3   |\n",
    "|:-------:|:-------------:|------------:|\n",
    "|  Cell1  |    Cell2      |       Cell3 |\n\n",
    "The sections should be:\n",
    "1. **Title**: Generate a concise and descriptive title for the analysis. The title should follow the format: `# Subject`  Ensure that the title accurately reflects the content and main focus of the analysis. \n",
    "2. **Abstract**: Provide a brief summary of the analysis's objectives, methods, key findings, and conclusions.\n",
    "3. **Introduction**: Introduce the dataset, its origin, and its significance in the field of data analysis and sports analytics. Mention any relevant background information.\n",
    "4. **Data Summary**: Include a detailed summary of the dataset, with tables and descriptive statistics. Highlight any notable patterns, trends, and key observations in the data.\n",
    "5. **Attributes Explanation**: Explain every attribute and its data type in the dataset.\n",
    "6. **Data Analysis Explanation**: Explain the methods used for data analysis, including any statistical tests, visualizations, or machine learning algorithms applied. Provide detailed interpretations of the results.\n",
    "7. **Possible Interpretation**: Offer potential explanations or interpretations for the findings. Discuss any theories or hypotheses that might explain the observed patterns or results.\n",
    "8. **Suggested Further Analyses**: Suggest additional analyses or experiments that could be performed on the dataset to gain deeper insights.\n",
    "9. **Conclusion**: Summarize the key findings, key observations, and their implications. Discuss any limitations of the analysis and potential areas for future research.\n",
    "10. **Possible References**: List any references or sources cited in the analysis.\n",
    "Ensure that the markdown formatting is correct, the content is well-organized and scientifically rigorous, and there should be no '---' above or below headers as these break the markdown preview.",
    "Use ` for variable names and to structure the content better e.g `var1` or `var2`",
    "Do not use bold, italic or back quotes in Tables but",
    "DO USE bold, italic and backquotes in the rest of the markdown for better structure",
    "Highlight important parts and keywords",
    "Do not insert any .png or html tags as these are not wanted in the .md"
  )
  
  # Add the additional prompt if provided
  if (additional_prompt != "") {
    prompt <- paste(prompt, "\n\nAdditional instructions:\n", additional_prompt)
  }
  
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
  
  # Token price calculator for initial call
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
  
  if (!is.null(content$choices)) {
    analysis <- content$choices[[1]]$message$content
    cat("Validating and formatting markdown...\n")
    validated_analysis <- validate_and_format_md(analysis, api_key)  # Validate and format the markdown content
    
    # Token price calculator for validation call
    response <- POST(
      url = "https://api.openai.com/v1/chat/completions",
      add_headers(Authorization = paste("Bearer", api_key), 'Content-Type' = 'application/json'),
      body = list(
        model = "gpt-4o",
        messages = list(list(role = "user", content = validated_analysis))
      ),
      encode = "json"
    )
    validation_content <- content(response, "parsed")
    validation_usage <- validation_content$usage
    if (!is.null(validation_usage)) {
      total_tokens <- validation_usage$total_tokens
      total_input_tokens <- validation_usage$prompt_tokens
      total_output_tokens <- validation_usage$completion_tokens
      
      validation_total_cost <- (total_input_tokens * price_per_input_token) + (total_output_tokens * price_per_output_token)
      cat("Validation call - Total tokens used:", total_tokens, "\n")
      cat("Validation call - Total cost (USD):", validation_total_cost, "\n")
      
      total_cost <- total_cost + validation_total_cost
      cat("Total cost (USD) for both calls:", total_cost, "\n")
    } else {
      cat("Validation call - Token usage information not available.\n")
    }
    
    validated_analysis <- clean_up_table(validated_analysis)  # Clean up the table
    if (!is.null(validated_analysis)) {
      cat("Creating markdown file...\n")
      create_md(validated_analysis, output_name)  # Call create_md function to save the validated analysis as .md file
      cat(paste("Analysis generation complete. Markdown file:", "\"",output_name,"\"",  "created and validated.\n"))
    } else {
      cat("Failed to validate the analysis.\n")
    }
  } else {
    analysis <- NULL
    cat("Failed to generate analysis. No content returned from OpenAI API.\n")
  }
  
  return(analysis)
}