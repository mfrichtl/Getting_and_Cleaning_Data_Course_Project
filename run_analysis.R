library(dplyr)
library(data.table)

## Build the training data set
## Check to see if it exists first to save time
names <- as.vector((read.table("./features.txt"))[[2]])
if (!exists("training_data")) {
  table1 <- tbl_df(read.table("./train/subject_train.txt",
                              col.names = "subject"))
  table2 <- tbl_df(read.table("./train/y_train.txt", col.names = "label"))
  table3 <- tbl_df(read.table("./train/X_train.txt", col.names = names))

  training_data <- tbl_df(bind_cols(table1, table2, table3))
}

## Build the testing data set
if (!exists("testing_data")) {
  table1 <- tbl_df(read.table("./test/subject_test.txt",
                              col.names = "subject"))
  table2 <- tbl_df(read.table("./test/y_test.txt", col.names = "label"))
  table3 <- tbl_df(read.table("./test/X_test.txt", col.names = names))

  testing_data <- tbl_df(bind_cols(table1, table2, table3))
}

## Clean up temp files
rm(list = ls(pattern = "table"))

## Merging the two data sets
if (!exists("merged")) {
  merged <- tbl_df(merge(testing_data, training_data, all = TRUE))
}

## Extract the means and standard deviations for each data set
if (!exists("extracted")) {
  extracted <- tbl_df(merged %>%
    select(subject, label, contains("mean"), contains("std"))
  )
}


## Get activity labels
activity_labels = read.table("./activity_labels.txt",
                             col.names = c("label", "activity"))

## Switch activity labels for numerals
data <- tbl_df(extracted)
data <- tbl_df(data %>%
  merge(activity_labels, all = TRUE) %>%
  select(-label)
)

## Sort and summarize the data by subject and activity.
sorted_data <- data %>%
  group_by(activity, subject) %>%
  summarise_each(funs(mean))

## Save the tidy data set as a text file.
write.table(sorted_data, "./sorted_data.txt", row.names = FALSE)
