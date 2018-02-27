rm(list=ls(all=TRUE))
library(XML)
require(RCurl)
library(httr)
library(stringr)
#load("producttoprated.rda")
path<-"L:/Lab/NCCT_ExpoCast/ExpoCast2015/DBiryol_FCS/DRUGSTORE_HTML"
setwd(path)
htmlRoot <- "http://www.drugstore.com"
# filelinks <- list.files("drugstorehtml", pattern="*.html", full.names=TRUE)#open all files
foldernames<-list.dirs(path="./drugstorelinks/www.drugstore.com/",full.names=TRUE,recursive=TRUE)

filenames<-foldernames[4:length(foldernames)] #first three are rootwebsite , just skip
brands<-sapply(strsplit(foldernames, split='/', fixed=TRUE), function(x) (x[5]))#brands list
filenames<-gsub("./","",filenames,fixed=TRUE)
filenames<-paste0("L:/Lab/NCCT_ExpoCast/ExpoCast2015/DBiryol_FCS/DRUGSTORE_HTML/",filenames)
fileweb<- list.files(filenames, full.names=TRUE,recursive=TRUE)#open all files
links<-fileweb[1:75]
for(i in 1:length(fileweb)){
  ppage <- htmlParse(fileweb[i])
  ## Get a list of category for each product
  links[i]<- unlist(xpathApply(ppage,"//link [@rel='canonical']",xmlGetAttr,"href"))   
}
l<-links

df<-as.data.frame(matrix(ncol=5,nrow=1))
names(df)<-c("brands","prod_cat","product_name","ingredients","links")
dfnew<-df
for(i in 1:length(links)){
  url1<-getURL(url=links[i])
  page<-htmlParse(url1)
  l<- unlist(xpathApply(page,"//span/a [@class='oesLink']",xmlGetAttr,"href"))  
  web<-unlist(lapply(l,function(x) {paste(htmlRoot,x,sep="")}))
  df$brands<-sapply(strsplit(links[i], split='/', fixed=TRUE), function(x) (x[6]))
  df$prod_cat<-sapply(strsplit(links[i], split='/', fixed=TRUE), function(x) (x[5]))
  for(j in 1:length(l)){
  df$product_name<-sapply(strsplit(l[j], split='/', fixed=TRUE), function(x) (x[2]))
  df$links<-web[j]
  url1<-getURL(url=web[j])
  page<-htmlParse(url1)
  ingred<- xpathApply(page,"//table[@id='TblProdForkIngredients']/tr/td[@class='contenttd']",xmlValue)
  if(length(ingred)!=0){
    ind<-grep(pattern="Ingredients:",ingred)
    df$ingredients<-paste(ingred,collapse="")
  }
  dfnew<-rbind(df,dfnew)
  
  }}
  
  dfnew<-dfnew[1:472,]
save(dfnew,file="babyandsuncareprod.rda")
  k<-grep(pattern="qx",dfnew$brands)
dfnew$brands[k]<-sapply(strsplit(dfnew$links[k], split='/', fixed=TRUE), function(x) (x[4]))
dfnew$brands[k]<-sapply(strsplit(dfnew$brands[k], split='-', fixed=TRUE), function(x) (x[1]))
dfnew<-dfnew[-k[15],]
dfnew$brands<-gsub("-"," ",dfnew$brands,fixed=TRUE)
dfnew$product_name<-gsub("-"," ",dfnew$product_name,fixed=TRUE)
dfnew$prod_cat<-gsub("-"," ",dfnew$prod_cat,fixed=TRUE)
UniStr <- function(category){
  category <- as.character(category)
  category <- iconv(category,"latin1","ASCII",sub="")
  category <- factor(category)
  return(category)
}
dfnew$ingredients<-UniStr(dfnew$ingredients)
dfnew$ingredients<-as.character(dfnew$ingredients)
ind<-grep(pattern="Active Ingredients:",dfnew$ingredients)
dfnew$active_ingred[ind]<-str_extract(string = dfnew$ingredients[ind], pattern = perl("(?<=Ingredients:).*(?=Inactive)"))
dfnew$ingredients[ind]<-str_extract(string = dfnew$ingredients[ind], pattern = perl("(?<=Inactive Ingredients:).*"))
dfnew$ingredients<-gsub("\n","",dfnew$ingredients,fixed=TRUE)
dfnew$active_ingred<-gsub("Contains:","",dfnew$active_ingred,fixed=TRUE)
dfnew$active_ingred<-gsub("Other Ingredients:","",dfnew$active_ingred,fixed=TRUE)
dfnew$ingredients<-gsub("Contains:","",dfnew$ingredients,fixed=TRUE)
dfnew$ingredients<-gsub("Other Ingredients:","",dfnew$ingredients,fixed=TRUE)

save(dfnew,file="baby_mom_and_personalcare_prod.rda")