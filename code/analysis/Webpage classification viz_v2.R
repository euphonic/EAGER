# just visualize about model accuracy results

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)
library(scales)
library(reshape2)

setwd("/Users/Sanjay/dev/EAGER/data/orgs/about/")

# load data
in.res <- read.csv("about_model_training_results_toR.csv", header = TRUE, stringsAsFactors = FALSE)
in.res


#--------------
# Create Theme
#--------------

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

g10.df <- in.res[c(1,3,4,6,7,9) , c(1,2,3,5)]
g10.df
colnames(g10.df)

g10.melt <- melt(g10.df, id.vars='Name')

newline.labels = c("AdaBoost", "Decision\nTree", "Nearest\nNeighbors", "Neural\nNet", "RBF\nSVM", "SVC")

g10.a <- ggplot(data=g10.melt, aes(x=Name, y=value)) +
  geom_bar(aes(fill = variable), position = "dodge", stat="identity") + 
  labs(x="Classifier", y="Accuracy") + 
  scale_x_discrete(labels=newline.labels) + 
  scale_fill_manual(values=c("#999999", "#195377", "#56B4E9"), 
                    name="Feature set",
                    labels=c("Count only", "Text only", "All features")) + 
  scale_y_continuous(limits=c(0,.9), breaks=seq(0,.9,by=.2)) +
  theme.eager_chart_HIST
g10.a
ggsave("../../analysis/model_accuracy_bar_v2.png")

g10.b <- ggplot(data=g10.melt, aes(x=Name, y=value, group=variable, colour=variable)) +
  geom_line(size=1.25) + 
  geom_point(size=1.25) + 
  labs(x="Model", y="Accuracy") + 
  theme.eager_chart_LINE
g10.b

