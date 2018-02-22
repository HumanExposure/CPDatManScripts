## Name: collect_pg_ingdisc_urls.R
## Author: Katherine A. Phillips
## Date Created: July 2015
## Purpose: Uses provided URLS for Unilever's UK ingredient disclosures to download HTML
##          files.


library(RCurl)
library(XML)

setwd("C:/Users/kphillip/Documents/Unilever")

## Process url as HTML file
products_url <- getURL(url="http://pioti.unilever.com/pioti/en/p2.asp?selectCountry=UK&language=EN")

## Parses HTML file
upage <- htmlParse(products_url)

## Root link (for making links to download later)
htmlRoot <- "http://www.unilever.com/PIOTI/EN/"

## Get list of hyperrefs from products_url -- you need to look at the actual
## HTML source of products_url to know that "//form/div/a" is what you need,
## this will be different for every site you scrape
brands <- unlist(xpathApply(upage,"//form/div/a",xmlGetAttr,"href"))

## Build a list of brand names
brands <- unlist(lapply(brands,function(x) {gsub(" ","%20",x,fixed=T)}))

## Build a list of links for each brand name
blinks <- unlist(lapply(brands,function(x) {paste(htmlRoot,x,sep="")}))

## Loop over each brand
for (i in 1:length(blinks)){

    ## Parse each link to the brand web page
    ppage <- htmlParse(blinks[i])

    ## Get a list of products for each brand
    products <- unlist(xpathApply(ppage,"//form/div/ul/li/a",xmlGetAttr,"href"))

    ## Get product names
    prod_names <- unlist(xpathApply(ppage,"//producttext",xmlValue))
    prod_names <- gsub(" ","_",gsub("-","",gsub("&","and",tolower(prod_names),fixed=T),fixed=T),fixed=T)

    ## Build list of product names
    products <- unlist(lapply(products,function(x) {gsub(" ","%20",x,fixed=T)}))

    ## Build list of product links
    plinks <- unlist(lapply(products,function(x) {paste(htmlRoot,x,sep="")}))

    ## Output progress
    cat(paste(gsub("%20","_",tail(strsplit(brands[i],split="=")[[1]],n=1),fixed=T),"\n"))

    ## Download ingredient list HTML for each product
    for (j in 1:length(plinks)){
        if (paste(prod_names[j],".html",sep="") %in% list.files(path="Product_HTML/",pattern="*.html")) {next}
        cat(".")
        Sys.sleep(1)
        download.file(url=plinks[j],destfile = paste("Product_HTML/",prod_names[j],".html",sep=""),quiet=TRUE)
    }
    cat("\n")
}

## Write ingredient list to files
write.csv(prdct_tbl,"UnileverIngredients.csv",row.names=FALSE)
