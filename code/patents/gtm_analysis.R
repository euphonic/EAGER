# formerly sme_large_firm_compare_v5.R

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)
library(scales)
require(MASS)

setwd("/Users/kg284kt/dev/EAGER/data/patents/measures/")

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

# load disruption index firm=level data: see integrate_disruption_index.R 
# you can find these files at http://russellfunk.org/cdindex/data.html 
i2017y_mean_by_firm <- read.csv ("i2017y_mean_by_firm.csv", header = TRUE, stringsAsFactors = FALSE)
cd_2017y_mean_by_firm <- read.csv ("cd_2017y_mean_by_firm.csv", header = TRUE, stringsAsFactors = FALSE)
colnames(i2017y_mean_by_firm)
colnames(cd_2017y_mean_by_firm)

# import keyword measures
in.keyword_counts <- read.csv("../../analysis/measures/keyword_counts_v2.csv", header = TRUE, stringsAsFactors = FALSE) 
View(in.keyword_counts)

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

# join in keywords
patents_keywords_about <- patents_web_emps_about %>% 
  inner_join(in.keyword_counts, by = c("lookup_firm_web" = "Name"))
nrow (patents_keywords_about)
colnames(patents_keywords_about)

summary(patents_keywords_about$about_exact.count)
patents_keywords_about[patents_keywords_about$about_exact.count == 0, 14] <- 1
summary(patents_keywords_about$about_exact.count)
patents_keywords_about$rd_per_page = patents_keywords_about$rd_pattern / patents_keywords_about$about_exact.count
hist(patents_keywords_about$rd_per_page)
cor (patents_keywords_about$count.p.id., patents_keywords_about$patent_pattern)
View(patents_keywords_about)

# join in citations
patents_keywords_about_citations <- patents_keywords_about %>% 
  inner_join(i2017y_mean_by_firm, by = c("lookup_firm_web" = "lookup_firm")) %>% 
  inner_join(cd_2017y_mean_by_firm, by = c("lookup_firm_web" = "lookup_firm")) %>%
  inner_join(in.ass_first_year, by = c("lookup_firm" = "lookup_firm"))
View(patents_keywords_about_citations)

write.csv(patents_keywords_about_citations, "patents_keywords_about_citations.csv", row.names = FALSE)
colnames(patents_keywords_about_citations)

mean_2017y_by_size <- patents_keywords_about_citations %>% group_by(sme) %>% 
  summarize(mean = mean(mean_i2017y, na.rm=TRUE))
mean_id2017y_by_size

mean_cd2017y_by_size <- patents_keywords_about_citations %>% group_by(sme) %>% 
  summarize(mean = mean(mean_cd2017y, na.rm=TRUE))
mean_cd2017y_by_size

g1.df <- patents_keywords_about_citations %>% arrange(max_emps) %>% as.data.frame()
nrow (g1.df)
View(g1.df)

