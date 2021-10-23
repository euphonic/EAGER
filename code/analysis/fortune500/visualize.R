# this script visualizes fortune 500 employment figures vs. employment figures gathered from this project's secondary data collection 
# SanjayKAroraPhD@gmail.com
# march 2020

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)
# library(rjags)
# library(MVN)
library(stats)
library(scales)
# MacOS
setwd("/Users/sanjay/dev/EAGER/code/analysis/fortune500/")
in.emps <- read.csv("to_visualize_in_R.csv", header = TRUE, stringsAsFactors = FALSE)
View (in.emps)
# load (".RData")

is.numeric(in.emps$max_emps)
in.emps$emps <- as.numeric(gsub(",", "", in.emps$emps))
is.numeric(in.emps$emps)

in.emps$log_emps <- log(in.emps$emps)
in.emps$log_max_emps <- log(in.emps$max_emps)

View (in.emps)
shapiro.test(in.emps$max_emps)
shapiro.test(in.emps$emps)

cor.test(in.emps$max_emps, in.emps$emps, alternative="two.sided", method="kendall" )
cor.test(in.emps$max_emps, in.emps$emps, alternative="two.sided", method="spearman" )
cor.test(in.emps$max_emps, in.emps$emps, alternative="two.sided", method="pearson" )

shapiro.test(in.emps$log_max_emps)
shapiro.test(in.emps$log_emps)

cor.test(in.emps$log_max_emps, in.emps$log_emps, alternative="two.sided", method="kendall" )
cor.test(in.emps$log_max_emps, in.emps$log_emps, alternative="two.sided", method="spearman" )
cor.test(in.emps$log_max_emps, in.emps$log_emps, alternative="two.sided", method="pearson" )


# BASIC THEME
theme.eager_chart <- 
  theme(legend.position = "right") +
  theme(plot.title = element_text(size=26, family="Trebuchet MS", face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=18, family="Trebuchet MS", face="bold", color="#666666")) +
  theme(legend.title= element_text(size=14, family="Trebuchet MS", color="black")) +
  theme(legend.text = element_text(size=12, family="Trebuchet MS", color="black")) +
  theme(axis.text.x = element_text(size=12, family="Trebuchet MS", color="black")) +
  theme(axis.text.y = element_text(size=12, family="Trebuchet MS", color="black")) +
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

g1 <- ggplot(data=in.emps, aes(x=log_emps, y=log_max_emps)) +
  geom_point(alpha=.4, size=4, color="#0037ff") +
  labs(x="Log Fortune Employees", y="Log\nScraped\nEmployees") + 
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g1

g2 <- ggplot(data=in.emps, aes(x=emps, y=max_emps)) +
  geom_point(alpha=.4, size=2, color="#0037ff") +
  labs(x="Fortune Employees", y="Scraped\nEmployees") + 
  geom_smooth(method = "lm") +
  scale_x_continuous(label=comma, limits=c(0,700000), breaks=seq(0,700000,by=100000)) +
  scale_y_continuous(label=comma, limits=c(0,505000), breaks=seq(0,500000,by=100000)) +
  theme.eager_chart_SCATTER
g2
# ggsave("../../analysis/model_accuracy_bar_v2.png")