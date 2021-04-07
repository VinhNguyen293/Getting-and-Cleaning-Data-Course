---
title: "final project - Getting and Cleaning Data"
author: "NGUYEN THE VINH"
date: "April 7th 2021"
output:
  html_document:
    keep_md: yes
---

## Description
Project is used for practising getting and cleaning data. Data collected from a study about analyzing human activity by using Smartphones


### Collection of the raw data
get link, download file and unzip file
```{r}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./projectData/projectfile.zip", method = "curl")
unzip("./projectData/projectfile.zip",exdir="./projectData")
```
read raw data
```{r}

features.data <- read.table("./projectData/UCI HAR Dataset/features.txt")
activity.labels <- read.table("./projectData/UCI HAR Dataset/activity_labels.txt")

subject_train <- read.table("./projectData/UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("./projectData/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./projectData/UCI HAR Dataset/train/y_train.txt")

subject_test <- read.table("./projectData/UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./projectData/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./projectData/UCI HAR Dataset/test/y_test.txt")
```

### Guide to create the tidy data file
Merges the training and the test sets to create one data set.
```{r}
bindX <- rbind(X_train,X_test)
```

Appropriately labels the data set with descriptive variable names.
```{r}
names(bindX)<-features.data[,2]
```
Extracts only the measurements on the mean and standard deviation for each measurement.
```{r}
extract.mean.std <- bindX[,grep("mean|std",colnames(bindX))]
```

Uses descriptive activity names to name the activities in the data set
```{r}
bindY <- rbind(y_train,y_test)
bindY[,1] <-sapply(bindY[,1],function(x)activity.labels[x,2])
names(bindY)<-"activity"
```

Merge subject from test and train
```{r}
bind.subject <- rbind(subject_train,subject_test)
names(bind.subject) <- "subject"
```

merge all data
```{r}
total.data <- cbind(bind.subject,bindY,extract.mean.std)
```

From the total.data , creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```{r}
subdata <- aggregate(total.data[,3:81],by=list(subject = total.data$subject,activity=total.data$activity),FUN = mean)
```
Appropriately labels the data set with descriptive variable names
```{r}
name.new <- names(subdata)
name.new <- gsub("[(][)]", "", name.new)
name.new <- gsub("^t", "TimeDomain_", name.new)
name.new <- gsub("^f", "FrequencyDomain_", name.new)
name.new <- gsub("Acc", "Accelerometer", name.new)
name.new <- gsub("Gyro", "Gyroscope", name.new)
name.new <- gsub("Mag", "Magnitude", name.new)
name.new <- gsub("-mean-", "_Mean_", name.new)
name.new <- gsub("-std-", "_StandardDeviation_", name.new)
name.new <- gsub("-", "_", name.new)
names(subdata) <- name.new
```
## Write data
```{r}
write.table(subdata,file = "tidydata.txt",row.names = FALSE)
```
