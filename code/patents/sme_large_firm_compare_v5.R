# this script compares both small and large firms patenting behavior
# also pulls in website (ABOUT) page numbers to merge on the other employment and patent data
# the focus on about pages is the change from v1 to v2

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)
library(scales)

setwd("/Users/Sanjay/dev/EAGER/data/patents/measures/")

#--------------
# Create Theme
#--------------

# BASIC THEME
theme.eager_chart <- 
  theme(legend.position = "none") +
  theme(plot.title = element_text(size=26, family="Trebuchet MS", face="bold", hjust=0, color="#666666")) +
  theme(axis.title = element_text(size=18, family="Trebuchet MS", face="bold", color="#666666")) +
  theme(axis.title.y = element_text(angle=0)) + 
  theme(axis.text=element_text(size=10, family="Trebuchet MS", color="#666666"))

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


# load data
in.ass_all <- read.csv("assignees_overall.csv", header = TRUE, stringsAsFactors = FALSE)
in.ass_3 <- read.csv("assignees_3industries.csv", header = TRUE, stringsAsFactors = FALSE)
in.ass_3$patent_id <- as.character(in.ass_3$patent_id)
in.inv_all <- read.csv("inventors_overall.csv", header = TRUE, stringsAsFactors = FALSE) 
in.inv_3 <- read.csv("inventors_3industries.csv", header = TRUE)
in.inv_3$patent_id <- as.character(in.inv_3$patent_id)
in.pat_3 <- read.csv("patents_3industries.csv", header = TRUE, stringsAsFactors = FALSE)
in.pat_all <- read.csv("patents_overall.csv", header = TRUE, stringsAsFactors = FALSE)

in.ass_first_year <- read.csv("assignees_first-year.csv", header = TRUE, stringsAsFactors = FALSE)
in.lookup <- read.csv("assignee-2-patent-lookup.csv", header = TRUE, stringsAsFactors = FALSE) 

in.eager_assignee <- read.csv("..//eager_assignee.csv", header = TRUE, stringsAsFactors = FALSE) 
in.eager_assignee$max_emps <- as.numeric(gsub(",", "", in.eager_assignee$max_emps))
in.eager_assignee$sme <- 1
colnames (in.eager_assignee)
nrow(in.eager_assignee)
nrow(in.eager_assignee[in.eager_assignee$size_state == 'FirmSize.UNDEFINED',]) # == 97
# nrow(in.eager_assignee[in.eager_assignee$hit_url == '',]) # == 199
in.eager_assignee <- in.eager_assignee[in.eager_assignee$size_state != 'FirmSize.UNDEFINED' ,]
nrow(in.eager_assignee)
nrow(in.eager_assignee) - nrow (in.eager_assignee[in.eager_assignee$hit_url == '', ]) # firms with urls
in.eager_assignee[which(in.eager_assignee$size_state == 'FirmSize.LARGE_FIRM'), 22] <- 0
nrow(in.eager_assignee[in.eager_assignee$sme == 1, ])
nrow(in.eager_assignee[in.eager_assignee$sme == 0, ])
in.eager_assignee <- in.eager_assignee[,c(1,2,3,8,16:22)]

View(in.eager_assignee)

in.web_pages <- read.csv("..//..//orgs//about//about_predicted_and_labels.csv", header = TRUE, stringsAsFactors = FALSE) # just about page measures
in.web_pages_all <- read.csv("..//..//analysis//measures//simple_web_measures_v2.csv", header = TRUE, stringsAsFactors = FALSE) 
in.web_pages_all$avg_words_per_page = in.web_pages_all$num_words / in.web_pages_all$pages

nrow (in.web_pages)
nrow(in.web_pages_all)

# number of small vs large firms
head(in.pat_all)
nrow(in.pat_all)
head (in.eager_assignee)
count_assignees_by_size <- in.pat_all %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% count(sme)
count_assignees_by_size
anti_join(in.pat_all, in.eager_assignee, by = c("lookup_firm"))
nrow(anti_join(in.eager_assignee, in.pat_all, by = c("lookup_firm")))
count_assignees_by_size

# average number of employees 
mean_emps_by_size <- in.eager_assignee  %>% group_by(sme) %>% summarize(mean = mean(max_emps, na.rm=TRUE))
mean_emps_by_size

# avg first year
head (in.ass_first_year)
nrow (in.ass_first_year %>% inner_join(in.eager_assignee, by = "lookup_firm"))
View(anti_join(in.eager_assignee, in.ass_first_year, by = "lookup_firm"))
mean_first_year_by_size <- in.ass_first_year %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(sme) %>% 
  summarize(mean = mean(year.min.p..date..., na.rm=TRUE))
mean_first_year_by_size

# mean number of patents all
mean_patents_all_by_size <- in.pat_all %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(sme) %>% 
  summarize(mean = mean(count.p.id., na.rm=TRUE))
mean_patents_all_by_size

