# R script to scrape RMA, BOB, TBL website to extract current exchange rate 
# for BTN against USD, AUD and SGD and 12 other rates (as on 04/09/2023)
# and rate for Gold and Silver


### revised on 04 September 2025 based on 2023, 2024 versions


# load libraries, install if not available 
# if(!require(tidyverse)) install.packages("tidyverse")
if(!require(rvest)) {
    install.packages("rvest") 
    library(rvest)
}


if(!require(dplyr)) {
    install.packages("dplyr") 
    library(dplyr)
}


# call scripts to scrape RMA website for forex
source("scrapeRMAforex.R")
forex_df <- scrapeRMAforex()


# call scripts to scrape RMA website for gold and silver rate
source("ScrapeRMAGoldSilver.R")
goldsil_df <- ScrapeRMAGoldSilver()


# save files, 
# add 21600 seconds or 6 hours for BST in file name 
# as system time is in UTC
forex_filename <- paste0("data/", 
                         format(Sys.time() + 21600, "%Y%m%d-%H%M%S"), ".csv")
write.csv(forex_df, forex_filename, row.names = FALSE)


goldsil_filename <- paste0("data/goldsilver/", 
                           format(Sys.time() + 21600, "%Y%m%d-%H%M%S"), ".csv")
write.csv(goldsil_df, goldsil_filename, row.names = FALSE)


rm(list=ls())
gc()
cat("\014")

# q()
