#check and create a directory
if(!file.exists("./projectData")){
  dir.create("./projectData")
}

#get link, download file and unzip file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./projectData/projectfile.zip", method = "curl")
unzip("./projectData/projectfile.zip",exdir="./projectData")

#read raw data
features.data <- read.table("./projectData/UCI HAR Dataset/features.txt")
activity.labels <- read.table("./projectData/UCI HAR Dataset/activity_labels.txt")

subject_train <- read.table("./projectData/UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("./projectData/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./projectData/UCI HAR Dataset/train/y_train.txt")

subject_test <- read.table("./projectData/UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./projectData/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./projectData/UCI HAR Dataset/test/y_test.txt")

#Merges the training and the test sets to create one data set.
bindX <- rbind(X_train,X_test)

#Appropriately labels the data set with descriptive variable names.
names(bindX)<-features.data[,2]

#Extracts only the measurements on the mean and standard deviation for each measurement.
extract.mean.std <- bindX[,grep("mean|std",colnames(bindX))]

#Uses descriptive activity names to name the activities in the data set
bindY <- rbind(y_train,y_test)
bindY[,1] <-sapply(bindY[,1],function(x)activity.labels[x,2])
names(bindY)<-"activity"

#Merge subject from test and train
bind.subject <- rbind(subject_train,subject_test)
names(bind.subject) <- "subject"

#merge data
total.data <- cbind(bind.subject,bindY,extract.mean.std)

#From the total.data , creates a second, independent tidy data set with the average of each variable for each activity and each subject.
subdata <- aggregate(total.data[,3:81],by=list(subject = total.data$subject,activity=total.data$activity),FUN = mean)

#Appropriately labels the data set with descriptive variable names
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

#Write data
write.table(subdata,file = "tidydata.txt",row.names = FALSE)

