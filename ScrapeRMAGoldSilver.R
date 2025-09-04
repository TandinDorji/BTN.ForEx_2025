# R script to scrape ### RMA ### website to extract 
# price of gold and silver in Bhutan

# first created on 04/09/2025

# load libraries, install if not available 
### already in main file


# retrieve all data from url and load into "contents"
# using read_html function from rvest package
# enclosed within error handler in case website is down

ScrapeRMAGoldSilver <- function(){
    url <- "https://www.rma.org.bt/commemorativeItems/"
    
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
        
        # store rate into data frame and select required rows (gold, silver)
        xr <- data.frame(tables) %>% 
            filter(PARTICULARS %in% c("Gold", "Silver"))
        
        
        # clean up column name
        names(xr) <- c("Particular", "Unit", "Rate in BTN")
        
        xr <- xr %>% 
            mutate("Source" = "RMA", "Date (YMD)" = format(Sys.Date(), "%Y%m%d"))
        
        xr    # return df to main file
    }
}