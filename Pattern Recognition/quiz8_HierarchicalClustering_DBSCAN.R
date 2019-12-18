rm = (list=ls())

dcdata = read.csv("dcdata.txt")
target = dcdata[, 3]
dcdata = dcdata[, 1:2]

    

d = dist(dcdata)
hc_single = hclust(d, method = "single")
clusters_single = cutree(hc_single, k = 2)
plot(dcdata, col = clusters_single, pch = 15, main = "Single Linkage")
text(dcdata, labels = row.names(dcdata), pos = 2)



hc_complete = hclust(d, method = "complete")
clusters_complete = cutree(hc_complete, k = 2)
plot(dcdata, col = clusters_complete, 15, main = "Complete Linkage")

library(dbscan)

model = dbscan(dcdata, eps = 0.75, minPts = 5)
plot(dcdata, col = model$cluster + 1, pch = ifelse(model$cluster, 1, 4))

model = dbscan(dcdata, eps = 1, minPts = 5)
plot(dcdata, col = model$cluster + 1, pch = ifelse(model$cluster, 1, 4))
 
model = dbscan(dcdata, eps = 1.25, minPts = 5)
plot(dcdata, col = model$cluster + 1, pch = ifelse(model$cluster, 1, 4))
 
model = dbscan(dcdata, eps = 1.5, minPts = 5)
plot(dcdata, col = model$cluster + 1, pch = ifelse(model$cluster, 1, 4))

model = kmeans(dcdata, 2)
plot(dcdata, col = model$cluster + 1)


library(MLmetrics)
Accuracy(clusters_single, target)

Accuracy(clusters_complete, target)
