rm = (list=ls())

library(rpart)
library(rpart.plot)

cars = read.csv("cars.txt")
head(cars)

#Overall Gini
absfreq = table(cars[,c(5,5)])
freq = prop.table(absfreq, 1)
freqSum = rowSums(prop.table(absfreq))
GINI_overall = 1 -freqSum["No"]^2 - freqSum["Yes"]^2
 
# Customers ID - Gini
# Since we have 20 different customers IDs
# we will end up in 20 different leaves, each of them
# is gonna have one sample and the GINI_of_customer_i = 1 - (1/1)^2 
# If we continue we will end up in a zero result

# GINI_Sex , Attention if it asks for GINI_M or GINI_F
absfreq = table(cars[, c(2, 5)])
freq = prop.table(absfreq, 1)
freqSum = rowSums(prop.table(absfreq))
GINI_M = 1 - freq["M", "No"]^2 - freq["M", "Yes"]^2
GINI_F = 1 - freq["F", "No"]^2 - freq["F", "Yes"]^2
GINI_Sex = freqSum["M"] * GINI_M + freqSum["F"] * GINI_F

# GINI_Cars
absfreq = table(cars[, c(3, 5)])
freq = prop.table(absfreq, 1)
freqSum = rowSums(prop.table(absfreq))
GINI_Family = 1 - freq["Family", "No"]^2 - freq["Family", "Yes"]^2
GINI_Sedan = 1 - freq["Sedan", "No"]^2 - freq["Sedan", "Yes"]^2
GINI_Sport = 1 - freq["Sport", "No"]^2 - freq["Sport", "Yes"]^2
GINI_CarType = freqSum["Family"] * GINI_Family + freqSum["Sedan"] * GINI_Sedan + freqSum["Sport"] * GINI_Sport

# GINI_Budget
absfreq = table(cars[, c(4, 5)])
freq = prop.table(absfreq, 1)
freqSum = rowSums(prop.table(absfreq))
GINI_Low = 1 - freq["Low", "No"]^2 - freq["Low", "Yes"]^2
GINI_Medium = 1 - freq["Medium", "No"]^2 - freq["Medium", "Yes"]^2
GINI_High = 1 - freq["High", "No"]^2 - freq["High", "Yes"]^2
GINI_VeryHigh = 1 - freq["VeryHigh", "No"]^2 - freq["VeryHigh", "Yes"]^2
GINI_Budget = freqSum["Low"] * GINI_Low + freqSum["Medium"] * GINI_Medium + freqSum["High"] * GINI_High + freqSum["VeryHigh"] * GINI_VeryHigh

model <- rpart(Insurance ~ CarType +  Budget + Sex, method = "class", data = cars, minsplit = 1, minbucket = 1, cp = -1)
rpart.plot(model, extra = 104, nn = TRUE)

