
# combine_birdnet_files.R
# Eleanor Hadfield
# 2023-06-05

## INSTALL THESE PACKAGES IF NECESSARY BY REMOVING HASHTAG ON CODE BELOW
# install.packages("tidyverse")
# install.packages("fs")

## LOAD PACKAGES
library(tidyverse)
library(fs)

## SET THE PATH TO THE FOLDER CONTAINING THE FILES (THIS IS THE TRIP FOLDER)
file_path <- "/Users/eleanorhadfield/Desktop/birdnet/HR_2026_04"

## GET THE LIST OF FILES IN THE FOLDER RECURSIVELY
file_list <- dir_ls(path = file_path, recurse = TRUE)
print(file_list)  # Debugging

## PRINT THE NUMBER OF FILES
num_files <- length(file_list)
print(num_files)

## DEFINE YOUR FUNCTION TO BE APPLIED TO EACH FOLDER
read_filter_and_extract_info <- function(file_path) {
  print(file_path)  # Debugging
  df <- read_csv(file_path)
  
  ## EXTRACT TIME FROM FILE NAME
  time <- str_extract(string = file_path, pattern = "(?<=_)(\\d{2}-\\d{2})")
  
  ## CONVERT TIME FORMAT FROM "HH-MM" TO "HH:MM"
  time <- str_replace(time, "-", ":")
  
  ## EXTRACT DAY FROM FILE NAME
  day <- str_extract(string = file_path, pattern = "(?<=-)(\\d{2})(?=_)")
  
  ## EXTRACT MONTH FROM FILE NAME
  month <- str_extract(string = file_path, pattern = "(?<=-)(\\d{2})(?=-)")
  
  ## CONVERT MONTH FROM NUMBER TO NAME
  month <- month.abb[as.integer(month)]
  
  ## EXTRACT DATE FROM FILE NAME
  date <- str_extract(string = file_path, pattern = "\\d{4}-\\d{2}-\\d{2}")
  
  ## EXTRACT DEVICE NUMBER FROM FILE PATH
  dev_num <- str_extract(string = file_path, pattern = "(?<=/)(\\w+)(?=/(?:\\d{4}-\\d{2}-\\d{2})/)")
  
  ## EXTRACT SITE NUMBER FROM FILE PATH
  si_num <- str_extract(string = file_path, pattern = "(?<=/)(\\w+)(?=/(?:\\w+/\\d{4}-\\d{2}-\\d{2})/)")
  
  ## ASSIGN VALUES IN SITE_NUMBER TO GROUPS IN TREATMENT
  treatment <- case_when(
    si_num %in% c("B8_01", "B8_02", "B8_03", "B8_04", "B8_05", "B8_06") ~ "Burnt",
    si_num %in% c("UB8_01", "UB8_02", "UB8_03", "UB8_04", "UB8_05", "UB8_06", "UB8_07", "UB8_08", "UB8_09", "UB8_10", "UB8_11", "UB8_12") ~ "Unburnt",
    TRUE ~ NA_character_
  )
  
  ## ADD COLUMNS TO THE DATA FRAME
  df <- df %>% mutate(Hour = time, Day = day, Month = month, Date = date, Device_Number = dev_num, Treatment = treatment, Site_Number = si_num)
  
  df
}

## SPECIFY THE MAIN FOLDER PATH (THIS IS THE SAME AS THE TRIP FOLDER USED IN LINE 15)
trip_folder <- "/Users/eleanorhadfield/Desktop/birdnet/HR_2026_04"

## GET A LIST OF SUBFOLDERS WITHIN THE MAIN FOLDER
regions <- list.files(trip_folder, full.names = TRUE, recursive = TRUE)
print(regions)  # Debugging

## APPLY THE FUNCTION TO EACH SUBFOLDER USING PURRR'S MAP FUNCTION
results <- map(regions, read_filter_and_extract_info) %>%
  keep(~ nrow(.) > 0)

## COMBINE THE RESULTS INTO ONE DATA FRAME
combined <- bind_rows(results)

## SPECIFY THE OUTPUT CSV FILE PATH (WHERE DO YOU WANT TO SAVE THIS MASTER FILE?)
final_df <- "/Users/eleanorhadfield/Desktop/birdnet/HR_2026_04/HR_2026_04.csv"

## WRITE THE COMBINED FILE TO A CSV FILE
write_csv(combined, final_df)
