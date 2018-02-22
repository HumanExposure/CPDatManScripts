## Name: collect_method_fuse_data.R
## Author: Katherine A. Phillips
## Date Created: March 2015
## Purpose: Collects and parses HTML files for Method's ingredient disclosures and uses.

library(stringr)
library(XML)

##----------------------------------------------------------------------------##
## This finds all the links on the Method webpage, don't really need this ##
## now since I saved the hrefs to a file                                      ##
##----------------------------------------------------------------------------##

## URL to page listing all Method products
method_link <- "http://methodhome.com/products/"

## Parse the HTML on the page
method_page <- htmlParse(method_link)

## Get all the links on the page
method_links <- xpathSApply(method_page,"//a/@href")
method_links <- unique(method_links)

## Stop using the page
free(method_page)

## Convert the HTML object to a vector
method_links <- as.vector(method_links)

## Open a file for writing
method_file <- file("method_links.txt")

## Write each link to a line in the file
writeLines(method_links,method_file)

## Close the file
close(method_file)





##----------------------------------------------------------------------------##
## This loop downloads all the URLs into the pwd. Only run IFF you do not     ##
## have the HTML files saved -- this loop takes FOREVER!                      ##
##----------------------------------------------------------------------------##

## Store all children URLs as vector
urls <- readLines("method_links.txt",warn=FALSE)

## Loop over all URLs
for (i in 1:length(urls)){

    ## Make full URL
    ChemURL <- urls[i]

    ## Create a HTML file name
    ChemFileName <- paste(gsub("-","_",
                         gsub(" ","",tail(
                         strsplit(ChemURL,split="[/]")[[1]],n=1))),
                         ".html",sep="")

    ## Download the file
    ChemFile <- download.file(url=ChemURL,destfile=ChemFileName)

    ## Don't overload the server
    Sys.sleep(10)
}





##----------------------------------------------------------------------------##
## This loop uses the downloaded HTML files to create a data frame, which     ##
## contains chemical names, uses, and the corresponding file                  ##
##----------------------------------------------------------------------------##

## Store all children URLs as vector
urls <- readLines("method_links.txt",warn=FALSE)
product_list <- list()

## Loop over all the URLs
for (i in 1:length(urls)){

    ## Make full URL
    ChemURL <- urls[i]

    ## Create a HTML file name
    ChemFileName <- paste(gsub("-","_",
                         gsub(" ","",tail(
                         strsplit(ChemURL,split="[/]")[[1]],n=1))),
                         ".html",sep="")

    ## Check that there is a table in the HTML`
    N_tables <- length(readHTMLTable(ChemFileName))

    ## Cycle loop if there is no table
    if (N_tables <= 0) {next}

    ## Pull ingredient/use table from file
    ChemTable <- as.data.frame(readHTMLTable(ChemFileName,which=1,header=TRUE))

    ## Keep the basename of the file for product name
    ChemTable$ChemFile <- strsplit(ChemFileName,split='[.]')[[1]][1]

    ## Delete unnecessary columns,  if it exists
    if ("learn more" %in% names(ChemTable)){
        ChemTable <- ChemTable[,!(names(ChemTable)=="learn more")]
    }
    ChemTable <- ChemTable[,!(names(ChemTable)=="environmental + health summary")]

    ## Add product data frame to list of data frames
    product_list[[ChemFileName]] <- ChemTable
}

## Merge all data frames in list
MethodChem <- Reduce(function(x,y) merge(x,y,all=TRUE),product_list)

## Rename data frame columns
colnames(MethodChem)[2] <- "ChemicalName"
colnames(MethodChem)[3] <- "UseCategory"
colnames(MethodChem)[1] <- "File"

## Remove commas so CSV file works
MethodChem$ChemicalName <- gsub(",",";",MethodChem$ChemicalName)
MethodChem$UseCategory <- gsub(",",";",MethodChem$UseCategory)

## Get rid of when product was updated last
MethodChem$first <- sapply(as.character(MethodChem$ChemicalName),
                           FUN=function(x) {strsplit(x,split=" ")[[1]][1]})
MethodChem <- MethodChem[which(MethodChem$first != "updated"),]

## Put needed data in data frame
MethodChem <- data.frame(ChemicalName=MethodChem$ChemicalName,
                         UseCategory=MethodChem$UseCategory,
                         Product=MethodChem$File)

## Write data frame to file
write.csv(MethodChem,"MethodChemicalIngredients_RAW.csv",
          quote=FALSE,row.names=FALSE)
