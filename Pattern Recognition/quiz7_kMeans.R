rm = (list=ls())

data = read.csv("quiz.txt")
head(data)


centers = data.frame(c(-4,0,4), c(10,0,10))
model = kmeans(data, centers)
cohesion = model$tot.withinss
cohesion
library(cluster)
seperation = model$betweenss
seperation

model_silhouette = silhouette(model$cluster, dist(data))
plot(model_silhouette)


centers_2 = data.frame(c(-2,2,0), c(0,0,10))
model_2 = kmeans(data, centers_2)
model_silhouette_2 = silhouette(model_2$cluster, dist(data))
plot(model_silhouette_2)

