## Name: collect_pg_ingdisc_urls.R
## Author: Katherine A. Phillips
## Date Created: Sep 2015
## Purpose: Uses provided link, which was a wildcard search displaying all results on a
##          single web page for P&G ingredient disclosures, to search for the URL to the
##          PDF ingredient disclosure on P&G's website. That URL is then written to a
##          Windows's BAT file that calls the wget.exe application. Once the BAT file is
##          completely written, it can be run on a Windows OS to download each PDF file
##          returned by the P&G ingredient disclosure search.

library(XML)
library(RCurl)

## Root webpage
pgroot <- "http://www.pgproductsafety.com"

## SDS search pages
pgpage <- "http://www.pgproductsafety.com/productsafety/search_results.php?submit=Search&searchtext=%2A&category=SDS&start=1&num=2400"
pgurl <- getURL(url = pgpage)
pghtml <- htmlParse(pgurl)

## Links to either look at SDS or add SDS to download queue
pglinks <- unlist(xpathApply(pghtml,"//div[@class='result-data']/p/a",xmlGetAttr,"href"))

## Get rid of "add to download queue" links
pglinks <- pglinks[which(grepl("queue",pglinks)==FALSE)]

## Construct working links
pglinks <- paste(pgroot,pglinks,sep="")
pglinks <- gsub(" ","%20",pglinks)

## Wget executable name
execname <- "wget.exe"

## Write batch file to download all links
Names <- paste(execname,unique(pglinks),sep=" ")
fileConn <- file("Download_All_ProcterGamble_Links.bat")
writeLines(Names,fileConn)
close(fileConn)
