# R script to read ForEx files in data folder and remove duplicate files
# because of running script/job twice daily in GitHub. 
# Leave only one file per day if both files are same;
# otherwise, rename files with date followed by index (1, 2).


# created on 26/09/2025

#*Revised on 24/10/2025
#*Revised script to accomodate the following scenarios:
#* If both files are bad (RMA website was down), remove them both.
#* If one file is bad, remove it and rename the other.

# load libraries, install if not available 

if(!require(dplyr)) {
    install.packages("dplyr") 
    library(dplyr)
}


# function to clean the files for
# (1) ForEx rates and (2) Gold and silver rates


clean_files <- function(data_path) {
    # List all new CSV files (with dash '-' in their names)
    # Rest are all cleaned up.
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
        
        # Read both files safely
        file1 <- tryCatch(read.csv(pair$path[1], stringsAsFactors = FALSE), error = function(e) NULL)
        file2 <- tryCatch(read.csv(pair$path[2], stringsAsFactors = FALSE), error = function(e) NULL)
        
        # Function to check for the test string - "RMA website is down"
        contains_test_string <- function(df) {
            if (is.null(df)) return(FALSE)
            any(grepl("RMA website is down", unlist(df), fixed = TRUE))
        }
        
        # Check both files
        file1_has_string <- contains_test_string(file1)
        file2_has_string <- contains_test_string(file2)
        
        # Handle cases based on presence of test string
        if (file1_has_string && file2_has_string) {
            # If both files are bad, add them to History and remove.
            
            # Append both filenames to History.txt
            write(
                paste(pair$path[1], pair$path[2], sep = "\n"),
                file = "History.txt",
                append = TRUE
            )
            # Delete both the files
            file.remove(pair$path[1])
            file.remove(pair$path[2])
        } else if (file1_has_string || file2_has_string) {
            # If one file is bad, delete it and rename the other one.
            # Delete the one with the test string
            if (file1_has_string) {
                file.remove(pair$path[1])
                # Rename file2 to yyyymmdd.csv
                new_name <- file.path(data_path, paste0(d, ".csv"))
                file.rename(pair$path[2], new_name)
            } else {
                file.remove(pair$path[2])
                # Rename file1 to yyyymmdd.csv
                new_name <- file.path(data_path, paste0(d, ".csv"))
                file.rename(pair$path[1], new_name)
            }
        } else {
            # Neither file has the test string — compare contents
            if (!is.null(file1) && !is.null(file2) && identical(file1, file2)) {
                # Both files are good and are identical
                # Rename and keep one (remove the other)
                new_name <- file.path(data_path, paste0(d, ".csv"))
                file.rename(pair$path[1], new_name)
                file.remove(pair$path[2])
            } else {
                # Else, rename both files and don't delete.
                new_name1 <- file.path(data_path, paste0(d, "_1.csv"))
                new_name2 <- file.path(data_path, paste0(d, "_2.csv"))
                file.rename(pair$path[1], new_name1)
                file.rename(pair$path[2], new_name2)
            }
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
