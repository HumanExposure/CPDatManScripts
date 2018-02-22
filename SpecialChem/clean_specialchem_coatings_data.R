## Name: clean_specialchem_coatings_data.R
## Author: Katherine A. Phillips
## Date Created: February 2015
## Purpose: Cleans up coatings data collected from SpecialChem.


source("CASFunctions.R")
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

chems <- read.csv("Cleaned_Coatings.csv")
chems <- chems[c(1,4,5)]
colnames(chems)[3] <- "ReportedFunction"
chems$ChemicalName <- stringr::str_trim(tolower(as.character(chems$ChemicalName)))
chems$CuratedFunction <- stringr::str_trim(tolower(as.character(chems$ReportedFunction)))
chems$LastLetter <- sapply(chems$CuratedFunction,function(x){tail(strsplit(x,split="")[[1]],n=1)})
chems$CuratedFunction[which(chems$LastLetter=="s")] <- sapply(chems$CuratedFunction[which(chems$LastLetter == "s")],
                                                               function(x) {
                                                                  substr(x,start=1,stop=(nchar(x) - 1))
                                                               })

chems$FunctionRoot <- sapply(chems$CuratedFunction, function(x) {WordStemmer(x)})
chems$CuratedFunction <- gsub(" ", "_", as.character(chems$CuratedFunction),fixed = TRUE)
chems$FunctionRoot <- gsub(" ", "_", as.character(chems$FunctionRoot),fixed = TRUE)
chems$Source <- "SpecialChem"
chems$WebURL <- "http://coatings.specialchem.com/"
chems$DownloadDate <- "2014-11-07 00:00:00"
chems$DownloadedBy <- "Kristin Isaacs"
chems <- chems[c("CAS", "ChemicalName",
                 "ReportedFunction", "CuratedFunction", "FunctionRoot",
                 "Source", "WebURL", "DownloadDate", "DownloadedBy")]
write.csv(chems,"CoatingFunctionalUse_01112015.csv",row.names = FALSE)
