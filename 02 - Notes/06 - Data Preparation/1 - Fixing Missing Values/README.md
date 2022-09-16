Handling Missing Data
================
Daniel Carpenter

-   <a href="#deletion-and-indicators"
    id="toc-deletion-and-indicators"><span
    class="toc-section-number">1</span> Deletion and Indicators</a>
    -   <a href="#summary" id="toc-summary"><span
        class="toc-section-number">1.1</span> Summary</a>
    -   <a href="#single-imputation" id="toc-single-imputation"><span
        class="toc-section-number">1.2</span> Single Imputation</a>
    -   <a href="#multiple-imputation" id="toc-multiple-imputation"><span
        class="toc-section-number">1.3</span> Multiple Imputation</a>
    -   <a href="#maximum-likelihood" id="toc-maximum-likelihood"><span
        class="toc-section-number">1.4</span> Maximum Likelihood</a>
    -   <a href="#multiple-imputation-in-r"
        id="toc-multiple-imputation-in-r"><span
        class="toc-section-number">1.5</span> Multiple Imputation in R</a>
    -   <a href="#section" id="toc-section"><span
        class="toc-section-number">1.6</span> </a>

# Deletion and Indicators

## Summary

<img src="images/paste-CE124352.png" width="550" />

## Single Imputation

### How to determine missingness cause?

> Example in R

<img src="images/paste-E5A3A1B5.png" width="550" />

| **MAR**  | Missing values in `y` depend on `x`, which x *is in* the data       |
|----------|---------------------------------------------------------------------|
| **MNAR** | Missing values in `y` depend on `y` (itself)                        |
| **MCAR** | Missing values in `y` depend on `z`, which `z` *is NOT* in the data |

### Handling Missingness - Basic/Simple Approaches

-   Note most imputation assumes MCAR or MAR

-   Can hurt the variance if not used well.

-   Nothing is perfect

<img src="images/paste-752F6FFF.png" width="550" />

