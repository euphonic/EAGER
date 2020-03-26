# this script creates a matrix of firm level patent, employment, and website measures for use in the bias analysis.
# can also be used for MSM
# sarora@air.org
# february 2019

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)
library(rjags)
library(MVN)
library(stats)
# MacOS
setwd("/Users/kg284kt/dev/EAGER/data/patents/measures")
# load (".RData")

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

# predicted pages
in.web_pages <- read.csv("..//..//orgs//about//about_predicted_and_labels.csv", header = TRUE, stringsAsFactors = FALSE) # just about page measures
head(in.web_pages)

firm_about_page_measures = in.web_pages %>% group_by(firm_name)  %>% 
  summarize (about_gen.count = n(), about_exact.count = sum(is_about), default_to_home = sum(default_to_home))
head (firm_about_page_measures)

# import keyword measures
in.keyword_counts <- read.csv("../../analysis/measures/keyword_counts_v1.csv", header = TRUE, stringsAsFactors = FALSE) 
View(in.keyword_counts)

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
                            firm_level_measures$sme == 1 &
                            ! is.na(firm_level_measures$pages), ])

# load disruption index firm=level data: see integrate_disruption_index.R 
# you can find these files at http://russellfunk.org/cdindex/data.html 
i2017y_mean_by_firm <- read.csv ("i2017y_mean_by_firm.csv", header = TRUE, stringsAsFactors = FALSE)
cd_2017y_mean_by_firm <- read.csv ("cd_2017y_mean_by_firm.csv", header = TRUE, stringsAsFactors = FALSE)


# keyword count correlations with patent intensity, etc.
patents_keywords_about <- in.pat_all %>% inner_join(in.eager_assignee, by = "lookup_firm") %>% 
  inner_join(firm_about_page_measures, by = c("lookup_firm_web" = "firm_name")) %>% 
  inner_join(in.keyword_counts, by = c("lookup_firm_web" = "Name"))
nrow (patents_keywords_about)
colnames(patents_keywords_about)

summary(patents_keywords_about$about_exact.count)
patents_keywords_about[patents_keywords_about$about_exact.count == 0, 25] <- 1
summary(patents_keywords_about$about_exact.count)
patents_keywords_about$rd_per_page = patents_keywords_about$rd_pattern / patents_keywords_about$about_exact.count
hist(patents_keywords_about$rd_per_page)
cor (patents_keywords_about$count.p.id., patents_keywords_about$rd_per_page)
View(patents_keywords_about)

# variables are not normally distributed 
qqplot(patents_keywords_about$rd_pattern, patents_keywords_about$count.p.id.)
qqplot(patents_keywords_about$rd_per_page, patents_keywords_about$count.p.id.)
mvn(cbind (patents_keywords_about$rd_per_page, patents_keywords_about$count.p.id.), mvnTest = c("mardia"), univariateTest = "SW")

shapiro.test(patents_keywords_about$rd_pattern)
shapiro.test(patents_keywords_about$rd_per_page)
shapiro.test(patents_keywords_about$count.p.id.)

# kendall correlational tests
cor.test(patents_keywords_about$rd_pattern, patents_keywords_about$count.p.id., alternative="two.sided", method="kendall" )
cor.test(patents_keywords_about$count.p.id., patents_keywords_about$rd_per_page, alternative="two.sided", method="kendall" )

# spearman
cor.test(patents_keywords_about$rd_pattern, patents_keywords_about$count.p.id., alternative="two.sided", method="spearman" )
cor.test(patents_keywords_about$count.p.id., patents_keywords_about$rd_per_page, alternative="two.sided", method="spearman" )

# pearson's to compare scientometrics findings
cor.test(patents_keywords_about$rd_pattern, patents_keywords_about$count.p.id., alternative="two.sided", method="pearson" )
cor.test(patents_keywords_about$count.p.id., patents_keywords_about$rd_per_page, alternative="two.sided", method="pearson" )


hist (patents_keywords_about[patents_keywords_about$count.p.id. < 1000,1])
hist (patents_keywords_about[patents_keywords_about$rd_pattern < 200,28])
hist (patents_keywords_about[patents_keywords_about$rd_per_page < 100,29])

patents_keywords_about$lg_count_pid <- log(patents_keywords_about$count.p.id.)
patents_keywords_about$lg_rd_pattern <- log(patents_keywords_about$rd_pattern + 1)
patents_keywords_about$lg_rd_page <- log(patents_keywords_about$rd_per_page + 0.01)
patents_keywords_about$lg_patent_pattern <- log(patents_keywords_about$patent_pattern + 1)

hist (patents_keywords_about$lg_count_pid)
hist (patents_keywords_about$lg_rd_pattern)
hist (patents_keywords_about$lg_rd_page)
hist (patents_keywords_about$lg_patent_pattern)


# variables are not normally distributed 
qqplot(patents_keywords_about$lg_rd_pattern, patents_keywords_about$lg_count_pid)
qqplot(patents_keywords_about$lg_rd_page, patents_keywords_about$lg_count_pid)
qqplot(patents_keywords_about$lg_patent_pattern, patents_keywords_about$lg_count_pid)
mvn(cbind (patents_keywords_about$lg_rd_pattern, patents_keywords_about$lg_count_pid), mvnTest = c("mardia"), univariateTest = "SW")

shapiro.test(patents_keywords_about$lg_rd_pattern)
shapiro.test(patents_keywords_about$lg_rd_page)
shapiro.test(patents_keywords_about$lg_count_pid)
shapiro.test(patents_keywords_about$lg_patent_pattern)

# kendall correlational tests
cor.test(patents_keywords_about$lg_rd_pattern, patents_keywords_about$lg_count_pid, alternative="two.sided", method="kendall" )
cor.test(patents_keywords_about$lg_count_pid, patents_keywords_about$lg_rd_page, alternative="two.sided", method="kendall" )
cor.test(patents_keywords_about$lg_count_pid, patents_keywords_about$lg_patent_pattern, alternative="two.sided", method="kendall" )


# spearman
cor.test(patents_keywords_about$lg_rd_pattern, patents_keywords_about$lg_count_pid, alternative="two.sided", method="spearman" )
cor.test(patents_keywords_about$lg_count_pid, patents_keywords_about$lg_rd_page, alternative="two.sided", method="spearman" )
cor.test(patents_keywords_about$lg_count_pid, patents_keywords_about$lg_patent_pattern, alternative="two.sided", method="spearman" )


# pearson's to compare scientometrics findings
cor.test(patents_keywords_about$lg_rd_pattern, patents_keywords_about$lg_count_pid, alternative="two.sided", method="pearson" )
cor.test(patents_keywords_about$lg_count_pid, patents_keywords_about$lg_rd_page, alternative="two.sided", method="pearson" )
cor.test(patents_keywords_about$lg_count_pid, patents_keywords_about$lg_patent_pattern, alternative="two.sided", method="pearson" )


