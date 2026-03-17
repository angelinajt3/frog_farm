# GOAL = COMTRS summed by active ingredients by amph
# 17 March 2026
# L Gonzales & N Atkins
##################################################################################

# Clear environment
rm(list=ls())

# Load libraries 
library(tidyverse)
library(janitor) 
library(dplyr)

# Load tables 
pur_data <- read.table("udc23_56.txt", header = TRUE, sep = ",") # Ventura pesticide use report 2023
haz_data <- read.table("prod_env_hazard.dat", header = FALSE, col.names = "prod_haz",sep = ",") # productno with hazard code (last two digits)

# Clean data #####################################################################
# pur data - lbs_chm_used is lbs_ai - need productno as characters
pur_clean <- pur_data |> clean_names() |>  
  select(prodno, product_name, chem_code, chemname, lbs_chm_used, lbs_prd_used,
         grower_id, aer_gnd_ind, site_code, site_name, comtrs) |>
  mutate(prodno = trimws(as.character(prodno)))

# haz data - want two new columns, prodno and haz_code (last two digits)
haz_clean <- haz_data |> mutate(prodno = trimws(as.character(substr(prod_haz, 1, nchar(prod_haz) - 2))),
  haz_code = substr(prod_haz, nchar(prod_haz) - 1, nchar(prod_haz)))
haz_n0 <- haz_clean |> filter(haz_code == "N0") |> select(prodno) # 200 product numbers with N0

# Filter for harmful products ####################################################
# filter pur data using haz_n0 - for obs using products wth N0 only
pur_N0 <- pur_clean |> filter(prodno %in% haz_n0$prodno) # drops from 138722 to 1329 obs!

# Summarize and Export ###########################################################
# sum by COMTRS 
comtrs_sum <- pur_N0 |> group_by(comtrs) |>
  summarise(lbs_ai_amph = sum(lbs_chm_used, na.rm = TRUE)) # 104 observations with one blank - likely that massive one from data exploration
            
# save results!
write_csv(comtrs_sum, "comtrs_sum.csv")
