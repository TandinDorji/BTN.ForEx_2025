# Load required library
library(ggplot2)

# Set the data folder path
data_path <- "data"

# List all CSV files in the folder
files <- list.files(path = data_path, pattern = "\\.csv$", full.names = TRUE)

# Initialize an empty data frame
all_data <- data.frame()

# Loop through each file
for (file in files) {
    # Extract date from filename (assumes format: yyyymmdd-hhmmss.csv)
    fname <- basename(file)
    date_str <- substr(fname, 1, 8)
    date_parsed <- as.Date(date_str, format = "%Y%m%d")
    
    # Read the CSV file safely
    df <- tryCatch(read.csv(file, stringsAsFactors = FALSE), error = function(e) NULL)
    
    if (!is.null(df)) {
        # Add parsed date column
        df$date <- date_parsed
        
        # Convert target columns to numeric
        cols_to_convert <- c("Notes.Buy", "Notes.Sell", "TT.Buy", "TT.Sell")
        for (col in cols_to_convert) {
            if (col %in% names(df)) {
                df[[col]] <- as.numeric(as.character(df[[col]]))
            } else {
                df[[col]] <- NA  # Fill with NA if column is missing
            }
        }
        
        # Append to the main data frame
        all_data <- rbind(all_data, df)
    }
}

# Filter for CUR == "AUD"
aud_data <- subset(all_data, CUR == "AUD")

# Add average rate column
aud_data$Average.Rate <- rowMeans(aud_data[, 3:6], na.rm = TRUE)


# Plot line graph
ggplot(aud_data, aes(x = date)) +
    geom_line(aes(y = Notes.Buy, color = "Notes.Buy")) +
    geom_line(aes(y = Notes.Sell, color = "Notes.Sell")) +
    geom_line(aes(y = TT.Buy, color = "TT.Buy")) +
    geom_line(aes(y = TT.Sell, color = "TT.Sell")) +
    geom_line(aes(y = Average.Rate, color = "Average.Rate"), size = 1.1) +
    ylim(55, 60) +
    labs(title = "AUD Exchange Rates Over Time (BTN)",
         x = "Date",
         y = "Rate",
         color = "Metric") +
    theme_minimal()
