rm(list=ls(all=TRUE))
library(XML)
require(RCurl)
library(httr)
library(stringr)
require(data.table)
load("baby_mom_and_personalcare_prod.rda") 
dfnew$ingredients<-gsub(";",",",dfnew$ingredients,fixed=TRUE)
dfnew$ingredients<-gsub("May contains:," ,"",dfnew$ingredients,fixed=TRUE)
dfnew$ingredients<-gsub("Extracts of:,","",dfnew$ingredients,fixed=TRUE)
dfnew$ingredients<-gsub("\\s*\\([^\\)]+\\)","",as.character(dfnew$ingredients)) # to remove the text with paranthesis
nocomma<-1:nrow(dfnew)
names(dfnew)[5]<-"link"
dfnew$prod_cat<-NULL
nocomma<-c(1:nrow(dfnew))
for(i in 1:nrow(dfnew)){nocomma[i]<-str_count(dfnew$ingredients[i], ',')}
nocomma<-nocomma+1
dfnew$freq_ing<-NA
dfnew$freq_ing<-as.character(dfnew$freq_ing)
dfnew$Ranking<-NA
for(i in 1:length(nocomma)){dfnew$freq_ing[i]<-paste(as.character(c(1:nocomma[i])),collapse=",")}
 dt <- data.table(dfnew)
# dt.expanded <- dt[rep(seq(nrow(dt)), freq_ing), 1:6, with=F]
# df<-as.data.frame(dt.expanded)
# s <- unlist(strsplit(df$ingredients, split = ","))
d.dt <- data.table(dfnew, key=c("product_name","brands","Ranking","link","active_ingred"))
dtnew <- d.dt[, list(ingredients = unlist(strsplit(ingredients, ",")),freq_ing = unlist(strsplit(freq_ing, ","))), by=c("product_name","brands","Ranking","link","active_ingred")]

df<-as.data.frame(dtnew)
df$Ranking<-df$freq_ing
df$freq_ing<-NULL
df<-df[,c("brands","ingredients","Ranking","product_name","active_ingred","link")]
row.has.na<-apply(df[,c("brands","ingredients","Ranking","product_name","link")],1, function(x){any(is.na(x))})
# ind<-which(row.has.na==TRUE)
# df<-df[-ind,]
# df<-df[!is.na(df$ingredients),]
# k<-grep(pattern="Flavor",df$ingredients)
#  df<-df[-k,]
# k<-grep(pattern="Fragrance",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Oats",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Vitamin",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Honey",df$ingredients)
# df<-df[-k,]
#  k<-grep(pattern="Extract",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Flower",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Syrup",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Carrot",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Blueberry",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Caffeine",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Leaf",df$ingredients)
# df<-df[-k,]
# 
# k<-grep(pattern="Parfum",df$ingredients)
# df<-df[-k,]
# k<-grep(pattern="Aqua",df$ingredients)
# df$ingredients[k]<-"Water"
# 
# write.csv(df,file="drugstore_products2.csv")
# 
