library("msm")
library("dplyr")
library("igraph")
library("diffusr")
setwd("/home/eager/EAGER/data/orgs/workshop/depth0_boilerpipe/")

labels <- c("power|technolog|system", "thermoplast|use|long", "technolog|develop|new", "technolog|energi|celanes", "power|use|high")

in.depth0_topics <- read.csv("out_topics.csv", header = TRUE, stringsAsFactors = FALSE)
head(in.depth0_topics)
nrow(in.depth0_topics)
in.depth0_topics$main_topic <- in.depth0_topics$main_topic + 1
unique(in.depth0_topics$main_topic)
num_topics <- length(unique(in.depth0_topics$main_topic))
num_topics

cnt_by_topic <- in.depth0_topics %>% count(main_topic)
p0 <- cnt_by_topic$n / sum(cnt_by_topic$n)

groups <- in.depth0_topics %>% group_indices(firm_key)
in.depth0_topics$gid <- groups
View(in.depth0_topics)

# state table (msm)
head(in.depth0_topics)
st <- statetable.msm(main_topic, gid, data = in.depth0_topics)
rownames(st) <- colnames(st) <- labels
st

# igraph
net=graph.adjacency(st,mode="directed",weighted=TRUE,diag=FALSE)
# Compute node degrees (#links) and use that to set node size:
deg <- degree(net, mode="all")
V(net)$size <- deg*3
E(net)$width <- E(net)$weight * 2
E(net)$arrow.size <- .2
graph_attr(net, "layout") <- layout_with_lgl
plot.igraph(net,vertex.label=V(net)$name,layout=layout_with_lgl, edge.arrow.size=0.5, edge.curved=.4, vertex.label.color="black", edge.color="gray80",
            vertex.color="light blue", vertex.frame.color="light blue", rescale=TRUE)


## Stationary distribution of a Markov chain (igraph)
w <- random_walk(net, start = 3, steps = 1000, mode = "out")
ec <- eigen_centrality(net, directed = TRUE)$vector
pg <- page_rank(net, damping = 0.999)$vector
## These are similar, but not exactly the same
cor(table(w), ec)
## But these are (almost) the same
cor(table(w), pg)

# msm
qm <- matrix(rep (1, num_topics^2), nrow=num_topics, ncol=num_topics)
diag(qm) <- 0
rownames(qm) <- colnames(qm) <- labels
qm

# Train base model
eager.msm1 <- msm(main_topic ~ para_order, subject = gid, data = in.depth0_topics, qmatrix = qm, exacttimes = TRUE, gen.inits=TRUE)
eager.msm1

# Introduce covariates
eager.msm2 <- msm(main_topic ~ para_order, covariates = ~ num_words + prob ,subject = gid, data = in.depth0_topics, qmatrix = qm, exacttimes = TRUE, gen.inits=TRUE, control = list(fnscale = 4000, maxit = 10000))
eager.msm2
hazard.msm(eager.msm2)
lrtest.msm(eager.msm1, eager.msm2)

# Compare models

# diffusr random walk
st.matrix <- matrix(st, nrow=num_topics, ncol=num_topics, dimnames=list(labels, labels))
st.matrix
pt    <- random.walk(p0, st.matrix)

