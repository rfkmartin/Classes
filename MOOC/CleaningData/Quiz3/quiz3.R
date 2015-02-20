data<-read.csv("getdata-data-ss06hid.csv")
agLog<-data[which(data$ACR==3&data$AGS==6),]
print(head(agLog[,1:10]))

library(jpeg)
data<-readJPEG("getdata-jeff.jpg",native=TRUE)
print(quantile(data,probs=c(0.3,0.8)))

ed<-read.csv("getdata-data-EDSTATS_Country.csv")
gdp<-read.csv("getdata-data-GDP.csv",skip=4,nrows=190)
gdp<-subset(gdp,select=c(X,X.1,X.3,X.4))
gdp$gdp<-as.integer(gsub(",","",gdp$X.4))
merged<-merge(ed,gdp,by.x="CountryCode",by.y="X")
merged<-merged[,c(1,3,32,33,35)]
print(head(merged[order(merged$gdp),],13))

tapply(merged$gdp,merged$Income.Group,mean)

print(merged$quant<-cut(merged$X.1,quantile(merged$X.1,probs=c(0,0.2,0.4,0.6,0.8,1))))
print(table(merged$quant,merged$Income.Group))