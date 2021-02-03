library(ggplot2)
library(tidyr)

#classifying data based on location and site type
site_state <- c("TEXAS", "ILLINOIS", "ILLINOIS", "MICHIGAN", "ILLINOIS", "PENNSYLVANIA",
                "PENNSYLVANIA", "TEXAS", "NORTH CAROLINA", "ILLINOIS", "KENTUCKY", "KENTUCKY",
                "NORTH CAROLINA", "NORTH CAROLINA", "NORTH CAROLINA", "OHIO", "OHIO", "NORTH CAROLINA",
                "COLORADO", "MICHIGAN", "PENNSYLVANIA", "KANSAS", "KANSAS", "KENTUCKY",
                "PENNSYLVANIA", "OHIO", "KENTUCKY", "KENTUCKY", "KENTUCKY", "COLORADO",
                "PENNSYLVANIA", "OHIO", "TEXAS", "KENTUCKY", "NORTH CAROLINA", "WISCONSIN",
                "PENNSYLVANIA", "OHIO", "MICHIGAN", "COLORADO", "COLORADO", "NORTH CAROLINA",
                "INDIANA", "ILLINOIS", "MICHIGAN", "INDIANA", "MINNESOTA", "MICHIGAN",
                "SOUTH DAKOTA", "CALIFORNIA", "CALIFORNIA", "FLORIDA", "CALIFORNIA", "FLORIDA")

site_id <- c("ALC188", "ALH157", "ALH257", "ANA115", "ANL146", "ARE128",
             "ARE228", "BBE401", "BFT142", "BVL130", "CDZ171", "CKT136",
             "CND125", "COW005", "COW137", "DCP114", "DCP214", "DUK008",
             "GTH161", "HOX148", "KEF112", "KIC003", "KNZ184", "LCW121",
             "LRL117", "LYK123", "MAC426", "MCK131", "MCK231", "MEV405",
             "MKG113", "OXF122", "PAL190", "PBF129", "PNF126", "PRK134",
             "PSU106", "QAK172", "RED004", "ROM206", "ROM406", "RTP101",
             "SAL133", "STK138", "UVL124", "VIN140", "VOY413", "WEL149",
             "WNC429", "PIN414", "JOT403", "IRL141", "DEV412", "EVE419")

# Site types: 1 - natural, a less habited area, away from major population centers
#             2 - urban, near a major city or high population area
#             3 - coastal, near an ocean
#             4 - agricultural

site_type <- c(1, 4, 4, 1, 2, 4, 
               4, 1, 3, 4, 4, 4,
               2, 1, 1, 1, 4, 1,
               1, 1, 2, 2, 2, 4,
               2, 4, 4, 2, 4, 1,
               1, 4, 4, 4, 1, 2,
               3, 2, 1, 1, 1, 2,
               4, 2, 4, 3, 1, 2,
               4, 3, 2, 3, 2, 3)

#reading data from file
SiteClassifcation <- data.frame(site_state, site_id, site_type)
AllSiteData <- read.csv("AnnualConcentrationsNew.csv")

#filtering data to selected sites
FilteredSiteData <- AllSiteData[(AllSiteData$SITE_ID %in% SiteClassifcation$site_id),]
names(FilteredSiteData) <- c("ID", "Year", "StartDate", "EndDate", "SO2", "SO4",
                             "NO3", "HNO3", "TNO3", "NH4")

#Creating vector of site type classification values
TempSiteType <- integer()
SiteTypeName <- factor()
for(i in 1:nrow(FilteredSiteData)) {
  for(j in 1:nrow(SiteClassifcation)){
    if(FilteredSiteData[i,1] == SiteClassifcation[j,2]){
      TempSiteType <- c(TempSiteType, SiteClassifcation[j,3])
    }
  }
}

#assigning each site's classification based on its type
for(i in TempSiteType) {
  if(i == 1) {
    SiteTypeName <- c(SiteTypeName, "natural")
  }
  if(i == 2) {
    SiteTypeName <- c(SiteTypeName, "urban")
  }
  if(i == 3) {
    SiteTypeName <- c(SiteTypeName, "coastal")
  }
  if(i == 4) {
    SiteTypeName <- c(SiteTypeName, "agricultural")
  }
}

#adding the type data to the data frame
FilteredSiteData$SiteTypeN <- factor(SiteTypeName)
FilteredSiteData$SiteType <- TempSiteType
FilteredSiteData2019 <- FilteredSiteData[FilteredSiteData$Year == 2019,]
str(FilteredSiteData)

#creating a plot for each gas
HNO3Plot <- ggplot(FilteredSiteData2019, aes(SiteTypeN, HNO3, fill = SiteTypeN)) +
  geom_boxplot() +
  geom_jitter(shape=16, position=position_jitter(0.2)) +
  labs(x = "Location Type", y = "Pollutant Concentration (ug/m^3)", title = "Nitric Acid(HNO3)") +
  theme(plot.title = element_text(hjust = 0.5))
HNO3Plot

NH4Plot <- ggplot(FilteredSiteData2019, aes(SiteTypeN, NH4, fill = SiteTypeN)) +
  geom_boxplot() +
  geom_jitter(shape=16, position=position_jitter(0.2)) +
  labs(x = "Location Type", y = "Pollutant Concentration (ug/m^3)", title = "Ammonium (NH4)") +
  theme(plot.title = element_text(hjust = 0.5))
NH4Plot

SO2Plot <- ggplot(FilteredSiteData2019, aes(SiteTypeN, SO2, fill = SiteTypeN)) +
  geom_boxplot() +
  geom_jitter(shape=16, position=position_jitter(0.2)) +
  labs(x = "Location Type", y = "Pollutant Concentration (ug/m^3)", title = "Sulfur Dioxide(SO2)") +
  theme(plot.title = element_text(hjust = 0.5))
SO2Plot

SO4Plot <- ggplot(FilteredSiteData2019, aes(SiteTypeN, SO4, fill = SiteTypeN)) +
  geom_boxplot() +
  geom_jitter(shape=16, position=position_jitter(0.2)) +
  labs(x = "Location Type", y = "Pollutant Concentration (ug/m^3)", title = "Sulfate (SO4)") +
  theme(plot.title = element_text(hjust = 0.5))
SO4Plot