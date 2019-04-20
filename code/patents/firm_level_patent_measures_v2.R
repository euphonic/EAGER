# this script creates a matrix of firm level patent, employment, and website measures for use in the bias analysis.
# can also be used for MSM
# sarora@air.org
# february 2019

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)

# MacOS
setwd("/Users/sanjay/dev/EAGER/data/patents/measures")

# load data
in.eager_patents <- read.csv("../eager_patent_all.csv", header = TRUE, stringsAsFactors = FALSE)
# in.eager_citations <- read.csv("citations_3industries.csv", header = TRUE, stringsAsFactors = FALSE)
# in.eager_citations$patent_id <- as.character(in.eager_citations$patent_id)
in.ass_all <- read.csv("assignees_overall.csv", header = TRUE, stringsAsFactors = FALSE)
in.ass_3 <- read.csv("assignees_3industries.csv", header = TRUE, stringsAsFactors = FALSE)
in.ass_3$patent_id <- as.character(in.ass_3$patent_id)
in.inv_all <- read.csv("inventors_overall.csv", header = TRUE, stringsAsFactors = FALSE) 
in.inv_3 <- read.csv("inventors_3industries.csv", header = TRUE)
in.inv_3$patent_id <- as.character (in.inv_3$patent_id)
in.pat_3 <- read.csv("patents_3industries.csv", header = TRUE, stringsAsFactors = FALSE)
in.pat_all <- read.csv("patents_overall.csv", header = TRUE, stringsAsFactors = FALSE)

in.ass_first_year <- read.csv("assignees_first-year.csv", header = TRUE, stringsAsFactors = FALSE)
# first year of patent for firm 
colnames(in.ass_first_year)[1] <- 'first_year'
head (in.ass_first_year)

in.lookup <- read.csv("assignee-2-patent-lookup.csv", header = TRUE, stringsAsFactors = FALSE) 

in.eager_assignee <- read.csv("..//eager_assignee.csv", header = TRUE, stringsAsFactors = FALSE) 
in.eager_assignee$max_emps <- as.numeric(gsub(",", "", in.eager_assignee$max_emps))
in.eager_assignee$sme <- 1
colnames (in.eager_assignee)
nrow(in.eager_assignee)
in.eager_assignee[which(in.eager_assignee$size_state == 'FirmSize.LARGE_FIRM'), 22] <- 0
nrow(in.eager_assignee[in.eager_assignee$sme == 1, ])
nrow(in.eager_assignee[in.eager_assignee$sme == 0, ])

# not used but still loaded
in.web_pages_all <- read.csv("../../analysis/measures/simple_web_measures_v2.csv", header = TRUE, stringsAsFactors = FALSE) 
in.web_pages_all$avg_words_per_page = in.web_pages_all$num_words / in.web_pages_all$pages
head(in.web_pages_all)

# number of patents all
head(in.pat_all)
num_patents_all_by_firm <- in.pat_all %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(lookup_firm) %>% 
  summarize(num_patents_all = sum(count.p.id.))
head(num_patents_all_by_firm)

# number of patents 3 industries
num_patents_3_by_firm <- in.pat_3 %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(lookup_firm) %>% 
  summarize(num_patents_3 = sum(count.epa.id.))
num_patents_3_by_firm


# number of assignees all
head (in.ass_all)
mean_assignees_all_by_firm <- in.ass_all %>% inner_join(in.lookup, by = "patent_id") %>% group_by(lookup_firm)  %>%  
  summarize(mean_assignees_all = mean( count.pa.assignee_id., na.rm=TRUE)) 
head(mean_assignees_all_by_firm)

# number of assignees 3 industries
head (in.ass_3)
mean_assignees_3_by_firm <- in.ass_3 %>% inner_join(in.lookup, by = "patent_id") %>% group_by(lookup_firm)  %>%  
  summarize(mean_assignees_3 = mean(count.pa.assignee_id., na.rm=TRUE)) 
mean_assignees_3_by_firm

# average number of inventors all  
head (in.inv_all)
mean_inventors_all_by_size <- in.inv_all %>% inner_join(in.lookup, by = c("patent_id")) %>% group_by(lookup_firm)  %>%  
  summarize(mean_inventors_all = mean( count.pi.inventor_id., na.rm=TRUE)) 
mean_inventors_all_by_size

# average number of inventors 3 industries 
head (in.inv_3)
mean_inventors_3_by_size <- in.inv_3 %>% inner_join(in.lookup, by = "patent_id") %>% group_by(lookup_firm)  %>%  
  summarize(mean_inventors_3 = mean( count.pi.inventor_id., na.rm=TRUE)) 
