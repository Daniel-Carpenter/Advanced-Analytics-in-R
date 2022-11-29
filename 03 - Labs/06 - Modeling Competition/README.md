Modeling Competition: Machine Learning in R to Predict Customer Sales
================
Daniel Carpenter, Sonaxy Mohanty, & Zachary Knepp
October 2022

-   <a href="#general-data-prep" id="toc-general-data-prep">General Data
    Prep</a>
    -   <a href="#read-training-data" id="toc-read-training-data">Read Training
        Data</a>
    -   <a href="#create-numeric-and-factor-base-data-frames"
        id="toc-create-numeric-and-factor-base-data-frames">Create
        <code>numeric</code> and <code>factor</code> <em>base</em>
        <code>data frames</code></a>
-   <a href="#a-i---data-understanding"
    id="toc-a-i---data-understanding"><code>(a, i)</code> - Data
    Understanding</a>
    -   <a href="#numeric-data-quality-report"
        id="toc-numeric-data-quality-report">Numeric Data Quality Report</a>
    -   <a href="#factor-data-quality-report"
        id="toc-factor-data-quality-report">Factor Data Quality Report</a>
    -   <a href="#exploratory-analysis"
        id="toc-exploratory-analysis">Exploratory Analysis</a>
-   <a href="#a-ii---data-preparation"
    id="toc-a-ii---data-preparation"><code>(a, ii)</code> - Data
    Preparation</a>
    -   <a href="#clean-up-null-data" id="toc-clean-up-null-data">Clean up Null
        Data</a>
    -   <a href="#group-by-customer" id="toc-group-by-customer">Group by
        Customer</a>
    -   <a href="#create-targetrevenue-variable"
        id="toc-create-targetrevenue-variable">Create <code>targetRevenue</code>
        Variable</a>
    -   <a
        href="#create-dataset-without-the-custid-field-called-dftraincleannocust"
        id="toc-create-dataset-without-the-custid-field-called-dftraincleannocust">Create
        dataset without the <code>custID</code> field called
        <code>df.train.clean.noCust</code></a>
-   <a href="#a-iii---modeling"
    id="toc-a-iii---modeling"><code>(a, iii)</code> - Modeling</a>
    -   <a href="#ols-model" id="toc-ols-model">OLS Model</a>
    -   <a href="#model-2-pcr-model" id="toc-model-2-pcr-model">Model 2: PCR
        Model</a>
    -   <a href="#model-3-mars" id="toc-model-3-mars">Model 3: MARS</a>
    -   <a href="#model-4-elastic-net-model"
        id="toc-model-4-elastic-net-model">Model 4: Elastic Net Model</a>
-   <a href="#a-iv---debrief" id="toc-a-iv---debrief"><code>(a, iv)</code> -
    Debrief</a>
    -   <a href="#summary-table" id="toc-summary-table">Summary Table</a>
    -   <a href="#interpretations-of-debrief"
        id="toc-interpretations-of-debrief">Interpretations of Debrief</a>
-   <a href="#apply-to-test-data" id="toc-apply-to-test-data">Apply to Test
    Data</a>

``` r
# Packages --------

# Data Wrangling
library(tidyverse)
library(skimr)
library(lubridate) # dates

# Modeling
library(MASS)
library(caret) # Modeling variants like SVM
library(earth) # Modeling with Mars
library(pls)   # Modeling with PLS
library(glmnet) # Modeling with LASSO

# Aesthetics
library(knitr)
library(cowplot)  # multiple ggplots on one plot with plot_grid()
library(scales)
library(kableExtra)
library(ggplot2)
library(inspectdf)

#Hold-out Validation
library(caTools)

#Data Correlation
library(GGally)
library(regclass)

#RMSE Calculation
library(Metrics)

#p-value for OLS model
library(broom)

#ncvTest
library(car)
```

## General Data Prep

> For general data preparation, please see conceptual steps below. See
> `.rmd` file for detailed code.

### Read Training Data

Clean data to ensure each read variable has the correct data type
(factor, numeric, Date, etc.)

``` r
# Convert all character data to factor
df.train.base <- read.csv('Train.csv', stringsAsFactors = TRUE)


# convert the ""'s to NA
df.train.base[df.train.base == ""] <- NA

# Clean data
df.train.base <- df.train.base %>% 
  
  # Ensure boolean variables are numeric
  mutate(adwordsClickInfo.isVideoAd = as.numeric(adwordsClickInfo.isVideoAd) ) %>%
  
  # Make sure dates are dates
  mutate(date = as.Date(date),
         visitStartTime = as_datetime(visitStartTime)
         ) %>%

  # Ensure factor are factors
  mutate(custId       = as.factor(custId),
         sessionId    = as.factor(sessionId),
         isTrueDirect = as.factor(isTrueDirect),
         newVisits    = as.factor(if_else(is.na(newVisits), 0, 1) ),
         bounces      = as.factor(if_else(is.na(bounces),   0, 1)   ),
         adwordsClickInfo.page      = as.factor(adwordsClickInfo.page),
         adwordsClickInfo.isVideoAd = as.factor(adwordsClickInfo.isVideoAd)
         ) %>%
  
  dplyr::select(-c(
    isMobile # This is contained in deviceCategory
    
  ))

#view(df.train.base)
```

### Create `numeric` and `factor` *base* `data frames`

Make data set of `numeric` variables called `df.train.base.numeric`

``` r
df.train.base.numeric <- df.train.base %>%

  # selecting all the numeric data
  dplyr::select_if(is.numeric) %>%

  # converting the data frame to tibble
  as_tibble()
```

Make data set of `factor` variables called `df.train.base.factor`

``` r
df.train.base.factor <- df.train.base %>%

  #selecting all the numeric data
  dplyr::select_if(is.factor) %>%

  #converting the data frame to tibble
  as_tibble()
```

## `(a, i)` - Data Understanding

> Create a data quality report of `numeric` and `factor` data  
> Created function called `dataQualityReport()` to create factor and
> numeric QA report

``` r
# Function for data report
dataQualityReport <- function(df) {
  
  # Function to remove any columns with NA
  removeColsWithNA <- function(df) {
    return( df[ , colSums(is.na(df)) == 0] )
  }
  
  # Create Comprehensive data report using skimr package
  # This is done a bit piece-wise because PDF latex does not like the skimr package
  # Very much. So Instead of printing `skim(df)`, I have to pull the contents manually
  # Unfortunately. This is not an issue with html typically.
  dataReport <- skim(df) %>%
    rename_all(~str_replace(.,"skim_","")) %>%
    arrange(type, desc(complete_rate) ) # sort data 
  
  # Filter to the class types
  dataReport.numeric <- dataReport %>% filter(type == 'numeric') # numeric data
  dataReport.factor  <- dataReport %>% filter(type == 'factor' ) # factor  data
  
  # Remove columns that do not apply to this type of data -----------------------
  
  ## numeric data
  dataReport.numeric <- removeColsWithNA(dataReport.numeric)  %>%
    
    # Clean column names by removing numeric prefix, 
    rename_all(~str_replace(.,"numeric.","")) 
    
  ## factor  data
  dataReport.factor  <- removeColsWithNA(dataReport.factor ) %>%
  
    # Clean column names by removing factor  prefix
    rename_all(~str_replace(.,"factor.",""))  
  
  
  # Set up options for Display the reports
  options(skimr_strip_metadata = FALSE)
  options(digits=2)
  options(scipen=99)
  
  # Numeric report <- Get summary of data frame --------------------------------
  
    # data frame stats
    dfStats.num <- data.frame(Num_Numeric_Variables = ncol(df %>% select_if(is.numeric)),
                              Total_Observations    = nrow(df) )
    
    # Now see individual column statistics
    dfColStats.num <- dataReport.numeric %>% 
      dplyr::select(-type, -hist)
    
  
  # Factor report <- Get summary of data frame --------------------------------
  
    # Get summary of data frame
    dfStats.factor <- data.frame(Num_Factor_Variables = ncol(df %>% select_if(is.factor)),
                                 Total_Observations   = nrow(df) )
    
    # Now see individual column statistics
    dfColStats.factor <- dataReport.factor  %>% 
      dplyr::select(-type, -ordered) 
    
    
  # Return the data frames
  return(list('dfStats.num'       = dfStats.num,    
              'dfColStats.num'    = dfColStats.num,
              'dfStats.factor'    = dfStats.factor, 
              'dfColStats.factor' = dfColStats.factor))
}
```

