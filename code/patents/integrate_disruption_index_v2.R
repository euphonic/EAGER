# integrate eager assignee cross-section with funk et al. disruption index measures
# available at http://russellfunk.org/cdindex/data.html
# sanjaykaroraphd@gmail.com
# september 2019

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)
# MacOS
setwd("/Users/Sanjay.K.Arora/dev/EAGER/data/patents/measures")


#--------------
# Create Theme
#--------------

source(file.path("/Users/Sanjay.K.Arora/dev/EAGER/code/viz_lib.R"))

# load patent data
in.flm <- read.csv ("firm_level_measures.csv", header = TRUE, stringsAsFactors = FALSE)
in.a2p <- read.csv ("assignee-2-patent-lookup.csv", header = TRUE, stringsAsFactors = FALSE)

head(in.flm)
head(in.a2p)
nrow(in.a2p)

# load disruption measures and grab the project patent numbers 
in.di <- read.csv ("/Users/Sanjay.K.Arora/data/web_of_innovation/cd_index_20210819.csv", header = TRUE, stringsAsFactors = FALSE)
in.di$patent_number_char <- as.character(in.di$patent_id)
head (in.di)
nrow(in.di)

a2p_di <- in.a2p %>% inner_join(in.di, by = c( "patent_id" = "patent_number_char"))
View (a2p_di)
nrow(in.a2p)
head(a2p_di)
colnames(a2p_di)
length(unique(a2p_di$lookup_firm)) # 1472, which is the number of firms from the study's sample period of time 
data.class (a2p_di$lookup_firm)

table(a2p_di$cd_index_5)

View(a2p_di[order(a2p_di$lookup_firm, decreasing = TRUE), ])
View (a2p_di[a2p_di$lookup_firm == '3M Innovative Properties Company', ])

# group measure by lookup firm
cd_mean_by_firm <- a2p_di %>% group_by(lookup_firm) %>% 
  summarize(mean_cd_index = mean(cd_index_5, na.rm=TRUE))
View (cd_mean_by_firm)

# impure nans with 1
nrow(cd_mean_by_firm[is.nan(cd_mean_by_firm$mean_cd_index), ])
cd_mean_by_firm$imputed = 0
cd_mean_by_firm[is.nan(cd_mean_by_firm$mean_cd_index), which(colnames(cd_mean_by_firm)=="imputed")] = 1
cd_mean_by_firm[is.nan(cd_mean_by_firm$mean_cd_index), which(colnames(cd_mean_by_firm)=="mean_cd_index")] = -1

# predict disruption as a function of industry, year of first patent, employee size 
flm_cd_mean <- in.flm %>% inner_join(cd_mean_by_firm, by = c( "lookup_firm" = "lookup_firm"))
flm_cd_mean['log_max_emps'] = log(flm_cd_mean['max_emps'])
flm_cd_mean['log_num_patents_all'] = log(flm_cd_mean['num_patents_all'])
flm_cd_mean_sub = flm_cd_mean[flm_cd_mean$max_emps <= 500, ]
View (flm_cd_mean_sub)


controls.fit = lm(mean_cd_index ~ nano + green + log_max_emps + log_num_patents_all, data=flm_cd_mean)
summary(controls.fit)

g1 <- ggplot(data=cd_mean_by_firm, aes(x=mean_cd_index)) +
  geom_histogram(binwidth=0.01) +
  theme.eager_chart_HIST
g1

# write out
write.csv(cd_mean_by_firm, "cd_mean_by_firm_2021.csv", row.names = FALSE)
