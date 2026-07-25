

## Loop through all files/species

# Set the path to the folder containing the evaluation text files
folder_path <- "~/Library/CloudStorage/OneDrive-TheUniversityofSydney(Staff)/Documents/biochallenge_segments/"

# List all .txt files in the folder (full paths included)
txt_files <- list.files(path = folder_path, pattern = "*.txt", full.names = TRUE)

# Create an empty data frame to store threshold results for each species
thresholds_df <- data.frame(
  Species = character(), 
  ScoreThreshold = character(), 
  FalsePositives = integer(), 
  TruePositives = integer(),
  Total = integer(), 
  stringsAsFactors = FALSE
)

# Loop through each evaluation file
for (file in txt_files) {
  # Read the tab-separated evaluation file into a data frame
  data <- read.table(file, sep = '\t', header = TRUE)
  
  # Extract the BirdNET score from the first 5 characters of the 'Begin.File' column
  data$Score <- substr(data$Begin.File, 1, 5)
  data$Score <- as.numeric(data$Score)  # Convert to numeric for modelling
  
  # Fit a logistic regression model: Eval (0 = FP, 1 = TP) ~ Score
  model <- glm(Eval ~ Score, family = "binomial", data = data)
  
  # Calculate the score threshold corresponding to a predicted probability of 0.9
  p <- 0.9
  score_threshold <- (log(p / (1 - p)) - model$coefficients[1]) / model$coefficients[2]
  
  # Extract species name from the file name by removing "_eval" and ".txt"
  plot_name <- gsub(".txt", "", basename(file))
  
  # Count false positives and true positives
  false_positives <- sum(data$Eval == 0)
  true_positives <- sum(data$Eval == 1)
  total_observations <- nrow(data)
  
  # Append the results to the thresholds data frame
  thresholds_df <- rbind(thresholds_df, data.frame(
    Species = plot_name, 
    ScoreThreshold = format(round(score_threshold, 3), nsmall = 3),
    FalsePositives = false_positives, 
    TruePositives = true_positives,
    Total = total_observations
  ))
}

# Write the final thresholds data frame to a CSV file
write.csv(thresholds_df, file = paste0(folder_path, "score_thresholds.csv"), row.names = FALSE)


#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

## Focus on one species - USEFUL IF CONFIDENCE THRESHOLDS ARE OUTSIDE THE 0-1 RANGE

# Load data
data <- read.table("~/Library/CloudStorage/OneDrive-TheUniversityofSydney(Staff)/Documents/biochallenge_segments/Australasian_Figbird_eval.txt", 
                   sep = '\t', header = TRUE)

# Extract the score from the "Begin.File" column
data$Score <- substr(data$Begin.File, 1, 5)
data$Score <- as.numeric(data$Score)

# Fit a logistic regression model
model <- glm(Eval ~ Score, family = "binomial", data = data)

# Plot the data and the logistic regression curve
prediction_values <- seq(0, 1, 0.01)
predictions <- predict(model, list(Score = prediction_values), type = 'response')

# Plot the data and the logistic regression curve
plot(Eval ~ Score, data = data, xlim = c(0, 1), pch = 16, col = rgb(0, 0, 0, 0.3),
     xlab = "Confidence Score",      # X-axis label
     ylab = "Probability of True Positives")  # Y-axis label

lines(predictions ~ prediction_values, lwd = 4, col = rgb(1, 0, 0, 0.5))

# Calculate the score threshold for p = 0.9
p <- 0.9
score_threshold <- (log(p/(1-p)) - model$coefficients[1]) / model$coefficients[2]
score_threshold

# Add lines at the score threshold *****CHANGE THIS FOR PREFERRED PROBABILITY (0.9) AND THRESHOLD*****
abline(h = 0.9, col = "blue", lty = 2)
abline(v = 0.08323467, col = "blue", lty = 3)





