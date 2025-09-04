# R script to scrape RMA, BOB, TBL website to extract current exchange rate 
# for BTN against USD, AUD and SGD and 12 other rates (as on 04/09/2023)


### revised on 04 September 2025 based on 2023, 2024 versions

### revised on 16 September, 2023
# Added code for error handling HTTPS error, when website is down
# Created new main file (BTN.Exchange ... ) and scrapeBanks_2 files
# to run in parallel with the older cron job for safety


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


# call scripts to scrape the three websites
# pass argument (URL)
# receive value --> df per site

source("scrapeRMA.R")
rateRMA <- scrapeRMA()
rate <- rateRMA

rate <- cbind(rate, "Date (YMD)" = format(Sys.Date(), "%Y%m%d"))
# View(rate)


filename <- paste0("data/", format(Sys.time(), "%Y%m%d-%H%M%S"), ".csv")


write.csv(rate, filename, row.names = FALSE)
rm(list=ls())
gc()
cat("\014")
# q()