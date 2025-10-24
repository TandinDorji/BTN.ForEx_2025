# R script to read ForEx files in data folder and remove duplicate files
# because of running script/job twice daily in GitHub. 
# Leave only one file per day if both files are same;
# otherwise, rename files with date followed by index (1, 2).


# created on 26/09/2025

# load libraries, install if not available 

if(!require(dplyr)) {
    install.packages("dplyr") 
    library(dplyr)
}


# function to clean the files for
# (1) ForEx rates and (2) Gold and silver rates

clean_files <- function(data_path) {
    # List all CSV files
    files <- list.files(path = data_path, pattern = "-.*\\.csv$", full.names = TRUE)
    
    
    # Extract date and time from filenames
    file_info <- data.frame(
        path = files,
        name = basename(files),
        date = substr(basename(files), 1, 8),
        time = substr(basename(files), 10, 15),
        stringsAsFactors = FALSE
    )
    
    # Group by date
    grouped <- file_info %>% group_by(date)
    
    # Process each pair
    for (d in unique(grouped$date)) {
        pair <- grouped %>% filter(date == d) %>% arrange(time)
        file1 <- read.csv(pair$path[1], stringsAsFactors = FALSE)
        # file2 <- read.csv(pair$path[2], stringsAsFactors = FALSE)
        file2 <- tryCatch(
            read.csv(pair$path[2], stringsAsFactors = FALSE),
            error = function(e) NULL
        )
        
        
        if (identical(file1, file2)) {
            # Rename first file to yyyymmdd.csv
            new_name <- file.path(data_path, paste0(d, ".csv"))
            file.rename(pair$path[1], new_name)
            # Delete second file
            file.remove(pair$path[2])
        } else {
            # Rename both files to yyyymmdd_1.csv and yyyymmdd_2.csv
            new_name1 <- file.path(data_path, paste0(d, "_1.csv"))
            new_name2 <- file.path(data_path, paste0(d, "_2.csv"))
            file.rename(pair$path[1], new_name1)
            file.rename(pair$path[2], new_name2)
        }
    }
}


# clean ForEx files
clean_files("data")


# clean Gold and Silver rate files
clean_files("data/goldsilver")


rm(list=ls())
gc()
cat("\014")
