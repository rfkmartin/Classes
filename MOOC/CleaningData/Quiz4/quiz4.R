gdp<-read.csv("getdata-data-ss06hid.csv")
x<-strsplit(names(gdp),"wgtp")
print(x[123])

gdp<-read.csv("getdata-data-GDP.csv",skip=4)
G<-gdp$X.4
G<-G[1:190]
H<-gsub(",","",G)
I<-as.numeric(H)
print(mean(I))

d<-grep("^United",gdp$X.3)
print(length(d))

ed<-read.csv("getdata-data-EDSTATS_Country.csv")
names(gdp)=c("CountryCode","A","GDP.Rank","Long.Name1","GDP","B","C","D","E","F")
f<-merge(gdp,ed)
print(length(f))

library(quantmod)
amzn = getSymbols("AMZN",auto.assign=FALSE)
sampleTimes = index(amzn)
i<-grep("2012-",sampleTimes)
print(length(i))

j<-grep("Monday",weekdays(as.Date(sampleTimes[i],'%d-%m-%Y')))
print(length(j))