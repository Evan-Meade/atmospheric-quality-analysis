# corn_synthesizer.r
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

