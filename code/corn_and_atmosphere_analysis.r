# corn_and_atmosphere_analysis.r
# 
# Evan Meade, 2020
# 
# Here, we unite the analyses of corn and atmospheric quality over
# time to investigate any possible correlations between the two.
# 

# Library imports
library(ggplot2)
library(GGally)

# Reading in the epa_usda_matched.csv data
epa_trimmed <- read.csv("data/synthesized/epa_usda_matched.csv", row.names = 1)


# 
# First, we explore the possible correlations between trace gas
# concentrations and our positive crop quality metric from the corn
# analysis. Then, we investigate specific examples to find


# FIGURE: corn_atmo_corr.png
# 
# Correlation matrix for each of the trace gas concentrations and the
# positive corn quality metric constructed in the corn crop analysis
# (normalized nationally).
corn_atmo_corr <- ggcorr(epa_trimmed[, c(5:18, 22)], label = TRUE) +
  labs(title = "Trace Gas and Corn Crop Quality Correlations")
print(corn_atmo_corr)


# FIGURE: natl_diff_ca.png
# 
# Scatter plot of samples' positive crop quality plotted against
# atmospheric calcium concentration.
natl_diff_ca <- ggplot(data = epa_trimmed) +
  geom_point(mapping = aes(x = CA, y = Natl.Diff)) +
  labs(title = "Positive Crop Quality vs. Atmospheric Calcium Concentrations",
       x = "Calcium Concentration (ug/m^3)",
       y = "Percentage of Sample w/ Positive Crop Quality *",
       caption = "* metric representing the percentage of a sample which is of excellent or good quality")
print(natl_diff_ca)


# FIGURE: natl_difff_so4.png
# 
# Scatter plot of samples' positive crop quality plotted against
# atmospheric sulfate concentration.
natl_diff_so4 <- ggplot(data = epa_trimmed) +
  geom_point(mapping = aes(x = TSO4, y = Natl.Diff)) +
  labs(title = "Positive Crop Quality vs. Atmospheric Sulfate Concentrations",
       x = "Sulfate Concentration (ug/m^3)",
       y = "Percentage of Sample w/ Positive Crop Quality *",
       caption = "* metric representing the percentage of a sample which is of excellent or good quality")
print(natl_diff_so4)


# 
# The scatter plots are a bit hard to read because there is so
# much overlap between the points. So a box plot is probably better
# for examining the relationship between the distributions.
# 

# Binning crop quality metric due to high grouping
epa_trimmed$Natl.Diff.Rounded <- as.factor(floor(epa_trimmed$Natl.Diff / 10) * 10)

# FIGURE: natl_diff_so4_box_plot.png
# 
# Box plot of binned corn crop quality metric against sulfate
# concentrations.
natl_diff_so4_box_plot <- ggplot(data = epa_trimmed) +
  geom_boxplot(mapping = aes(x = Natl.Diff.Rounded, y = TSO4, color = Natl.Diff.Rounded),
               show.legend = FALSE) +
  labs(title = "Distributions of Sulfate (SO4) Concentrations Grouped by Crop Quality",
       x = "Percentage of Sample w/ Positive Quality, Rounded Down *",
       y = "Sulfate Concentration (ug/m^3)",
       caption = "* metric representing the percentage of a sample which is of excellent or good quality")
print(natl_diff_so4_box_plot)