<table>
<colgroup>
<col style="width: 16%" />
<col style="width: 34%" />
<col style="width: 32%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th>Handling</th>
<th>Description</th>
<th>Implication</th>
<th>Example</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Listwise</td>
<td>Delete entire record if there are nulls</td>
<td>Less data</td>
<td><code>newdata &lt;- na.omit(mydata)</code></td>
</tr>
<tr class="even">
<td>Pairwise Deletion</td>
<td>Use all cases if available, for each column.</td>
<td>Hard to compare columns</td>
<td><code>mean(column,  na.rm=TRUE</code></td>
</tr>
<tr class="odd">
<td><p>Indicators</p>
<p><em>DO NOT USE THIS FOR MOST ANALYSIS</em></p></td>
<td>Create new binary <code>1/0</code> indicating missing values, or
could create new factor</td>
<td>Produces biased estimates since likely does not represent true
variance</td>
<td></td>
</tr>
<tr class="even">
<td>Single Value Imputation</td>
<td>Missing value changed with the mean, median</td>
<td>Produces biased estimates since likely does not represent
<em>true</em> variance</td>
<td></td>
</tr>
<tr class="odd">
<td>Stratified Imputation</td>
<td>Impute based on groupings</td>
<td>Less bad than single</td>
<td>Average income for male, females, etc.</td>
</tr>
</tbody>
</table>

### Handling Missingness - Predictive Approaches

<img src="images/paste-7C541A82.png" width="550" />

| Handling                 | Description                                                               | Implication                                                                                                                                    | Example                        |
|--------------------------|---------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|
| Regression               | Build regression from non missing data. Then predict the values           | Trend is good, but it reduces error                                                                                                            |                                |
| Regression with Error    | Same as above, but include the `residual standard error` from model       | Still deflates variance, and cannot usually test success. Similar trend with realistic error, similar to original data. Does not restain range |                                |
| Predictive mean matching | Hybrid between regression, but also includes the range of current dataset | Better than prior, but can create ranges of variance that are incorrect.                                                                       | ![](images/paste-48081196.png) |
| kNN                      | Uses distance calclulation to discover closest data to missing one        | Increased neighbors will be similar to mean imputation                                                                                         | ![](images/paste-4CE0562F.png) |

### Single Imputation in R

``` r
#Example of single imputation techniques for ISE 5103 Intelligent Data Analytics
#Charles Nicholson
#September 2015

#load appropriate libraries
library(VIM)
library(mice)


# CREATE A SET OF FAKE DATA  (y ~ x) ------------
x<-rexp(1000)
y<-0.5*rnorm(1000) + 0.5*x       
z<-runif(1000)

alpha<-runif(1000) # not included in dataframe
beta<-runif(1000)  # not included in dataframe

df<-data.frame(x,y,z)

xmax<-ceiling(max(df$x))
ymax<-ceiling(max(df$y))
ymin<-floor(min(df$y))


#scatterplot would look like this if there were NO MISSING INFORMATION
plot(df$x,df$y,ylim=c(ymin,ymax), xlim=c(0,xmax) , xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-1.png)

``` r
# now lets create some missing values....
dfMiss <- df

dfMiss[df$y>1.30,"y"]<-NA           #MNAR
dfMiss[alpha<0.2,"z"]<-NA           #MCAR
dfMiss[beta>0.90,"y"]<-NA           #MCAR
dfMiss[df$x>2.65,"y"]<-NA           #MAR

missing <- is.na(dfMiss$y)
sum(missing)
```

    [1] 232

``` r
dfMiss$missing <- missing

#scatterplot now looks like this...
plot(dfMiss$x,dfMiss$y,ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-2.png)

``` r
#imputaion by "hotdeck" --------------------------------------------------------
dfHD.imp <- dfMiss

#sample m values from from the non-missing data (with replacement)
hotdeck <- dfHD.imp[!missing,"y"]  # create sample pool

n <- length(hotdeck)    #size of sample pool
m <- sum(missing)    #how many samples do I need?

hotdeck <- hotdeck[sample(n,m,replace=TRUE)]

dfHD.imp[missing,"y"]<-hotdeck

plot(df$x,df$y,ylim=c(-1.3,4.25))    #plot of all data (no missings)
```

![](README_files/figure-gfm/unnamed-chunk-1-3.png)

``` r
#plot data with hotdeck imputation -- imputed values in red
plot(dfHD.imp$x, dfHD.imp$y, col = factor(dfHD.imp$missing), ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-4.png)

``` r
par(mfrow=c(2,1))   #setup graphics device to make two plots on the screen

hist(df$y, xlim=c(-1,xmax), main="All Data", xlab="x")   #histogram of all data
trueMV<-round(mean(df$y),3)                               
trueVar<-round(var(df$y),3)
abline(v = trueMV, col = "blue", lwd = 2)                    # add a line for the mean
text(4, 205, label=paste("Mean:",trueMV, "  Var:", trueVar)) # add text for mean and var

hist(dfHD.imp$y, xlim=c(-1,xmax), main="Hot Deck", xlab="x")
mv<-round(mean(dfHD.imp$y),3)
svar<-round(var(dfHD.imp$y),3)
abline(v = mv, col = "blue", lwd = 2)
text(4, 100, label=paste("Mean:",mv, "  Var:", svar))
```

![](README_files/figure-gfm/unnamed-chunk-1-5.png)

``` r
par(mfrow=c(1,1))   # reset graphics device to the default 1 plot



#imputation by mean ---------------------------------------------------------

dfMean.imp<-dfMiss  #copy of the data with missings

dfMean.imp[missing,"y"]<-mean(dfMean.imp$y,na.rm=T)   #imputation by mean


par(mfrow=c(2,1))
hist(df$y, xlim=c(-1,xmax), main="All Data", xlab="x")
abline(v = trueMV, col = "blue", lwd = 2)
text(4, 205, label=paste("Mean:",trueMV, "  Var:", trueVar))

hist(dfMean.imp$y, xlim=c(-1,xmax), main="Mean Imputation", xlab="x")
mv<-round(mean(dfMean.imp$y),3)
svar<-round(var(dfMean.imp$y),3)
abline(v = mv, col = "blue", lwd = 2)
text(4, 205, label=paste("Mean:",mv, "  Var:", svar))
```

![](README_files/figure-gfm/unnamed-chunk-1-6.png)

``` r
par(mfrow=c(1,1))

plot(dfMean.imp$x, dfMean.imp$y, col = factor(dfMean.imp$missing), ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-7.png)

``` r
#imputation by "regression"  ---------------------------------------------

fit<-lm(dfMiss$y~dfMiss$x)    # fit a linear model to the data
f<-summary(fit)
print (f)  
```


    Call:
    lm(formula = dfMiss$y ~ dfMiss$x)

    Residuals:
         Min       1Q   Median       3Q      Max 
    -1.69438 -0.31201  0.00807  0.31616  1.17192 

    Coefficients:
                Estimate Std. Error t value Pr(>|t|)    
    (Intercept) -0.01975    0.02528  -0.781    0.435    
    dfMiss$x     0.42572    0.02658  16.014   <2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

    Residual standard error: 0.4576 on 766 degrees of freedom
      (232 observations deleted due to missingness)
    Multiple R-squared:  0.2508,    Adjusted R-squared:  0.2499 
    F-statistic: 256.5 on 1 and 766 DF,  p-value: < 2.2e-16

``` r
str(f)
```

    List of 12
     $ call         : language lm(formula = dfMiss$y ~ dfMiss$x)
     $ terms        :Classes 'terms', 'formula'  language dfMiss$y ~ dfMiss$x
      .. ..- attr(*, "variables")= language list(dfMiss$y, dfMiss$x)
      .. ..- attr(*, "factors")= int [1:2, 1] 0 1
      .. .. ..- attr(*, "dimnames")=List of 2
      .. .. .. ..$ : chr [1:2] "dfMiss$y" "dfMiss$x"
      .. .. .. ..$ : chr "dfMiss$x"
      .. ..- attr(*, "term.labels")= chr "dfMiss$x"
      .. ..- attr(*, "order")= int 1
      .. ..- attr(*, "intercept")= int 1
      .. ..- attr(*, "response")= int 1
      .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
      .. ..- attr(*, "predvars")= language list(dfMiss$y, dfMiss$x)
      .. ..- attr(*, "dataClasses")= Named chr [1:2] "numeric" "numeric"
      .. .. ..- attr(*, "names")= chr [1:2] "dfMiss$y" "dfMiss$x"
     $ residuals    : Named num [1:768] 0.7 -0.959 0.3 0.218 0.406 ...
      ..- attr(*, "names")= chr [1:768] "2" "3" "4" "5" ...
     $ coefficients : num [1:2, 1:4] -0.0197 0.4257 0.0253 0.0266 -0.7812 ...
      ..- attr(*, "dimnames")=List of 2
      .. ..$ : chr [1:2] "(Intercept)" "dfMiss$x"
      .. ..$ : chr [1:4] "Estimate" "Std. Error" "t value" "Pr(>|t|)"
     $ aliased      : Named logi [1:2] FALSE FALSE
      ..- attr(*, "names")= chr [1:2] "(Intercept)" "dfMiss$x"
     $ sigma        : num 0.458
     $ df           : int [1:3] 2 766 2
     $ r.squared    : num 0.251
     $ adj.r.squared: num 0.25
     $ fstatistic   : Named num [1:3] 256 1 766
      ..- attr(*, "names")= chr [1:3] "value" "numdf" "dendf"
     $ cov.unscaled : num [1:2, 1:2] 0.00305 -0.00243 -0.00243 0.00338
      ..- attr(*, "dimnames")=List of 2
      .. ..$ : chr [1:2] "(Intercept)" "dfMiss$x"
      .. ..$ : chr [1:2] "(Intercept)" "dfMiss$x"
     $ na.action    : 'omit' Named int [1:232] 1 10 15 23 27 28 30 31 34 36 ...
      ..- attr(*, "names")= chr [1:232] "1" "10" "15" "23" ...
     - attr(*, "class")= chr "summary.lm"

``` r
c<-f[[4]]                     # extract the coefficients 
se<-f[[6]]                    # extract the model standard error

dfReg.imp <- dfMiss
dfReg.imp[missing,"y"]<- (c[1] + c[2]*dfReg.imp[missing,"x"])   #imputataion with regression


par(mfrow=c(2,1))
hist(df$y, xlim=c(-1,xmax), main="All Data", xlab="x")
abline(v = trueMV, col = "blue", lwd = 2)
text(4, 205, label=paste("Mean:",trueMV, "  Var:", trueVar))

hist(dfReg.imp$y, xlim=c(-1,xmax), main="Regression Imputation", xlab="x")
mv<-round(mean(dfReg.imp$y),3)
svar<-round(var(dfReg.imp$y),3)
abline(v = mv, col = "blue", lwd = 2)
text(4, 205, label=paste("Mean:",mv, "  Var:", svar))
```

![](README_files/figure-gfm/unnamed-chunk-1-8.png)

``` r
par(mfrow=c(1,1))

plot(dfReg.imp$x, dfReg.imp$y, col = factor(dfReg.imp$missing),ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-9.png)

``` r
# USE THE mice PACKAGE FOR Predictive Mean Matching (PMM) -----------------------
dfPMM.imp <- dfMiss

#imputation by PMM
dfPMM.imp[missing,"y"] <- mice.impute.pmm(dfPMM.imp$y, !dfPMM.imp$missing, dfPMM.imp$x)

plot(dfPMM.imp$x, dfPMM.imp$y, col = factor(dfPMM.imp$missing), ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-10.png)

``` r
par(mfrow=c(2,1))
hist(df$y, xlim=c(-1,xmax),main="All Data", xlab="x")
abline(v = trueMV, col = "blue", lwd = 2)
text(4, 205, label=paste("Mean:",trueMV, "  Var:", trueVar))

hist(dfPMM.imp$y, xlim=c(-1,xmax), main="Predictive Mean Matching", xlab="x")
mv<-round(mean(dfPMM.imp$y),3)
svar<-round(var(dfPMM.imp$y),3)
abline(v = mv, col = "blue", lwd = 2)
text(4, 80, label=paste("Mean:",mv, "  Var:", svar))
```

![](README_files/figure-gfm/unnamed-chunk-1-11.png)

``` r
par(mfrow=c(1,1))



#imputation by "regression" plus random error -------------------------

dfRegErr.imp <- dfReg.imp

#imputation by regression with error (remember that se = standard error of model)
dfRegErr.imp[missing,"y"] <- dfRegErr.imp[missing,"y"] + rnorm(sum(missing),0,se**2)

par(mfrow=c(2,1))
hist(df$y, xlim=c(-1,xmax), main="All Data", xlab="x")
abline(v = trueMV, col = "blue", lwd = 2)
text(4, 205, label=paste("Mean:",trueMV, "  Var:", trueVar))

hist(dfRegErr.imp$y, xlim=c(-1,xmax), main="Regression Imputation with Error", xlab="x")
mv<-round(mean(dfRegErr.imp$y),3)
svar<-round(var(dfRegErr.imp$y),3)
abline(v = mv, col = "blue", lwd = 2)
text(4, 205, label=paste("Mean:",mv, "  Var:", svar))
```

![](README_files/figure-gfm/unnamed-chunk-1-12.png)

``` r
par(mfrow=c(1,1))

plot(dfRegErr.imp$x, dfRegErr.imp$y, col = factor(dfRegErr.imp$missing), ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-13.png)

``` r
# k-nearest neighbor from VIM package (kNN imputation) ----------------------------

dfKNN.imp <- kNN(dfMiss[,1:3],k=5)
plot(dfKNN.imp$x, dfKNN.imp$y, col = factor(dfKNN.imp$y_imp), ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-14.png)

``` r
par(mfrow=c(2,1))
hist(df$y, xlim=c(-1,xmax), main="All Data", xlab="x")
abline(v = trueMV, col = "blue", lwd = 2)
text(4, 205, label=paste("Mean:",trueMV, "  Var:", trueVar))

hist(dfKNN.imp$y, xlim=c(-1,xmax), main="k-Nearest Neighbor", xlab="x")
mv<-round(mean(dfKNN.imp$y),3)
svar<-round(var(dfKNN.imp$y),3)
abline(v = mv, col = "blue", lwd = 2)
text(4, 100, label=paste("Mean:",mv, "  Var:", svar))
```

![](README_files/figure-gfm/unnamed-chunk-1-15.png)

``` r
par(mfrow=c(1,1))


# for fun, try kNN with 400 neighbors....  it takes a few seconds...

dfKNN400.imp <- kNN(dfMiss[,1:3],k=400)
plot(dfKNN400.imp$x, dfKNN400.imp$y, col = factor(dfKNN400.imp$y_imp), ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-16.png)

``` r
#in summary...

par(mfrow = c(2,2))
plot(df$x,df$y,ylim=c(-1.3,4.25), main="All Data")
plot(dfMean.imp$x, dfMean.imp$y, col = factor(dfMean.imp$missing), main="Mean", ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
plot(dfHD.imp$x, dfHD.imp$y, col = factor(dfHD.imp$missing), main="Hot Deck", ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
plot(dfReg.imp$x, dfReg.imp$y, col = factor(dfReg.imp$missing), main="Regression", ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-17.png)

``` r
plot(df$x,df$y,ylim=c(-1.3,4.25), main="All Data")
plot(dfPMM.imp$x, dfPMM.imp$y, col = factor(dfPMM.imp$missing),  main="Predictive Mean Matching",ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
plot(dfKNN.imp$x, dfKNN.imp$y, col = factor(dfKNN.imp$y_imp),  main="k-Nearest Neighbors", ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
plot(dfRegErr.imp$x, dfRegErr.imp$y, col = factor(dfRegErr.imp$missing) , main="Regression with Random Error",ylim=c(ymin,ymax), xlim=c(0,xmax), xlab="x", ylab="y")
```

![](README_files/figure-gfm/unnamed-chunk-1-18.png)

## Multiple Imputation

### Steps

<img src="images/paste-1FB21749.png" width="550" />

<img src="images/paste-184564F2.png" width="550" />

<img src="images/paste-48743776.png" width="550" />

<img src="images/paste-1F97A760.png" width="550" />

<img src="images/paste-62405CCD.png" width="550" />

<img src="images/paste-78D2A36E.png" width="550" />

<img src="images/paste-73F43BF5.png" width="550" />

<img src="images/paste-4F48D3A7.png" width="550" />

### Iterative Approach

<img src="images/paste-E9CE03AE.png" width="550" />

## Maximum Likelihood

<img src="images/paste-59B715D4.png" width="550" />

<img src="images/paste-D0424C25.png" width="550" />

<img src="images/paste-F663E9C6.png" width="550" />

## Multiple Imputation in R

``` r
rm(list = ls())

# Example code to demonstrate multivariate imputation by chained equations (mice)
# ISE 5103 Intelligent Data Analytics
# Charles Nicholson
# September 2015


# the package mice: multivariate imputation by chained equations
library(mice)
```


    Attaching package: 'mice'

    The following object is masked from 'package:stats':

        filter

    The following objects are masked from 'package:base':

        cbind, rbind

``` r
# create some random sample data 
#-------------------------------------------------
n=100   #n equals the number of observations

#four variables
x1<-5*runif(n)
x2<- rnorm(n) + runif(n) - 0.5*x1
x3<-x1+2*rexp(n) + rnorm(n)
x4<-x1+x2+2*runif(n) + rnorm(n)

# let y be some function of x1, x2, and x3
y<-5*x1+4*x2+2*x3+rnorm(n)


# create a data frame from the vectors
df<-data.frame(y,x1,x2,x3,x4)

dfFull<-df  #save the full data for later use
#-------------------------------------------------


# introduce some missingness in the data for multiple variables using different rules
#-------------------------------------------------
df[y<10,"x1"]<-NA

u<-runif(n)
df[u*y>10,"x1"]<-NA

df[y+5*x3-x4 > 50,"x2"]<-NA

u<-runif(n)
df[(y*u+x3+x2) > 15,"x1"]<-NA

df[x3+x1<3,"y"]<-NA

u<-runif(n)
df[((y+x3+x1)*u > 15 & (y+x3+x1)*u < 50),"x4"]<-NA

#check the percent missing per variable
myfun<-function(x) mean(is.na(x))
apply(df,2,myfun)
```

       y   x1   x2   x3   x4 
    0.09 0.73 0.31 0.00 0.33 

``` r
#-------------------------------------------------


# perform the first two steps of MI using the "mice" command 
# create m=6 data sets and impute missing values 
imp<-mice(df,m=6,meth="norm.nob")
```


     iter imp variable
      1   1  y  x1  x2  x4
      1   2  y  x1  x2  x4
      1   3  y  x1  x2  x4
      1   4  y  x1  x2  x4
      1   5  y  x1  x2  x4
      1   6  y  x1  x2  x4
      2   1  y  x1  x2  x4
      2   2  y  x1  x2  x4
      2   3  y  x1  x2  x4
      2   4  y  x1  x2  x4
      2   5  y  x1  x2  x4
      2   6  y  x1  x2  x4
      3   1  y  x1  x2  x4
      3   2  y  x1  x2  x4
      3   3  y  x1  x2  x4
      3   4  y  x1  x2  x4
      3   5  y  x1  x2  x4
      3   6  y  x1  x2  x4
      4   1  y  x1  x2  x4
      4   2  y  x1  x2  x4
      4   3  y  x1  x2  x4
      4   4  y  x1  x2  x4
      4   5  y  x1  x2  x4
      4   6  y  x1  x2  x4
      5   1  y  x1  x2  x4
      5   2  y  x1  x2  x4
      5   3  y  x1  x2  x4
      5   4  y  x1  x2  x4
      5   5  y  x1  x2  x4
      5   6  y  x1  x2  x4

``` r
# the output object is quite complex!
str(imp)
```

    List of 22
     $ data           :'data.frame':    100 obs. of  5 variables:
      ..$ y : num [1:100] 36.5 15.1 13.7 33.1 19.7 ...
      ..$ x1: num [1:100] NA NA NA NA NA ...
      ..$ x2: num [1:100] NA 0.0907 -2.213 NA 1.251 ...
      ..$ x3: num [1:100] 8.04 2.45 3.48 5.3 1.75 ...
      ..$ x4: num [1:100] NA 2.76 3.18 NA NA ...
     $ imp            :List of 5
      ..$ y :'data.frame':  9 obs. of  6 variables:
      .. ..$ 1: num [1:9] 17.82 9.27 12.5 10.84 22.73 ...
      .. ..$ 2: num [1:9] 18.3 10.8 17.3 1.9 10.6 ...
      .. ..$ 3: num [1:9] 25.88 7.44 13.88 16.99 8.56 ...
      .. ..$ 4: num [1:9] 14.33 14.53 9.09 9.27 18.7 ...
      .. ..$ 5: num [1:9] 8.18 5.01 16.42 -2.14 11.67 ...
      .. ..$ 6: num [1:9] 14.2 3.09 13.46 10.22 15.61 ...
      ..$ x1:'data.frame':  73 obs. of  6 variables:
      .. ..$ 1: num [1:73] 5.51 1.81 3.05 5.88 1.96 ...
      .. ..$ 2: num [1:73] 6.05 1.67 3.22 6.34 1.97 ...
      .. ..$ 3: num [1:73] 4.02 2.12 3.19 6.3 2.01 ...
      .. ..$ 4: num [1:73] 4.8 1.82 3.28 5.25 2.39 ...
      .. ..$ 5: num [1:73] 3.06 1.72 2.91 4.45 1.71 ...
      .. ..$ 6: num [1:73] 3.45 1.85 3.19 4.89 2.04 ...
      ..$ x2:'data.frame':  31 obs. of  6 variables:
      .. ..$ 1: num [1:31] -1.801 -1.89 -1.55 -3.265 -0.755 ...
      .. ..$ 2: num [1:31] -2.196 -2.481 -0.46 -2.616 0.798 ...
      .. ..$ 3: num [1:31] -0.1112 -2.4121 -0.0337 -0.7429 -2.3768 ...
      .. ..$ 4: num [1:31] -0.504 -0.824 0.992 -1.85 -1.59 ...
      .. ..$ 5: num [1:31] 1.229 0.209 -0.551 -2.872 -2.388 ...
      .. ..$ 6: num [1:31] 1.322 -0.426 0.903 1.015 -2.772 ...
      ..$ x3:'data.frame':  0 obs. of  6 variables:
      .. ..$ 1: logi(0) 
      .. ..$ 2: logi(0) 
      .. ..$ 3: logi(0) 
      .. ..$ 4: logi(0) 
      .. ..$ 5: logi(0) 
      .. ..$ 6: logi(0) 
      ..$ x4:'data.frame':  33 obs. of  6 variables:
      .. ..$ 1: num [1:33] 3.35 2.9 2.73 1.89 4.02 ...
      .. ..$ 2: num [1:33] 4.78 1.85 4.01 2.97 1.91 ...
      .. ..$ 3: num [1:33] 6.58 1.88 3.65 2.2 2.96 ...
      .. ..$ 4: num [1:33] 4.03 8.01 2.64 7.32 3 ...
      .. ..$ 5: num [1:33] 4.95 5.01 2.7 5.69 1.55 ...
      .. ..$ 6: num [1:33] 5.15 4.49 2.06 2.82 5.53 ...
     $ m              : num 6
     $ where          : logi [1:100, 1:5] FALSE FALSE FALSE FALSE FALSE FALSE ...
      ..- attr(*, "dimnames")=List of 2
      .. ..$ : chr [1:100] "1" "2" "3" "4" ...
      .. ..$ : chr [1:5] "y" "x1" "x2" "x3" ...
     $ blocks         :List of 5
      ..$ y : chr "y"
      ..$ x1: chr "x1"
      ..$ x2: chr "x2"
      ..$ x3: chr "x3"
      ..$ x4: chr "x4"
      ..- attr(*, "calltype")= Named chr [1:5] "type" "type" "type" "type" ...
      .. ..- attr(*, "names")= chr [1:5] "y" "x1" "x2" "x3" ...
     $ call           : language mice(data = df, m = 6, method = "norm.nob")
     $ nmis           : Named int [1:5] 9 73 31 0 33
      ..- attr(*, "names")= chr [1:5] "y" "x1" "x2" "x3" ...
     $ method         : Named chr [1:5] "norm.nob" "norm.nob" "norm.nob" "" ...
      ..- attr(*, "names")= chr [1:5] "y" "x1" "x2" "x3" ...
     $ predictorMatrix: num [1:5, 1:5] 0 1 1 1 1 1 0 1 1 1 ...
      ..- attr(*, "dimnames")=List of 2
      .. ..$ : chr [1:5] "y" "x1" "x2" "x3" ...
      .. ..$ : chr [1:5] "y" "x1" "x2" "x3" ...
     $ visitSequence  : chr [1:5] "y" "x1" "x2" "x3" ...
     $ formulas       :List of 5
      ..$ y :Class 'formula'  language y ~ x1 + x2 + x3 + x4
      .. .. ..- attr(*, ".Environment")=<environment: 0x000001785b1a7750> 
      ..$ x1:Class 'formula'  language x1 ~ y + x2 + x3 + x4
      .. .. ..- attr(*, ".Environment")=<environment: 0x000001785b1a7750> 
      ..$ x2:Class 'formula'  language x2 ~ y + x1 + x3 + x4
      .. .. ..- attr(*, ".Environment")=<environment: 0x000001785b1a7750> 
      ..$ x3:Class 'formula'  language x3 ~ y + x1 + x2 + x4
      .. .. ..- attr(*, ".Environment")=<environment: 0x000001785b1a7750> 
      ..$ x4:Class 'formula'  language x4 ~ y + x1 + x2 + x3
      .. .. ..- attr(*, ".Environment")=<environment: 0x000001785b1a7750> 
     $ post           : Named chr [1:5] "" "" "" "" ...
      ..- attr(*, "names")= chr [1:5] "y" "x1" "x2" "x3" ...
     $ blots          :List of 5
      ..$ y : list()
      ..$ x1: list()
      ..$ x2: list()
      ..$ x3: list()
      ..$ x4: list()
     $ ignore         : logi [1:100] FALSE FALSE FALSE FALSE FALSE FALSE ...
     $ seed           : logi NA
     $ iteration      : num 5
     $ lastSeedValue  : int [1:626] 10403 88 -291823388 1531880436 -1526226202 -1728801340 -174910660 410358064 -1768731936 -1410079209 ...
     $ chainMean      : num [1:5, 1:5, 1:6] 14.23 3.15 -1.02 NaN 2.9 ...
      ..- attr(*, "dimnames")=List of 3
      .. ..$ : chr [1:5] "y" "x1" "x2" "x3" ...
      .. ..$ : chr [1:5] "1" "2" "3" "4" ...
      .. ..$ : chr [1:6] "Chain 1" "Chain 2" "Chain 3" "Chain 4" ...
     $ chainVar       : num [1:5, 1:5, 1:6] 53.62 2.99 1.21 NA 5.35 ...
      ..- attr(*, "dimnames")=List of 3
      .. ..$ : chr [1:5] "y" "x1" "x2" "x3" ...
      .. ..$ : chr [1:5] "1" "2" "3" "4" ...
      .. ..$ : chr [1:6] "Chain 1" "Chain 2" "Chain 3" "Chain 4" ...
     $ loggedEvents   : NULL
     $ version        :Classes 'package_version', 'numeric_version'  hidden list of 1
      ..$ : int [1:3] 3 14 0
     $ date           : Date[1:1], format: "2022-09-16"
     - attr(*, "class")= chr "mids"

``` r
#take a look at how the means and variances of the imputed values are (hopefully) converging 
imp$chainMean
```

    , , Chain 1

               1         2         3         4         5
    y  14.228546 12.799000 11.897580 12.929319 12.275717
    x1  3.154591  3.081603  3.085334  3.018010  2.971983
    x2 -1.017031 -1.231082 -1.204315 -1.292886 -1.242064
    x3       NaN       NaN       NaN       NaN       NaN
    x4  2.895627  2.412950  2.620749  3.383481  3.045063

    , , Chain 2

                1          2          3          4          5
    y  13.1391611 12.7173663 12.5321062 12.4762822 12.5259588
    x1  2.7231018  2.7982031  2.8172642  2.8524404  2.9120308
    x2 -0.6405485 -0.8300922 -0.8007957 -0.8933472 -0.9969076
    x3        NaN        NaN        NaN        NaN        NaN
    x4  2.3978410  2.7063814  3.0727816  3.0295233  2.8326097

    , , Chain 3

                1         2          3          4          5
    y  13.7701782 12.574830 12.2983592 11.6394529 11.6857522
    x1  2.8947238  2.930269  2.8806210  2.8782418  2.8214375
    x2 -0.8503463 -1.032329 -0.9717387 -0.8368825 -0.8899258
    x3        NaN       NaN        NaN        NaN        NaN
    x4  3.2018880  2.780420  3.0416808  2.9143800  2.9693455

    , , Chain 4

                1          2          3         4          5
    y  12.6331788 12.9727306 12.4425672 12.786956 12.0554614
    x1  2.8080801  2.9067266  2.8603337  2.822612  2.9381709
    x2 -0.8770137 -0.7719299 -0.8141042 -0.768209 -0.7618326
    x3        NaN        NaN        NaN       NaN        NaN
    x4  2.1716898  3.1118124  2.6683309  3.182829  2.7267202

    , , Chain 5

               1         2         3         4         5
    y   9.010063  7.442539  6.452989  7.217470  6.198170
    x1  2.908396  2.765180  2.826098  2.855861  2.837387
    x2 -1.083099 -1.232457 -1.186220 -1.275999 -1.105776
    x3       NaN       NaN       NaN       NaN       NaN
    x4  3.207060  3.533507  3.527793  3.122692  2.729963

    , , Chain 6

                1          2          3          4          5
    y  10.9412007  9.8171035  9.6411062  8.7432868  8.4256010
    x1  2.6994438  2.7797111  2.7410857  2.7261588  2.7468670
    x2 -0.8454753 -0.6677091 -0.5862775 -0.6188764 -0.5742836
    x3        NaN        NaN        NaN        NaN        NaN
    x4  2.7512786  2.9506716  2.7992314  2.8636454  2.5932410

``` r
imp$chainVar
```

    , , Chain 1

               1         2         3         4         5
    y  53.616034 56.217224 63.600123 45.610079 53.421662
    x1  2.986480  2.356234  2.406588  2.072360  2.147585
    x2  1.210991  1.184698  1.310245  1.574433  1.691584
    x3        NA        NA        NA        NA        NA
    x4  5.346222  5.466760  2.957443  4.425536  3.265945

    , , Chain 2

               1         2         3         4         5
    y  22.325913 19.327053 22.453569 18.871959 28.665027
    x1  2.420422  2.103069  2.117815  1.995121  2.301774
    x2  1.323591  1.336789  1.216557  1.306079  1.522702
    x3        NA        NA        NA        NA        NA
    x4  3.298602  4.495604  3.063236  4.041263  4.508184

    , , Chain 3

               1         2         3         4         5
    y  49.589451 62.203275 66.860798 69.531218 74.899536
    x1  2.578042  2.144011  2.178571  2.098635  1.906882
    x2  1.711060  1.865871  1.713622  1.467722  1.400355
    x3        NA        NA        NA        NA        NA
    x4  3.401632  3.866862  5.279044  2.146249  4.459921

    , , Chain 4

               1         2         3         4         5
    y  28.963092 32.591733 31.226146 32.002192 25.344283
    x1  2.560972  2.814716  2.773476  2.366979  2.708774
    x2  1.755741  1.710696  1.761814  1.508524  1.646477
    x3        NA        NA        NA        NA        NA
    x4  4.036133  3.524654  3.799017  3.651276  3.215369

    , , Chain 5

               1         2         3         4         5
    y  40.739937 54.385398 50.445731 43.100532 42.478533
    x1  2.796366  2.257946  2.340382  2.500273  2.613255
    x2  2.212980  1.989790  1.825763  1.820044  1.698820
    x3        NA        NA        NA        NA        NA
    x4  5.810349  5.527044  3.570975  3.704882  3.901006

    , , Chain 6

               1         2         3         4         5
    y  53.993283 58.469265 57.499568 59.870252 57.318051
    x1  2.060049  2.034125  2.113129  2.276535  2.205339
    x2  2.095286  2.011449  2.280113  2.498055  2.297260
    x3        NA        NA        NA        NA        NA
    x4  3.625587  4.505942  4.324174  3.293350  2.802659

``` r
#can plot those means and variances
plot(imp)
```

![](README_files/figure-gfm/unnamed-chunk-2-1.png)

![](README_files/figure-gfm/unnamed-chunk-2-2.png)

``` r
# perform the third step of MI using the "with" command
# to perform a standard analysis (in this case, a linear regression) on each data set 
fit<-with(imp, lm(y~x1+x2+x3+x4))

#perfrom the fourth step of MI, recombination, using the "pool" command 
est<-pool(fit)


plot(dfFull)      #pairs plot of full data
```

![](README_files/figure-gfm/unnamed-chunk-2-3.png)

``` r
plot(df)          #pairs plot of available cases
```

![](README_files/figure-gfm/unnamed-chunk-2-4.png)

``` r
plot(na.omit(df)) #pairs plot for complete cases
```

![](README_files/figure-gfm/unnamed-chunk-2-5.png)

``` r
#coefficient estimates based on full data (before creating missingness)
summary(fullfit<-lm(data=dfFull,y~x1+x2+x3+x4))
```


    Call:
    lm(formula = y ~ x1 + x2 + x3 + x4, data = dfFull)

    Residuals:
        Min      1Q  Median      3Q     Max 
    -2.1243 -0.6730 -0.0499  0.6152  3.5941 

    Coefficients:
                Estimate Std. Error t value Pr(>|t|)    
    (Intercept)  0.18631    0.26360   0.707    0.481    
    x1           4.89935    0.12237  40.038   <2e-16 ***
    x2           3.82976    0.13252  28.900   <2e-16 ***
    x3           1.96895    0.04202  46.860   <2e-16 ***
    x4           0.06814    0.07999   0.852    0.396    
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

    Residual standard error: 1.051 on 95 degrees of freedom
    Multiple R-squared:  0.9871,    Adjusted R-squared:  0.9865 
    F-statistic:  1810 on 4 and 95 DF,  p-value: < 2.2e-16

``` r
#coefficient estimates based on complete cases (no imputation)
summary(missfit<-lm(data=df,y~x1+x2+x3+x4))
```


    Call:
    lm(formula = y ~ x1 + x2 + x3 + x4, data = df)

    Residuals:
        Min      1Q  Median      3Q     Max 
    -1.0855 -0.5615 -0.0714  0.3976  1.3525 

    Coefficients:
                Estimate Std. Error t value Pr(>|t|)    
    (Intercept)  0.50025    0.90852   0.551    0.591    
    x1           4.90271    0.29116  16.839 1.09e-10 ***
    x2           3.91335    0.35555  11.006 2.81e-08 ***
    x3           1.85284    0.15059  12.304 6.78e-09 ***
    x4           0.02905    0.18520   0.157    0.878    
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

    Residual standard error: 0.8246 on 14 degrees of freedom
      (81 observations deleted due to missingness)
    Multiple R-squared:  0.9709,    Adjusted R-squared:  0.9626 
    F-statistic: 116.7 on 4 and 14 DF,  p-value: 1.38e-10

``` r
#coefficient estimates based on MICE (recombined estimates)
summary(est)
```

             term   estimate std.error statistic        df      p.value
    1 (Intercept)  1.7083152 0.5874381  2.908077  5.360565 3.083348e-02
    2          x1  5.1207601 0.1825645 28.049051  9.853290 9.954704e-11
    3          x2  4.1912998 0.1958684 21.398555 10.929553 2.859446e-10
    4          x3  1.6940625 0.1165017 14.541095  4.048363 1.203495e-04
    5          x4 -0.2121735 0.1115440 -1.902152 10.711391 8.436470e-02

## 
