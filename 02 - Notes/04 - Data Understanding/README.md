Data Understanding: 2nd Stage of C-DM Model
================
Daniel Carpenter

-   <a href="#resources" id="toc-resources"><span
    class="toc-section-number">1</span> Resources</a>
-   <a href="#data-quality" id="toc-data-quality"><span
    class="toc-section-number">2</span> Data Quality</a>
-   <a href="#visualization-in-r" id="toc-visualization-in-r"><span
    class="toc-section-number">3</span> Visualization in R</a>
-   <a href="#correlation" id="toc-correlation"><span
    class="toc-section-number">4</span> Correlation</a>
-   <a href="#outliers" id="toc-outliers"><span
    class="toc-section-number">5</span> Outliers</a>
-   <a href="#missing-values" id="toc-missing-values"><span
    class="toc-section-number">6</span> Missing Values</a>
-   <a href="#principal-component-analysis-dimension-reduction"
    id="toc-principal-component-analysis-dimension-reduction"><span
    class="toc-section-number">7</span>
    <code>Principal Component Analysis</code> &amp;
    <code>dimension reduction</code></a>
-   <a href="#principal-component-analysis-in-r"
    id="toc-principal-component-analysis-in-r"><span
    class="toc-section-number">8</span> Principal Component Analysis in
    <code>R</code></a>

# Resources

