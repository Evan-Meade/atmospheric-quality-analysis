# corn_exploration.r
# 
# Evan Meade, 2020
# 
# Here, we explore the corn crop quality dataset with some simple
# plots and metrics.
#


# Library imports
library(ggplot2)

# Reading in the corn_flat.csv data
corn_flat <- read.csv("data/synthesized/corn_flat.csv", row.names = 1)

# Creating time variable to help plot all of the data on the same scale
corn_flat$Week.Total <- (corn_flat$Year - 1986) * 52 + corn_flat$Week

# 
# For simplicity, I am going to start by analyzing just the Texas
# data. It has the most observations of any state, so it will be good
# for partial analysis.
# 

# New metric which is the percentage of excellent, good, or fair corn
corn_flat$Prc.Positive <- corn_flat$Prc.Excellent + corn_flat$Prc.Good + corn_flat$Prc.Fair

# Creating Texas data subset
texas_corn <- corn_flat[which(corn_flat$State == "TEXAS"), ]

# Creating National data subset
natl_corn <- corn_flat[which(corn_flat$Geo.Level == "NATIONAL"), ]

# Plotting Texas quality over time
texas_quality_over_time <- ggplot(data = texas_corn) +
  geom_line(mapping = aes(x = Week.Total, y = Prc.Excellent), color = "green") +
  geom_line(mapping = aes(x = Week.Total, y = Prc.Good), color = "greenyellow") +
  geom_line(mapping = aes(x = Week.Total, y = Prc.Fair), color = "yellow") +
  geom_line(mapping = aes(x = Week.Total, y = Prc.Poor), color = "pink") +
  geom_line(mapping = aes(x = Week.Total, y = Prc.VeryPoor), color = "red")
print(texas_quality_over_time)

texas_smooth_quality_over_time <- ggplot(data = texas_corn) +
  geom_smooth(mapping = aes(x = Week.Total, y = Prc.Excellent), color = "green") +
  geom_smooth(mapping = aes(x = Week.Total, y = Prc.Good), color = "greenyellow") +
  geom_smooth(mapping = aes(x = Week.Total, y = Prc.Fair), color = "yellow") +
  geom_smooth(mapping = aes(x = Week.Total, y = Prc.Poor), color = "pink") +
  geom_smooth(mapping = aes(x = Week.Total, y = Prc.VeryPoor), color = "red")
print(texas_smooth_quality_over_time)

texas_quality_by_week <- ggplot(data = texas_corn) +
  geom_point(mapping = aes(x = Week, y = Prc.Excellent, col = Year)) +
  scale_color_gradient(low = "yellow", high = "red")
print(texas_quality_by_week)


texas_natl_pos_over_time <- ggplot() +
  geom_point(mapping = aes(x = texas_corn$Week.Total, y = texas_corn$Prc.Positive),
            color = "orange") +
  geom_point(mapping = aes(x = natl_corn$Week.Total, y = natl_corn$Prc.Positive),
            color = "gray") +
  geom_smooth(mapping = aes(x = texas_corn$Week.Total, y = texas_corn$Prc.Positive),
              color = "red") +
  geom_smooth(mapping = aes(x = natl_corn$Week.Total, y = natl_corn$Prc.Positive),
              color = "black")
print(texas_natl_pos_over_time)


# all_state_pos_smooth <- ggplot()
# for (state in unique(corn_flat$State)[1:2]) {
#   state_data <- corn_flat[which(corn_flat$State == state), ]
#   all_state_pos_smooth <- all_state_pos_smooth +
#     geom_smooth(mapping = aes(x = state_data$Week.Total, y = state_data$Prc.Positive))
# }
all_state_pos_smooth <- ggplot(data = corn_flat) +
  geom_smooth(mapping = aes(x = Week.Total, y = Prc.Positive, group = State, color = Geo.Level))
print(all_state_pos_smooth)