### Numeric Data Quality Report

-   `pageviews` has some null values, but there are an insignificant
    amount, so we will just drop those rows.

``` r
# Get the factor and numeric reports
initialReport <- dataQualityReport(df.train.base)

# Numeric data frame stats
initialReport$dfStats.num %>% kable()
```

<table>
<thead>
<tr>
<th style="text-align:right;">
Num_Numeric_Variables
</th>
<th style="text-align:right;">
Total_Observations
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
70071
</td>
</tr>
</tbody>
</table>

``` r
# Numeric column stats
initialReport$dfColStats.num %>%
  kable() %>% kable_styling(font_size=7, latex_options = 'HOLD_position') # numeric data
```

<table class="table" style="font-size: 7px; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
variable
</th>
<th style="text-align:right;">
n_missing
</th>
<th style="text-align:right;">
complete_rate
</th>
<th style="text-align:right;">
mean
</th>
<th style="text-align:right;">
sd
</th>
<th style="text-align:right;">
p0
</th>
<th style="text-align:right;">
p25
</th>
<th style="text-align:right;">
p50
</th>
<th style="text-align:right;">
p75
</th>
<th style="text-align:right;">
p100
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
visitNumber
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
3.1
</td>
<td style="text-align:right;">
8.7
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
155
</td>
</tr>
<tr>
<td style="text-align:left;">
timeSinceLastVisit
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
256450.2
</td>
<td style="text-align:right;">
1164717.4
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
10375
</td>
<td style="text-align:right;">
30074517
</td>
</tr>
<tr>
<td style="text-align:left;">
revenue
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
10.2
</td>
<td style="text-align:right;">
99.5
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
15981
</td>
</tr>
<tr>
<td style="text-align:left;">
pageviews
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
6.3
</td>
<td style="text-align:right;">
11.7
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
469
</td>
</tr>
</tbody>
</table>
### Factor Data Quality Report

-   Location data unknown, so add an `Unknown` label for `null` values
-   Appears that few people use website from the ads, which cause many
    null values. See more details below.

``` r
# factor data frame stats
initialReport$dfStats.factor %>% kable()
```

<table>
<thead>
<tr>
<th style="text-align:right;">
Num_Factor_Variables
</th>
<th style="text-align:right;">
Total_Observations
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
28
</td>
<td style="text-align:right;">
70071
</td>
</tr>
</tbody>
</table>

``` r
# factor column stats
initialReport$dfColStats.factor %>%
  kable() %>% kable_styling(font_size=7, latex_options = 'HOLD_position') # numeric data
```

