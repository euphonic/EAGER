library("msm")
library("dplyr")
setwd("/home/eager/EAGER/data/orgs/workshop/depth0_pages/")

in.depth0_topics <- read.csv("out_topics.csv", header = TRUE, stringsAsFactors = FALSE)
head(in.depth0_topics)
nrow(in.depth0_topics)
unique(in.depth0_topics$main_topic)
in.depth0_topics$main_topic <- in.depth0_topics$main_topic + 1
num_topics <- length(unique(in.depth0_topics$main_topic))
num_topics


groups <- in.depth0_topics %>% group_indices(firm_key)
in.depth0_topics$gid <- groups
View(in.depth0_topics)

head(in.depth0_topics)
statetable.msm(main_topic, gid, data = in.depth0_topics)

qm <- matrix(rep (1, num_topics^2), nrow=num_topics, ncol=num_topics)
diag(qm) <- 0
qm

eager.msm <- msm(main_topic ~ para_order, subject = gid, data = in.depth0_topics, qmatrix = qm, exacttimes = TRUE, gen.inits=TRUE)
eager.msm
