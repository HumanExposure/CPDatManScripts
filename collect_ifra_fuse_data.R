## Name: collect_fuse_data.R
## Author: Katherine A. Phillips
## Date Created: February 2015
## Purpose: Collects and cleans IFRA HTML table listing fragrances

library(RCurl)
library(XML)
setwd("C:/Users/kphillip/Documents/CleaningProducts")
source("C:/Users/kphillip/Documents/RLibraries/CASFunctions.r")


WordStemmer <- function(item){
    suffix4L <- c("ical","yzer","izer","iser","able","ance","ized")
    suffix3L <- c("ier","ing","ant","ent","tor","ion","ive","ial","ogy","ity")
    suffix2L <- c("er","al","ic","or")
    words <- strsplit(item, split = " ", fixed=TRUE)[[1]]
    stemmed_words <- vector(mode="character", length = length(words))
    i <- 0
    for (word in words){

       i <- i + 1
       suffix <- substr(word,nchar(word) - 3, nchar(word))
       if (suffix %in% suffix4L){

          stemmed_words[i] <- substr(word,1,nchar(word)-4)

       } else {

          suffix <- substr(word, nchar(word) - 2, nchar(word))
          if (suffix %in% suffix3L){

             stemmed_words[i] <- substr(word, 1, nchar(word) - 3)

          } else {

             suffix <- substr(word, nchar(word) - 1, nchar(word))
             if (suffix %in% suffix2L) {

                stemmed_words[i] <- substr(word, 1, nchar(word) - 2)

             } else {

                stemmed_words[i] <- word

             }

          }

       }
    }
    return(paste(stemmed_words,collapse=" "))
}


url <- "C:/Users/kphillip/Documents/CleaningProducts/UseCASMatching/InternationalFragranceAssociationIngredientsList.html"
webpage <- htmlParse(url)
CAS<-xpathSApply(webpage,"//td[@width='106']",xmlValue)
ChemicalName<-xpathSApply(webpage,"//td[@width='443']",xmlValue)
Fragrances <- data.frame(CAS=CAS,ChemicalName=ChemicalName,UseCategory=rep("frag",length(CAS)))
Fragrances <- Fragrances[-which(Fragrances$CAS=="CASNumber"),]
Fragrances$CAS <- gsub("-","_",as.character(Fragrances$CAS),fixed=TRUE)
Fragrances$CAS <- PadCAS(Fragrances$CAS)
Fragrances$ChemicalName <- as.character(Fragrances$ChemicalName)
Fragrances$ChemicalName <- gsub("[\r\n]","",Fragrances$ChemicalName)
Fragrances$ChemicalName <- gsub("\\s+"," ",Fragrances$ChemicalName)
Fragrances$ChemicalName <- gsub(",","_",Fragrances$ChemicalName,fixed=TRUE)
rownames(Fragrances) <- NULL

Fragrances <- Fragrances[c(1,2)]
colnames(Fragrances) <- c("CAS","ChemicalName")
Fragrances$ChemicalName <- stringr::str_trim(tolower(as.character(Fragrances$ChemicalName)))
Fragrances$ReportedFunction <- "fragrance"
Fragrances$CuratedFunction <- "fragrance"
Fragrances$FunctionRoot <- sapply(Fragrances$CuratedFunction, function(x) {WordStemmer(x)})
Fragrances$Source <- "International Fragrance Association"
Fragrances$WebURL <- "http://www.ifraorg.org/en-us/ingredients"
Fragrances$DownloadDate <- "2015-03-01 00:00:00"
Fragrances$DownloadedBy <- "Katherine Phillips"
write.csv(Fragrances,"FragranceFunctionalUse_01112015.csv",row.names = FALSE)