<table class="table" style="font-size: 7px; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
variable
</th>
<th style="text-align:right;">
n_missing
</th>
<th style="text-align:right;">
complete_rate
</th>
<th style="text-align:right;">
n_unique
</th>
<th style="text-align:left;">
top_counts
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
sessionId
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
70071
</td>
<td style="text-align:left;">
200: 1, 400: 1, 600: 1, 700: 1
</td>
</tr>
<tr>
<td style="text-align:left;">
custId
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
47249
</td>
<td style="text-align:left;">
234: 155, 558: 135, 455: 129, 818: 115
</td>
</tr>
<tr>
<td style="text-align:left;">
channelGrouping
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:left;">
Org: 27503, Soc: 13528, Ref: 13482, Dir: 11824
</td>
</tr>
<tr>
<td style="text-align:left;">
deviceCategory
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
des: 53986, mob: 13868, tab: 2217
</td>
</tr>
<tr>
<td style="text-align:left;">
isTrueDirect
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
0: 42026, 1: 28045
</td>
</tr>
<tr>
<td style="text-align:left;">
bounces
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
0: 40719, 1: 29352
</td>
</tr>
<tr>
<td style="text-align:left;">
newVisits
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
1: 46127, 0: 23944
</td>
</tr>
<tr>
<td style="text-align:left;">
browser
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
27
</td>
<td style="text-align:left;">
Chr: 51584, Saf: 12007, Fir: 2407, Int: 1357
</td>
</tr>
<tr>
<td style="text-align:left;">
source
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
131
</td>
<td style="text-align:left;">
goo: 29233, you: 12708, (di: 11825, mal: 10840
</td>
</tr>
<tr>
<td style="text-align:left;">
continent
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
Ame: 42508, Asi: 13697, Eur: 11992, Oce: 901
</td>
</tr>
<tr>
<td style="text-align:left;">
subContinent
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
22
</td>
<td style="text-align:left;">
Nor: 38860, Sou: 4823, Nor: 3601, Wes: 3563
</td>
</tr>
<tr>
<td style="text-align:left;">
country
</td>
<td style="text-align:right;">
85
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
176
</td>
<td style="text-align:left;">
Uni: 36941, Ind: 3044, Uni: 2330, Can: 1918
</td>
</tr>
<tr>
<td style="text-align:left;">
operatingSystem
</td>
<td style="text-align:right;">
307
</td>
<td style="text-align:right;">
1.00
</td>
<td style="text-align:right;">
15
</td>
<td style="text-align:left;">
Mac: 23970, Win: 23707, And: 8074, iOS: 7487
</td>
</tr>
<tr>
<td style="text-align:left;">
medium
</td>
<td style="text-align:right;">
11827
</td>
<td style="text-align:right;">
0.83
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
org: 27503, ref: 27010, cpc: 2085, aff: 911
</td>
</tr>
<tr>
<td style="text-align:left;">
networkDomain
</td>
<td style="text-align:right;">
33448
</td>
<td style="text-align:right;">
0.52
</td>
<td style="text-align:right;">
5014
</td>
<td style="text-align:left;">
com: 2890, ver: 1372, rr.: 1319, com: 1247
</td>
</tr>
<tr>
<td style="text-align:left;">
topLevelDomain
</td>
<td style="text-align:right;">
33448
</td>
<td style="text-align:right;">
0.52
</td>
<td style="text-align:right;">
183
</td>
<td style="text-align:left;">
net: 15027, com: 6297, tr: 874, in: 868
</td>
</tr>
<tr>
<td style="text-align:left;">
region
</td>
<td style="text-align:right;">
38485
</td>
<td style="text-align:right;">
0.45
</td>
<td style="text-align:right;">
309
</td>
<td style="text-align:left;">
Cal: 11254, New: 3468, Ill: 1047, Tex: 909
</td>
</tr>
<tr>
<td style="text-align:left;">
city
</td>
<td style="text-align:right;">
39028
</td>
<td style="text-align:right;">
0.44
</td>
<td style="text-align:right;">
477
</td>
<td style="text-align:left;">
Mou: 4569, New: 3465, San: 2183, Sun: 1362
</td>
</tr>
<tr>
<td style="text-align:left;">
referralPath
</td>
<td style="text-align:right;">
43062
</td>
<td style="text-align:right;">
0.39
</td>
<td style="text-align:right;">
383
</td>
<td style="text-align:left;">
/: 11419, /yt: 4359, /yt: 842, /an: 836
</td>
</tr>
<tr>
<td style="text-align:left;">
metro
</td>
<td style="text-align:right;">
49183
</td>
<td style="text-align:right;">
0.30
</td>
<td style="text-align:right;">
72
</td>
<td style="text-align:left;">
San: 10072, New: 3526, Los: 1050, Chi: 1047
</td>
</tr>
<tr>
<td style="text-align:left;">
campaign
</td>
<td style="text-align:right;">
67310
</td>
<td style="text-align:right;">
0.04
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:left;">
AW : 1229, Dat: 911, AW : 575, tes: 35
</td>
</tr>
<tr>
<td style="text-align:left;">
keyword
</td>
<td style="text-align:right;">
67412
</td>
<td style="text-align:right;">
0.04
</td>
<td style="text-align:right;">
415
</td>
<td style="text-align:left;">
6qE: 997, 1hZ: 213, Goo: 183, (Re: 182
</td>
</tr>
<tr>
<td style="text-align:left;">
adwordsClickInfo.gclId
</td>
<td style="text-align:right;">
68245
</td>
<td style="text-align:right;">
0.03
</td>
<td style="text-align:right;">
1405
</td>
<td style="text-align:left;">
Cj0: 14, Cjw: 10, CIy: 9, Cj0: 9
</td>
</tr>
<tr>
<td style="text-align:left;">
adwordsClickInfo.page
</td>
<td style="text-align:right;">
68260
</td>
<td style="text-align:right;">
0.03
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
1: 1806, 2: 2, 3: 1, 5: 1
</td>
</tr>
<tr>
<td style="text-align:left;">
adwordsClickInfo.slot
</td>
<td style="text-align:right;">
68260
</td>
<td style="text-align:right;">
0.03
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
Top: 1771, RHS: 40, emp: 0
</td>
</tr>
<tr>
<td style="text-align:left;">
adwordsClickInfo.adNetworkType
</td>
<td style="text-align:right;">
68260
</td>
<td style="text-align:right;">
0.03
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
Goo: 1811, emp: 0
</td>
</tr>
<tr>
<td style="text-align:left;">
adwordsClickInfo.isVideoAd
</td>
<td style="text-align:right;">
68260
</td>
<td style="text-align:right;">
0.03
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
0: 1811
</td>
</tr>
<tr>
<td style="text-align:left;">
adContent
</td>
<td style="text-align:right;">
69230
</td>
<td style="text-align:right;">
0.01
</td>
<td style="text-align:right;">
27
</td>
<td style="text-align:left;">
Goo: 449, Dis: 82, Goo: 79, Ful: 49
</td>
</tr>
</tbody>
</table>
### Exploratory Analysis

``` r
#aggregate revenue
CustRev <- stats::aggregate(df.train.base$revenue, 
                     by=list(df.train.base$custId),
                     FUN = sum,
                     na.rm = TRUE)

#renaming fields
names(CustRev) <- c('custId', 'totalRevenue')

#merging datasets
df.train.merge <- merge(df.train.base, CustRev, by='custId')

#applying transformation
df.train.merge$totalRevenue <- df.train.merge$totalRevenue + 1
df.train.merge$totalRevenue <- log(df.train.merge$totalRevenue)
```

#### Analysis 1:

-   Checking the distribution of the transformation of the aggregrate
    customer-level sales value based on the natural log:

``` r
hist(df.train.merge$totalRevenue,
     col = 'skyblue4',
     main = 'Distribution of Target Revenue for each customer',
     xlab = 'Target Revenue')
```

![](Carpenter_Mohanty_Knepp_HW6_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

-   We can see that the transformed revenue doesn’t look like a normal
    distribution with a spike at 0 revenue which means it can be an
    outlier.

#### Analysis 2:

-   Correlation between features in the dataset

``` r
df.train.merge %>%
  ggplot(aes(x = fct_reorder(channelGrouping, desc(totalRevenue) ),
             y = totalRevenue) ) +
  # Boxplots
  geom_boxplot(aes(color = channelGrouping), fill = 'lightsteelblue1', alpha = 0.7) +
  coord_flip() +
  
  # Theme, y scale format, and labels
  theme_minimal() + 
  theme(panel.grid.major.x = element_blank()) +
  
  #scale_y_continuous(labels = comma) +
  labs(title = 'Distribution of Transformed Revenue by Different Online Store Channels',
       subtitle = 'Ordered Descending by Transformed Revenue Generated by Channels',
       x = 'Channels Used by Customers for Online Store',
       y = 'Transformed Revenue Generated')
```

![](Carpenter_Mohanty_Knepp_HW6_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

## `(a, ii)` - Data Preparation

> For general data preparation, please see conceptual steps below. See
> `.rmd` file for detailed code.

### Clean up Null Data

See that when `region` is `Osaka Prefecture` and `city` is `Osaka` some
location details are `NULL`

-   Implication: the other fields can be manually set to correct values
    based on region and city criteria

-   So, set `location related` null fields to `know` description for the
    above `region` and `city` condition

``` r
# df.train.base[!complete.cases(df.train.base$continent), ] %>%
#   distinct(continent, subContinent, country, region, metro, city)
# 
# 
# df.train.base %>%
#   filter(region == 'Osaka Prefecture') %>%
#   distinct(continent, subContinent, country, metro, city, region)

df.train <- df.train.merge


df.train$continent[is.na(df.train$continent) &
           df.train$region == 'Osaka Prefecture'] <- 'Asia'

# df.train %>%
#   filter(region == 'Osaka Prefecture' & city == 'Osaka') %>%
#   distinct(subContinent)

df.train$subContinent[is.na(df.train$subContinent) &
           df.train$region == 'Osaka Prefecture' &
             df.train$city == 'Osaka'] <- 'Eastern Asia'

# df.train %>%
#   filter(region == 'Osaka Prefecture' & city == 'Osaka') %>%
#   distinct(country)

df.train$country[is.na(df.train$country) &
           df.train$region == 'Osaka Prefecture' &
             df.train$city == 'Osaka'] <- 'Japan'
  
# df.train %>%
#   filter(region == 'Osaka Prefecture' & city == 'Osaka') %>%
#   distinct(metro)

# df.train %>%
#   filter(metro == 'JP_KINKI')

df.train$metro[is.na(df.train$metro) &
           df.train$region == 'Osaka Prefecture' &
             df.train$city == 'Osaka'] <- 'JP_KINKI'
```

See that when `continent` is `null`, then other `location` related
fields are also null

-   Implication: these other fields depend on the `continent` variable

-   So, set `location related` null fields to `Unknow` description

``` r
# If null in location data, then 'Unknown' location
df.train <- df.train %>%
  mutate_at(
    # Only mutate these location variables
    vars(continent:city), 
    
    # Apply function rename null values to Unknown
    list(~ as.factor(ifelse(is.na(.), 'Unknown', .) ) ) 
  )
```

See that when `medium` is `null`, then other `ad`, `keyword` and
`campaign` related fields are (mostly) null

-   Implication: these other fields depend on the `medium` variable

-   So, set these null fields to `None` description, since a null value
    indicates the user did not has `no traffic source`

``` r
# Now clean up the data in the main data frame `df.train`
# by setting null values to "No taffic source" if there is no medium
# Applies to "ad*", keyword, and campaign, referralPath, medium variables
df.train <- df.train %>%
  mutate_at(
    # Only mutate the variables starting with ad, THEN the campaign variable
    vars(starts_with('ad'), keyword, campaign, referralPath, medium), 
    
    # Apply function rename set the campaign text if campaign is null
    list(~ as.factor(ifelse(is.na(medium), 'No traffic source ', .) ) ) 
  ) 
```

See that when `campaign` is `null`, then some `ad` related fields are
(mostly) null

-   Implication: these other fields depend on the `campaign` variable

-   So, set `adwordsClickInfo.page` null fields to `None` description,
    since a null value indicates the user did not come using an
    advertisement

``` r
# Now clean up the data in the main data frame `df.train`
# by setting null values to "None" if there is no campaign.
# Applies to "ad*", keyword, and campaign variables
df.train <- df.train %>%
  mutate_at(
    # Only mutate the variables starting with ad, THEN the campaign variable
    vars(adwordsClickInfo.page, adwordsClickInfo.slot, adwordsClickInfo.adNetworkType, adwordsClickInfo.isVideoAd, campaign), 
    
    # Apply function rename set the campaign text if campaign is null
    list(~ as.factor(ifelse(is.na(campaign), 'No Campaign', .) ) ) 
  ) 
```

Similar to campaign, whenever `keyword` is NA, some `ads` is null

``` r
#NO_KEYWORD_TEXT = 'No Keyword'

# Now clean up the data in the main data frame `df.train`
# by setting null values to "No Keyword" if there is no keyword
# Applies to some "ad*", and keyword variables
df.train <- df.train %>%
  mutate_at(
    # Only mutate the variables starting with ad, THEN the keyword variable
    vars(adContent, adwordsClickInfo.adNetworkType, adwordsClickInfo.isVideoAd, keyword), 
    
    # Apply function rename set the campaign text if campaign is null
    list(~ as.factor(ifelse(is.na(keyword), 'No Keyword', .) ) ) 
  ) 
```

Similar to the campaign data, if the `adContent` is null, label as
`No Ad`.

-   Implications: If there is no ad Content of the traffic source then
    there is no no referral path

``` r
# If the `adContent` is null, label as `None`
df.train <- df.train %>%
  mutate_at(
    # Only mutate the referral path
    vars(referralPath, adContent), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(adContent), 'No Ad', .) ) ) 
  )
```

Similar to the campaign data, if the `adwordsClickInfo.adNetworkType` is
null, then all `ad` related variables are also `NULL`.

-   Implications: If there is no ad search then customer didn’t see any
    ad.

``` r
# If the `adwordsClickInfo.adNetworkType` is null, label as `No Ad Network`
df.train <- df.train %>%
  mutate_at(
    # Only mutate the referral path
    vars(adwordsClickInfo.page, adwordsClickInfo.slot, adwordsClickInfo.gclId,
         adwordsClickInfo.isVideoAd, adwordsClickInfo.adNetworkType), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(adwordsClickInfo.adNetworkType), 'No Ad Network', .) ) ) 
  )
```

Similar to the adwordsClickInfo.adNetworkType data, if the
`adwordsClickInfo.page` is null, then some `ad` related variables are
also `NULL` and there is no referral source.

-   Implications: If there is no ad published on a page then customer
    didn’t see any ad.

``` r
# If the `adwordsClickInfo.page` is null, label as `No Ad Page`
df.train <- df.train %>%
  mutate_at(
    # Only mutate the referral path
    vars(referralPath, adwordsClickInfo.slot, adwordsClickInfo.gclId, adwordsClickInfo.page), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(adwordsClickInfo.page), 'No Ad Page', .) ) ) 
  )
```

If `network domain` is `NULL` then all the related domains are also
NULL.

``` r
# If the `network domain` is null, label as `No Domain`
df.train <- df.train %>%
  mutate_at(
    # Only mutate the referral path
    vars(networkDomain:topLevelDomain), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(.), 'No Domain', .) ) ) 
  )
```

Setting `referralPath` for NAs.

``` r
# If the `network domain` is null, label as `No Domain`
df.train <- df.train %>%
  mutate_at(
    # Only mutate the referral path
    vars(referralPath), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(referralPath), 'No Referrer', .) ) ) 
  )
```

Setting `adwordsClickInfo.gclId` for NAs.

``` r
# If the `network domain` is null, label as `No Domain`
df.train <- df.train %>%
  mutate_at(
    # Only mutate the referral path
    vars(adwordsClickInfo.gclId), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(adwordsClickInfo.gclId), 'No Google Click ID', .) ) ) 
  )
```

Now we have very few null values rows. Let’s simply remove them. See
below for how many.

``` r
# Number of rows with any nulls
numRowsWithNulls <- nrow(df.train[!complete.cases(df.train), ])

# Output text
paste('There are', numRowsWithNulls, 'rows with nulls')
```

    ## [1] "There are 318 rows with nulls"

``` r
paste0('That equates to ', round(numRowsWithNulls / nrow(df.train)* 100, 1), '% rows with nulls')
```

    ## [1] "That equates to 0.5% rows with nulls"

``` r
# Drop the rows
df.train <- df.train %>% drop_na()
paste('Total Rows Remaining:', nrow(df.train))
```

    ## [1] "Total Rows Remaining: 69753"

``` r
# Check the data set - see that most of the ad data is now cleaned.
# report12 <- dataQualityReport(df.train)
# report12$dfColStats.factor %>% kable()
```

``` r
# We are going to factor collapse factor columns with more than 4 columns
# So there will be 5 of the original, and 1 containing 'other'
# This is the threshold
FACTOR_THRESHOLD = 4

df.train.clean <- df.train

# Make data set of `factor` variables called `df.train.base.factor`
df.train.factor <- df.train %>%

  # selecting all the numeric data
  dplyr::select_if(is.factor) %>%

  # converting the data frame to tibble
  as_tibble()

# Get list of factors and the number of unique values
factorCols <-
  as.data.frame(t(df.train.factor %>% summarise_all(n_distinct))) #%>%
  # kable()

# Get a list of the factors we are going to collapse
colsWithManyFactors <- rownames(factorCols %>% filter(V1 > FACTOR_THRESHOLD))

# Show a summary of how many factors will be collapsed
numberOfColsWithManyFactors = length(colsWithManyFactors)
paste('Before cleaning, there are', numberOfColsWithManyFactors, 'factor columns with more than',
      FACTOR_THRESHOLD, 'unique values')
```

    ## [1] "Before cleaning, there are 24 factor columns with more than 4 unique values"

``` r
# Collapse the affected factors in the original data (the one that already has imputation)
## for each factor column that we are about to collapse
# The third column is omits the cutstomer ID and session ID
FIRST_NON_CUST_SESSION_IDX = 3
for (collapsedColNum in FIRST_NON_CUST_SESSION_IDX:numberOfColsWithManyFactors) {

  # The name of the column with null values
  nameOfThisColumn <- colsWithManyFactors[collapsedColNum]

  # Get the actual data of the column with nulls
  colWithManyFactors <- df.train[, nameOfThisColumn]

  # lumps all levels except for the n most frequent
  df.train.clean[, nameOfThisColumn] <- fct_lump_n(colWithManyFactors,
                                                   n=FACTOR_THRESHOLD)
}
# Check to see if the factor lumping worked
factorColsCleaned <-
  t(df.train.clean %>%
                       select_if(is.factor) %>%
                       summarise_all(n_distinct))
paste('After cleaning, there are', sum(factorColsCleaned > FACTOR_THRESHOLD + 1, na.rm = TRUE),
      "columns with more than", FACTOR_THRESHOLD + 1, "unique values (omitting NA's)")
```

    ## [1] "After cleaning, there are 2 columns with more than 5 unique values (omitting NA's)"

``` r
#Cleaning up some  variables no longer needed
rm(CustRev,
   numRowsWithNulls,
   df.train.base,
   df.train.base.factor,
   df.train.base.numeric,
   df.train.merge,
   factorColsCleaned,
   FIRST_NON_CUST_SESSION_IDX,
   nameOfThisColumn,
   numberOfColsWithManyFactors,
   collapsedColNum,
   colsWithManyFactors
)
```

### Group by Customer

Get list of customers who visited once and twice

``` r
# Get list of customers and visit count
df.train.clean.uniqueCust <- df.train.clean %>%
  group_by(custId) %>%
  summarise(totalVisits = n() )


# Customer visits more than 1
df.train.clean.uniqueCustMulti <- df.train.clean.uniqueCust %>%
  filter(totalVisits > 1)

# Customer data who only visited once
df.train.clean.custSingle <- df.train.clean %>%
  filter( !(custId %in% df.train.clean.uniqueCustMulti$custId) )

# Number of customers visiting more than once
nrow(df.train.clean.uniqueCustMulti)
```

Group by customer & Sum up all numeric data

-   Filter to only the customers who visited twice

-   Get the unique visits and choose the first visit

-   THis is just an assumption! Not the best, but we have to make a
    choice.

-   Append unique customers to non-unique customers (that are now
    unique)

-   Note not using all columns, only columns NOT specific to the model

``` r
df.train.clean.custMultiToSingle <- df.train.clean %>%
  
  # Filter to only the customers who visited twice
  filter(custId %in% df.train.clean.uniqueCustMulti$custId) %>%
    
  # Note Remove session related variables and regroup
  group_by(custId) %>%
  
  # Get the unique visits and choose the first visit
  # THis is just an assumption! Not the best, but we have to make a choice.
  summarise(
    browser                        = unique(browser)[1], 
    operatingSystem                = unique(operatingSystem)[1], 
    deviceCategory                 = unique(deviceCategory)[1], 
    continent                      = unique(continent)[1], 
    subContinent                   = unique(subContinent)[1], 
    country                        = unique(country)[1], 
    region                         = unique(region)[1], 
    metro                          = unique(metro)[1], 
    city                           = unique(city)[1], 
    networkDomain                  = unique(networkDomain)[1], 
    topLevelDomain                 = unique(topLevelDomain)[1], 
    campaign                       = unique(campaign)[1], 
    source                         = unique(source)[1],
    medium                         = unique(medium)[1],
    keyword                        = unique(keyword)[1], 
    isTrueDirect                   = unique(isTrueDirect)[1], 
    referralPath                   = unique(referralPath)[1], 
    adContent                      = unique(adContent)[1], 
    adwordsClickInfo.page          = unique(adwordsClickInfo.page)[1], 
    adwordsClickInfo.slot          = unique(adwordsClickInfo.slot)[1], 
    adwordsClickInfo.gclId         = unique(adwordsClickInfo.gclId)[1], 
    adwordsClickInfo.adNetworkType = unique(adwordsClickInfo.adNetworkType)[1], 
    adwordsClickInfo.isVideoAd     = unique(adwordsClickInfo.isVideoAd)[1],
    bounces                        = unique(bounces)[1],
    newVisits                      = unique(newVisits)[1],
    pageviews                      = sum(pageviews),
    revenue                        = sum(revenue)
  )


df.train.clean.custSingle <- df.train.clean.custSingle %>% 
  dplyr::select(
          custId, browser, operatingSystem, deviceCategory, continent, subContinent, country, 
          region, metro, city, networkDomain, topLevelDomain, campaign, source, medium, 
          keyword, isTrueDirect, referralPath, adContent, adwordsClickInfo.page, 
          adwordsClickInfo.slot, adwordsClickInfo.gclId, adwordsClickInfo.adNetworkType, 
          adwordsClickInfo.isVideoAd, bounces, newVisits, pageviews, revenue
          )

# Make sure we captured all customers
nrow(df.train.clean.custSingle) + nrow(df.train.clean.custMultiToSingle)
```

    ## [1] 46967

``` r
nrow(df.train.clean.uniqueCust)
```

    ## [1] 46967

``` r
ncol(df.train.clean.custSingle)
```

    ## [1] 28

``` r
ncol(df.train.clean.custMultiToSingle)
```

    ## [1] 28

``` r
# Append unique customers to non-unique customers (that are now unique)
df.train.clean.cust <- rbind(df.train.clean.custMultiToSingle, 
                             df.train.clean.custSingle)  
```

### Create `targetRevenue` Variable

``` r
df.train.clean.cust <- df.train.clean.cust %>%
  mutate(targetVariable = log(revenue + 1)) %>%
  dplyr::select(-revenue)
```

### Create dataset without the `custID` field called `df.train.clean.noCust`

``` r
df.train.clean.noCust <- df.train.clean.cust[, 2:ncol(df.train.clean.cust)] 
```

## `(a, iii)` - Modeling

### OLS Model

#### Fit the Model

-   Initially created a model with all variables, then used `stepAIC()`
    to identify important variables  
-   Implemented in the OLS model to realize a better fit model.

``` r
# The OLS model
# See RMD for stepAIC function that generated these relevant variables for the model
ols <- lm(targetVariable ~ operatingSystem + country + metro + city + networkDomain + 
            source + keyword + isTrueDirect + referralPath + bounces + 
            newVisits + pageviews,
          data = df.train.clean.noCust)
```

#### View and Interpret Results

``` r
# Key diagnostics for OLS: lm final summary table
summary(ols)
#plot(ols)
```

``` r
# Note that used Step AIC to build out the abovve model.
# Commented out to minimize computation exertion in file

# ols.stepAIC <- stepAIC(ols, direction = "both")
# summary(ols.stepAIC)

# Best Model Output:
# targtargetVariable ~ operatingSystem + country + metro + city + networkDomain + 
#     source + keyword + isTrueDirect + referralPath + bounces + 
#     newVisits + pageviewsnewVisits + pageviews
```

``` r
# Get the RMSE and R Squared of the model
ols.rmse    <- rmse(actual=df.train.clean.noCust$targetVariable, predicted=ols$fitted.values)
ols.summary <- summary(ols)

# Key diagnostics
keyDiagnostics.ols <- data.frame(Model    = 'OLS',
                                 Notes    = 'lm',
                                 Hyperparameters = 'N/A',
                                 RMSE     = ols.rmse,
                                 Rsquared = ols.summary$adj.r.squared)

# Show output
keyDiagnostics.ols %>% 
  knitr::kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Model
</th>
<th style="text-align:left;">
Notes
</th>
<th style="text-align:left;">
Hyperparameters
</th>
<th style="text-align:right;">
RMSE
</th>
<th style="text-align:right;">
Rsquared
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
OLS
</td>
<td style="text-align:left;">
lm
</td>
<td style="text-align:left;">
N/A
</td>
<td style="text-align:right;">
0.93
</td>
<td style="text-align:right;">
0.5
</td>
</tr>
</tbody>
</table>

### Model 2: PCR Model

#### Fit the Model

-   Based on model testing, highest $R^2$ is around 68 number of
    components.  
-   Fits data much better than the former model.

``` r
# Fit the model
pcr <- mvr(targetVariable ~ operatingSystem + country + metro + city + networkDomain + 
            source + keyword + isTrueDirect + referralPath + bounces + 
            newVisits + pageviews,
          data = df.train.clean.noCust, 
          
          # Modeling params
          center = TRUE,
          scale  = TRUE, 
          validation = "CV")
```

#### View and Interpret Results

``` r
# See the summary output
summary(pcr)

# validationplot(pcr)
# validationplot(pcr, val.type = 'R2')
```

``` r
# Key diagnostics for PCR final summary table
RMSE.pcr <- RMSEP(pcr, ncomp=15)
R2.pcr <- R2(pcr, ncomp = 1:15)

# Get the RMSE and R Squared of the model
keyDiagnostics.pcr <- data.frame(Model    = 'PCR',
                                 Notes    = 'pcr',
                                 Hyperparameters = paste('ncomp = ', pcr$ncomp),
                                 RMSE     = min(RMSE.pcr$val),
                                 Rsquared = max(R2.pcr$val) )

# Show output
keyDiagnostics.pcr %>% 
  knitr::kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Model
</th>
<th style="text-align:left;">
Notes
</th>
<th style="text-align:left;">
Hyperparameters
</th>
<th style="text-align:right;">
RMSE
</th>
<th style="text-align:right;">
Rsquared
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
PCR
</td>
<td style="text-align:left;">
pcr
</td>
<td style="text-align:left;">
ncomp = 36
</td>
<td style="text-align:right;">
0.94
</td>
<td style="text-align:right;">
0.49
</td>
</tr>
</tbody>
</table>

### Model 3: MARS

#### Fit the Model

-   Use MARS model from earth package.  
-   Fits data similarly to the former models.

``` r
# Model tuning controls
ctrl <- trainControl(method  = "repeatedcv", 
                     number  = 5, # 5 fold cross validation
                     repeats = 1  # 1 repeats
                     )

# Fit the model
marsFit <- train(data = df.train.clean.noCust, 
                 targetVariable ~ operatingSystem + country + metro + city + networkDomain + 
                   source + keyword + isTrueDirect + referralPath + bounces + 
                   newVisits + pageviews,
                  method     = "earth",             # Earth is for MARS models
                  tuneLength = 9,                   # 9 values of the cost function
                  preProc    = c("center","scale"), # Center and scale data
                  trControl  = ctrl 
                 )
summary(marsFit)
#plot(marsFit)
```

#### View and Interpret Results

``` r
# Key diagnostics for final model

# Get the RMSE and R Squared of the model
hyperparameters.mars = list('degree' = marsFit[["bestTune"]][["degree"]],
                            'nprune' = marsFit[["bestTune"]][["nprune"]])

keyDiagnostics.mars <- data.frame(Model   = 'MARS',
                                  Notes    = 'caret and earth',
                                  Hyperparameters = paste('Degree =', hyperparameters.mars$degree, ',',
                                                          'nprune =', hyperparameters.mars$nprune)
                                  )

keyDiagnostics.mars <- cbind(keyDiagnostics.mars,
                            marsFit$results %>% 
                              filter(degree == hyperparameters.mars$degree,
                                     nprune == hyperparameters.mars$nprune) %>%
                              dplyr::select(RMSE, Rsquared)
                      )

# Show output
keyDiagnostics.mars %>% kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Model
</th>
<th style="text-align:left;">
Notes
</th>
<th style="text-align:left;">
Hyperparameters
</th>
<th style="text-align:right;">
RMSE
</th>
<th style="text-align:right;">
Rsquared
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
MARS
</td>
<td style="text-align:left;">
caret and earth
</td>
<td style="text-align:left;">
Degree = 1 , nprune = 8
</td>
<td style="text-align:right;">
0.77
</td>
<td style="text-align:right;">
0.66
</td>
</tr>
</tbody>
</table>

### Model 4: Elastic Net Model

#### Fit the Model

``` r
rm(df.train.clean.factor)
rm(df.train.clean.numeric)

# Train and tune the Elastic net
# Fit the model
fit.elasticnet <- train(data = df.train.clean.noCust, 
                        targetVariable ~ operatingSystem + country + metro + city + networkDomain + 
                          source + keyword + isTrueDirect + referralPath + bounces + 
                          newVisits + pageviews,
                        method     = "glmnet",            # Elastic net
                        preProc    = c("center","scale"), # Center and scale data
                        tuneLength = 10,                  # 10 values of alpha and lambdas
                        trControl  = ctrl)
```

#### View and Interpret Results

``` r
# Function to get the best hypertuned parameters
get_best_result = function(caret_fit) {
  best = which(rownames(caret_fit$results) == rownames(caret_fit$bestTune))
  best_result = caret_fit$results[best, ]
  rownames(best_result) = NULL
  best_result
}
result.elasticnet <- get_best_result(fit.elasticnet)

# Gather key diagnostics for summary table
# Get the RMSE and R Squared of the model
hyperparameters.elasticnet = list('Alpha'  = result.elasticnet$alpha,
                                  'Lambda' = result.elasticnet$lambda)


keyDiagnostics.elasticnet <- data.frame(Model    = 'Elastic Net',
                                        Notes    = 'caret and elasticnet',
                                        Hyperparameters = paste('Alpha =',
                                                                hyperparameters.elasticnet$Alpha, ',',
                                                                'Lambda =',
                                                                hyperparameters.elasticnet$Lambda),
                                        RMSE     = result.elasticnet$RMSE,
                                        Rsquared = result.elasticnet$Rsquared
                                        )

# Show output
keyDiagnostics.elasticnet %>% knitr::kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Model
</th>
<th style="text-align:left;">
Notes
</th>
<th style="text-align:left;">
Hyperparameters
</th>
<th style="text-align:right;">
RMSE
</th>
<th style="text-align:right;">
Rsquared
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Elastic Net
</td>
<td style="text-align:left;">
caret and elasticnet
</td>
<td style="text-align:left;">
Alpha = 0.2 , Lambda = 0.000381198688071757
</td>
<td style="text-align:right;">
0.93
</td>
<td style="text-align:right;">
0.49
</td>
</tr>
</tbody>
</table>
## `(a, iv)` - Debrief

### Summary Table

``` r
# Add the key diagnostics here
rbind(
  keyDiagnostics.ols,
  keyDiagnostics.pcr,
  keyDiagnostics.mars,
  keyDiagnostics.elasticnet
) %>%
  
  # Round to 4 digits across numeric data
  mutate_if(is.numeric, round, digits = 4) %>%
  
  # Spit out kable table
  kable()
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Model
</th>
<th style="text-align:left;">
Notes
</th>
<th style="text-align:left;">
Hyperparameters
</th>
<th style="text-align:right;">
RMSE
</th>
<th style="text-align:right;">
Rsquared
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
OLS
</td>
<td style="text-align:left;">
lm
</td>
<td style="text-align:left;">
N/A
</td>
<td style="text-align:right;">
0.93
</td>
<td style="text-align:right;">
0.50
</td>
</tr>
<tr>
<td style="text-align:left;">
PCR
</td>
<td style="text-align:left;">
pcr
</td>
<td style="text-align:left;">
ncomp = 36
</td>
<td style="text-align:right;">
0.94
</td>
<td style="text-align:right;">
0.49
</td>
</tr>
<tr>
<td style="text-align:left;">
MARS
</td>
<td style="text-align:left;">
caret and earth
</td>
<td style="text-align:left;">
Degree = 1 , nprune = 8
</td>
<td style="text-align:right;">
0.77
</td>
<td style="text-align:right;">
0.66
</td>
</tr>
<tr>
<td style="text-align:left;">
Elastic Net
</td>
<td style="text-align:left;">
caret and elasticnet
</td>
<td style="text-align:left;">
Alpha = 0.2 , Lambda = 0.000381198688071757
</td>
<td style="text-align:right;">
0.93
</td>
<td style="text-align:right;">
0.49
</td>
</tr>
</tbody>
</table>

### Interpretations of Debrief

# Apply to Test Data

-   Need to clean test data like we did in the train

-   Note all comments for the main model apply here

-   Then apply the models to this dataset

-   Outputs a CSV with predicted customer log revenue

-   For general data preparation, please see conceptual steps below. See
    `.rmd` file for detailed code.

``` r
# ### Read Testing Data
# Clean data to ensure each read variable has the correct data type (factor, numeric, Date, etc.)
# Convert all character data to factor
df.test.base <- read.csv('Test.csv', stringsAsFactors = TRUE)


# convert the ""'s to NA
df.test.base[df.test.base == ""] <- NA

# Clean data
df.test.base <- df.test.base %>% 
  
  # Ensure boolean variables are numeric
  mutate(adwordsClickInfo.isVideoAd = as.numeric(adwordsClickInfo.isVideoAd) ) %>%
  
  # Make sure dates are dates
  mutate(date = as.Date(date),
         visitStartTime = as_datetime(visitStartTime)
         ) %>%

  # Ensure factor are factors
  mutate(custId       = as.factor(custId),
         sessionId    = as.factor(sessionId),
         isTrueDirect = as.factor(isTrueDirect),
         newVisits    = as.factor(if_else(is.na(newVisits), 0, 1) ),
         bounces      = as.factor(if_else(is.na(bounces),   0, 1)   ),
         adwordsClickInfo.page      = as.factor(adwordsClickInfo.page),
         adwordsClickInfo.isVideoAd = as.factor(adwordsClickInfo.isVideoAd)
         ) %>%
  
  dplyr::select(-c(
    isMobile # This is contained in deviceCategory
    
  ))

#view(df.test.base)

### Create `numeric` and `factor` *base* `data frames`
# Make data set of `numeric` variables called `df.test.base.numeric`
df.test.base.numeric <- df.test.base %>%

  # selecting all the numeric data
  dplyr::select_if(is.numeric) %>%

  # converting the data frame to tibble
  as_tibble()

# Make data set of `factor` variables called `df.test.base.factor`
df.test.base.factor <- df.test.base %>%

  #selecting all the numeric data
  dplyr::select_if(is.factor) %>%

  #converting the data frame to tibble
  as_tibble()

# ### Numeric Data Quality Report
# * `pageviews` has some null values, but there are an insignificant amount, so we will just drop those rows.

# Get the factor and numeric reports
initialReport <- dataQualityReport(df.test.base)

# Numeric data frame stats
initialReport$dfStats.num %>% kable()

# Numeric column stats
initialReport$dfColStats.num %>%
  kable() %>% kable_styling(font_size=7, latex_options = 'HOLD_position') # numeric data

# ### Factor Data Quality Report
# * Location data unknown, so add an `Unknown` label for `null` values
# * Appears that few people use website from the ads, which cause many null values. See more details below.

# factor data frame stats
initialReport$dfStats.factor %>% kable()

# factor column stats
initialReport$dfColStats.factor %>%
  kable() %>% kable_styling(font_size=7, latex_options = 'HOLD_position') # numeric data

# `(a, ii)` - Data Preparation
# > For general data preparation, please see conceptual steps below. See `.rmd` file for detailed code.
# 
# ### Clean up Null Data
# See that when `region` is `Osaka Prefecture` and `city` is `Osaka` some location details are `NULL` 
# * Implication: the other fields can be manually set to correct values based on region and city criteria  
# * So, set `location related` null fields to `know` description for the above `region` and `city` condition

df.test <- df.test.base


df.test$continent[is.na(df.test$continent) &
           df.test$region == 'Osaka Prefecture'] <- 'Asia'

# df.test %>%
#   filter(region == 'Osaka Prefecture' & city == 'Osaka') %>%
#   distinct(subContinent)

df.test$subContinent[is.na(df.test$subContinent) &
           df.test$region == 'Osaka Prefecture' &
             df.test$city == 'Osaka'] <- 'Eastern Asia'

# df.test %>%
#   filter(region == 'Osaka Prefecture' & city == 'Osaka') %>%
#   distinct(country)

df.test$country[is.na(df.test$country) &
           df.test$region == 'Osaka Prefecture' &
             df.test$city == 'Osaka'] <- 'Japan'
  
# df.test %>%
#   filter(region == 'Osaka Prefecture' & city == 'Osaka') %>%
#   distinct(metro)

# df.test %>%
#   filter(metro == 'JP_KINKI')

df.test$metro[is.na(df.test$metro) &
           df.test$region == 'Osaka Prefecture' &
             df.test$city == 'Osaka'] <- 'JP_KINKI'

# <!-- See that when `continent` is `null`, then other `location` related fields are also null   -->
# <!-- * Implication: these other fields depend on the `continent` variable   -->
# <!-- * So, set `location related` null fields to `Unknow` description  -->

# If null in location data, then 'Unknown' location
df.test <- df.test %>%
  mutate_at(
    # Only mutate these location variables
    vars(continent:city), 
    
    # Apply function rename null values to Unknown
    list(~ as.factor(ifelse(is.na(.), 'Unknown', .) ) ) 
  )
  
# See that when `medium` is `null`, then other `ad`, `keyword` and `campaign` related fields are (mostly) null  
# * Implication: these other fields depend on the `medium` variable
# * So, set these null fields to `None` description, since a null value indicates
# the user did not has `no traffic source`  

# Now clean up the data in the main data frame `df.test`
# by setting null values to "No taffic source" if there is no medium
# Applies to "ad*", keyword, and campaign, referralPath, medium variables
df.test <- df.test %>%
  mutate_at(
    # Only mutate the variables starting with ad, THEN the campaign variable
    vars(starts_with('ad'), keyword, campaign, referralPath, medium), 
    
    # Apply function rename set the campaign text if campaign is null
    list(~ as.factor(ifelse(is.na(medium), 'No traffic source ', .) ) ) 
  ) 

# See that when `campaign` is `null`, then some `ad` related fields are (mostly) null  
# * Implication: these other fields depend on the `campaign` variable
# * So, set `adwordsClickInfo.page` null fields to `None` description, since a null value indicates
# the user did not come using an advertisement  

# Now clean up the data in the main data frame `df.test`
# by setting null values to "None" if there is no campaign.
# Applies to "ad*", keyword, and campaign variables
df.test <- df.test %>%
  mutate_at(
    # Only mutate the variables starting with ad, THEN the campaign variable
    vars(adwordsClickInfo.page, adwordsClickInfo.slot, adwordsClickInfo.adNetworkType, adwordsClickInfo.isVideoAd, campaign), 
    
    # Apply function rename set the campaign text if campaign is null
    list(~ as.factor(ifelse(is.na(campaign), 'No Campaign', .) ) ) 
  ) 


# Similar to campaign, whenever `keyword` is NA, some `ads` is null  
#NO_KEYWORD_TEXT = 'No Keyword'

# Now clean up the data in the main data frame `df.test`
# by setting null values to "No Keyword" if there is no keyword
# Applies to some "ad*", and keyword variables
df.test <- df.test %>%
  mutate_at(
    # Only mutate the variables starting with ad, THEN the keyword variable
    vars(adContent, adwordsClickInfo.adNetworkType, adwordsClickInfo.isVideoAd, keyword), 
    
    # Apply function rename set the campaign text if campaign is null
    list(~ as.factor(ifelse(is.na(keyword), 'No Keyword', .) ) ) 
  ) 

# Similar to the campaign data, if the `adContent` is null, label as `No Ad`. 
# *   Implications: If there is no ad Content of the traffic source then there is no no referral path  

# If the `adContent` is null, label as `None`
df.test <- df.test %>%
  mutate_at(
    # Only mutate the referral path
    vars(referralPath, adContent), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(adContent), 'No Ad', .) ) ) 
  )

# Similar to the campaign data, if the `adwordsClickInfo.adNetworkType` is null, then all `ad` related variables are also `NULL`. 
# *   Implications: If there is no ad search then customer didn't see any ad.  

# If the `adwordsClickInfo.adNetworkType` is null, label as `No Ad Network`
df.test <- df.test %>%
  mutate_at(
    # Only mutate the referral path
    vars(adwordsClickInfo.page, adwordsClickInfo.slot, adwordsClickInfo.gclId,
         adwordsClickInfo.isVideoAd, adwordsClickInfo.adNetworkType), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(adwordsClickInfo.adNetworkType), 'No Ad Network', .) ) ) 
  )