# mean number of patents 3 industries
mean_patents_3_by_size <- in.pat_3 %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(sme) %>% 
  summarize(mean = mean(count.epa.id., na.rm=TRUE))
mean_patents_3_by_size

# average number of assignees all
head (in.ass_all)
mean_assignees_all_by_size <- in.ass_all %>% inner_join(in.lookup, by = "patent_id") %>% group_by(lookup_firm)  %>%  
  summarize(mean = mean( count.pa.assignee_id., na.rm=TRUE)) %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(sme) %>% 
  summarize(mean = mean(mean, na.rm=TRUE))
mean_assignees_all_by_size

# average number of assignees 3 industries
head (in.ass_3)
mean_assignees_3_by_size <- in.ass_3 %>% inner_join(in.lookup, by = "patent_id") %>% group_by(lookup_firm)  %>%  
  summarize(mean = mean( count.pa.assignee_id., na.rm=TRUE)) %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(sme) %>% 
  summarize(mean = mean(mean, na.rm=TRUE))
mean_assignees_3_by_size

# average number of inventors all  
head (in.inv_all)
mean_inventors_all_by_size <- in.inv_all %>% inner_join(in.lookup, by = "patent_id") %>% group_by(lookup_firm)  %>%  
  summarize(mean = mean( count.pi.inventor_id., na.rm=TRUE)) %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(sme) %>% 
  summarize(mean = mean(mean, na.rm=TRUE))
mean_inventors_all_by_size

# average number of inventors 3 industries 
head (in.inv_3)
mean_inventors_3_by_size <- in.inv_3 %>% inner_join(in.lookup, by = "patent_id") %>% group_by(lookup_firm)  %>%  
  summarize(mean = mean( count.pi.inventor_id., na.rm=TRUE)) %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% group_by(sme) %>% 
  summarize(mean = mean(mean, na.rm=TRUE))
mean_inventors_3_by_size

# prep website data by aggregating on firm
head (in.web_pages)
firm_about_page_measures = in.web_pages %>% group_by(firm_name)  %>% 
  summarize (about_gen.count = n(), about_exact.count = sum(is_about), default_to_home = sum(default_to_home))
head (firm_about_page_measures)

patents_web_emps_about <- in.pat_all %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% 
  inner_join(firm_about_page_measures, by = c("lookup_firm_web" = "firm_name"))
nrow (patents_web_emps_about)
View(patents_web_emps_about)

g1.df <- patents_web_emps_about %>% arrange(max_emps) %>% as.data.frame()
nrow (g1.df)
View(g1.df)