mean_inventors_3_by_size


# straight citation counts < 5 years
# mean_citations_3_by_firm <- in.eager_citations %>% right_join(in.lookup, by = cby = "patent_id")  %>% group_by(organization_clnd)  %>%  
  # summarize(mean_citations_3 = mean( num_citations, na.rm=TRUE))
# mean_citations_3_by_firm[is.na(mean_citations_3_by_firm$mean_citations_3), 2] <- 0 # change na's to 0's 
# View(mean_citations_3_by_firm)


# final out
nrow( in.eager_assignee %>%  # 1,470 w/ just firms and patents or 1,176 once joining the website data in 
  inner_join (in.web_pages_all, by =c("lookup_firm_web" = "firm_name")) %>%
  inner_join(in.ass_first_year, by = c("lookup_firm")) %>%
  inner_join(num_patents_all_by_firm, by = c("lookup_firm")) %>% inner_join(num_patents_3_by_firm, by = c("lookup_firm")) %>% 
  inner_join(mean_assignees_all_by_firm, by = c("lookup_firm")) %>% inner_join(mean_assignees_3_by_firm, by = c("lookup_firm")) %>%
  inner_join(mean_inventors_all_by_size, by = c("lookup_firm")) %>% inner_join(mean_inventors_3_by_size, by = c("lookup_firm")))


firm_level_measures <- in.eager_assignee %>% # 1,487
  left_join (in.web_pages_all, by =c("lookup_firm_web" = "firm_name")) %>%
  left_join(in.ass_first_year, by = c("lookup_firm")) %>%
  left_join(num_patents_all_by_firm, by = c("lookup_firm")) %>% left_join(num_patents_3_by_firm, by = c("lookup_firm")) %>% 
  left_join(mean_assignees_all_by_firm, by = c("lookup_firm")) %>% left_join(mean_assignees_3_by_firm, by = c("lookup_firm")) %>%
  left_join(mean_inventors_all_by_size, by = c("lookup_firm")) %>% left_join(mean_inventors_3_by_size, by = c("lookup_firm"))
nrow(firm_level_measures)
# firm_level_patent_plus_emp_measures[is.na(firm_level_patent_plus_emp_measures)] <- 0
# firm_level_patent_plus_emp_measures[firm_level_patent_plus_emp_measures == ""] <- 0
View(firm_level_measures)
write.csv(firm_level_measures, "firm_level_measures.csv", row.names = FALSE)

# check percent of small firms with website data
nrow (firm_level_measures[firm_level_measures$size_state != 'FirmSize.UNDEFINED' & 
                            firm_level_measures$sme == 1, ])
nrow (firm_level_measures[firm_level_measures$size_state != 'FirmSize.UNDEFINED' & 
                            firm_level_measures$sme == 1, ])
nrow (firm_level_measures[firm_level_measures$size_state != 'FirmSize.UNDEFINED' & 
                            firm_level_measures$sme == 1 &
                            ! is.na(firm_level_measures$pages), ])

# grab cd5 data from a non-git directory (too large to store there)
# you can find these files at http://russellfunk.org/cdindex/data.html 
setwd("D:\\Sanjay")
in.cd <- read.csv("cdindex_20160321.csv", header = TRUE, stringsAsFactors = FALSE)
head(in.cd)
lapply(in.cd, class)
in.cd_numeric <- as.data.frame(sapply(in.cd, as.numeric))
in.cd_numeric$patent <- as.character(in.cd_numeric$patent)
lapply(in.cd_numeric, class)
head(in.cd_numeric)
# in.cdpanel <- read.csv("cdindex_panel_20160321.csv", header = TRUE, stringsAsFactors = FALSE) 
# head(in.cdpanel)

mean_cdindex_all_by_firm <- in.cd_numeric %>% inner_join(in.lookup, by = c("patent" = "id")) %>% group_by(organization_clnd)  %>%  
  summarize(mean = mean( cd_5, na.rm=TRUE))
head(mean_cdindex_all_by_firm)

mean_cdindex_3_by_firm <- in.cd_numeric %>% inner_join(in.eager_patents, by = c("patent" = "id")) %>% inner_join(in.lookup, by = c("patent" = "id")) %>% group_by(organization_clnd)  %>%  
  summarize(mean = mean( cd_5, na.rm=TRUE)) 
head(mean_cdindex_3_by_firm)



