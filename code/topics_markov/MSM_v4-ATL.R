library("msm")
library("dplyr")
library("igraph")
library("diffusr")

# mac os or linux
setwd("/Users/kg284kt/dev/EAGER/data/")
sector <- "green"

# copy the label vector from jupyter notebook
labels <- 
  c('start|state','univers|presid|serv|manag|dr.','manufactur|develop|materi|process|system','award|printer|year|2018|inform','develop|eye|test|drug|clinic','camera|tube|color|time|soni|develop','develop|custom|innov|provid|servic|research')

# load firm patent data
patent_data.file = "patents/measures/firm_level_measures.csv"
in.patent_data <- read.csv(patent_data.file, header = TRUE, stringsAsFactors = FALSE)
in.patent_data$log_patents_all <- log(in.patent_data$num_patents_all)
head(in.patent_data)
nrow (in.patent_data)
in.patent_data[grep("\\/", in.patent_data$organization_clnd, perl=TRUE),]



# load data and clean
# topics.file <- "orgs\\boilerpipe\\out_topics.csv"
topics.file <- paste0("orgs/para_topics_panel/", sector, "_out_topics.csv")
in.topics <- read.csv(topics.file, header = TRUE, stringsAsFactors = FALSE)
# in.topics <- in.topics[in.topics$main_topic != -1,] # remove start topics for exploratory check
head(in.topics)
nrow(in.topics)
in.topics$main_topic <- in.topics$main_topic + 2
unique(in.topics$main_topic)
num_topics <- length(unique(in.topics$main_topic))
num_topics

cnt_by_topic <- in.topics %>% count(main_topic)
cnt_by_topic

# percentage of topics overall all paragraphs in dataset
p0 <- cnt_by_topic$n / sum(cnt_by_topic$n)
p0

# assign groups and view
groups <- in.topics %>% group_indices(firm)
in.topics$gid <- groups
View(in.topics)

# state table (msm)
head(in.topics)
st <- statetable.msm(main_topic, gid, data = in.topics)
rownames(st) <- colnames(st) <- labels
st
prop.table(st, 1) # state changes by row percentages

# visualization the state matrix in igraph
net=graph.adjacency(st,mode="directed",weighted=TRUE,diag=FALSE)
# compute node degrees (#links) and use that to set node size:
deg <- degree(net, mode="all")
V(net)$size <- deg*3
E(net)$width <- log2(E(net)$weight)
E(net)$arrow.size <- 1.5
graph_attr(net, "layout") <- layout_with_lgl
plot.igraph(net,vertex.label=V(net)$name,layout=layout_with_lgl, edge.curved=.4, vertex.label.color="black", edge.color="gray80",
            vertex.color="light blue", vertex.frame.color="light blue", rescale=TRUE)


# stationary distribution of a Markov chain (igraph)
w <- random_walk(net, start = 1, steps = 1000, mode = "out")
ec <- eigen_centrality(net, directed = TRUE)$vector
pg <- page_rank(net, damping = 0.999)$vector

# correlations
cor(table(w), ec)
cor(table(w), pg)

# msm
qm <- matrix(rep (1, num_topics^2), nrow=num_topics, ncol=num_topics)
diag(qm) <- 0
rownames(qm) <- colnames(qm) <- labels
qm

# join firm-level patent variables with topic panel variables
joined.patents_topics <- in.topics %>% inner_join (in.patent_data, by=c("firm" = "lookup_firm"))
nrow(joined.patents_topics)
head(joined.patents_topics)
View(joined.patents_topics )

joined.patents_topics$log_max_emps <- log(joined.patents_topics$max_emps)

# base model
eager.msm1 <- msm(main_topic ~ para_order, subject = gid, data = in.topics, exacttimes = TRUE, qmatrix = qm, gen.inits=TRUE)
eager.msm1
pmatrix.msm(eager.msm1, t = 2, ci = "normal")

# introduce covariates
eager.msm2 <- msm(main_topic ~ para_order, covariates = ~ mean_cd2017y,subject = gid, data = joined.patents_topics, qmatrix = qm, exacttimes = TRUE, gen.inits=TRUE, control = list(fnscale = 4000, maxit = 10000))
eager.msm2



hazard.msm(eager.msm2)

# more covariates
eager.msm3 <- msm(main_topic ~ para_order, covariates = ~ mean_cd2017y + log_max_emps, subject = gid, data = joined.patents_topics, qmatrix = qm, exacttimes = TRUE, gen.inits=TRUE, control = list(fnscale = 4000, maxit = 10000))
eager.msm3
printnew.msm(eager.msm3)
hazard.msm(eager.msm3)
pmatrix.msm(eager.msm3, t = 1, ci = "normal")
sojourn.msm(eager.msm3) # how long you're in a state
pnext.msm(eager.msm3) # probability of going to the next state, somewhat easier to interpret along with sojourn times, than baseline transition intensities
totlos.msm(eager.msm3, tot=3) # total time in a state
efpt.msm(eager.msm3, tostate=2) # time to get to state x
envisits.msm(eager.msm3, tot=10)

# compare models
lrtest.msm(eager.msm1, eager.msm2) # null hypothesis that both models fit the data the same
lrtest.msm(eager.msm1, eager.msm3)
lrtest.msm(eager.msm2, eager.msm3)

# diffusr random walk -- not appropriate because diagnols coerced to 0 
st.matrix <- matrix(st, nrow=num_topics, ncol=num_topics, dimnames=list(labels, labels))
st.matrix
pt <- random.walk(p0, st.matrix)
pt

