# libraries used
library(dplyr) # data wrangling
library(neuralnet) # Used for neuralnet function
library(readr) # To read csv files
library(caTools) # To split data
library(Metrics) # To calculate RMSE value

?neuralnet

# Classification problem

# Data Source - "http://archive.ics.uci.edu/ml/datasets/Bank+Marketing"

bank_data = read.csv("bank.csv", sep = ';')

str(bank_data)

# Selecting few columns in data
bank = bank_data %>%
  select(-c('contact', 'day', 'month', 'duration', 'pdays'))

# Normalize data
bank$age = scale(bank$age, center = min(bank$age), scale = max(bank$age) - min(bank$age))
bank$balance = scale(bank$balance, center = min(bank$balance), scale = max(bank$balance) - min(bank$balance))
bank$campaign = scale(bank$campaign, center = min(bank$campaign), scale = max(bank$campaign) - min(bank$campaign))
bank$previous = scale(bank$previous, center = min(bank$previous), scale = max(bank$previous) - min(bank$previous))

set.seed(9)

bank_matrix = model.matrix(~., data =bank)
colnames(bank_matrix)[3] = "jobblueCollar"
colnames(bank_matrix)[8] = "jobselfEmployed"

fmla <- formula(paste("yyes ~ ", paste(colnames(bank_matrix[,-c(1,28)]), collapse= "+"), collapse = ""))

# Neuralnet model using backpropogation algorithm.
nn1 = neuralnet(fmla, data = bank_matrix,
                hidden = 1,
                algorithm = 'backprop',
                learningrate = 0.0001,
                err.fct="ce",
                linear.output = FALSE,
                stepmax = 1e+06)

plot(nn1) # Plotting the neuralnet

nn1$generalized.weights # To check the weights

pred = compute(nn1, bank_matrix[, -c(1,28)]) # To predict on test set
class_pred = round(pred$net.result)

# Neuralnet model using resilient backpropogation algorithm.
nn2 = neuralnet(fmla, data=bank_matrix,
                algorithm = "rprop+",
                hidden=c(5),
                threshold=0.5, # '0.5' not suggested. Default value is '0.01'. 
                rep=3,
                stepmax = 1e+06,
                lifesign =  "minimal")

plot(nn2, rep = "best") # Plot the best neuralnet


# Regresssion problem example

library(MASS) # Boston Data
?Boston
str(Boston)

# Normalize data

minb = apply(Boston, 2, min)
maxb = apply(Boston, 2, max)

scaled_data = as.data.frame(scale(Boston, center = minb, scale = maxb-minb))

summary(scaled_data)

fmla1 = formula(paste("medv~", paste(names(scaled_data[,c(-14)]), collapse= '+')))

# Neuralnet with '1' hidden layer.
nn3 = neuralnet(fmla1, data = scaled_data,
                hidden =  8,
                algorithm =  'backprop',
                learningrate =  0.001,
                linear.output = TRUE, 
                stepmax = 1e+06)

plot(nn3) # To plot the model


# Neuralnet with '2' hidden layers.
nn4 = neuralnet(fmla1, data = scaled_data,
                threshold = 0.5, # '0.5' not suggested. Default value is '0.01'.
                hidden =  c(5, 3),
                algorithm =  'backprop',
                learningrate =  0.001,
                linear.output = TRUE)

plot(nn4) # To plot the model.

pred = predict(nn3, scaled_data[, c(-1)]) # Predict on train data
pred

rmse(scaled_data$medv, pred) # To find RMSE value on train data.

pred1 = predict(nn4, scaled_data[, c(-1)])
pred1
rmse(scaled_data$medv, pred1)
