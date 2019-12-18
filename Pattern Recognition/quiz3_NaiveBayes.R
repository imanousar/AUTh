library(e1071)
library(MLmetrics)
library(ROCR)

Class = c(1, 1, 0, 0, 1, 1, 0, 0, 1, 0)
P_M1 = c(0.73, 0.69, 0.44, 0.55, 0.67, 0.47, 0.08, 0.15, 0.45, 0.35)
P_M2 = c(0.61, 0.03, 0.68, 0.31, 0.45, 0.09, 0.38, 0.05, 0.01, 0.04)
data = data.frame(Class, P_M1, P_M2)

# P_M1 find TPR when threshold = 0.5
model <- naiveBayes(Class ~ P_M1, data = data, )
xtest = data[,-1]
ytest = data[,1]
pred = predict(model, xtest)
predprob = predict(model, xtest, type = "raw")

pred_obj = prediction(data$P_M1, data$Class, label.ordering = c("0", "1"))
ROCcurve <- performance(pred_obj, "tpr", "fpr")

str(ROCcurve)
cutoffs <- data.frame(cut=ROCcurve@alpha.values[[1]], fpr=ROCcurve@x.values[[1]], tpr=ROCcurve@y.values[[1]])
cutoffs
ROCcurve
plot(ROCcurve, col = "red")

TP = length(which(data$Class == 1 & data$P_M1 >= 0.5))
FN = length(which(data$Class == 1 & data$P_M1 < 0.5))
recall = TP / (TP + FN)
recall

# P_M2 model

model <- naiveBayes(Class ~ P_M2, data = data, )
xtest = data[,-1]
ytest = data[,1]
pred = predict(model, xtest)
predprob = predict(model, xtest, type = "raw")

# predict F-measure for M_2
TP = length(which(data$Class == 1 & data$P_M2> 0.5))
FN = length(which(data$Class == 0 & data$P_M2 < 0.5))
FP = length(which(data$Class == 0 & data$P_M2 > 0.5))
precision = TP / (TP + FP)
recall = TP / (TP + FN)
f_measure_M2 = (2 * precision * recall) / (precision + recall)
#AUC for P_M2

pred_obj = prediction(predprob[,1], ytest, label.ordering = c("0", "1"))
ROCcurve <- performance(pred_obj, "tpr", "fpr")
plot(ROCcurve, col = "blue", add=TRUE)
Area_under_curve = performance(pred_obj, "auc")
Area_under_curve
abline(0,1, col = "grey")





## quiz3
rm = (list=ls())

Class = c(1, 1, 0, 0, 1, 1, 0, 0, 1, 0)
P_M1 = c(0.73, 0.69, 0.44, 0.55, 0.67, 0.47, 0.08, 0.15, 0.45, 0.35)
P_M2 = c(0.61, 0.03, 0.68, 0.31, 0.45, 0.09, 0.38, 0.05, 0.01, 0.04)
data = data.frame(Class, P_M1, P_M2)

# head(data)
# 
# # P_M1
# TP_M1 = length(which(data$Class == TRUE & data$P_M1 > 0.5))
# FN_M1 = length(which(data$Class == TRUE & data$P_M1 < 0.5))
# 
# TPR_M1 = TP_M1/(TP_M1+FN_M1)
# TPR_M1
# 
# # P_M2
# 
# TP_2 = length(which(data$Class == TRUE & data$P_M2 > 0.5))
# FN_2 = length(which(data$Class == TRUE & data$P_M2 < 0.5))
# FP_2 = length(which(data$Class == FALSE & data$P_M2 > 0.5))
# 
# recall = TP_2 / (TP_2 + FN_2)
# precision = TP_2 / (TP_2 + FP_2)
# f_measure_M2 = (2 * precision * recall) / (precision + recall)
# f_measure_M2

# auc for two models
model_1 <- naiveBayes(Class ~ P_M1, data = data)
model_2 <- naiveBayes(Class ~ P_M2, data = data)
xtest = data[,-1]
ytest = data[,1]
pred = predict(model_1, xtest)
predprob = predict(model_1, xtest, type = "raw")
pred_obj = prediction(predprob[,1], ytest, label.ordering =c("1", "0"))
ROCcurve <- performance(pred_obj, "tpr", "fpr")
plot(ROCcurve, col = "blue")
abline(0,1, col = "grey")



pred = predict(model_2, xtest)
predprob = predict(model_2, xtest, type = "raw")
pred_obj = prediction(predprob[,1], ytest, label.ordering =c("0", "1"))
ROCcurve <- performance(pred_obj, "tpr", "fpr")
plot(ROCcurve, col = "red", add=TRUE)
auc = performance(pred_obj, "auc")
auc 
