# Pesticide Analysis

# Load libraries 
library(tidyverse)

# Load tables
active_ingredients <- read_csv("active_ingredients.csv")
pesticide_ventura <- read_csv("pesticide_ventura.csv")

# Standardize text for matching (lowercase, strip whitespace)
active_ingredients <- active_ingredients |>
  mutate(active_ingredient = str_to_lower(str_trim(active_ingredient)))

pesticide_ventura <- pesticide_ventura |>
  mutate(active_ingredient = str_to_lower(str_trim(active_ingredient)))

# Pull products whose active ingredients appear in the harmful list
harmful_set <- active_ingredients |> pull(active_ingredient)

flagged_products <- pesticide_ventura |>
  filter(active_ingredient %in% harmful_set)

# View results
cat("Found", nrow(flagged_products), "records with harmful active ingredients.\n")
print(flagged_products)

# Export to CSV
write_csv(flagged_products, "flagged_pesticides_ventura.csv")
cat("Results saved to flagged_pesticides_ventura.csv\n")