g1.a <- ggplot(data=g1.df, aes(x=max_emps, y=about_gen.count)) +
  geom_point(alpha=.4, color="#00a5ff") +
  labs(x="Employees", y="Number of\nabout pages,\ngeneral") +
  scale_x_continuous(labels=scales::comma, limits=c(0,220000)) +
  scale_y_continuous(limits=c(0,90), breaks=seq(0,90,by=10)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g1.a
ggsave("../../analysis/emps_x_about-gen-pages_v-gtm.png")

g1.b <- ggplot(data=g1.df, aes(x=max_emps, y=about_exact.count)) +
  geom_point(aes(color=factor(default_to_home), alpha=factor(default_to_home))) + #color="#00a5ff"
  labs(x="Employees", y="Number of\nabout pages,\nmodeled") +
  scale_x_continuous(labels=scales::comma, limits=c(0,220000)) +
  scale_y_continuous(limits=c(0,20), breaks=seq(0,20,by=5)) +
  geom_smooth(method = "loess") +
  scale_colour_manual(values = c("blue", "red")) + 
  scale_alpha_discrete(range=c(0.2, 1)) + 
  theme.eager_chart_SCATTER
g1.b
ggsave("../../analysis/emps_x_about-exact-pages_v-gtm.png")

g1.c <- ggplot(data=g1.df, aes(x=count.p.id., y=about_gen.count)) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Patents", y="Number of\nabout pages,\ngeneral") +
  scale_x_continuous(labels=scales::comma, limits=c(0,15000)) +
  scale_y_continuous(limits=c(0,100), breaks=seq(0,100,by=10)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g1.c
ggsave("../../analysis/patents_x_about-gen-pages_v-gtm.png")

g1.d <- ggplot(data=g1.df, aes(x=count.p.id., y=about_exact.count)) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Patents", y="Number of\nabout pages,\nexact") +
  scale_x_continuous(labels=scales::comma, limits=c(0,15000)) +
  scale_y_continuous(limits=c(0,12), breaks=seq(0,12,by=2)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g1.d
ggsave("../../analysis/patents_x_about-exact-pages_v-gtm.png")


# size of firm and disruption index
g1.e <- ggplot(data=g1.df, aes(x=log(g1.df$max_emps), y=mean_cd2017y)) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Employees (logged)", y="Disruption\nindex\n(2017)") +
  scale_x_continuous(limits=c(0,12)) +
  scale_y_continuous(limits=c(-0.5,0.5), breaks=seq(-1,1,by=0.5)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g1.e
ggsave("../../analysis/emps_x_di_v-gtm.png")

# disruption index and keywords.  TODO: color by industry and perhaps size by size of firm
d1.a <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(rd_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="R&D website\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.a
ggsave("../../analysis/di_x_rd_v-gtm.png")

d1.b <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(patent_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Patent\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.b
ggsave("../../analysis/di_x_pat-mentions_v-gtm.png")

d1.c <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(product_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Product\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.c
ggsave("../../analysis/di_x_product_v-gtm.png")

d1.d <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(trial_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Trial\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.d
ggsave("../../analysis/di_x_trial-mentions_v-gtm.png")

d1.e <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(demo_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Demo\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.e
ggsave("../../analysis/di_x_demo-mentions_v-gtm.png")

d1.f <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(manufacturing_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Manufacturing\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.f
ggsave("../../analysis/di_x_manu-mentions_v-gtm.png")

d1.g <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(venture_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="VC\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.g
ggsave("../../analysis/di_x_vc-mentions_v-gtm.png")

d1.h <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(university_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="University\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.h
ggsave("../../analysis/di_x_uni-mentions_v-gtm.png")

d1.i <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(partnership_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Partnership\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.i
ggsave("../../analysis/di_x_parnter-mentions_v-gtm.png")

d1.j <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(greenness_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Greenness\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.j
ggsave("../../analysis/di_x_green-mentions_v-gtm.png")

d1.k <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(customization_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Customization\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.k
ggsave("../../analysis/di_x_customization-mentions_v-gtm.png")

d1.l <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(awards_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Awards\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.l
ggsave("../../analysis/di_x_awards-mentions_v-gtm.png")

d1.m <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(membership_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Membership\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.m
ggsave("../../analysis/di_x_member-mentions_v-gtm.png")

d1.n <- ggplot(data=g1.df, aes(x=mean_cd2017y, y=log(customer_pattern + 1))) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Disruption index (2017)", y="Customer\nmentions\n(logged)") +
  scale_x_continuous(limits=c(-0.5,0.5)) +
  scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.n
ggsave("../../analysis/di_x_customer-mentions_v-gtm.png")

d1.o <- ggplot(data=g1.df, aes(x=year.min.p..date..., y=mean_cd2017y)) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Year of first patent", y="Disruption\nindex (2017)") +
  scale_x_continuous(limits=c(1975, 2017)) +
  scale_y_continuous(limits=c(-0.5,0.5), breaks=seq(-0.5,0.5,by=0.1)) +  
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
d1.o
ggsave("../../analysis/di_x_year_v-gtm.png")

# create logged/squared variables
ols_frame <- patents_keywords_about_citations
ols_frame$log_rd_pattern <- log(ols_frame$rd_pattern + 1) 
ols_frame$log_patent_pattern <- log(ols_frame$patent_pattern + 1) 
ols_frame$log_product_pattern <- log(ols_frame$product_pattern + 1) 
ols_frame$log_manufacturing_pattern <- log(ols_frame$manufacturing_pattern + 1)
ols_frame$log_university_pattern <- log(ols_frame$university_pattern + 1)
ols_frame$log_partnership_pattern <- log(ols_frame$partnership_pattern + 1)
ols_frame$log_customer_pattern <- log(ols_frame$customer_pattern + 1)
ols_frame$log_max_emps <- log(ols_frame$max_emps + 1)
ols_frame$log_count.p.id. <- log(ols_frame$count.p.id. + 1)

ols_frame$log_rd_pattern_sq <- ols_frame$log_rd_pattern^2
ols_frame$log_patent_pattern_sq <- ols_frame$log_patent_pattern^2
ols_frame$log_product_pattern_sq <- ols_frame$log_product_pattern^2 
ols_frame$log_manufacturing_pattern_sq <- ols_frame$log_manufacturing_pattern^2
ols_frame$log_university_pattern_sq <- ols_frame$log_university_pattern^2
ols_frame$log_partnership_pattern_sq <- ols_frame$log_partnership_pattern^2
ols_frame$log_customer_pattern_sq <- ols_frame$log_customer_pattern^2

# perform ols
nrow(patents_keywords_about_citations[patents_keywords_about_citations$mean_cd2017y < 0,])
colnames(patents_keywords_about_citations)

m0 <- lm(mean_cd2017y ~ nano + synbio + log_max_emps, # di > 0
         data = ols_frame)
summary(m0)

m1 <- lm(mean_cd2017y ~ log_rd_pattern + log_patent_pattern + log_product_pattern +
         log_university_pattern +
         nano + synbio + log_max_emps, 
         data = ols_frame)
summary(m1)

m1_reduced <- lm(mean_cd2017y ~ log_rd_pattern + log_patent_pattern + log_product_pattern +
           log_manufacturing_pattern + log_university_pattern +
           nano + synbio + log_max_emps, 
         data = ols_frame)
summary(m1_reduced)

m2_full <- lm(mean_cd2017y ~ log_rd_pattern + log_rd_pattern_sq + log_patent_pattern + log_patent_pattern_sq + log_product_pattern + log_product_pattern_sq +
           log_manufacturing_pattern + log_manufacturing_pattern_sq + log_university_pattern + log_university_pattern_sq + log_partnership_pattern + log_partnership_pattern_sq + log_customer_pattern + log_customer_pattern_sq +
           nano + synbio + log_max_emps, 
         data = ols_frame)
summary(m2_full)


m2_reduced1 <- lm(mean_cd2017y ~ log_rd_pattern  + log_rd_pattern_sq + log_patent_pattern + log_product_pattern +
                   log_university_pattern + 
                   synbio + nano + log_max_emps, 
         data = ols_frame)
summary(m2_reduced1)

m2_reduced.sub <- lm(mean_cd2017y ~ log_rd_pattern  + log_rd_pattern_sq + log_patent_pattern + log_patent_pattern_sq + 
                    log_product_pattern + log_manufacturing_pattern + log_manufacturing_pattern_sq + log_university_pattern + 
                   synbio + nano + log_max_emps, 
                 data = ols_frame[which(ols_frame$mean_cd2017y > 0), ])
summary(m2_reduced.sub)

m3a <- lm(log_patent_pattern ~  log_count.p.id.  +
           nano + synbio + log_max_emps, 
         data = ols_frame)
summary(m3a)

m3b <- glm.nb(patent_pattern ~ log_count.p.id. + nano + synbio + log_max_emps, data = ols_frame)
summary(m3b)

# variables are not normally distributed 
colnames(g1.df)
shapiro.test(g1.df$max_emps) # emps
shapiro.test(g1.df$count.p.id.) # pats
shapiro.test(g1.df$about_gen.count) # about, general
shapiro.test(g1.df$about_exact.count) # about, exact

cor.test(g1.df[g1.df$max_emps > 6000,10], g1.df[g1.df$max_emps > 6000,13], alternative="two.sided", method="kendall" )
cor.test(g1.df[g1.df$max_emps > 6000,10], g1.df[g1.df$max_emps > 6000,14], alternative="two.sided", method="kendall" )

cor.test(g1.df[g1.df$count.p.id. > 900,1], g1.df[g1.df$count.p.id. > 900,13], alternative="two.sided", method="kendall" )
cor.test(g1.df[g1.df$count.p.id. > 500,1], g1.df[g1.df$count.p.id. > 500,14], alternative="two.sided", method="kendall" )


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
colnames (g2.df)
View(g2.df)
g2.a <- ggplot(data=g2.df, aes(x=max_emps, y=pages)) +
  geom_point(alpha=.4, color="#0037ff") +
  labs(x="Employees", y="Number of\npages") +
  scale_x_continuous(labels=scales::comma, limits=c(0,220000)) +
  scale_y_continuous(limits=c(0,500), breaks=seq(0,500,by=100)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g2.a
ggsave("../../analysis/emps_x_pages_v-gtm.png")

g2.b <- ggplot(data=g2.df, aes(x=count.p.id., y=pages)) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Patents", y="Number of\npages") +
  scale_x_continuous(labels=scales::comma, limits=c(0,15000)) +
  scale_y_continuous(limits=c(0,500), breaks=seq(0,500,by=100)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g2.b
ggsave("../../analysis/patents_x_pages_v-gtm.png")

g2.c <- ggplot(data=g2.df, aes(x=max_emps, y=count.p.id.)) +
  geom_point(alpha=.4, color="#7b00ff") +
  labs(x="Employees", y="Patents") +
  scale_x_continuous(labels=scales::comma, limits=c(0,220000)) +
  scale_y_continuous(labels=scales::comma, limits=c(0,15000), breaks=seq(0,15000,by=3000)) +
  geom_smooth(method = "loess") +
  theme.eager_chart_SCATTER
g2.c
ggsave("../../analysis/emps_x_patents_v-gtm.png")

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



# ###################
# firm-level measures
# ###################

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

# final out
nrow( in.eager_assignee %>%  # 1,470 w/ just firms and patents or 1,176 once joining the website data in 
        inner_join (in.web_pages_all, by =c("lookup_firm_web" = "firm_name")) %>%
        inner_join(in.ass_first_year, by = c("lookup_firm")) %>%
        inner_join(num_patents_all_by_firm, by = c("lookup_firm")) %>% inner_join(num_patents_3_by_firm, by = c("lookup_firm")) %>% 
        inner_join(mean_assignees_all_by_firm, by = c("lookup_firm")) %>% inner_join(mean_assignees_3_by_firm, by = c("lookup_firm")) %>%
        inner_join(mean_inventors_all_by_size, by = c("lookup_firm")) %>% inner_join(mean_inventors_3_by_size, by = c("lookup_firm")))


firm_level_measures <- in.eager_assignee %>% 
  left_join (in.web_pages_all, by =c("lookup_firm_web" = "firm_name")) %>%
  left_join(in.ass_first_year, by = c("lookup_firm")) %>%
  left_join(num_patents_all_by_firm, by = c("lookup_firm")) %>% left_join(num_patents_3_by_firm, by = c("lookup_firm")) %>% 
  left_join(mean_assignees_all_by_firm, by = c("lookup_firm")) %>% left_join(mean_assignees_3_by_firm, by = c("lookup_firm")) %>%
  left_join(mean_inventors_all_by_size, by = c("lookup_firm")) %>% left_join(mean_inventors_3_by_size, by = c("lookup_firm")) %>%
  left_join(in.keyword_counts, by = c("lookup_firm" = "Name")) %>%
  left_join(firm_about_page_measures, by = c("lookup_firm" = "firm_name")) %>%
  left_join(i2017y_mean_by_firm, by = c("lookup_firm" = "lookup_firm")) %>% 
  left_join(cd_2017y_mean_by_firm, by = c("lookup_firm" = "lookup_firm"))
nrow(firm_level_measures)
# firm_level_patent_plus_emp_measures[is.na(firm_level_patent_plus_emp_measures)] <- 0
# firm_level_patent_plus_emp_measures[firm_level_patent_plus_emp_measures == ""] <- 0
View(firm_level_measures)
write.csv(firm_level_measures, "firm_level_measures.csv", row.names = FALSE)
