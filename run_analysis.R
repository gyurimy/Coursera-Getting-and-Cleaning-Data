
### Getting and Cleaning Data Processing Steps :
# 1. Merges the training and the test sets to create one data set
# 2. Extracts only the measurements on the mean and standard deviation for each measurement
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject


### 1. Merges the training and the test sets to create one data set

## Read the tables (txt files)

# Data (X_train, X_test)
x_train_raw_data <- read.table("./train/X_train.txt")
x_test_raw_data <- read.table("./test/X_test.txt")

# Label (y_train, y_test)
y_train_raw_data <- read.table("./train/y_train.txt")
y_test_raw_data <- read.table("./test/y_test.txt")

# Subject (subject_train, subject_test)
subject_train <- read.table("./train/subject_train.txt")
subject_test <- read.table("./test/subject_test.txt")


### 3. Uses descriptive activity names to name the activities in the data set
names(subject_train) <- "subject"
names(subject_test) <- "subject"


### 4. Appropriately labels the data set with descriptive activity names
names(y_train_raw_data) <- "activity"
names(y_test_raw_data) <- "activity"


# Add column names for measurement data (for step 2)
features <- read.table("./features.txt")

# Clean up the the labels by removing excessive "\\()" and ""
# features <- gsub("\\()", "", features$V2)

names(x_train_raw_data) <- features$V2
names(x_test_raw_data) <- features$V2

# Merge data into one dataset by cbind, rbind
train_data <- cbind(subject_train, y_train_raw_data, x_train_raw_data)
test_data <- cbind(subject_test, y_test_raw_data, x_test_raw_data)
merge_data <- rbind(train_data, test_data)


### 2. Extracts only the measurements on the mean and standard deviation for each measurement

# Look for columns contain patterns like "mean()" or "std()"
# matching_columns <- grep("-mean\\(\\)|-std\\(\\)", tolower(features[, 2]), value=FALSE)
matching_columns <- grepl("mean\\(\\)", names(merge_data)) | grepl("std\\(\\)", names(merge_data))
matching_columns[1:2] <- TRUE

# Remove unnecessary columns
merge_data <- merge_data[, matching_columns]

# Convert the "activity" column integer -> factor
merge_data$activity <- factor(merge_data$activity, labels=c("Laying", "Standing", "Sitting", "Walking", "Walking Upstairs", "Walking Downstairs"))


### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

# Load the package "reshape2"
library(reshape2)

# Get average of each varaiable for each subject and each activity
melt_data <- melt(merge_data, id=c("subject","activity"))
dcast_data <- dcast(melt_data, subject + activity ~ variable, mean)

# Write the result dataset to txt file and csv file
write.table(dcast_data, "./result_cleaning_dataset.txt")
write.csv(dcast_data, "./result_cleaning_dataset.csv", row.names=FALSE)



