#Download the file
if(!file.exists("./data")){dir.create("./data")}
fileURL<-  "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,destfile = "./data/Dataset.zip", method = "curl")

#Unzip the file
unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

#Get the list of files

path_rf<- file.path("./data", "UCI HAR Dataset")
files <- list.files(path_rf,recursive = TRUE)
files

#read the activity files, subject files and features files.

data_activity_test <- read.table(file.path(path_rf,"test","Y_test.txt"),header = FALSE)
data_activity_train <- read.table(file.path(path_rf,"train","Y_train.txt"),header = FALSE)

data_subject_test <- read.table(file.path(path_rf,"test","subject_test.txt"),header = FALSE)
data_subject_train <- read.table(file.path(path_rf,"train","subject_train.txt"),header = FALSE)

data_features_test <- read.table(file.path(path_rf,"test","X_test.txt"),header = FALSE)
data_features_train <- read.table(file.path(path_rf,"train","X_train.txt"),header = FALSE)

#Look at the properties
str(data_activity_test)
str(data_activity_train)

str(data_subject_test)
str(data_subject_train)

str(data_features_test)
str(data_features_train)

#Concatenate data tables
data_subject <- rbind(data_subject_train,data_subject_test)
data_activity <- rbind(data_activity_train,data_activity_test)
data_features <- rbind(data_features_train,data_features_test)

#set names to variable
names(data_subject)<-c("subject")
names(data_activity)<-c("activity")

data_features_names <- read.table(file.path(path_rf, "features.txt"),head = FALSE)
names(data_features)<- data_features_names$V2

#Merge columns to get the data frame
data_combine <- cbind(data_subject, data_activity)
data <- cbind(data_features,data_combine)

#Extracts only the measurements on the mean and standard deviation for each measurement. 
#Subset Name of Features by measurements on the mean and standard deviation
subdata_features_name <- data_features_names$V2[grep("mean\\(\\)|std\\(\\)",data_features_names$V2)]

#Subset the dataframe by selected names and features.
selected_names <- c(as.character(subdata_features_name),"subject","activity")
data <- subset(data,select = selected_names)

# check the structure
str(data)

#Uses descriptive activity names to name the activities in the data set
# read descriptive activity names
activity_labels <- read.table(file.path(path_rf,"activity_labels.txt"),header = FALSE)

head(data$activity,30)

#Appropriately labels the data set with descriptive variable names. 
names(data)<-gsub("^t","time", names(data))
names(data)<-gsub("^f","frequency", names(data))
names(data)<-gsub("Acc","Accelerometer", names(data))
names(data)<-gsub("Gyro","Gyroscope", names(data))
names(data)<-gsub("Mag","Magnitude", names(data))
names(data)<-gsub("BodyBody","Body", names(data))

names(data)

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#install.packages("plyr")
library(plyr)

data2 <- aggregate(.~subject+activity, data, mean)
data2 <- data2[order(data2$subject, data2$activity),]
write.table(data2,file = "tidydata.txt",row.names = FALSE)



#install.packages("codebook")
#library(codebook)
#new_codebook_rmd()