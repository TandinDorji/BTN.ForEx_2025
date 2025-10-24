if(!require(dplyr)) {
    install.packages("dplyr") 
    library(dplyr)
}

data_path <- "data"
# data_path <- "data/goldsilver"

# files <- list.files(path = data_path, pattern = "-.*\\.csv$", full.names = TRUE)
files <- list.files(path = data_path, pattern = "\\.csv$", full.names = TRUE)

down <- list()

for (file in files) {
    # file = files[31]
    df <- read.csv(file, stringsAsFactors = FALSE)
    
    # Check if the file is useful - see if it contains "RMA website is down" 
    contains_string <- any(grepl("RMA website is down", df, fixed = TRUE))
    if(contains_string) {
        down <- append(down, file)
    }
}

down
