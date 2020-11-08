# corn_exploration.r
# 
# Evan Meade, 2020
# 
# Here, we explore the corn crop quality dataset with some simple
# plots and metrics.
#


# Library imports
library(ggplot2)
library(GGally)

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
# NOTE: Used to be Excellent + Good + Fair, but changed after seeing
# that Fair has a negative correlation with Excellent and Good,
# suggesting that the natural pairing is just Excellent + Good
corn_flat$Prc.Positive <- corn_flat$Prc.Excellent + corn_flat$Prc.Good

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


# 
# Now I want to explore the data for the states we will be using, so I will
# create a new subset of our states.
# 

# Creating subset
# our_states <- names(sort(table(corn_flat$State), decreasing = TRUE)[1:17])
# NOTE: our_states was revised to be the intersection of the states with
# the most entries in corn_flat, and states which have EPA Castnet
# stations.
our_states <- c("COLORADO", "ILLINOIS", "INDIANA", "KANSAS", "KENTUCKY",
                "MICHIGAN", "MINNESOTA", "NORTH CAROLINA", "OHIO",
                "PENNSYLVANIA", "SOUTH DAKOTA", "TEXAS", "WISCONSIN",
                "US TOTAL")
corn_used <- corn_flat[which(corn_flat$State %in% our_states), ]

# Recreating smooth positive plot with our subset
all_state_pos_smooth <- ggplot(data = corn_used) +
  geom_smooth(mapping = aes(x = Week.Total, y = Prc.Positive, group = State, color = Geo.Level),
              method = "loess",
              formula = "y ~ x",
              se = FALSE)
print(all_state_pos_smooth)


# 
# I want to create a metric representing the gap between each state's smoothed 
# Prc.Positive and the national smoothed Prc.Positive. This creates a single
# metric which represents a state's performance relative to the country.
# 

# First, subsetting the data to have endpoints of all 17 states
# Allows the regressions to be totally interpolative
x <- table(corn_used$Week.Total)
week_min <- min(as.integer(names(x[which(x == length(our_states))])))
week_max <- max(as.integer(names(x[which(x == length(our_states))])))
corn_used_trimmed <- corn_used[which(corn_used$Week.Total %in% week_min:week_max), ]


# 
# I want to take a minute to summarize what I have done and want to do
# for this particular plot:
#   1. Combined 3 .csv files into one dataframe
#   2. Flattened dataframe so each row represents a unique time and place
#   3. Created Week.Total and Prc.Positive features
#   4. Trimmed to the states we used over an interpolative time interval
#   5. Ran a loess regression on each state (because of noisy data)
#   6. Calculated state - national loess estimation for each week
#   7. Created new dataframe with all the differences
#   8. Plotted new difference metric over time for all states
# 

# 
# Now to create loess values for each state, interpolate on all weeks
# contained here, and calculate differences from national.
# 

corn_loess <- data.frame()

natl_loess <- loess(Prc.Positive ~ Week.Total,
                    corn_used_trimmed[which(corn_used_trimmed$State == "US TOTAL"), ])

for (state in unique(corn_used_trimmed$State)) {
  state_loess <- loess(Prc.Positive ~ Week.Total,
                       corn_used_trimmed[which(corn_used_trimmed$State == state), ])
  
  state_col <- rep(state, (week_max - week_min + 1))
  week_col <- week_min:week_max
  if (state == "US TOTAL") {
    level_col <- rep("NATIONAL", (week_max - week_min + 1))
  } else {
    level_col <- rep("STATE", (week_max - week_min + 1))
  }
  diff_col <- predict(state_loess, week_col) - predict(natl_loess, week_col)
  
  state_df <- data.frame(state_col, week_col, level_col, diff_col)
  corn_loess <- rbind(corn_loess, state_df)
  # for (week in week_min:week_max) {
  #   pred_diff <- predict(state_loess)
  #   corn_loess <- rbind(corn_loess, c(state, week, ))
  # }
}
colnames(corn_loess) <- c("State", "Week.Total", "Geo.Level", "Natl.Diff")

loess_diff_plot <- ggplot(data = corn_loess) +
  geom_line(mapping = aes(x = Week.Total, y = Natl.Diff, group = State, color = State))
print(loess_diff_plot)


# 
# Before going further with this time series analysis, I want to try a few
# other non-time series plots. Namely, I want to see what correlations
# exist between the quality classes, if any.
# 

corn_pair_plots <- ggpairs(corn_flat[, 7:11])
print(corn_pair_plots)

corn_corr_plot <- ggcorr(corn_flat[, 7:11], label = TRUE)
print(corn_corr_plot)










