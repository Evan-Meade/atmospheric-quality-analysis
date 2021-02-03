# atmospheric-quality-analysis
Group project at UT Dallas for STAT 3355 - Data Analysis, exploring atmospheric and crop quality over time


[**Evan Meade**](https://github.com/Evan-Meade) (Team Leader), Enrique Cardenas, Jay Shah

![Example slide highlighting Evan's engineered corn crop quality metric over time](example_slide.png)

*Example slide highlighting Evan's engineered corn crop quality metric over time*

**For full results, see `Report.pdf`. For a visual summary, see `Presentation.pdf`.**

## Motivation

We wanted to see if we could highlight a specific effect of environmental degradation using large datasets and rigorous statistical techniques. In particular, we sought to investigate the impact of atmospheric conditions on crop health. Corn was our crop of choice because it is the most widely grown feed grain in the United States, and has a large historical dataset associated with its cultivation. This makes it a useful barometer for tracking environmental impacts over time.

## Data

Our atmospheric data was sourced from the EPA's [CASTNET database](https://java.epa.gov/castnet/clearsession.do), which provides hourly, daily, and weekly measurements of atmospheric conditions and trace gas concentrations. Selecting our indicators from 54 reporting locations, this amounted to 12,782 observations of 11 variables.

Our corn crop quality data was sourced from the USDA's [National Agricultural Statistics Service](https://quickstats.nass.usda.gov), which grades weekly corn samples from across the country according to 5 quality levels. Here we selected all historical data, amounting to 84,023 observations of 21 variables.

Taking the geographical intersection of these two datasets, we reduced our dataset to 13 states tracked from 1990 to 2020.

## Summary of Methods

**NOTE:** *We had to redo the file structure in order to put this repo in final submission format. Some of the code may reference file locations which have changed, but the scripts are otherwise fully functional.*

We divided analysis into three sections: atmospheric, crop, and comparative.

In the atmospheric analysis, the EPA data was cleaned and visualized to highlight the differences in trace gases over time. Then, reporting locations were categorized by type, and concentration distributions plotted by environmental type.

In the corn crop analysis, Evan engineered a scalar metric to describe all five quality categories at once. This metric was plotted over time for each state, showing which states under- or over-performed over time (relative to the national average).

In the comparative analysis, Evan plotted this engineered metric against different trace gas concentrations to look for a correlation.

## Conclusions

It was visually shown that crops which overperform relative to the national average are strongly correlated with lower sulfate concentrations. This is likely connected to acid rain, since higher atmospheric sulfate concetrations lead to more acid rain, which can harm plants.

This is a specific impact of environmental degradation which negatively impacts plant life. Therefore, we were able to meet our goal by demonstrating this effect using data and statistical techniques.