# Similar to the adwordsClickInfo.adNetworkType data, if the `adwordsClickInfo.page` is null, then some `ad` related variables are also `NULL` and there is no referral source. 
# *   Implications: If there is no ad published on a page then customer didn't see any ad.  

# If the `adwordsClickInfo.page` is null, label as `No Ad Page`
df.test <- df.test %>%
  mutate_at(
    # Only mutate the referral path
    vars(referralPath, adwordsClickInfo.slot, adwordsClickInfo.gclId, adwordsClickInfo.page), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(adwordsClickInfo.page), 'No Ad Page', .) ) ) 
  )

# If `network domain` is `NULL` then all the related domains are also NULL. 
df.test <- df.test %>%
  mutate_at(
    # Only mutate the referral path
    vars(networkDomain:topLevelDomain), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(.), 'No Domain', .) ) ) 
  )

# Setting `referralPath` for NAs. 
# If the `network domain` is null, label as `No Domain`
df.test <- df.test %>%
  mutate_at(
    # Only mutate the referral path
    vars(referralPath), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(referralPath), 'No Referrer', .) ) ) 
  )

# Setting `adwordsClickInfo.gclId` for NAs. 
# If the `network domain` is null, label as `No Domain`
df.test <- df.test %>%
  mutate_at(
    # Only mutate the referral path
    vars(adwordsClickInfo.gclId), 
    
    # Apply function rename set the referral to none
    list(~ as.factor(ifelse(is.na(adwordsClickInfo.gclId), 'No Google Click ID', .) ) ) 
  )

