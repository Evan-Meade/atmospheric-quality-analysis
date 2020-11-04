# corn_synthesis.r
# 
# Evan Meade, 2020
# 
# This script reads the raw corn crop quality .csv files and combines
# them into a single synthesized .csv. As noted in the README, the NASS
# data portal only allows for 50,000 results to be returned at once,
# which means a dataset of this size requires multiple downloads.
# 


# First we read in each of the files as their own dataframes
corn_1 <- read.csv("data/raw/corn_quality__excellent_fair.csv")
corn_2 <- read.csv("data/raw/corn_quality__good_poor.csv")
corn_3 <- read.csv("data/raw/corn_quality__verypoor.csv")

# Now we combine the individual dataframes into a master dataframe
corn <- rbind(corn_1, corn_2, corn_3)


# 
# If you look at the dataframe at this point, you will see a number of
# columns which only have 1 value. In other words, they provide no
# information. They are likely vestigial variables from other USDA
# analysis.
# 
# Most of these columns simply have all null values, likely due to
# being irrelevant to the dataset at hand. Some simply have only one
# value. Either way, we will remove them because they are cluttering
# up our analysis and not providing any value.
# 

# Finding all columns with only one value
drop_cols <- c()
for (var in colnames(corn)) {
  unique_count <- length(unique(corn[, var]))
  if (unique_count == 1) {
    drop_cols <- c(drop_cols, var)
  }
}

# Dropping all columns with only one value
corn <- corn[, setdiff(colnames(corn), drop_cols)]


# 
# Now, we would like to combine all 5 quality variables for each sample.
# We can do this by noting that each sample has the same time and location
# data. Then, we split on this for the 5 values we seek.
# 

# Creating new row names for more convenient indexing
obs_id <- c()
for (i in 1:nrow(corn)) {
  new_id <- paste0(corn[i, "State"], "-", corn[i, "Week.Ending"])
  obs_id <- c(obs_id, new_id)
}
obs_id <- unique(obs_id)

# Creating new dataframe for flattened corn data, one row per observation
corn_flat <- unique(data.frame(corn[1:6]))
rownames(corn_flat) <- obs_id

# Fill with values form original corn dataframe, replace data NA with 0
for (i in 1:nrow(corn)) {
  new_id <- paste0(corn[i, "State"], "-", corn[i, "Week.Ending"])
  data_var <- corn[i, "Data.Item"]
  data_value <- corn[i, "Value"]
  corn_flat[new_id, data_var] <- data_value
}
corn_flat[, 7:11][is.na(corn_flat[, 7:11])] <- 0


# 
# Now we just polish the dataframe by renaming, recasting, and
# reordering the columns. Then, we save it to a new .csv file for
# easy reading in the future.
# 

# Renaming and rearranging data columns in corn_flat for readability
colnames(corn_flat) <- c("Year", "Week", "Week.Ending",
                         "Geo.Level", "State", "State.ANSI",
                         "Prc.Excellent", "Prc.Fair", "Prc.Good",
                         "Prc.Poor", "Prc.VeryPoor")
col_order <- c(1, 2, 3, 4, 5, 6, 7, 9, 8, 10, 11)
corn_flat <- corn_flat[col_order]

# Substituting week with the actual number
for (i in 1:nrow(corn_flat)) {
  corn_flat[i, "Week"] <- substr(corn_flat[i, "Week"], 7, 8)
}
corn_flat$Week <- as.integer(corn_flat$Week)

# Sort rows by row names
corn_flat <- corn_flat[order(rownames(corn_flat)), ]


# Save final corn_flat to synthesized .csv file
write.csv(corn_flat, file = "data/synthesized/corn_flat.csv")
