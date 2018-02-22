## Name: collect_scjohn_fuse_data.R
## Author: Katherine A. Phillips
## Date Created: April 2015
## Purpose: Collect and parse HTML data for SC Johnson's Ingredient/Use database.


library(XML)

##----------------------------------------------------------------------------##
## This finds all the links on the sc johnson webpage, don't really need this ##
## now since I saved the hrefs to a file                                      ##
##----------------------------------------------------------------------------##

## Base URL
scjurl <- "http://www.whatsinsidescjohnson.com/en-us/ingredients.aspx"

## Parse the HTML from the URL in as way to make it human-searchable
doc <- htmlParse(scjurl)

## Get all of the links out of the parsed HTML
links <- xpathSApply(doc,"//a/@href")

## Release the URL so you're not holding up the servers
free(doc)

## Save the links as an array
links <- as.vector(links)





##----------------------------------------------------------------------------##
## This loop downloads all the URLs into the pwd. Only run IFF you do not     ##
## have the HTML files saved -- this loop takes FOREVER!                      ##
##----------------------------------------------------------------------------##

## Root URL for downloading HTML files
scjurl <- "http://www.whatsinsidescjohnson.com"

## Store all children URLs as vector
urls <- readLines("scjohnson_indredients_hrefs.txt",warn=FALSE)

## Loop over all URLs -- I know, you're not supposed to loop in R, but it's so easy!
for (i in 1:length(urls)){

    ## Make full URL
    ChemURL <- paste(scjurl,urls[i],sep='')

    ## Create a HTML file name
    ChemFileName <- gsub('-','_',gsub("aspx","html",basename(ChemURL)))

    ## Download the file
    ChemFile <- download.file(url=ChemURL,destfile=ChemFileName)

    ## Don't overload the server
    Sys.sleep(10)
}





##----------------------------------------------------------------------------##
## This loop uses the downloaded HTML files to create a data frame, which     ##
## contains chemical names, uses, and the corresponding file                  ##
##----------------------------------------------------------------------------##

## Root URL for downloading HTML files
scjurl <- "http://www.whatsinsidescjohnson.com"

## Store all children URLs as vector
urls <- readLines("scjohnson_indredients_hrefs.txt",warn=FALSE)

## Initialize empty data frame
SCJChem <- data.frame()

## Loop over all the URLs
for (i in 1:length(urls)){

    ## Create the HTML file name
    ChemFileName <- gsub('-','_',gsub("aspx","html",basename(urls[i])))

    ## Parse chemical HTML file
    ChemDoc <- xmlParse(ChemFileName,isHTML=TRUE)

    ## Extract chemical name from HTML file
    ChemName <- xmlValue(xpathSApply(ChemDoc,"//h3")[[3]])

    ## Extract chemical descriptions from HTML file
    ChemUse <- xmlValue(xpathSApply(ChemDoc,"//p")[[2]])
    ChemUse <- gsub(","," ",ChemUse)

    ## Make full URL
    ChemURL <- paste(scjurl,urls[i],sep='')

    ## Store name, description, and file location in data frame
    SCJChem <- rbind(SCJChem,t(c(ChemName,ChemUse,ChemURL)))
}

## Rename data frame columns
colnames(SCJChem)[1] <- "ChemicalName"
colnames(SCJChem)[2] <- "UseCategory"
colnames(SCJChem)[3] <- "File"

## Save information to csv file
write.csv(SCJChem,"SCJohnsonChemicalIngredients_RAW.csv",quote=FALSE,row.names=FALSE,col.names=TRUE)