# Now we have very few null values rows. Let's simply remove them. See below for how many.
# Number of rows with any nulls
numRowsWithNulls <- nrow(df.test[!complete.cases(df.test), ])

# Output text
paste('There are', numRowsWithNulls, 'rows with nulls')
paste0('That equates to ', round(numRowsWithNulls / nrow(df.test)* 100, 1), '% rows with nulls')

# Drop the rows
# df.test <- df.test %>% drop_na()
paste('Total Rows Remaining:', nrow(df.test))

# Get list of unique factors in the training sample
# * Goal: reduce factors in test data to the training sample  
# * Models cannot predict factors that don't exist in the model  
df.test.clean <- df.test # copy data


# Get list of unique factors in the training sample
uniqueTrainFactors <- lapply(df.train.clean.noCust %>% select_if(is.factor), unique)

# For each factor column in the train data
for (factorColName in names(uniqueTrainFactors) ) {
  
  # Get unique levels of the factor column
  trainUniqueFactors <- unique(df.train.clean.noCust[, factorColName])
  trainUniqueFactors <- levels(trainUniqueFactors[[factorColName]])

  # If the factor data is in training data, then use it, else put 'Other'
  df.test.clean[[factorColName]] = as.factor(ifelse(df.test.clean[[factorColName]] %in% trainUniqueFactors,
                                                    paste0(df.test.clean[[factorColName]]),
                                                    'Other') 
  )
}

