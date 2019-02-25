# just visualize about model accuracy results

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)
library(scales)

setwd("/Users/sarora/dev/EAGER/data/orgs/about/")

# load data
in.res <- read.csv("about_model_training_results_toR.csv", header = TRUE, stringsAsFactors = FALSE)
in.res


#--------------
# Create Theme
#--------------

# BASIC THEME
theme.eager_chart <- 
  theme(legend.position = "none") +
  theme(plot.title = element_text(size=26, family="Trebuchet MS", face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=18, family="Trebuchet MS", face="bold", color="#666666")) +
  theme(axis.title.y = element_text(angle=0)) 

# SCATTERPLOT THEME
theme.eager_chart_SCATTER <- theme.eager_chart +
  theme(axis.title.x = element_text(hjust=0, vjust=-.5))

# LINE THEME
theme.eager_chart_LINE <- theme.eager_chart +
  theme(axis.title.x = element_text(hjust=0, vjust=-.5))

# HISTOGRAM THEME
theme.eager_chart_HIST <- theme.eager_chart +
  theme(axis.title.x = element_text(hjust=0, vjust=-.5))

# SMALL MULTIPLE THEME
theme.eager_chart_SMALLM <- theme.eager_chart +
  theme(panel.grid.minor = element_blank()) +
  theme(strip.text.x = element_text(size=16, family="Trebuchet MS", face="bold", color="#666666")) 

g10.df <- in.res[c(1,3,4,6,7,9) ,]
g10.df
colnames(g10.df)

g10 <- ggplot(data=g10.df, aes(x=Name)) +
  geom_line(aes(y=Count.based.features, colour="var0"), group=1, size=1.25) +
  geom_point(aes(y=Count.based.features)) + 
  geom_line(aes(y=Text.features, colour="var1"), group=1, size=1.25) +
  geom_point(aes(y=Text.features)) + 
  # geom_line(aes(y=All.features.minus.header.text, colour="var2"), group=1, size=1.25) +
  geom_line(aes(y=All.features, colour="var3"), group=1, size=1.25) +
  geom_point(aes(y=All.features)) + 
  labs(x="Name", y="Accuracy") + 
  theme.eager_chart_SCATTER
g10


theme(legend.direction = 'horizontal', 
      legend.position = 'bottom',
      legend.key = element_rect(size = 5),
      legend.key.size = unit(1.5, 'lines'),
      legend.title=element_blank()
)

test_data <-
  data.frame(
    var0 = 100 + c(0, cumsum(runif(49, -20, 20))),
    var1 = 150 + c(0, cumsum(runif(49, -10, 10))),
    date = seq(as.Date("2002-01-01"), by="1 month", length.out=100)
  )

head(test_data)
ggplot(test_data, aes(date)) + 
  geom_line(aes(y = var0, colour = "var0")) + 
  geom_line(aes(y = var1, colour = "var1"))