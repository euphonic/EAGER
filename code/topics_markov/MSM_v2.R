library("msm")
library("dplyr")
library("igraph")
library("diffusr")
setwd("/home/eager/EAGER/data/orgs/workshop/depth0_boilerpipe/")

# copy the label vector from jupyter notebook
labels <- c("technolog|power|use", "thermoplast|cooki|technolog", "warn|technolog|energi", "energi|technolog|system", "cancer|develop|diagnost")

# load data and clean
in.depth0_topics <- read.csv("out_topics.csv", header = TRUE, stringsAsFactors = FALSE)
head(in.depth0_topics)
nrow(in.depth0_topics)
in.depth0_topics$main_topic <- in.depth0_topics$main_topic + 1
unique(in.depth0_topics$main_topic)
num_topics <- length(unique(in.depth0_topics$main_topic))
num_topics

cnt_by_topic <- in.depth0_topics %>% count(main_topic)

# percentage of topics overall all paragraphs in dataset
p0 <- cnt_by_topic$n / sum(cnt_by_topic$n)
p0

# assign groups and view
groups <- in.depth0_topics %>% group_indices(firm_key)
in.depth0_topics$gid <- groups
View(in.depth0_topics)

# state table (msm)
head(in.depth0_topics)
st <- statetable.msm(main_topic, gid, data = in.depth0_topics)
rownames(st) <- colnames(st) <- labels
st

# visualization the state matrix in igraph
net=graph.adjacency(st,mode="directed",weighted=TRUE,diag=FALSE)
# compute node degrees (#links) and use that to set node size:
deg <- degree(net, mode="all")
V(net)$size <- deg*3
E(net)$width <- E(net)$weight * 2
E(net)$arrow.size <- 2
graph_attr(net, "layout") <- layout_with_lgl
plot.igraph(net,vertex.label=V(net)$name,layout=layout_with_lgl, edge.curved=.4, vertex.label.color="black", edge.color="gray80",
            vertex.color="light blue", vertex.frame.color="light blue", rescale=TRUE)


# stationary distribution of a Markov chain (igraph)
w <- random_walk(net, start = 3, steps = 1000, mode = "out")
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

# base model
eager.msm1 <- msm(main_topic ~ para_order, subject = gid, data = in.depth0_topics, exacttimes = TRUE, qmatrix = qm, gen.inits=TRUE)
eager.msm1
pmatrix.msm(eager.msm1, t = 2, ci = "normal")

# introduce covariates
eager.msm2 <- msm(main_topic ~ para_order, covariates = ~ num_words + prob ,subject = gid, data = in.depth0_topics, qmatrix = qm, exacttimes = TRUE, gen.inits=TRUE, control = list(fnscale = 4000, maxit = 10000))
eager.msm2
hazard.msm(eager.msm2)

# compare models
lrtest.msm(eager.msm1, eager.msm2)

# diffusr random walk -- not appropriate because diagnols coerced to 0 
st.matrix <- matrix(st, nrow=num_topics, ncol=num_topics, dimnames=list(labels, labels))
st.matrix
pt <- random.walk(p0, st.matrix)
pt

