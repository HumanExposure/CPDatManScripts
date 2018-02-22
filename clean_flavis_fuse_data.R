## Name: clean_flavis_fuse_data.R
## Author: Katherine A. Phillips
## Date Created: May 2015
## Purpose: Cleans up Fl@vis data collected from Fl@voruing Substances.


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

chems <- readxl::read_excel("RAWFlavisNameandCAS.xlsx", col_names = FALSE)
colnames(chems) <- c("ChemicalName", "CAS")
chems$ChemicalName <- tolower(as.character(chems$ChemicalName))
chems$CAS <- PadCAS(as.character(chems$CAS))
chems <- chems[c("CAS", "ChemicalName")]
chems$ReportedFunction <- "flavorant"
chems$CuratedFunction <- "flavorant"
chems$FunctionRoot <- sapply(chems$CuratedFunction, function(x) {WordStemmer(x)})
chems$Source <- "Food Flavourings Database (EU)"
chems$WebURL <- "http://ec.europa.eu/food/food/chemicalsafety/flavouring/database/dsp_search.cfm"
chems$DownloadDate <- "2015-05-01 00:00:00"
chems$DownloadedBy <- "Katherine Phillips"
write.csv(chems,"FlavouringsFunctionalUse_01112015.csv",row.names = FALSE)
# chems$DownloadedBy <- "Marc Duchatilier"
# write.csv(chems,"GeneralChemicalsFunctionalUse_01152016.csv", row.names = FALSE)
