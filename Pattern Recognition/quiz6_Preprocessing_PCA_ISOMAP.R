rm = (list=ls())

data(Glass, package = "mlbench")
training = Glass[c(1:50, 91:146), -10]
trainingType = factor(Glass[c(1:50, 91:146), 10])
testing = Glass[51:90, -10]
testingType = factor(Glass[51:90, 10])

pca_model <- prcomp(training, center = TRUE, scale = TRUE)
eigenvalues = pca_model$sdev^2
sprintf("PC1 value is: %s", eigenvalues[1]/sum(eigenvalues))


pc <- as.data.frame(predict(pca_model, training)[,1:4])
info_loss = sum(eigenvalues[5:9])/sum(eigenvalues)
sprintf("Info loss by keeping 4 PCA is: %s", info_loss)

library(MLmetrics)
library(class)

y = knn(training, testing,trainingType, k=3)
sprintf("Accuracy for knn(k=3): %s", Accuracy(y,testingType))
sprintf("Recall for knn(k=3) and class = 2: %s", Recall(testingType,y,2))

acc = c()
for(i in c(1:9))
{
  pctest <- as.data.frame(predict(pca_model,testing)[,1:i])
  pctrain <- as.data.frame(predict(pca_model,training)[,1:i])
  knn_y <- knn(pctrain, pctest,trainingType, k=3)
  acc[i]=Accuracy(knn_y,testingType)
}
which.max(acc)
