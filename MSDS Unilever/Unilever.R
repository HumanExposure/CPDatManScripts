library(XML)
library(RCurl)
library(utils)
library(xlsx)
library(gtools)

### working folder ###
pth <- "I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction"
setwd(pth)


### UNL_namelist.xlsx contains product name, MSDS #, and URL to the MSDS file ###
data_all_raw <- read.xlsx(paste(pth, "/UNL_namelist.xlsx", sep=""), sheetName = "1")

### list all the downloaded pdfs ###
filenames <- list.files(paste(pth, "/UNL_pdf", sep=""))
filenames_sort <- mixedsort(filenames)

### try to list broken pdf files ###
for (file in filenames_sort){
	pdf_old_name <- (strsplit(file, ".pdf")[[1]])
	find_ind <- which(data_all_raw$Product.Name==pdf_old_name)
	if (length(find_ind)>0){
		file.rename(from=paste(pth, '/UNL_pdf/', pdf_old_name, ".pdf", sep=""), to=paste(pth, '/UNL_pdf/', find_ind, ".pdf", sep=""))
	}
	if (length(find_ind)==0){
		print (pdf_old_name)
	}
}


### convert pdf to text file ###
filenames <- list.files(paste(pth, "/Unilever_pdf", sep=""))
filenames_sort <- mixedsort(filenames)[53]

### specify location of pdftotext.exe
exe_pth <- '"I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/xpdfbin-win-3.04/bin64/pdftotext.exe"'
zero_file <- c()

for (file in filenames_sort){
	print (file)

	file_pth <- paste('"I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/Unilever_pdf/"', file, sep="")
	system(paste(exe_pth, " -table -nopgbrk ", file_pth, sep=""))

}


### combine all CSV files ###
pth <- "I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/UNL_csv"
setwd(pth)

filenames <- list.files(pth)
filenames_sort <- mixedsort(filenames)

file_all <- c()
for (file in filenames_sort){
	print (file)
	file_temp <- read.csv(file, header=TRUE, sep=",")
	file_all <- rbind(file_all, file_temp)
}

library(xlsx)
write.xlsx(x = file_all, file = "UNL_all.xlsx",
        sheetName = "UNL_all_xlsx", row.names = FALSE)

