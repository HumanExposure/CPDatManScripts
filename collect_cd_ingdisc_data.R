## Name: collect_cd_ingdisc_data.R
## Author: Katherine A. Phillips
## Date Created: July 2015
## Purpose: Downloads PDF ingredient disclosures from Church & Dwight (Arm & Hammer).


library(RCurl)
library(XML)

setwd( "C:/Users/kphillip/Documents/ArmAndHammer")
page1 <- htmlParse("Search_Results_Page_1.html")
page2 <- htmlParse("Search_Results_Page_2.html")


BuildLinks <- function(webpage){
    prefix <- "https://wercs.churchdwight.com/webviewer.external/private/document.aspx?prd="
    suffix1 <- "&__VIEWSTATEGENERATOR=6D9364FC&productName_option=d__value~&productID_option=d__value~"
    suffix2 <- "&language=d__EN&subformat=d__ING&hidRequiredList=ConcatedValue%20=&queryString=language=EN"


    links <- unlist(xpathApply(webpage,'//a',xmlGetAttr,"href"))
    links <- links[which(grepl("getDocument",links))]
    links <- unlist(lapply(links,function(x) {strsplit(gsub("'","",
                                                       gsub(")","",
                                                       gsub("javascript:getDocument(","",x,fixed=T),
                                                                                           fixed=T),
                                                                                           fixed=T),
                                                       split=",",fixed=T)[[1]][2]}))
    links <- unlist(lapply(links,function(x) {gsub(":","%3A",
                                              gsub(" ","%20",x,fixed=T),
                                                               fixed=T)}))
    links <- unlist(lapply(links,function(x){paste(prefix,x,suffix1,suffix2,sep="")}))

    return(links)
}

link1s <- BuildLinks(page1)
link2s <- BuildLinks(page2)

links <- c(link1s,link2s)
