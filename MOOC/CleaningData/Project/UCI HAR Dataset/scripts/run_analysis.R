## read in features
feats<-read.table("../features.txt")
## select features with mean()
idx<-grep("mean\\(\\)",feats$V2)


## read in test data
test.subject =read.table("../test/subject_test.txt")
test.X       =read.table("../test/X_test.txt")
test.y       =read.table("../test/y_test.txt")
## merge these together
test<-cbind(test.subject,test.y,test.X)
## clear up some space
remove(test.subject)
remove(test.X)
remove(test.y)

## read in training data
train.subject=read.table("../train/subject_train.txt")
train.X      =read.table("../train/X_train.txt")
train.y      =read.table("../train/y_train.txt")
## merge these together
train<-cbind(train.subject,train.y,train.X)
## clear up some space
remove(train.subject)
remove(train.X)
remove(train.y)

## combine test and training data
data<-rbind(test,train)
## clear up some space
remove(train)
remove(test)

## pare down subject with mean() features
names(data)<-c("Subject.ID","Activity.ID",as.character(feats$V2))
mean.idx=c(1,2,idx+2)
mean.data<-data[mean.idx]

## read activity
acts<-read.table("../activity_labels.txt")
names(acts)<-c("Activity.ID","Activity")
## label activities with text labels
mean.data<-merge(acts,mean.data)
