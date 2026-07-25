# Load necessary libraries
library(dplyr)
library(lubridate)


# Read in the data files
spring_detections <- combined

#read.csv("BM_birds_output/combined_files/2025_03.csv")
threshold_table <- read.csv("C:/Users/ehad6905/OneDrive - The University of Sydney (Staff)/Documents/BM_kingfisher/confidence_thresholds/threshold_table_version_1.5.csv")

# Rename columns to ensure consistency
thresholds <- threshold_table %>%
  rename(`Common name` = AI_common)


# Join the datasets on species name to match each detection with its threshold
combined1 <- combined %>%
  left_join(thresholds, by = "Common name")

# Replace NA values in the threshold column with 0.1
combined1 <- combined1 %>%
  mutate(threshold_p_0.9 = ifelse(is.na(threshold_p_0.9), 0.9, threshold_p_0.9))

# Filter rows where confidence score meets or exceeds the species-specific threshold
filtered_detections <- combined1 %>%
  filter(Confidence >= threshold_p_0.9)


filtered_detections <- filtered_detections %>%
  select(-(threshold_p_0.8), -threshold_p_0.85, -threshold_p_0.9)

# Save the filtered dataset if needed
write.csv(filtered_detections, "C:/Users/ehad6905/OneDrive - The University of Sydney (Staff)/Documents/BM_birds_output/version_1.5/2024_04_v1.5.csv", row.names = FALSE)


filtered_detections <- filtered_detections %>%
  select(-FalsePositives, -TruePositives, -Total)

