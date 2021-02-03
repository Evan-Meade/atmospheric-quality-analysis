# corn_epa_cleaning.r
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
site_states <- c("TEXAS", "ILLINOIS", "ILLINOIS", "MICHIGAN", "ILLINOIS", "PENNSYLVANIA",
                 "PENNSYLVANIA", "TEXAS", "NORTH CAROLINA", "ILLINOIS", "KENTUCKY", "KENTUCKY",
                 "NORTH CAROLINA", "NORTH CAROLINA", "NORTH CAROLINA", "OHIO", "OHIO", "NORTH CAROLINA",
                 "COLORADO", "MICHIGAN", "PENNSYLVANIA", "KANSAS", "KANSAS", "KENTUCKY",
                 "PENNSYLVANIA", "OHIO", "KENTUCKY", "KENTUCKY", "KENTUCKY", "COLORADO",
                 "PENNSYLVANIA", "OHIO", "TEXAS", "KENTUCKY", "NORTH CAROLINA", "WISCONSIN",
                 "PENNSYLVANIA", "OHIO", "MICHIGAN", "COLORADO", "COLORADO", "NORTH CAROLINA",
                 "INDIANA", "ILLINOIS", "MICHIGAN", "INDIANA", "MINNESOTA", "MICHIGAN",
                 "SOUTH DAKOTA")
names(site_states) <- c("ALC188", "ALH157", "ALH257", "ANA115", "ANL146", "ARE128",
                        "ARE228", "BBE401", "BFT142", "BVL130", "CDZ171", "CKT136",
                        "CND125", "COW005", "COW137", "DCP114", "DCP214", "DUK008",
                        "GTH161", "HOX148", "KEF112", "KIC003", "KNZ184", "LCW121",
                        "LRL117", "LYK123", "MAC426", "MCK131", "MCK231", "MEV405",
                        "MKG113", "OXF122", "PAL190", "PBF129", "PNF126", "PRK134",
                        "PSU106", "QAK172", "RED004", "ROM206", "ROM406", "RTP101",
                        "SAL133", "STK138", "UVL124", "VIN140", "VOY413", "WEL149",
                        "WNC429")
epa$State <- site_states[epa$SITE_ID]

# Now we extract the year and week number for each observation from the DATEOFF
epa_time_obj <- strptime(epa$DATEOFF, format = "%m/%d/%Y %H:%M:%S")
epa$Year <- as.integer(strftime(epa_time_obj, format = "%Y"))
epa$Week <- as.integer(strftime(epa_time_obj, format = "%V"))

# To reduce matching difficulties for fractional 53rd weeks, we group them with 52nd weeks
epa[which(epa$Week == 53), "Week"] <- 52

# We can save this version of epa which leaves the sites separate
# After this, we will link EPA and USDA data
write.csv(epa, "data/synthesized/epa_weekly_filter_packs__all_sites.csv")


# Making a copy of epa measurements trimmed down to useful columns
col_order <- c(26, 27, 28, 1, 5:18)
epa_trimmed <- data.frame(epa[col_order])
epa_trimmed$Count <- rep(1, nrow(epa_trimmed))

# Labeling rows in the regression dataframe by state and time for matching
for (i in 1:nrow(corn_loess)) {
  obs_label <- paste0(corn_loess[i, "State"], "-", corn_loess[i, "Week.Total"])
  corn_loess[i, "Obs.Label"] <- obs_label
}

# Matching EPA and USDA data by state and time
for (i in 1:nrow(epa_trimmed)) {
  week_total <- (epa_trimmed[i, "Year"] - 1986) + epa_trimmed[i, "Week"]
  epa_trimmed[i, "Week.Total"] <- week_total
  obs_label <- paste0(epa_trimmed[i, "State"], "-", week_total)
  epa_trimmed[i, "Obs.Label"] <- obs_label
  if (obs_label %in% corn_loess$Obs.Label) {
    epa_trimmed[i, "Natl.Diff"] <- corn_loess[which(corn_loess$Obs.Label == obs_label), "Natl.Diff"]
  }
}

# Saving matched data to file
write.csv(epa_trimmed, "data/synthesized/epa_usda_matched.csv")
