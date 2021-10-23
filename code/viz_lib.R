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
