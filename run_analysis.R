library(dplyr)
library(data.table)

## Build the training data set
## Check to see if it exists first to save time
if (!exists("training_data")) {
  table1 <- tbl_df(read.table("./train/subject_train.txt",
                              col.names = "subject"))
  table2 <- tbl_df(read.table("./train/y_train.txt", col.names = "label"))
  table3 <- tbl_df(read.table("./train/X_train.txt",
                              col.names = 1:561))

  training_data <- tbl_df(bind_cols(table1, table2, table3))
}

## Build the testing data set
if (!exists("testing_data")) {
  table1 <- tbl_df(read.table("./test/subject_test.txt",
                              col.names = "subject"))
  table2 <- tbl_df(read.table("./test/y_test.txt", col.names = "label"))
  table3 <- tbl_df(read.table("./test/X_test.txt",
                              col.names = 1:561))

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
    select(subject, label, X1:X6) %>%
    rename(MeanX = X1, MeanY = X2, MeanZ = X3, StdX = X4, StdY = X5, StdZ = X6)
  )
}


## Get activity labels
activity_labels = read.table("./activity_labels.txt",
                             col.names = c("label", "activity"))

## Switch activity labels for numerals
data <- tbl_df(extracted)
data <- tbl_df(data %>%
  merge(activity_labels, all = TRUE) %>%
  merge(activity_labels, all = TRUE) %>%
  select(-label)
)

sorted_data <- data %>%
  group_by(activity, subject) %>%
  summarize(
    meanX = mean(MeanX),
    meanY = mean(MeanY),
    meanZ = mean(MeanZ),
    stdX = mean(StdX),
    stdY = mean(StdY),
    stdZ = mean(StdZ)
  )

write.table(sorted_data, "./sorted_data.txt", sep = ",", row.names = FALSE)
