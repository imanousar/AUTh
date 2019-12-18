rm = (list=ls())


kmdata = read.csv("kmdata.txt")
x = kmdata[, 1:2]
y = kmdata[, 3]
par(mfrow=c(2,2))

plot(x)
plot(x, col = y)

model_K = kmeans(x,center=3)
plot(x, col = model_K$cluster)
points(model_K$centers, col = 1:3 , cex = 2 , pch = "+")

library(mixtools)
model_G = mvnormalmixEM(x, k = 3 , epsilon = 0.1)
plot(model_G, which = 2)

library(MLmetrics)
Acc_K = Accuracy(y_pred = model_K$cluster, y)

results_G = max.col(model_G$posterior)
Acc_G = Accuracy(y_pred = results_G, y)

Acc_G
Acc_K