# If any remaining nulls then bin as other or  0 
# checkNAs <- function(x) { sum(is.na(x))}
# lapply(df.test.clean, checkNAs)
# lapply(df.test.clean, class)
# See that pageviews, operatingSystem, and source are NA

df.test.clean$pageviews[is.na(df.test.clean$pageviews)] <- 0
df.test.clean$operatingSystem[is.na(df.test.clean$operatingSystem)] <- "Other"
df.test.clean$source[is.na(df.test.clean$source)] <- "Other"

# Check to see if it worked
# check <- df.test.clean[!complete.cases(df.test.clean), ]
# View(check)

# Validation
uniqueTestFactors <- lapply(df.test.clean %>% select_if(is.factor), unique)
sum(!is.element(uniqueTrainFactors$operatingSystem, 
                 uniqueTestFactors$operatingSystem)
)

# uniqueTrainFactors$operatingSystem
# uniqueTestFactors$operatingSystem
# uniqueTestFactors

### Group by Customer
## Get list of customers who visited once and twice
# Get list of customers and visit count
df.test.clean.uniqueCust <- df.test.clean %>%
  group_by(custId) %>%
  summarise(totalVisits = n() )


# Customer visits more than 1
df.test.clean.uniqueCustMulti <- df.test.clean.uniqueCust %>%
  filter(totalVisits > 1)

