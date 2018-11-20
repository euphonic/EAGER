# this script compares both small and large firms patenting behavior
# also pulls in website page numbers to merge on the other employment and patent data

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)

setwd("C:\\Users\\sarora\\Documents\\GitHub\\EAGER\\data\\patents\\measures")

# load data
in.ass_all <- read.csv("assignees_overall.csv", header = TRUE, stringsAsFactors = FALSE)
in.ass_3 <- read.csv("assignees_3industries.csv", header = TRUE, stringsAsFactors = FALSE)
in.ass_3$patent_id <- as.character(in.ass_3$patent_id)
in.inv_all <- read.csv("inventors_overall.csv", header = TRUE, stringsAsFactors = FALSE) 
in.inv_3 <- read.csv("inventors_3industries.csv", header = TRUE)
in.inv_3$id <- as.character(in.inv_3$id)
in.pat_3 <- read.csv("patents_3industries.csv", header = TRUE, stringsAsFactors = FALSE)
in.pat_all <- read.csv("patents_overall.csv", header = TRUE, stringsAsFactors = FALSE)

in.ass_first_year <- read.csv("assignees_first-year.csv", header = TRUE, stringsAsFactors = FALSE)
in.lookup <- read.csv("assignee-2-patent-lookup.csv", header = TRUE, stringsAsFactors = FALSE) 

in.eager_assignee <- read.csv("..\\eager_assignee.csv", header = TRUE, stringsAsFactors = FALSE) 
in.eager_assignee$employees <- as.numeric(gsub(",", "", in.eager_assignee$employees))
in.eager_assignee$sme <- in.eager_assignee$employees
in.eager_assignee[which(in.eager_assignee$employees > 500 & in.eager_assignee$thes_types=="Corporate"), 5] <- 0
in.eager_assignee[which(in.eager_assignee$employees < 500 & !is.na(in.eager_assignee$employees) & in.eager_assignee$thes_types=="Corporate"), 5] <- 1
View(in.eager_assignee)

in.web_pages <- read.csv("..\\..\\analysis\\measures\\simple_web_measures_v1.csv", header = TRUE, stringsAsFactors = FALSE) 

# number of small vs large firms
head(in.pat_all)
head (in.eager_assignee)
count_assignees_by_size <- in.pat_all %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% count(sme)
count_assignees_by_size

# average number of employees 
mean_emps_by_size <- in.eager_assignee  %>% group_by(sme) %>% summarize(mean = mean(employees, na.rm=TRUE))
mean_emps_by_size

# avg first year
head (in.ass_first_year)
mean_first_year_by_size <- in.ass_first_year %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% group_by(sme) %>% 
  summarize(mean = mean(year.min.p..date..., na.rm=TRUE))
mean_first_year_by_size

# average number of patents all
mean_patents_all_by_size <- in.pat_all %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% group_by(sme) %>% 
  summarize(mean = mean(count.p.id., na.rm=TRUE))
mean_patents_all_by_size

# average number of patents 3 industries
mean_patents_3_by_size <- in.pat_3 %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% group_by(sme) %>% 
  summarize(mean = mean(count.epa.id., na.rm=TRUE))
mean_patents_3_by_size


# average number of assignees all
head (in.ass_all)
mean_assignees_all_by_size <- in.ass_all %>% inner_join(in.lookup, by = c("patent_id" = "id")) %>% group_by(organization_clnd)  %>%  
  summarize(mean = mean( count.pa.assignee_id., na.rm=TRUE)) %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% group_by(sme) %>% 
  summarize(mean = mean(mean, na.rm=TRUE))
mean_assignees_all_by_size

# average number of assignees 3 industries
head (in.ass_3)
mean_assignees_all_by_size <- in.ass_3 %>% inner_join(in.lookup, by = c("patent_id" = "id")) %>% group_by(organization_clnd)  %>%  
  summarize(mean = mean( count.pa.assignee_id., na.rm=TRUE)) %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% group_by(sme) %>% 
  summarize(mean = mean(mean, na.rm=TRUE))
mean_assignees_all_by_size

# average number of inventors all  
head (in.inv_all)
mean_inventors_all_by_size <- in.inv_all %>% inner_join(in.lookup, by = c("id")) %>% group_by(organization_clnd)  %>%  
  summarize(mean = mean( count.pi.inventor_id., na.rm=TRUE)) %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% group_by(sme) %>% 
  summarize(mean = mean(mean, na.rm=TRUE))
mean_inventors_all_by_size

# average number of inventors 3 industries 
head (in.inv_3)
mean_inventors_all_by_size <- in.inv_3 %>% inner_join(in.lookup, by = c("id")) %>% group_by(organization_clnd)  %>%  
  summarize(mean = mean( count.pi.inventor_id., na.rm=TRUE)) %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% group_by(sme) %>% 
  summarize(mean = mean(mean, na.rm=TRUE))
mean_inventors_all_by_size

# merge in website data
head (in.web_pages)
patents_web_emps <- in.pat_all %>% inner_join(in.eager_assignee, by = c("organization_clnd")) %>% 
  inner_join(in.web_pages, by = c("organization_clnd" = "firm_name"))

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

# HISTOGRAM THEME
theme.eager_chart_HIST <- theme.eager_chart +
  theme(axis.title.x = element_text(hjust=0, vjust=-.5))

# SMALL MULTIPLE THEME
theme.eager_chart_SMALLM <- theme.eager_chart +
  theme(panel.grid.minor = element_blank()) +
  theme(strip.text.x = element_text(size=16, family="Trebuchet MS", face="bold", color="#666666"))    

g1.df <- patents_web_emps %>% arrange(employees) %>% as.data.frame()
head (g1.df)
ggplot(data=g1.df, aes(x=employees, y=num_pages)) +
  geom_point(alpha=.4, size=4, color="#880011") +
  labs(x="Employees", y="Number of pages") +
  theme.eager_chart_SCATTER
g1.df


