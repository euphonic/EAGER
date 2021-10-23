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

# load patent data
in.flm <- read.csv ("firm_level_measures.csv", header = TRUE, stringsAsFactors = FALSE)
in.a2p <- read.csv ("assignee-2-patent-lookup.csv", header = TRUE, stringsAsFactors = FALSE)

head(in.flm)
head(in.a2p)
nrow(in.a2p)

# load disruption measures and grab the project patent numbers 
in.di <- read.csv ("/Users/Sanjay.K.Arora/data/web_of_innovation/cdindex_cross_20190513.csv", header = TRUE, stringsAsFactors = FALSE)
in.di$patent_number_char <- as.character(in.di$patent_number)
head (in.di)
nrow(in.di)

a2p_di <- in.a2p %>% inner_join(in.di, by = c( "patent_id" = "patent_number_char"))
View (a2p_di)
nrow(in.a2p)
head(a2p_di)
colnames(a2p_di)
length(unique(a2p_di$lookup_firm)) # 1472, which is the number of firms from the study's sample period of time 
data.class (a2p_di$lookup_firm)
# a2p_di$cd_2017y_clnd <- a2p_di$cd_2017y
# View(a2p_di[a2p_di$cd_2017y_clnd == '\\N',])
# a2p_di[a2p_di$cd_2017y_clnd == '\\N',15] <- 0
# a2p_di$cd_2017y_clnd <- as.numeric(a2p_di$cd_2017y_clnd)

table(a2p_di$cd_2017y)

View(a2p_di[order(a2p_di$lookup_firm, decreasing = TRUE), ])
View (a2p_di[a2p_di$lookup_firm == '3M Innovative Properties Company', ])

# group measure by lookup firm
i2017y_mean_by_firm <- a2p_di %>% group_by(lookup_firm) %>% 
  summarize(mean_i2017y = mean(i_2017y, na.rm=TRUE))
head(i2017y_mean_by_firm)

# group measure by lookup firm
cd_2017y_mean_by_firm <- a2p_di %>% group_by(lookup_firm) %>% 
  summarize(mean_cd2017y = mean(cd_2017y, na.rm=TRUE))
head(cd_2017y_mean_by_firm)

View (cd_2017y_mean_by_firm)

# write out
write.csv(i2017y_mean_by_firm, "i2017y_mean_by_firm.csv", row.names = FALSE)
write.csv(cd_2017y_mean_by_firm, "cd_2017y_mean_by_firm.csv", row.names = FALSE)
