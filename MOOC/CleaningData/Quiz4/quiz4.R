gdp<-read.csv("getdata-data-ss06hid.csv")
x<-strsplit(names(gdp),"wgtp")
x[123]

gdp<-read.csv("getdata-data-GDP.csv",skip=4)
G<-G[1:190]
H<-gsub(",","",G)
I<-as.numeric(H)
mean(I)

grep("^United",gdp$X.3)

