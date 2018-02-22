library(XML)
library(RCurl)
library(utils)

pth <- "I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/P&G_pdf"
setwd(pth)

## Root webpage
pgroot <- "http://www.pgproductsafety.com"

## SDS search pages
pgpage <- "http://www.pgproductsafety.com/productsafety/search_results.php?submit=Search&searchtext=%2A&category=SDS&start=1&num=2403"
pgurl <- getURL(url = pgpage)
pghtml <- htmlParse(pgurl)

## Links to either look at SDS or add SDS to download queue
pglinks <- unlist(xpathApply(pghtml,"//div[@class='result-data']/p/a", xmlGetAttr, "href"))

## Get rid of "add to download queue" links
pglinks <- pglinks[which(grepl("queue", pglinks)==FALSE)]

## Construct working links
pglinks <- paste(pgroot, pglinks, sep="")
pglinks_clean <- gsub(" ", "%20", pglinks)


# ## Wget executable name
# execname <- "wget.exe"
# ## Write batch file to download all links
# Names <- paste(execname, unique(pglinks), sep=" ")
# fileConn <- file("Download_All_ProcterGamble_Links.bat")
# writeLines(Names, fileConn)
# close(fileConn)


missing_url <- c()
for (i in 1:length(pglinks_clean)){
	print (i)

	pdf_name_temp <- tail(strsplit(pglinks_clean[i], "/")[[1]], 1)


	tryCatch(
		download.file(pglinks_clean[i], paste(i, pdf_name_temp, sep="_"), mode="wb"), 
		error=function(e){
			message(paste("URL does not seem to exist:", i))
			# missing_url <- c(missing_url, i)
			}
		)
	Sys.sleep(1)
}

pdf_name_all <- c()
for (kk in 1:length(pglinks_clean)){
	pdf_name_part_1 <- tail(strsplit(pglinks_clean[kk], "/")[[1]], 1)
	pdf_name <- paste(kk, pdf_name_part_1, sep="_")
	pdf_name_all <- c(pdf_name_all, pdf_name)
}

name_matrix <- data.frame(pglinks_clean=pglinks_clean, pdf_name=pdf_name_all)
write.csv(file="P_G_URL_name_list.csv", x=name_matrix)

# url_add <- "http://www.pgproductsafety.com/productsafety/sds/SDS_2015/DAWN_ULTRA_POWER_DISSOLVER._back_up.pdf"
# getURL(url_add, nobody=1L, header=1L)


# missing_url <- c()
# broken_url <- c()

# for (i in 1:1742){
# 	file_id <- as.numeric(strsplit(filenames_sort[i], "_")[[1]][1])

# 	if (grepl("_SDS_", filenames_sort[i])) {
# 		broken_url <- c(broken_url, i)
# 	}

# }


### convert to text file ###

library('gtools')
filenames <- list.files(pth)
filenames_sort <- mixedsort(filenames)

exe_pth <- '"I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/xpdfbin-win-3.04/bin64/pdftotext.exe"'
zero_file <- c()

filenames_sort_2 <- filenames_sort[79]
for (file in filenames_sort_2){
	print (file)
	file_size <- file.info(paste(pth, "/", file, sep=""))$size
	if (is.na(file_size)){
		zero_file <- c(zero_file, file)
	} else{
	file_pth <- paste('"I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/P&G_pdf/"', file, sep="")
	# print (file_pth)
	system(paste(exe_pth, " -table -nopgbrk ", file_pth, sep=""))
		
	}
}



### combine all CSV files ###
pth <- "I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/P&G_csv"
setwd(pth)

library('gtools')
filenames <- list.files(pth)
filenames_sort <- mixedsort(filenames)

file_all <- c()
for (file in filenames_sort){
	print (file)
	file_temp <- read.csv(file, header=TRUE, sep=",")
	file_all <- rbind(file_all, file_temp)
	# print (file_temp)
}

write.csv(file="all_csv.csv", x=file_all)