g1.a <- ggplot(data=g1.df[g1.df$sme == 1,], aes(x=max_emps, y=about_gen.count)) +
  geom_point(alpha=.4, color="#00a5ff") +
  labs(x="Employees", y="Number of\nabout pages,\ngeneral") +
  scale_x_continuous(labels=comma, limits=c(0,500)) +
  scale_y_continuous(limits=c(0,90), breaks=seq(0,90,by=10)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g1.a
ggsave("../../analysis/emps_x_about-gen-pages_v5.png")

g1.b <- ggplot(data=g1.df[g1.df$sme == 1,], aes(x=max_emps, y=about_exact.count)) +
  geom_point(aes(color=factor(default_to_home), alpha=factor(default_to_home))) + #color="#00a5ff"
  labs(x="Employees", y="Number of\nabout pages,\nmodeled") +
  scale_x_continuous(labels=comma, limits=c(0,500)) +
  scale_y_continuous(limits=c(0,20), breaks=seq(0,20,by=5)) +
  geom_smooth(method = "loess") +
  scale_colour_manual(values = c("blue", "red")) + 
  scale_alpha_discrete(range=c(0.2, 1)) + 
  theme.eager_chart_SCATTER
g1.b
ggsave("../../analysis/emps_x_about-exact-pages_v5.png")

g1.c <- ggplot(data=g1.df[g1.df$sme == 1,], aes(x=count.p.id., y=about_gen.count)) +
  geom_point(alpha=.4, size=4, color="#7b00ff") +
  labs(x="Patents", y="Number of\nabout pages,\ngeneral") +
  scale_x_continuous(labels=comma, limits=c(0,4500)) +
  scale_y_continuous(limits=c(0,100), breaks=seq(0,100,by=10)) +
  geom_smooth(method = "lm") +
  theme.eager_chart_SCATTER
g1.c
ggsave("../../analysis/patents_x_about-gen-pages_v4.png")

g1.d <- ggplot(data=g1.df[g1.df$sme == 1,], aes(x=count.p.id., y=about_exact.count)) +
  geom_point(alpha=.4, size=4, color="#7b00ff") +
  labs(x="Patents", y="Number of\nabout pages,\nexact") +
  scale_x_continuous(labels=comma, limits=c(0,4500)) +
  scale_y_continuous(limits=c(0,12), breaks=seq(0,12,by=2)) +
  geom_smooth(method = "lm") +
  theme.eager_chart_SCATTER
g1.d
ggsave("../../analysis/patents_x_about-exact-pages_v4.png")

# variables are not normally distributed 
colnames(g1.df)
shapiro.test(g1.df[g1.df$sme == 1,10]) # emps
shapiro.test(g1.df[g1.df$sme == 1,1]) # pats
shapiro.test(g1.df[g1.df$sme == 1,13]) # about, general
shapiro.test(g1.df[g1.df$sme == 1,14]) # about, exact


cor.test(g1.df[g1.df$sme == 1,10], g1.df[g1.df$sme == 1,13], alternative="two.sided", method="kendall" )
cor.test(g1.df[g1.df$sme == 1,10], g1.df[g1.df$sme == 1,14], alternative="two.sided", method="kendall" )

cor.test(g1.df[g1.df$sme == 1,1], g1.df[g1.df$sme == 1,13], alternative="two.sided", method="kendall" )
cor.test(g1.df[g1.df$sme == 1,1], g1.df[g1.df$sme == 1,14], alternative="two.sided", method="kendall" )


# merge in website data (measures for all pages)
nrow(setdiff(in.eager_assignee$lookup_firm_web, in.web_pages_all$firm_name))
setdiff(in.web_pages_all$firm_name, in.eager_assignee$lookup_firm_web)
web_emps <- in.eager_assignee %>%  inner_join(in.web_pages_all, by = c("lookup_firm_web" = "firm_name"))
View(anti_join(in.web_pages_all, in.eager_assignee, by = c("firm_name" = "lookup_firm")))
nrow(web_emps)

head (in.web_pages_all)
patents_web_emps_all <- in.pat_all %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% 
  inner_join(in.web_pages_all, by = c("lookup_firm_web" = "firm_name"))
nrow(patents_web_emps_all)


g2.df <- patents_web_emps_all %>% arrange(max_emps) %>% as.data.frame()
nrow (g2.df)
View(g2.df)
g2.a <- ggplot(data=g2.df[g2.df$sme ==1, ], aes(x=max_emps, y=pages)) +
  geom_point(alpha=.4, color="#0037ff") +
  labs(x="Employees", y="Number of\npages") +
  scale_x_continuous(labels=comma, limits=c(0,500)) +
  scale_y_continuous(limits=c(0,400), breaks=seq(0,400,by=100)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g2.a
ggsave("../../analysis/emps_x_pages_v5.png")

g2.b <- ggplot(data=g2.df[g2.df$sme ==1, ], aes(x=count.p.id., y=pages)) +
  geom_point(alpha=.4, size=4, color="#7b00ff") +
  labs(x="Patents", y="Number of\npages") +
  scale_x_continuous(labels=comma, limits=c(0,5000)) +
  scale_y_continuous(limits=c(0,400), breaks=seq(0,400,by=100)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g2.b
ggsave("../../analysis/patents_x_pages_v4.png")

g2.c <- ggplot(data=g2.df[g2.df$sme ==1, ], aes(x=max_emps, y=count.epa.id.)) +
  geom_point(alpha=.4, size=4, color="#7b00ff") +
  labs(x="Employees", y="Patents") +
  scale_x_continuous(labels=comma, limits=c(0,500)) +
  scale_y_continuous(limits=c(0,40), breaks=seq(0,40,by=10)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g2.c
ggsave("../../analysis/emps_x_patents_v4.png")

# variables are not normally distributed 
shapiro.test(g2.df[g2.df$sme ==1, ]$max_emps)
shapiro.test(g1.df[g1.df$sme == 1,]$about_gen.count)
shapiro.test(g1.df[g1.df$sme == 1,]$about_exact.count)

# kendall correlational tests
cor.test(g2.df[g2.df$sme ==1, ]$max_emp, g2.df[g2.df$sme ==1, ]$pages, alternative="two.sided", method="kendall" )
cor.test(g2.df[g2.df$sme ==1, ]$count.p.id., g2.df[g2.df$sme ==1, ]$max_emps, alternative="two.sided", method="kendall" )

cor.test(g1.df[g1.df$sme == 1,]$max_emp, g1.df[g1.df$sme == 1,]$about_gen.count, alternative="two.sided", method="kendall" )
cor.test(g1.df[g1.df$sme == 1,]$max_emp, g1.df[g1.df$sme == 1,]$about_exact.count, alternative="two.sided", method="kendall" )


# website variables
colnames (g2.df)
mean_pages_depth_0_by_size <- g2.df %>% group_by(sme) %>% summarize(mean = mean(pages, na.rm=TRUE))
mean_pages_depth_0_by_size

colnames (g1.df)
candididate_about_us_pages_by_size <- g1.df %>% group_by(sme) %>% summarize(mean = mean(about_gen.count, na.rm=TRUE))
candididate_about_us_pages_by_size

predicted_about_us_pages_by_size <- g1.df %>% group_by(sme) %>% summarize(mean = mean(about_exact.count, na.rm=TRUE))
predicted_about_us_pages_by_size

