Introduction to R
================
Daniel Carpenter
August 22, 2022

-   <a href="#intro-to-r" id="toc-intro-to-r"><span
    class="toc-section-number">1</span> Intro to R</a>

# Intro to R

``` r
# examples on how to drop variables from a data frame and rename variables

#using the mtcars data set that comes standard with the R installation
data(mtcars)
head(mtcars)  # just take a peek at the data before we start annihilating it...
```

                       mpg cyl disp  hp drat    wt  qsec vs am gear carb
    Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

``` r
# remove a variable by it's column position -----------------------  (two ways)
mtcars[2] <- NULL  # this sets the second column of mtcars to NULL; thus removing it from the data frame
head(mtcars)       # after running the above code, we see the second column "cyl" is gone 
```

                       mpg disp  hp drat    wt  qsec vs am gear carb
    Mazda RX4         21.0  160 110 3.90 2.620 16.46  0  1    4    4
    Mazda RX4 Wag     21.0  160 110 3.90 2.875 17.02  0  1    4    4
    Datsun 710        22.8  108  93 3.85 2.320 18.61  1  1    4    1
    Hornet 4 Drive    21.4  258 110 3.08 3.215 19.44  1  0    3    1
    Hornet Sportabout 18.7  360 175 3.15 3.440 17.02  0  0    3    2
    Valiant           18.1  225 105 2.76 3.460 20.22  1  0    3    1

``` r
mtcars <- mtcars[-1]   # this is another way of doing the same thing.  
                       # this time the first column is dropped.  
                       # the negative sign in the index indicates that you DON'T want column 1 in the results
                       # to make the results permanent, you have to overwrite mtcars
                       # that is, mtcars is then REDEFINED based on the output of mtcars[-1]

head(mtcars)           # "mpg" is now gone
```

                      disp  hp drat    wt  qsec vs am gear carb
    Mazda RX4          160 110 3.90 2.620 16.46  0  1    4    4
    Mazda RX4 Wag      160 110 3.90 2.875 17.02  0  1    4    4
    Datsun 710         108  93 3.85 2.320 18.61  1  1    4    1
    Hornet 4 Drive     258 110 3.08 3.215 19.44  1  0    3    1
    Hornet Sportabout  360 175 3.15 3.440 17.02  0  0    3    2
    Valiant            225 105 2.76 3.460 20.22  1  0    3    1

``` r
#but don't worry!  if you want the original data back, just reload it!
data(mtcars)

head(mtcars)   #and voila! it's all back!
```

                       mpg cyl disp  hp drat    wt  qsec vs am gear carb
    Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

``` r
# remove a variable by name ----------------------  
mtcars["drat"] <- NULL    # this sets the column "drat" to NULL; thus removing it from the data frame
head(mtcars)              # after running the above code, we see the second column "cyl" is gone 
```

                       mpg cyl disp  hp    wt  qsec vs am gear carb
    Mazda RX4         21.0   6  160 110 2.620 16.46  0  1    4    4
    Mazda RX4 Wag     21.0   6  160 110 2.875 17.02  0  1    4    4
    Datsun 710        22.8   4  108  93 2.320 18.61  1  1    4    1
    Hornet 4 Drive    21.4   6  258 110 3.215 19.44  1  0    3    1
    Hornet Sportabout 18.7   8  360 175 3.440 17.02  0  0    3    2
    Valiant           18.1   6  225 105 3.460 20.22  1  0    3    1

``` r
#You can remove multiple columns as well:

mtcars[3:4] <- list(NULL)   # remove the 3rd and 4th columns from the data
head(mtcars)                # and you can see they are gone
```

                       mpg cyl    wt  qsec vs am gear carb
    Mazda RX4         21.0   6 2.620 16.46  0  1    4    4
    Mazda RX4 Wag     21.0   6 2.875 17.02  0  1    4    4
    Datsun 710        22.8   4 2.320 18.61  1  1    4    1
    Hornet 4 Drive    21.4   6 3.215 19.44  1  0    3    1
    Hornet Sportabout 18.7   8 3.440 17.02  0  0    3    2
    Valiant           18.1   6 3.460 20.22  1  0    3    1

