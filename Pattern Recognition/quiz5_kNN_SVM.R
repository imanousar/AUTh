rm = (list=ls())
library(MLmetrics)
library(e1071)

X1 = c(2,2,-2,-2,1,1,-1,-1)
X2 = c(2,-2,-2,2,1,-1,-1,1)
Y=c(1,1,1,1,2,2,2,2)

trainingdata =data.frame(X1,X2,Y)
plot(trainingdata[, c(1:2)], col = trainingdata$Y,pch = c("o","+")[trainingdata$Y])

svm_model = svm(Y ~ X1+X2, kernel="radial", type="C-classification",data = trainingdata, gamma = 1)
pred = predict(svm_model, trainingdata[,c(1:2)])
a = Accuracy(pred, trainingdata$Y)
a


svm_model_2 = svm(Y ~ X1+X2, kernel="radial", type="C-classification",data = trainingdata, gamma = 1000000)
test = predict(svm_model_2, data.frame(X1=-2,X2=-1.9))
test


# plots
X1 = seq(min(trainingdata[, 1]), max(trainingdata[, 1]), by = 0.1)
X2 = seq(min(trainingdata[, 2]), max(trainingdata[, 2]), by = 0.1)
mygrid = expand.grid(X1, X2)
colnames(mygrid) = colnames(trainingdata)[1:2]
pred = predict(svm_model, mygrid)
Y = matrix(pred, length(X1), length(X2))
contour(X1, X2, Y, add = TRUE, levels = 1.5, labels = "gamma = 1", col = "blue")

pred = predict(svm_model_2, mygrid)
Y = matrix(pred, length(X1), length(X2))
contour(X1, X2, Y, add = TRUE, levels = 1.5, labels = "gamma = 10e6", col = "red")

