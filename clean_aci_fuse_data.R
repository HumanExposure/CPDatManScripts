## Name: clean_aci_fuse_Data.R
## Author: Katherine A. Phillips
## Date Created: April 2015
## Purpose: Cleans up data entries from ACI's Ingredient Inventory. This table was
## originally copied and pasted from the ACI's website:
## http://www.cleaninginstitute.org/science/ingredients_and_assessments.aspx
## This file further splits chemicals with multiple uses into seperate records (one use
## per) record.


source("CASFunctions.R")
WordStemmer <- function(item){
    suffix4L <- c("ical","yzer","izer","iser","able","ance")
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
chems <- read.csv("AmericanCleaningInstitute_01152016_RAW.csv")
colnames(chems) <- c("ChemicalName", "CAS", "ReportedFunction")
chems$CAS <- PadCAS(gsub("-","_",as.character(chems$CAS), fixed = TRUE))
chems$DownloadDate <- "2016-01-01 00:00:00"
chems$DownloadedBy <- "Katherine Phillips"
chems$Source <- "American Cleaning Institute"
chems$WebURL <- "http://www.cleaninginstitute.org/Ingredient_Inventory/"

chems$CuratedFunction <- tolower(as.character(chems$ReportedFunction))
chems$CuratedFunction <- gsub(", ","|",chems$CuratedFunction,fixed = TRUE)
chems$CuratedFunction[which(grepl("-",chems$CuratedFunction,fixed = TRUE))] <- "bleaching agent|oxidizing agent"
s <- strsplit(as.character(chems$CuratedFunction),split='|',fixed=TRUE)
chems <- data.frame(CAS = rep(chems$CAS, sapply(s, length)),
                    ChemicalName = rep(chems$ChemicalName, sapply(s, length)),
                    ReportedFunction=rep(chems$ReportedFunction,sapply(s,length)),
                    CuratedFunction=unlist(s),
                    Source = rep(chems$Source, sapply(s,length)),
                    WebURL = rep(chems$WebURL, sapply(s, length)),
                    DownloadDate = rep(chems$DownloadDate, sapply(s, length)),
                    DownloadedBy = rep(chems$DownloadedBy, sapply(s, length))
                    )
chems <- chems[which(grepl("not otherwise listed",chems$CuratedFunction)==FALSE),]
chems$CuratedFunction <- factor(gsub("\\bph\\b","pH",as.character(chems$CuratedFunction)))
chems$CuratedFunction <- factor(gsub("\\buv\\b","UV",as.character(chems$CuratedFunction)))
chems$FunctionRoot <- sapply(as.character(chems$CuratedFunction), function(x) {WordStemmer(x)})
chems$CuratedFunction <- gsub(" ","_", chems$CuratedFunction)
chems$FunctionRoot <- gsub(" ", "_", chems$FunctionRoot)
chems <- chems[c("CAS", "ChemicalName",
                 "ReportedFunction", "CuratedFunction", "FunctionRoot",
                 "Source", "WebURL", "DownloadDate", "DownloadedBy")]
chems$ChemicalName <- tolower(as.character(chems$ChemicalName))

write.csv(chems,"AmericanCleaningInstituteFunctionalUse_01152016.csv",row.names = FALSE)
