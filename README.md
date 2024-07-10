# openAIScientist 🧪🔬

`openAIScientist` is an R package that generates comprehensive scientific analysis using OpenAI's API. The analysis is output in markdown format, making it easy to integrate into various documentation workflows.

`openAIScientist` was designed to provide users with a quick overview and analysis of their datasets, helping them to understand and interpret their data more efficiently.

<div align="center">
  <img src="https://hits.sh/github.com/noluyorAbi/openaAIScientist.svg?style=for-the-badge&label=TOTAL%20VIEWS&labelColor=000000&logo=r" style="margin-bottom: 10px; margin-top:10px" />
</div>

<div align="center">
  <img src="https://github.com/noluyorAbi/openAIScientist/actions/workflows/R-CMD-check.yml/badge.svg" style="margin-bottom: 10px;" />
</div>

## Table of Contents

- [Installation](#installation-)
- [Other Dependencies](#other-dependencies-)
- [Usage](#usage-)
  - [Function Arguments](#function-arguments-)
  - [Example](#example-)
- [Setting Up Your API Key](#setting-up-your-api-key-)
  - [Step-by-Step Instructions](#step-by-step-instructions-)
  - [Note on API Key Usage](#note-on-api-key-usage-)
- [Documentation](#documentation-)
- [Disclaimer](#disclaimer-)
- [Contributing](#contributing-)
- [License](#license-)

## Installation 💻

First, install the package along with its dependencies if you haven't already:

```r
library(devtools)
install_github("noluyorAbi/openaAIScientist")
```

## Other Dependencies 📦

The `openAIScientist` package relies on the following R packages, which will be installed automatically:

- `httr`: For HTTP requests.
- `utils`: For utility functions like capturing output.
- `readr`: For reading and writing data.

## Usage 🚀

To use the `openAIScientist` package, follow these steps:

1. Load the package.
2. Load your API key from `.Renviron`.
3. Use the `openAIScientist_generate_scientific_analysis` or `openAIScientist_generate_visualization_rmd` function to generate the analysis.

### Function Arguments 📊

#### `openAIScientist_generate_scientific_analysis`

- `data` (mandatory): A data frame containing the dataset to analyze.
- `api_key` (mandatory): Your OpenAI API key as a string.
- `output_name` (optional): The name of the output markdown file (default is "Analysis").
- `additional_prompt` (optional): Additional instructions for the OpenAI API.

#### `openAIScientist_generate_visualization_rmd`

- `data` (mandatory): A data frame containing the dataset to analyze.
- `api_key` (mandatory): Your OpenAI API key as a string.
- `output_name` (optional): The name of the output RMarkdown file (default is "Visualization").
- `additional_prompt` (optional): Additional instructions for the OpenAI API.

### Example 📝

```r
# Load the package
library(openAIScientist)

# Load environment variables from the .Renviron file
readRenviron(".Renviron")

# Example data
data <- data.frame(
  var1 = rnorm(100),
  var2 = rnorm(100),
  outcome = sample(c(0, 1), 100, replace = TRUE)
)

# Retrieve the API key from environment variables
api_key <- Sys.getenv("OPENAI_API_KEY")

# Generate scientific analysis
analysis <- openAIScientist_generate_scientific_analysis(data, api_key, "Analysis")

# Generate scientific analysis with additional prompt
analysis <- openAIScientist_generate_scientific_analysis(data, api_key, "Analysis-ADDITIONAL-PROMPT","Write the analysis in German")

# Generate visualization RMarkdown
visualization <- openAIScientist_generate_visualization_rmd(data, api_key, "Visualization")

# Generate visualization RMarkdown with additional prompt
visualization <- openAIScientist_generate_visualization_rmd(data, api_key, "Visualization-ADDITIONAL-PROMPT", "make the visualizations for red-green colorblind")

```

## Setting Up Your API Key 🔑

To securely store and load your OpenAI API key, you should use the `.Renviron` file. This file allows you to set environment variables that R can access.

### Step-by-Step Instructions 📝

1. **Create/Edit `.Renviron` File:**

   - Open your `.Renviron` file. If it doesn't exist, create it in your home directory or in the root of your project folder.
   - Add your OpenAI API key in the following format:
   
     ```plaintext
     OPENAI_API_KEY=your_openai_api_key
     ```

2. **Save and Reload Environment Variables:**

   - Save the `.Renviron` file.
   - In R, use the following command to reload the environment variables:
   
     ```r
     readRenviron("~/.Renviron")
     ```

3. **Access the API Key in Your R Script:**

   - Retrieve the API key using `Sys.getenv` as shown in the usage example above.
   
     ```r
     api_key <- Sys.getenv("OPENAI_API_KEY")
     ```

### Note on API Key Usage ℹ️

While you can directly paste your API key as an argument in the `generate_scientific_analysis` function, it is considered bad practice and results in “smelly” code. Using environment variables via `.Renviron` is a more secure and clean approach.

#### Example of "Smelly" Code ❌

```r
# Directly pasting the API key as an argument (not recommended)
analysis <- openAIScientist_generate_scientific_analysis(data, "your_openai_api_key", "Analysis")
```

Using environment variables as demonstrated in the previous examples is the recommended approach.

## Documentation 📖

For detailed documentation, please refer to the function documentation generated by Roxygen2. You can access the documentation within R:

```r
?openAIScientist_generate_scientific_analysis
?openAIScientist_generate_visualization_rmd
```

## Disclaimer ⚠️

The analysis is created with GPT-4, a very powerful and fast AI. However, there can still be inaccuracies and formatting issues as AIs can be unpredictable sometimes. For formatting issues, try reanalyzing the dataset.

## Contributing 🤝

If you find any issues or have suggestions for improvements, please create an issue or a pull request on GitHub.

## License 📜

This package is licensed under the GPL-3 License.

---
Made with ♥ by [noluyorAbi](https://github.com/noluyorAbi) for FortStaSoft @ LMU Munich, July 2024.

