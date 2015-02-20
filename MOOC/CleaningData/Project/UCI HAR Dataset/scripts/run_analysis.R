test.subject =read.table("../test/subject_test.txt")
test.X       =read.table("../test/X_test.txt")
test.y       =read.table("../test/y_test.txt")
##TODO merge these together
test<-cbind(test.subject,test.y,test.X)

train.subject=read.table("../train/subject_train.txt")
train.X      =read.table("../train/X_train.txt")
train.y      =read.table("../train/y_train.txt")
##TODO merge these together
train<-cbind(train.subject,train.y,train.X)

data<-rbind(test,train)
##subject=rbind(test.subject,train.subject)
##X      =rbind(test.X,train.X)
##y      =rbind(test.y,train.y)

## read in features
feats<-read.table("../features.txt")
## select features with mean() ?? meanFreq()
## pare down subject with mean() features

## read activity
acts<-read.table("../activity_labels.txt")
## label activities with text labels
