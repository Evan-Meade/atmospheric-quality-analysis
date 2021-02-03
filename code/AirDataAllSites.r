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
#Reading data from file
site_info <- data.frame(site_state, site_id, site_type)
AllSiteData <- read.csv("AnnualConcentrationsNew.csv")

#Filtering data based on selected sites
Site1 <- AllSiteData[(AllSiteData$SITE_ID %in% site_info$site_id),]
Site1 <- Site1[order(Site1$YEAR),]
names(Site1) <- c("ID", "Year", "StartDate", "EndDate", "SO2", "SO4", "NO3", "HNO3", "TNO3", "NH4")
Site1_melt <- tidyr::gather(Site1, pollutant, value, SO2:NH4)

#Creating plot
Site1plot <- ggplot(Site1_melt, aes(x = Year, y = value, color = pollutant)) + 
  geom_smooth(na.rm = TRUE) + xlab('Year') + ylab('Pollutant Concentration (ug/m^3)') + 
  theme(plot.title = element_text(hjust = 0.5))
Site1plot <- Site1plot + labs(title = "All Sites Pollutant Average")
Site1plot