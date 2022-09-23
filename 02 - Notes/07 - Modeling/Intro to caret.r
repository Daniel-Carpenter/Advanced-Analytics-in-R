library(caret)
library(AppliedPredictiveModeling)
library(tidyverse)
data(concrete,package="AppliedPredictiveModeling")

?concrete

# Compressive Strength of Concrete from Yeh (1998)
# 
# Data that can be used to model compressive strength of concrete formulations
# as a functions of their ingredients and age.
#
# From: http://archive.ics.uci.edu/ml/datasets/Concrete+Compressive+Strength
#
# "Concrete is the most important material in civil engineering. The 
# concrete compressive strength is a highly nonlinear function of age and 
# ingredients. These ingredients include cement, blast furnace slag, fly ash, 
# water, superplasticizer, coarse aggregate, and fine aggregate."

# Cement (component 1) -- quantitative -- kg in a m3 mixture -- Input Variable
# Blast Furnace Slag (component 2) -- quantitative -- kg in a m3 mixture -- Input Variable
# Fly Ash (component 3) -- quantitative -- kg in a m3 mixture -- Input Variable
# Water (component 4) -- quantitative -- kg in a m3 mixture -- Input Variable
# Superplasticizer (component 5) -- quantitative -- kg in a m3 mixture -- Input Variable
# Coarse Aggregate (component 6) -- quantitative -- kg in a m3 mixture -- Input Variable
# Fine Aggregate (component 7) -- quantitative -- kg in a m3 mixture -- Input Variable
# Age -- quantitative -- Day (1~365) -- Input Variable
# Concrete compressive strength -- quantitative -- MPa -- Output Variable 


glimpse(concrete)


#train command -- can access several models
#              -- performs resampling
#              -- performs hyperparameter tuning (when available)

# the "lm" model does not have any hyperparameters

fit <- train(CompressiveStrength~.,
             data=concrete,
             method="lm")

fit

fit$finalModel


#you can adjust the resampling parameters using "trainControl"


fitControl <- trainControl(method="cv",number=5)

fit <- train(CompressiveStrength~.,
             data=concrete,
             method="lm",
             trControl=fitControl)
fit



#if you wish to also train hyperparameters...
# (1) make sure you know what hyperparameters are available to tune
# (2) either use the default parameter search, or
# (3) more likely setup your own search parameters


# the lasso model has hyperparameters
# look for the correct "method" and parameter names on:
# https://topepo.github.io/caret/available-models.html


#method name is "lasso" and parameter name is "fraction"


#using default training values

fit <- train(CompressiveStrength~.,
             data=concrete,
             method="lasso",
             trControl=fitControl)

fit
plot(fit)

#or change the metric you want to plot

plot(fit, metric = "Rsquared")



#expanding the  default parameter search some

fit <- train(CompressiveStrength~.,
             data=concrete,
             method="lasso",
             trControl=fitControl,
             tuneLength = 10)

fit



#specifying exactly the hyperparameter values to use with "expand.grid"

lassoGrid <- expand.grid(fraction=seq(0.7,0.99,length=100))

fit <- train(CompressiveStrength~.,
             data=concrete,
             method="lasso",
             trControl=fitControl,
             tuneGrid=lassoGrid)
fit

plot(fit)


#now for a too complicated model

#specifying exactly the hyperparameter values to use with "expand.grid"

lassoGrid <- expand.grid(fraction=seq(0.35,0.95,length=30))

fit <- train(CompressiveStrength~.*.,   #<-- notice the change!
              data=concrete,
             method="lasso",
             trControl=fitControl,
             tuneGrid=lassoGrid)
fit

plot(fit)



#some models have multiple parameters to train
#e.g., elasticnet: method = "enet", parameters: fraction, lambda

enetGrid <- expand.grid(lambda=seq(0,.15,length=5),
                        fraction=seq(0.45,.9,length=30))


fit <- train(CompressiveStrength~.*.,
             data=concrete,
             method="enet",
             trControl=fitControl,
             tuneGrid=enetGrid)
fit
plot(fit)

#if there are two hyperparameters to be trained, you can look at the
# "level" plot to see what are good combinations of the values

plot(fit, plotType="level")

