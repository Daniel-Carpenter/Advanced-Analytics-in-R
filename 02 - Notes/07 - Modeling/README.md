Modeling
================
Daniel Carpenter

-   <a href="#objectives" id="toc-objectives"><span
    class="toc-section-number">1</span> Objectives</a>
-   <a href="#overview" id="toc-overview"><span
    class="toc-section-number">2</span> Overview</a>
-   <a href="#prediction" id="toc-prediction"><span
    class="toc-section-number">3</span> Prediction</a>
-   <a href="#classification" id="toc-classification"><span
    class="toc-section-number">4</span> Classification</a>
-   <a href="#overfitting" id="toc-overfitting"><span
    class="toc-section-number">5</span> Overfitting</a>
-   <a href="#testing-data" id="toc-testing-data"><span
    class="toc-section-number">6</span> Testing Data</a>
-   <a href="#predictions-on-data" id="toc-predictions-on-data"><span
    class="toc-section-number">7</span> Predictions on Data</a>

## Objectives

-   Supervised vs. Unsupervised Learning

-   Evaluate the technical performance of regression-based prediction
    models using tools such as Mean Absolute Error, RMSE, and Adjusted
    R^2

-   Use data strategies such as cross-validation and bootstrapping for
    model tuning and for assessing generalizable performance

## Overview

<img src="images/paste-3A0CA45F.png" width="550" />

<img src="images/paste-BA04C06C.png" width="550" />

## Prediction

> Predict continuous data

## Classification

> Try to predict non-continuous data

<img src="images/paste-16625F94.png" width="550" />

### Supervised Learning

> Goal is either inference or prediction

<img src="images/paste-E7E616DB.png" width="550" />

<img src="images/paste-84D683CB.png" width="550" />

<img src="images/paste-A50522AA.png" width="550" />

<img src="images/paste-0267F0EA.png" width="550" />

### Unsupervised Modeling

<img src="images/paste-02779782.png" width="550" />

## Overfitting

<img src="images/paste-B76CE432.png" width="550" />

<img src="images/paste-A64907E1.png" width="550" />

<img src="images/paste-39537926.png" width="395" height="323" />

<img src="images/paste-AB123C11.png" width="550" />

## Testing Data

<img src="images/paste-974E19A9.png" width="550" />

### Holdout Validation

> Single iteration

<img src="images/paste-968B54EC.png" width="400" />

<img src="images/paste-8E7B23AA.png" width="400" />

<img src="images/paste-7A597610.png" width="550" />

### K-Fold Cross Validation

> Holdout validation just multiple times

<img src="images/paste-CBB25790.png" width="550" />

### Bootstrap Sampling

<img src="images/paste-C65EC96A.png" width="550" />

<img src="images/paste-ADB22C07.png" width="550" />

## Predictions on Data

<img src="images/paste-470D7279.png" width="550" />

`caret` package streamlines the modeling process into similar function
conventions