# Customer data who only visited once
df.test.clean.custSingle <- df.test.clean %>%
  filter( !(custId %in% df.test.clean.uniqueCustMulti$custId) )

# Number of customers visiting more than once
nrow(df.test.clean.uniqueCustMulti)

# Group by customer & Sum up all numeric data
# * Filter to only the customers who visited twice  
# * Get the unique visits and choose the first visit  
# * THis is just an assumption! Not the best, but we have to make a choice.  
# * Append unique customers to non-unique customers (that are now unique)  
# * Note not using all columns, only columns NOT specific to the model

df.test.clean.custMultiToSingle <- df.test.clean %>%
  
  # Filter to only the customers who visited twice
  filter(custId %in% df.test.clean.uniqueCustMulti$custId) %>%
    
  # Note Remove session related variables and regroup
  group_by(custId) %>%
  
  # Get the unique visits and choose the first visit
  # THis is just an assumption! Not the best, but we have to make a choice.
  summarise(
    browser                        = unique(browser)[1], 
    operatingSystem                = unique(operatingSystem)[1], 
    deviceCategory                 = unique(deviceCategory)[1], 
    continent                      = unique(continent)[1], 
    subContinent                   = unique(subContinent)[1], 
    country                        = unique(country)[1], 
    region                         = unique(region)[1], 
    metro                          = unique(metro)[1], 
    city                           = unique(city)[1], 
    networkDomain                  = unique(networkDomain)[1], 
    topLevelDomain                 = unique(topLevelDomain)[1], 
    campaign                       = unique(campaign)[1], 
    source                         = unique(source)[1],
    medium                         = unique(medium)[1],
    keyword                        = unique(keyword)[1], 
    isTrueDirect                   = unique(isTrueDirect)[1], 
    referralPath                   = unique(referralPath)[1], 
    adContent                      = unique(adContent)[1], 
    adwordsClickInfo.page          = unique(adwordsClickInfo.page)[1], 
    adwordsClickInfo.slot          = unique(adwordsClickInfo.slot)[1], 
    adwordsClickInfo.gclId         = unique(adwordsClickInfo.gclId)[1], 
    adwordsClickInfo.adNetworkType = unique(adwordsClickInfo.adNetworkType)[1], 
    adwordsClickInfo.isVideoAd     = unique(adwordsClickInfo.isVideoAd)[1],
    bounces                        = unique(bounces)[1],
    newVisits                      = unique(newVisits)[1],
    pageviews                      = sum(pageviews)
  )