``` r
mtcars[c("disp","am")] <- list(NULL)   #you can do this by the column names as well
head(mtcars)               
```

                       mpg cyl    wt  qsec vs gear carb
    Mazda RX4         21.0   6 2.620 16.46  0    4    4
    Mazda RX4 Wag     21.0   6 2.875 17.02  0    4    4
    Datsun 710        22.8   4 2.320 18.61  1    4    1
    Hornet 4 Drive    21.4   6 3.215 19.44  1    3    1
    Hornet Sportabout 18.7   8 3.440 17.02  0    3    2
    Valiant           18.1   6 3.460 20.22  1    3    1

``` r
#We are down to only 4 columns now...  so let's reload the data and do a few more examples
data(mtcars)


#you can remove columns using the "c" function
mtcars <- mtcars[ -c(1, 3:6, 10) ]
head(mtcars)  
```

                      cyl  qsec vs am carb
    Mazda RX4           6 16.46  0  1    4
    Mazda RX4 Wag       6 17.02  0  1    4
    Datsun 710          4 18.61  1  1    1
    Hornet 4 Drive      6 19.44  1  0    1
    Hornet Sportabout   8 17.02  0  0    2
    Valiant             6 20.22  1  0    1

``` r
#finally you can use another base R function: subset()

# subset usually returns a subset of a data frame based on a logical condition 
# (see ?subset for details)
# however, you can also use it to drop columns.  

# drop the columns named "cyl" and "qsec" using subset():
mtcars <- subset(mtcars, select = -c(cyl,qsec) )
head(mtcars)
```

                      vs am carb
    Mazda RX4          0  1    4
    Mazda RX4 Wag      0  1    4
    Datsun 710         1  1    1
    Hornet 4 Drive     1  0    1
    Hornet Sportabout  0  0    2
    Valiant            1  0    1

``` r
#renaming variables in a data frame

#The easiest way to rename variables, is to first install and load the "reshape" package: 
library(reshape)
```

    Warning: package 'reshape' was built under R version 4.1.3

``` r
#and use the "rename" function
#usage: rename(mydata, c(oldname="newname"))

rename(mtcars, c(mpg = "MilesPerGallon"))
```

                        vs am carb
    Mazda RX4            0  1    4
    Mazda RX4 Wag        0  1    4
    Datsun 710           1  1    1
    Hornet 4 Drive       1  0    1
    Hornet Sportabout    0  0    2
    Valiant              1  0    1
    Duster 360           0  0    4
    Merc 240D            1  0    2
    Merc 230             1  0    2
    Merc 280             1  0    4
    Merc 280C            1  0    4
    Merc 450SE           0  0    3
    Merc 450SL           0  0    3
    Merc 450SLC          0  0    3
    Cadillac Fleetwood   0  0    4
    Lincoln Continental  0  0    4
    Chrysler Imperial    0  0    4
    Fiat 128             1  1    1
    Honda Civic          1  1    2
    Toyota Corolla       1  1    1
    Toyota Corona        1  0    1
    Dodge Challenger     0  0    2
    AMC Javelin          0  0    2
    Camaro Z28           0  0    4
    Pontiac Firebird     0  0    2
    Fiat X1-9            1  1    1
    Porsche 914-2        0  1    2
    Lotus Europa         1  1    2
    Ford Pantera L       0  1    4
    Ferrari Dino         0  1    6
    Maserati Bora        0  1    8
    Volvo 142E           1  1    2

``` r
#to overwrite the mtcars data frame with the update:
mtcars <- rename(mtcars, c(mpg = "MilesPerGallon"))
    
# mtcars[1:5,1:5]  #and there is the updated variable name.
```
