# R script to scrape ### RMA ### website to extract 
# current exchange rate for BTN against USD, AUD and SGD, etc.
# 12 rates as on 26/08/2023

# last revised on 04/09/2025 - changes
# url, code

# load libraries, install if not available 
### already in main file


# retrieve all data from url and load into "contents"
# using read_html function from rvest package
# enclosed within error handler in case website is down

scrapeRMA <- function(){
    url <- "https://www.rma.org.bt/exchangeRates/"
    
    contents <- tryCatch(
        read_html(url),
        error = function(e) {
            return(NA)
        }
    )
    
    if (is.na(contents)) {
        print("RMA website is down.")
    } else {
        tables <- contents %>% html_table(fill = TRUE)
        
        # store exchange rate into data frame and clean df
        xr <- data.frame(tables)
        
        # check table format before renaming columns
        check1 <- names(xr) == c("CURRENCY", "Notes", "Notes.1", "TT", "TT.1")
        check2 <- unlist(xr[1,], use.names = FALSE) == 
            c("CURRENCY","BUY","SELL","BUY","SELL")
        
        # if table format did not change, sum of checks 1,3 should be 10
        # else, raise error via log file to trigger code revision
        
        if(sum(check1, check2) == 10)
        {
            names(xr) <- c("Currency", "Notes.Buy", "Notes.Sell", 
                           "TT.Buy", "TT.Sell")
            xr <- xr[-1, ]
            rownames(xr) <- NULL
        } else {
            cat("Review scrape RMA code")
            xr <- NULL
        }
        
        
        # clean up currency name
        xr[, 1] <- gsub(pattern = "\n\\s+", replacement = "", x = xr[, 1])
        currency_code <- substr(xr[, 1], 1, 3)
        currency_name <- substr(xr[, 1], 4, 1000)
        
        names(xr)
        
        xr <- xr %>% 
            mutate("Currency" = currency_name, 
                   "CUR" = currency_code, "Source" = "RMA") %>% 
            select(1, 6, 2:5, 7)
        xr    # return df to main file
    }
}