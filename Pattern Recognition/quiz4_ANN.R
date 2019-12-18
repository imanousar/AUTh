library(class)

X1 = c(-2.0 , -2.0 , -1.8 , -1.4 , -1.2 , 1.2 ,1.3 , 1.3 , 2.0 , 2.0 ,-0.9, -0.5 ,-0.2 , 0.0 ,0.0 , 0.3 , 0.4 ,0.5 , 0.8 , 1.0)
X2 = c(-2.0 , 1.0 , -1.0 , 2.0 , 1.2 , 1.0, -1.0 , 2.0 , 0.0 , -2.0 , 0.0 , -1.0 , 1.5 , 0.0 , -0.5 , 1.0 , 0.0 , -1.5 , 1.5 , 0.0)
Y = c(1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2)
knndata = data.frame(X1 , X2 , Y)

X_train = knndata[,c("X1","X2")]
Y_train = knndata$Y
plot(X_train, col = Y_train, pch = c("o","+")[Y_train])

knn(X_train, c(1.5, -0.5), Y_train, k = 3, prob = TRUE)
knn(X_train, c(-1, 1), Y_train, k = 5, prob = TRUE)

rm(list=ls())
library(neuralnet)

X1 = c(2,2,-2,-2,1,1,-1,-1)
X2 = c(2,-2,-2,2,1,-1,-1,1)
Y  = c(1,1,1,1,2,2,2,2)
anndata = data.frame(X1 , X2 , Y)
plot(anndata[,c("X1","X2")], col = Y, pch = c("o","+")[Y]) 
model = neuralnet(Y ~ X1 + X2, anndata, hidden = c(2),  threshold = 0.01)
plot(model)

yEstimateTrain = compute(model, anndata[, c(1:2)])$net.result
TrainingError = anndata$Y - yEstimateTrain
MAE = mean(abs(TrainingError)) 
MAE