df.test.clean.custSingle <- df.test.clean.custSingle %>% 
  dplyr::select(
          custId, browser, operatingSystem, deviceCategory, continent, subContinent, country, 
          region, metro, city, networkDomain, topLevelDomain, campaign, source, medium, 
          keyword, isTrueDirect, referralPath, adContent, adwordsClickInfo.page, 
          adwordsClickInfo.slot, adwordsClickInfo.gclId, adwordsClickInfo.adNetworkType, 
          adwordsClickInfo.isVideoAd, bounces, newVisits, pageviews
          )

# Make sure we captured all customers
nrow(df.test.clean.custSingle) + nrow(df.test.clean.custMultiToSingle)
nrow(df.test.clean.uniqueCust)

ncol(df.test.clean.custSingle)
ncol(df.test.clean.custMultiToSingle)

# Append unique customers to non-unique customers (that are now unique)
df.test.clean.cust <- rbind(df.test.clean.custMultiToSingle, 
                             df.test.clean.custSingle)  

### Create dataset without the `custID` field called `df.test.clean.noCust`
df.test.clean.noCust <- df.test.clean.cust[, 2:ncol(df.test.clean.cust)] 
```

``` r
## Predict the customer data using the MARS model
predictions <- as.vector(
                    predict(marsFit,                # MARS Model from training data
                    newdata = df.test.clean.noCust) # Test data 
                    )


outputData <- data.frame(custId      = df.test.clean.cust$custId,
                         predRevenue = predictions)

# write the file
write.csv(file      = 'Kaggle Submission Data (Test).csv',
          x         = outputData,
          row.names = FALSE)
```