# epa_weekly_synthesis.r
# 
# Evan Meade, 2020
# 
# This script reads in the weekly filter pack data from the EPA
# and restructures it into a form that works well with the corn
# crop quality data. Namely, it calculates weeks and states for each
# entry, so that a master dataset can be constructed for weekly
# corn and atmospheric data.
# 


# First we read in the weekly EPA filter pack data
epa <- read.csv("data/raw/epa_weekly_filter_packs.csv")

# Then we add a state column using our knowledge of SITE_ID


# Now we extract the year for each observation from the DATEOFF







