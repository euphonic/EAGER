# this script creates a matrix of firm level patent measures

library(dplyr)
library(extrafont)
# font_import()
loadfonts(device = "pdf")
library (ggplot2)

setwd("/Users/sarora/dev/EAGER/data/patents/measures")

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

in.eager_assignee <- read.csv("../eager_assignee.csv", header = TRUE, stringsAsFactors = FALSE) 
in.eager_assignee$employees <- as.numeric(gsub(",", "", in.eager_assignee$employees))
in.eager_assignee$sme <- in.eager_assignee$employees
in.eager_assignee[which(in.eager_assignee$employees > 500 & in.eager_assignee$thes_types=="Corporate"), 5] <- 0
in.eager_assignee[which(in.eager_assignee$employees < 500 & !is.na(in.eager_assignee$employees) & in.eager_assignee$thes_types=="Corporate"), 5] <- 1
View(in.eager_assignee)

in.web_pages <- read.csv("../../analysis/measures/simple_web_measures_v1.csv", header = TRUE, stringsAsFactors = FALSE) 

# simple merge of assignees with firm patent and employee measures
