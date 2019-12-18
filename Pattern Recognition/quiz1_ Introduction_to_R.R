rm = (list=ls())

dn = list(paste("Y", as.character(1949:1960), sep = ""), month.abb)
airmat = matrix(AirPassengers, 12, byrow = TRUE, dimnames = dn)
air = as.data.frame(t(airmat))

mean(air$Y1951)

max(air["Jan",])
max(air["Feb",])

cor(air[4:6],air[3])

cor(t(air[1:12]))
cor(t(air[1:2,-1]))

a <- c()
for(i in 1:12)
{
  a <- c(a,sum(air[,i]))
}


a

w = unlist(air["Jan",])
w


###############  second try  ######################## 

rm = (list=ls())

dn = list(paste("Y", as.character(1949:1960), sep = ""), month.abb)
airmat = matrix(AirPassengers, 12, byrow = TRUE, dimnames = dn)
air = as.data.frame(t(airmat))

head(air)
# Y1949 Y1950 Y1951 Y1952 Y1953 Y1954 Y1955 Y1956 Y1957 Y1958 Y1959 Y1960
# Jan   112   115   145   171   196   204   242   284   315   340   360   417
# Feb   118   126   150   180   196   188   233   277   301   318   342   391
# Mar   132   141   178   193   236   235   267   317   356   362   406   419
# Apr   129   135   163   181   235   227   269   313   348   348   396   461
# May   121   125   172   183   229   234   270   318   355   363   420   472
# Jun   135   149   178   218   243   264   315   374   422   435   472   535


summary(air, digits=10)
summary(t(air), digits=10)
# mean number of passengers in 1951?
mean(air$Y1951)

# max no of passengers for January,February?
max(air["Jan",])
max(air["Feb",])

# cross correlation of 1952, 1953 and 1954 with 1951.
cor(air[4:6],air[3])
cor(air$Y1952, air$Y1951)

# cross correlation of January, February with November
cor(t(air[1:2,]), t(air["Nov",]))
cor(t(air["Jan",]), t(air["Nov",]))

# sum of passenger of each year
for(i in 1:12)
{
  a = c(a,sum(air[,i]))
  
}
plot(a)

plot(colSums(air), type="b")


