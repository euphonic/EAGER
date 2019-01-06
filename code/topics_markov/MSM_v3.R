library("msm")
library("dplyr")
library("igraph")
library("diffusr")

# mac os or linux
setwd("/Users/sarora/dev/EAGER/data/")
# windows
# setwd("C:\\Users\\sarora\\Documents\\GitHub\\EAGER\\data")

# copy the label vector from jupyter notebook
labels <- 
  c("product|2018|materi", "system|servic|technolog", "servic|technolog|solut", "inform|product|polici", "solut|technolog|use", "product|2018|busi")

# load firm patent data
# patent_data.file = "patents\\measures\\firm_level_patent_measures.csv"
patent_data.file = "patents/measures/firm_level_patent_measures.csv"
in.patent_data <- read.csv(patent_data.file, header = TRUE, stringsAsFactors = FALSE)
head(in.patent_data)
nrow (in.patent_data)
in.patent_data[grep("\\/", in.patent_data$organization_clnd, perl=TRUE),]

# load data and clean
# depth0_topics.file <- "orgs\\depth0_boilerpipe\\out_topics.csv"
depth0_topics.file <- "orgs/depth0_boilerpipe/out_topics.csv"
in.depth0_topics <- read.csv(depth0_topics.file, header = TRUE, stringsAsFactors = FALSE)
head(in.depth0_topics)
nrow(in.depth0_topics)
in.depth0_topics$main_topic <- in.depth0_topics$main_topic + 1
unique(in.depth0_topics$main_topic)
num_topics <- length(unique(in.depth0_topics$main_topic))
num_topics

cnt_by_topic <- in.depth0_topics %>% count(main_topic)
cnt_by_topic

# percentage of topics overall all paragraphs in dataset
p0 <- cnt_by_topic$n / sum(cnt_by_topic$n)
p0

# assign groups and view
groups <- in.depth0_topics %>% group_indices(firm)
in.depth0_topics$gid <- groups
View(in.depth0_topics)

# state table (msm)
head(in.depth0_topics)
st <- statetable.msm(main_topic, gid, data = in.depth0_topics)
rownames(st) <- colnames(st) <- labels
st
prop.table(st, 1) # state changes by row percentages

# visualization the state matrix in igraph
net=graph.adjacency(st,mode="directed",weighted=TRUE,diag=FALSE)
# compute node degrees (#links) and use that to set node size:
deg <- degree(net, mode="all")
V(net)$size <- deg*3
E(net)$width <- log(E(net)$weight)
E(net)$arrow.size <- 1
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
joined.patents_topics <- in.depth0_topics %>% inner_join (in.patent_data, by=c("firm" = "organization_clnd"))
nrow(joined.patents_topics)
head(joined.patents_topics)
View(joined.patents_topics )

# base model
eager.msm1 <- msm(main_topic ~ para_order, subject = gid, data = in.depth0_topics, exacttimes = TRUE, qmatrix = qm, gen.inits=TRUE)
eager.msm1
pmatrix.msm(eager.msm1, t = 2, ci = "normal")

# introduce covariates
eager.msm2 <- msm(main_topic ~ para_order, covariates = ~ mean_citations_3,subject = gid, data = joined.patents_topics, qmatrix = qm, exacttimes = TRUE, gen.inits=TRUE, control = list(fnscale = 4000, maxit = 10000))
eager.msm2
hazard.msm(eager.msm2)

# more covariates
eager.msm3 <- msm(main_topic ~ para_order, covariates = ~ mean_citations_3 + first_year + num_patents_all + mean_assignees_all + mean_inventors_3, subject = gid, data = joined.patents_topics, qmatrix = qm, exacttimes = TRUE, gen.inits=TRUE, control = list(fnscale = 4000, maxit = 10000))
eager.msm3
hazard.msm(eager.msm3)

# compare models
lrtest.msm(eager.msm1, eager.msm2)
lrtest.msm(eager.msm1, eager.msm3)
lrtest.msm(eager.msm2, eager.msm3)

# diffusr random walk -- not appropriate because diagnols coerced to 0 
st.matrix <- matrix(st, nrow=num_topics, ncol=num_topics, dimnames=list(labels, labels))
st.matrix
pt <- random.walk(p0, st.matrix)
pt

