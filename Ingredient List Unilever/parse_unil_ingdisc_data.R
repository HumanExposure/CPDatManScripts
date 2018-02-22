## Name: collect_pg_ingdisc_urls.R
## Author: Katherine A. Phillips
## Date Created: July 2015
## Purpose: Parses HTML files downloaded from collect_pg_ingdisc_urls.R into a single.


library(RCurl)
library(XML)

setwd("C:/Users/kphillip/Documents/Unilever")

files <- list.files(path="Product_HTML/",pattern="*.html")
for (i in 1:length(files)){
    ipage <- htmlParse(paste("Product_HTML/",files[i],sep=""))
    itbl <- xpathApply(ipage,"//table[@class='ingredient-list']")[[1]]
    itbl <- readHTMLTable(itbl)
    if (is.null(itbl)) {next}
    itbl$Rank <- rownames(itbl)
    itbl$File <- files[i]
    if (i == 1){
        prdct_tbl <- itbl
    } else {
       prdct_tbl <- rbind(prdct_tbl,itbl)
    }
    if(i%%10==0){cat(".")}
}
cat("\n")

write.csv("UnileverIngredients.csv",row.names=FALSE)
