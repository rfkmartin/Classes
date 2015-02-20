library("dplyr")
## read in features
feats<-read.table("../features.txt")
## select features with mean() and std()
idx.mean<-grep("mean\\(\\)",feats$V2)
idx.std<-grep("std\\(\\)",feats$V2)
idx<-union(idx.mean,idx.std)
idx<-idx[order(idx)]

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
idx=c(1,2,idx+2)
data<-data[idx]
## clean up variable names
old.names=names(data)
data.names<-gsub("-mean\\(\\)",".mean",old.names)
data.names<-gsub("-std\\(\\)",".std",data.names)
data.names<-gsub("-X",".X",data.names)
data.names<-gsub("-Y",".Y",data.names)
data.names<-gsub("-Z",".Z",data.names)
names(data)<-data.names

## read activity
acts<-read.table("../activity_labels.txt")
names(acts)<-c("Activity.ID","Activity")
## label activities with text labels
data<-merge(acts,data)

final<-data %>% group_by(Activity,Subject.ID) %>% summarise_each(funs(mean))
write.table(final,file="final.txt",row.name=FALSE)