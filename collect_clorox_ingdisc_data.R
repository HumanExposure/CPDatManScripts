## Name: collect_clorox_ingdisc_data.R
## Author: Katherine A. Phillips
## Date Created: March 2015
## Purpose: Collects and parses HTML files for Clorox's ingredient use information.


library(XML)
library(RCurl)
setwd("C:/Users/kphillip/Documents/DataCollection/Clorox_Ingredient_List")
source("../../CASFunctions.r")

##----------------------------------------------------------------------------##
## Part I: Get Brand Name Links                                               ##
##----------------------------------------------------------------------------##
## This finds all the links on the sc johnson webpage, don't really need this ##
## now since I saved the hrefs to a file                                      ##
##----------------------------------------------------------------------------##

## URL to page listing all Method products
CloroxURL <- "http://www.thecloroxcompany.com/products/ingredients-inside/"

## Parse the HTML on the page
CloroxPage <- htmlParse(CloroxURL)

## Get all the links on the page
CloroxLinks <- xpathSApply(CloroxPage,"//a/@href")

## Find unique links
CloroxLinks <- unique(CloroxLinks)

## Stop using the page
free(CloroxPage)

## Convert the HTML object to a vector
CloroxLinks <- as.vector(CloroxLinks)

## Open a file for writing
CloroxFile <- file("CloroxBrand_links.txt")

## Write each link to a line in the file
writeLines(CloroxLinks,CloroxFile)

## Close the file
close(CloroxFile)


##----------------------------------------------------------------------------##
## Part II: Get Product Name Links for each Brand                             ##
##----------------------------------------------------------------------------##
## Sigh! Nothing is easy, Clorox structures their website different than all  ##
## the others. Now, read in the links from the main page and get all the      ##
## links for each brand.                                                      ##
##----------------------------------------------------------------------------##

CloroxURL <- "http://www.thecloroxcompany.com"                                ## URL to page listing all Method products
urls <- readLines("CloroxBrand_links.txt",warn=FALSE)                         ## Store all children URLs as vector
for (i in 1:length(urls)){
    BrandURL <- paste(CloroxURL,urls[i],sep="")                                ## Get the URL for each brand
    BrandName <- paste(tail(strsplit(urls[i],
                           split="/")[[1]],n=1),"_links.txt",sep="")          ## Create a name for the links files
    BrandPage <- htmlParse(BrandURL)                                           ## Parse the HTML on the page
    BrandLinks <- xpathSApply(BrandPage,"//a/@href")                           ## Get all the links on the page
    free(BrandPage)                                                            ## Stop using the page
    BrandLinks <- as.vector(BrandLinks)                                        ## Convert the list of links to a vector
    BrandLinks <- unique(BrandLinks)                                           ## Find unique links
    BrandFile <- file(BrandName)                                               ## Open a file for writing
    writeLines(BrandLinks,BrandFile)                                           ## Write each link to a line in the file
    close(BrandFile)                                                           ## Close the file
}





##----------------------------------------------------------------------------##
## Part III: Download the HTML Files for each Product                         ##
##----------------------------------------------------------------------------##
## Okay, now I have all of the product links that I need so I can go out and  ##
## download the files I need and parse them after they are downloaded.        ##
## Downloaded files don't parse correctly...so just read the page and store   ##
## the necessary information 'on the fly'.                                    ##
##----------------------------------------------------------------------------##

## URL to page listing all Method products
CloroxURL <- "http://www.thecloroxcompany.com"

## Store all children URLs as vector
CompanyURLs <- readLines("CloroxBrand_links.txt",warn=FALSE)

## Loop over all Brand URLs
for (i in 1:length(CompanyURLs)){

    CURL <- CompanyURLs[i]

    ## Get the URL for each brand
    BrandURL <- paste(CloroxURL,CURL[i],sep="")

    ## Create a name for the links files
    BrandName <- paste(tail(strsplit(urls[i],
                       split="/")[[1]],n=1),"_links.txt",sep="")

    ## Get the URL for each product
    BrandURLs <- readLines(BrandName,warn=FALSE)

    ## Loop over all product URLs
    for(j in 1:length(BrandURLs)){

        ## Get the URL for a product
        BURL <- BrandURLs[j]
        ProductURL <- paste(CloroxURL,BURL,sep="")

        ## Create a HTML file name
        ProdFileName <- paste(gsub("-","_",
                                   gsub(" ","",
                                        tail(strsplit(ProductURL,split="[/]")[[1]],
                                             n=1)
                                       )
                                  ),".html",
                              sep="")
        ProdFileName <- paste("ProductHTML",ProdFileName,sep="/")

        ## Download the file
        ProdFile <- download.file(url=ProductURL,destfile=ProdFileName)

        ## Don't overload the server
        Sys.sleep(10)

   }
}





##----------------------------------------------------------------------------##
## Part IV: Get the Information from the HTML files                           ##
##----------------------------------------------------------------------------##
## Downloaded files don't parse correctly...so just read the page and store   ##
## the necessary information 'on the fly'. This should probably be combined   ##
## with Part III at some point.                                               ##
##----------------------------------------------------------------------------##

## URL to page listing all Method products
CloroxURL <- "http://www.thecloroxcompany.com"

## Store all children URLs as vector
CompanyURLs <- readLines("CloroxBrand_links.txt",warn=FALSE)
product_list <- list()

## Loop over all Brand URLs
for (i in 1:length(CompanyURLs)){
    CURL <- CompanyURLs[i]

    ## Get the URL for each brand
    BrandURL <- paste(CloroxURL,CURL,sep="")

    ## Create a name for the links files
    BrandName <- paste(tail(strsplit(CURL,
                       split="/")[[1]],n=1),"_links.txt",sep="")

    ## Get the URL for each product
    BrandURLs <- readLines(BrandName,warn=FALSE)

    ## Loop over all product URLs
    for(j in 1:length(BrandURLs)){

        ## Get the URL for a product
        BURL <- BrandURLs[j]
        ProductURL <- paste(CloroxURL,BURL,"/",sep="")
        ProductName <- tail(strsplit(ProductURL,split='/')[[1]],n=1)
        CompanyName <- strsplit(strsplit(BrandName,
                              split="[.]")[[1]][1],split="_")[[1]][1]
        ProdPage <- getURL(ProductURL)

        ## Parse chemical HTML file
        ProdDoc <- htmlParse(ProdPage)
        ChemName <- xpathSApply(ProdDoc,"//h4/a",xmlValue)
        ChemUse <- xpathSApply(ProdDoc,"//div[@class = 'accordionContent']/p",xmlValue)
        free(ProdDoc)
        ChemName <- sapply(ChemName,FUN=function(x) {gsub(",",";",x)})
        ChemName <- UniStr(ChemName)
        ChemUse <- sapply(ChemUse,FUN=function(x) {gsub(",",";",x)})
        ChemUse <- UniStr(ChemUse)
        ChemFrame <- data.frame(ChemicalName=ChemName,UseCategory=ChemUse,ProductName=ProductName)
        product_list[[ProductName]] <- ChemFrame
        rownames(ChemFrame) <- NULL
        print(paste("Data Aquired for",paste(toupper(CompanyName),"'s",sep=""),paste(ProductName,"...",sep="")),quote=FALSE)

        ## Don't overload the server
        Sys.sleep(10)

   }
}

## Merge all data frames in list
CloroxChem <- Reduce(function(x,y) merge(x,y,all=TRUE),product_list)

## Write data to file
write.csv(CloroxChem,"CloroxChemicalIngredients_RAW.csv",quote=FALSE,row.names=FALSE)
