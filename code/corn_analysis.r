# corn_analysis.r
# 
# Evan Meade, 2020
# 
# This script generates the figures I used to explore, characterize,
# and analyze the corn crop quality data.
# 

# Library imports
library(ggplot2)
library(GGally)

# Reading in the corn_used.csv data
corn_used <- read.csv("data/synthesized/corn_used.csv", row.names = 1)


# 
# First, I wanted to explore just the national level data to see if
# there are any obvious nationwide trends over time. This can also
# serve as a baseline to compare states against.
#

# Creating National data subset
natl_corn <- corn_used[which(corn_used$Geo.Level == "NATIONAL"), ]

# FIGURE: natl_corn_point_plot.png
# 
# Scatter plot of national corn crop sample qualities over time.
quality_classes <- c("green", "greenyellow", "yellow", "orange", "red")
names(quality_classes) <- c("Excellent", "Good", "Fair", "Poor", "Very Poor")

natl_corn_point_plot <- ggplot(data = natl_corn) +
  geom_point(mapping = aes(x = Year.Frac, y = Prc.Excellent, color = "green")) +
  geom_point(mapping = aes(x = Year.Frac, y = Prc.Good, color = "greenyellow")) +
  geom_point(mapping = aes(x = Year.Frac, y = Prc.Fair, color = "yellow")) +
  geom_point(mapping = aes(x = Year.Frac, y = Prc.Poor, color = "orange")) +
  geom_point(mapping = aes(x = Year.Frac, y = Prc.VeryPoor, color = "red")) +
  labs(title = "National Corn Crop Sample Qualities Over Time",
       x = "Year",
       y = "Percentage of Sample") +
  scale_color_identity(name = "Quality Level",
                       guide = "legend",
                       breaks = quality_classes,
                       labels = names(quality_classes))
print(natl_corn_point_plot)

# FIGURE: natl_corn_smooth_plot.png
# 
# Locally regressed curves providing a smooth fit of each crop quality class
# over time. Helps expose long term trends and removes some noise.
natl_corn_smooth_plot <- ggplot(data = natl_corn) +
  geom_smooth(mapping = aes(x = Year.Frac, y = Prc.Excellent, color = "green"),
              method = "loess", formula = "y ~ x") +
  geom_smooth(mapping = aes(x = Year.Frac, y = Prc.Good, color = "greenyellow"),
              method = "loess", formula = "y ~ x") +
  geom_smooth(mapping = aes(x = Year.Frac, y = Prc.Fair, color = "yellow"),
              method = "loess", formula = "y ~ x") +
  geom_smooth(mapping = aes(x = Year.Frac, y = Prc.Poor, color = "orange"),
              method = "loess", formula = "y ~ x") +
  geom_smooth(mapping = aes(x = Year.Frac, y = Prc.VeryPoor, color = "red"),
              method = "loess", formula = "y ~ x") +
  labs(title = "National Corn Crop Sample Qualities Over Time, Locally Smoothed",
       x = "Year",
       y = "Percentage of Sample") +
  scale_color_identity(name = "Quality Level",
                       guide = "legend",
                       breaks = quality_classes,
                       labels = names(quality_classes))
print(natl_corn_smooth_plot)


# FIGURE: corn_corr_plot.png
# 
# Correlations between each pair of corn crop quality levels.
corn_corr_plot <- ggcorr(corn_used[, 7:11], label = TRUE) +
  labs(title = "Corn Crop Quality Level Correlations")
print(corn_corr_plot)


# 
# Creating a new metric which summarizes the corn crop quality data
# by combining the "Excellent" and "Good" categories since they have
# negative correlations with all the others.
# 

# Defining new metric as Prc.Positive
corn_used$Prc.Positive <- corn_used$Prc.Excellent + corn_used$Prc.Good


# FIGURE: all_states_pos_smooth.png
# 
# Plotting smoothed Prc.Positive curves for each state/national average.
all_states_pos_smooth <- ggplot(data = corn_used) +
  geom_smooth(mapping = aes(x = Year.Frac, y = Prc.Positive,
                            group = State, color = Geo.Level),
              method = "loess",
              formula = "y ~ x",
              se = FALSE) +
  labs(title = "Positive USDA Corn Crop Quality Over Time, Locally Smoothed *",
       x = "Year",
       y = "Percentage of Sample",
       caption = "* metric representing the percentage of a sample which is of excellent or good quality") +
  scale_color_discrete("Sampling Level",
                       labels = c("National", "State"))
print(all_states_pos_smooth)


# 
# I want to create a metric representing the gap between each state's smoothed 
# Prc.Positive and the national smoothed Prc.Positive. This creates a single
# metric which represents a state's performance relative to the country.
# 

# First, subsetting the data to have endpoint weeks containing all states
# Allows the regressions to be totally interpolative
x <- table(corn_used$Week.Total)
num_states <- length(unique(corn_used$State))
week_min <- min(as.integer(names(x[which(x == num_states)])))
week_max <- max(as.integer(names(x[which(x == num_states)])))
corn_used_trimmed <- corn_used[which(corn_used$Week.Total %in% week_min:week_max), ]

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
}
colnames(corn_loess) <- c("State", "Week.Total", "Geo.Level", "Natl.Diff")
corn_loess$Year.Frac <- corn_loess$Week.Total / 52 + 1986


# FIGURE: states_pos_norm_smooth_plot.png
# 
# Each state's performance in the Prc.Positive metric, locally smoothed
# with loess to reduce noise. Normalized nationally by subtracting the
# national smoothed loess curve.
states_pos_norm_smooth_plot <- ggplot(data = corn_loess) +
  geom_line(mapping = aes(x = Year.Frac, y = Natl.Diff, group = State, color = State),
            size = 1.5) +
  labs(title = "USDA Corn Crop Quality Over Time (Normalized Nationally)",
       x = "Year",
       y = "Percentage of Sample w/ Positive Quality *",
       caption = "* metric representing the percentage of a sample which is of excellent or good quality")
print(states_pos_norm_smooth_plot)