-   [R for Data Science](https://r4ds.had.co.nz/)
-   [R Visualization](https://r-graph-gallery.com/index.html)
    -   [Visualization best
        practices](https://www.data-to-viz.com/caveats.html)
    -   [Animate ggplot](https://r-graph-gallery.com/animation.html)
    -   [Deciding on a
        visualization](https://www.data-to-viz.com/img/poster/poster_big.png)

<br> <br>

> Using visualization to understand the data  
> Reduce dimension of data for analysis

# Data Quality

Main elements to check for in dataset:

-   Accuracy *(errors)*
-   Completeness: *(selection bias)*
-   Timeliness *(Recency)*

<br>

# Visualization in R

Two Motivations of visuals:

## Exploring

Looking at data for

-   Outliers, highly skewed distributions
-   Correlations among variables
-   Truncated values; inexplicable values
-   Potential relationships and patterns

### Exploration based on number of datas

| Type                  | Visualization Options                                                         |
|-----------------------|-------------------------------------------------------------------------------|
| Univariate analyses   | descriptive statistics, frequency tables, histograms and densities, box plots |
| Bivariate analyses    | correlations and heatmaps, scatterplots, trends, cross tabulations            |
| Multivariate analyses | parallel plots, mosaic plots, regression, PCA, MDS, variable clustering       |

## Explaining (cleaned up)

## `ggplot` Examples

### Load data

### 

``` r
data(iris)     # make sure data is loaded   (the iris data is part of the standard R distribution)
head(iris)     # look at the first few records
```

      Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    1          5.1         3.5          1.4         0.2  setosa
    2          4.9         3.0          1.4         0.2  setosa
    3          4.7         3.2          1.3         0.2  setosa
    4          4.6         3.1          1.5         0.2  setosa
    5          5.0         3.6          1.4         0.2  setosa
    6          5.4         3.9          1.7         0.4  setosa

``` r
# ?iris          # access 'help' on the iris data  

#perform a frequency count for the Species
table(iris$Species)
```


        setosa versicolor  virginica 
            50         50         50 

### box plots

``` r
boxplot(data=iris, Sepal.Length ~ Species,           # boxplot of Sepal.Length by Species 
        main = "Iris Sepal Length by Species ",      # main plot title
        xlab = "Species",                            # x-axis label   
        ylab = "Sepal Length (cm)")                  # y-axis label   
```

![](README_files/figure-gfm/unnamed-chunk-2-1.png)

``` r
# if you want to save the plot as an image, you can 
# either use the "export" functionality in the Plots tab window in RStudio, 
# or you can use do this programmatically...  e.g. to save as a pdf use: pdf("filename.pdf")
# and then run the plot.  This redirects all graphics output to the pdf file.
# You can set the size (in inches) for the pdf output.
# To redirect back to the screen, turn off the "pdf device" using: dev.off()
# See example:


pdf("irisBoxplot.pdf",width=8, height=6)    #this will re-direct your graphic output to a pdf file

boxplot(data=iris, Sepal.Length ~ Species,           # boxplot of Sepal.Length by Species 
        main = "Iris Sepal Length by Species ",      # main plot title
        xlab = "Species",                            # x-axis label   
        ylab = "Sepal Length (cm)")                  # y-axis label   

dev.off()
```

    png 
      2 

### histograms and densities

``` r
#some very simple to code, quick and dirty histograms
# perfect for quickly exploring the data

par(mfrow=c(2,2))  #OPTIONAL: change the graphical parameters so the histograms are produced 4 to a page
#see ?par for more details on setting graphical parameters

hist(iris$Sepal.Length)
hist(iris$Sepal.Width)
hist(iris$Petal.Length)
hist(iris$Petal.Width)
```

![](README_files/figure-gfm/unnamed-chunk-3-1.png)

``` r
#NOTE:  we could have made these look better, e.g. with better titles and labels


hist(iris$Sepal.Length, main = "Sepal Length", xlab = "Sepal Length")
hist(iris$Sepal.Width,  main = "Sepal Width", xlab = "Sepal Width")
hist(iris$Petal.Length, main = "Petal Length", xlab = "Petal Length")
hist(iris$Petal.Width,  main = "Petal Width", xlab = "Petal Width")
```

![](README_files/figure-gfm/unnamed-chunk-3-2.png)

``` r
# but, usually when I am exploring the data, I will use the simple verison


par(mfrow=c(1,1))  #RESET graphical parameters to 1 plot per page


#for a final report or publication, I would use better graphics: ggplot2
#here is a basic example...
```

### `ggplot`

``` r
# ggplot2 is the "grammar of graphics" plot library and produces excellent graphics
library(ggplot2)

#qplot is one of the main functions in ggplot2 -- it is short for "quick plot"
#qplot allows you to do histograms, scatterplots, boxplots, line plots, etc.

qplot(data=iris, Petal.Length)
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](README_files/figure-gfm/unnamed-chunk-4-1.png)

``` r
#or you can set several options to modify the output

qplot(data=iris, Petal.Length,                       #identify data & variable
      geom="histogram",                   #set the "geometry"
      binwidth=0.2,                       #option for histogram
      main= "Histogram for Petal Length", #title
      xlab = "Petal Length",              #x-axis label
      fill=I("blue"),                     #fill color
      alpha=I(0.45))                      #set fill transparency
```

![](README_files/figure-gfm/unnamed-chunk-4-2.png)

``` r
#ggplot is the primary function in ggplot2
#it allows for much more control over the graphics than qplot does
```

### Density

``` r
#for the next chart, I want to produce a density

library(reshape2)  #this package allows us to reform the data from a "wide" format to a "long" format
iris2<- melt(iris)
```

    Using Species as id variables

``` r
#identify data and set the aesthetics         
ggplot(iris2[iris2$variable=="Petal.Length",], aes(x=value, fill=Species)) +
  geom_density(alpha=0.45) +        #set geometry and transparency    
  labs(x = "Petal Length",          #set x-label and title
       title = "Densities for Petal Length of Iris Species")
```

![](README_files/figure-gfm/unnamed-chunk-5-1.png)

``` r
#we can also use gplot to produce more advanced boxplots
ggplot(iris2,aes(x=variable, y=value, fill=Species)) + geom_boxplot()
```

![](README_files/figure-gfm/unnamed-chunk-5-2.png)

### Scatter

``` r
#scatter plots --------------------------------------

# create scatter plots for the numerical data in the iris data set
plot(iris)
```

![](README_files/figure-gfm/unnamed-chunk-6-1.png)

``` r
# qplot and ggplot allow you to add many options and control many settings
# in graphs -- this can look quite confusing at first
# however, most of the parameter settings are optional and have defaults if not set
# the following bit of code might seem a bit overwhelming at first,
# but most of the complexity is related to setting up colors, sizes, styles, and labels


# using qplot a.k.a "quickplot" to produce scatter plot
qplot(data=iris, x=Sepal.Length,y=Sepal.Width,size=I(5)) +   # point size=5 
  theme_bw() +                                               # using black and white background theme
  labs(y = "Sepal Width (cm)",                               # x-axis labels    
       x = "Sepal Length (cm)")                              # y-axis labels
```

![](README_files/figure-gfm/unnamed-chunk-6-2.png)

``` r
# using ggplot a.k.a "grammar of graphics plot" to produce scatter plot
ggplot(data=iris, aes(x=Sepal.Length,y=Sepal.Width)) +        # set data and aesthetics
  geom_point(aes(fill=Species),                               # add points (fill color based on "Species")
             colour="black",                                  # -- outline set to black
             pch=21,                                          # -- shape = 21, a filled circle
             size=5) +                                        # -- size = 5
  theme_bw() +                                                # using black and white background theme
  labs(y = "Sepal Width (cm)",                                # x-axis labels 
       x = "Sepal Length (cm)") +                             # x-axis labels    
  theme(legend.position = "none")                             # turn legend off
```

![](README_files/figure-gfm/unnamed-chunk-6-3.png)

``` r
ggplot(data=iris, aes(x=Sepal.Length,y=Sepal.Width)) +  
  geom_point(aes(fill=Species), colour="black",pch=21, size=5) +
  theme_bw() +
  labs(y = "Sepal Width (cm)",
       x = "Sepal Length (cm)") +
  theme(legend.key=element_blank())                         # legend is on, but the outline is off
```

![](README_files/figure-gfm/unnamed-chunk-6-4.png)

``` r
ggplot(data=iris, aes(x=Petal.Length,y=Petal.Width)) +  
  geom_point(aes(fill=Species),   
             alpha=I(.85),                               # alpha (i.e. opacity) is set to 0.85
             colour="black",pch=21, size=5) +
  theme_bw() +
  labs(y = "Petal Width (cm)",
       x = "Petal Length (cm)") +
  theme(legend.key=element_blank(),
        axis.title = element_text(size = 14))            # set axis title font size to 14
```

![](README_files/figure-gfm/unnamed-chunk-6-5.png)

``` r
ggplot(data=iris, aes(x=Petal.Length,y=Petal.Width)) + 
  geom_point(aes(fill=Species), 
             alpha=I(.75),                               # alpha (i.e. opacity) is set to 0.75
             position = "jitter",                        # "jitter" the position of the points
             colour="black",pch=21, size=5) +
  theme_bw() +
  labs(y = "Petal Width (cm)",
       x = "Petal Length (cm)") +
  theme(legend.key=element_blank(),
        axis.title = element_text(size = 14))
```

![](README_files/figure-gfm/unnamed-chunk-6-6.png)

``` r
# a "pairs" plot that incorporates densities, scatterplots, and correlations
```

### Interactive

``` r
library(GGally)   #adds some more functionality to ggplot2 -- including pairs and parallel plots
```

    Registered S3 method overwritten by 'GGally':
      method from   
      +.gg   ggplot2

``` r
ggpairs(iris[, 1:5], lower=list(continuous="smooth", wrap=c(colour="blue")),
        diag=list(wrap=c(colour="blue")), 
        upper=list(wrap=list(corSize=6)), axisLabels='show')
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](README_files/figure-gfm/unnamed-chunk-7-1.png)

### parallel plots

``` r
library(lattice)                                            #load the "lattice" library for parallel plots
parallelplot(~iris[1:5], data=iris,                         # create parallel plot of iris data;
             groups = Species,                            # use "Species" to define groups (and colors)
             horizontal.axis = FALSE)                                    # defaults to horizontal axis, set to vertical                           
```

![](README_files/figure-gfm/unnamed-chunk-8-1.png)

``` r
#parallelplot help documentation -- the input is unfortunately a little different with the ~ symbol
# ?parallelplot


parallelplot(~iris[1:4] | Species, data = iris,             #same as above, except condition the plot by Species
             groups = Species,   
             horizontal.axis = FALSE, 
             scales = list(x = list(rot = 90)))            #and rotate the labels on the x-axis
```

![](README_files/figure-gfm/unnamed-chunk-8-2.png)

``` r
# you can kind of go crazy with some of this stuff too...
# parallel plots + boxplots = maybe too messy to be useful?  let's see

# underlay univariate boxplots, add title, using a function from GGally
ggparcoord(data = iris,columns = c(1:4),groupColumn = 5,
           boxplot = TRUE,title = "Parallel Coord. Plot of Diamonds Data")
```

![](README_files/figure-gfm/unnamed-chunk-8-3.png)

### Radar

``` r
#my embarassingly bad radar plot in R...
# install.packages("fmsb")
library(fmsb)
radarchart(iris[,1:4], maxmin=FALSE, centerzero=TRUE)
```

![](README_files/figure-gfm/unnamed-chunk-9-1.png)

``` r
#my pitiful looking stars plot....
stars(iris[,1:4], radius=TRUE, key.loc = c(30,15), ncol=10, nrow= 15, col.stars = iris$Species)
```

![](README_files/figure-gfm/unnamed-chunk-9-2.png)

<br>

# Correlation

<br>

## Corr: Pearson, Spearman and Kendall

<br>

## `Concordant` and `discordant` pairs

<br>

# Outliers

<br>

# Missing Values

<br>

# `Principal Component Analysis` & `dimension reduction`

<br>

# Principal Component Analysis in `R`

<br>
