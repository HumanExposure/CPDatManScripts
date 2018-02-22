## Name: clean_scil_fuse_Data.R
## Author: Katherine A. Phillips
## Date Created: May 2015
## Purpose: Cleans up data entries from EPA's Safer Choice Ingredient List. This table was
## originally obtained as a CSV dump from SCIL's website.


source("C:/Users/kphillip/Documents/RLibraries/CASFunctions.R")
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

chems <- read.csv("DFEChemicals.csv")
chems$CAS <- PadCAS(as.character(chems$CAS))
chems$ChemicalName <- tolower(as.character(chems$ChemicalName))
chems <- chems[c(1,2,4)]
colnames(chems)[3] <- "ReportedFunction"
chems$CuratedFunction <- tolower(as.character(chems$ReportedFunction))
chems$CuratedFunction <- gsub(" - ","-",chems$CuratedFunction,fixed = TRUE)
chems$CuratedFunction <- gsub("-","|",chems$CuratedFunction, fixed = TRUE)
chems$CuratedFunction <- gsub("\\b and \\b","|",chems$CuratedFunction)
s <- strsplit(chems$CuratedFunction,split='|',fixed=TRUE)
chems <- data.frame(CAS = rep(chems$CAS, sapply(s,length)),
                    ChemicalName=rep(chems$ChemicalName, sapply(s,length)),
                    ReportedFunction=rep(chems$ReportedFunction,sapply(s,length)),
                    CuratedFunction = unlist(s))
chems$CuratedFunction <- as.character(chems$CuratedFunction)
chems$LastLetter <- sapply(chems$CuratedFunction,function(x){tail(strsplit(x,split="")[[1]],n=1)})
chems$CuratedFunction[which(chems$LastLetter=="s")] <- sapply(chems$CuratedFunction[which(chems$LastLetter == "s")],
                                                               function(x) {
                                                                  substr(x,start=1,stop=(nchar(x) - 1))
                                                               })
chems$FunctionRoot <- sapply(as.character(chems$CuratedFunction), function(x) {WordStemmer(x)})
chems$CuratedFunction <- gsub(" ", "_", as.character(chems$CuratedFunction), fixed = TRUE)
chems$FunctionRoot <- gsub(" ", "_", as.character(chems$CuratedFunction), fixed = TRUE)
chems$Source <- "Safer Choice Ingredient List"
chems$WebURL <- "http://www.epa.gov/saferchoice/safer-ingredients#scil"
chems$DownloadDate <- "2015-03-01 00:00:00"
chems$DownloadedBy <- "Katherine Phillips"
chems <- chems[c("CAS", "ChemicalName",
                 "ReportedFunction", "CuratedFunction", "FunctionRoot",
                 "Source", "WebURL", "DownloadDate", "DownloadedBy")]
write.csv(chems,"SaferChemicalIngredientList_01152016.csv",row.names = FALSE)
