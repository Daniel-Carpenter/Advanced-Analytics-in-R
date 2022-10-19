Descision Trees
================
Daniel Carpenter

-   <a href="#overview" id="toc-overview"><span
    class="toc-section-number">1</span> Overview</a>
-   <a href="#general-ideas" id="toc-general-ideas"><span
    class="toc-section-number">2</span> General Ideas</a>
-   <a href="#methods-to-assess-impurity"
    id="toc-methods-to-assess-impurity"><span
    class="toc-section-number">3</span> Methods to Assess Impurity</a>

## Overview

> Fantastic for classification Modeling

-   Evaluate impurity with Misclassification rate, Entropy, Information
    Gain, Information Gain Ratio and Gini Index

-   Compare and contrast the different impurity measures

-   Build classification trees in R

-   Improve your classification trees by using tree ensembles
    techniques: Bagging, Random Forests and Boosting

### Pros of Decision Trees

<img src="images/paste-43A68596.png" width="550" />

<img src="images/paste-1A6563CD.png" width="550" />

### Cons of Decision Trees

-   Overly complex

-   Model changes depending on input data. So difficult to explain to
    management

    -   Sensitive to the sample you use

    -   Numeric data sets can be complex and hard to comunicate

### Process Overview

<img src="images/paste-A7D7A647.png" width="550" />

<img src="images/paste-11EB79BD.png" width="550" />

<img src="images/paste-B8B1FC87.png" width="550" />

## General Ideas

### Interpretation of Decision Trees

<img src="images/paste-CB66EC9C.png" width="550" />

Algorithm idea:

<img src="images/paste-1BCA4E66.png" width="550" />

### Constructing Trees (Induction)

<img src="images/paste-47A4AD18.png" width="550" />

<img src="images/paste-6C8F67C9.png" width="550" />

<img src="images/paste-B80E61CD.png" width="550" />

## Methods to Assess Impurity

> Goal is to make the best predictive Model

### Summary of Methods

<img src="images/paste-11794188.png" width="550" />

### Method 1 - Using Misclassificatin Rate

-   Note do not use the misclassification rate

-   In practice, we do not use this. It is a greedy technique, only
    making the best decision based on a given iteration.

<img src="images/paste-1DEE8B6F.png" width="550" />

<img src="images/paste-FBA65C0C.png" width="550" />

<img src="images/paste-7E350799.png" width="550" />

### Method 2 - Entropy (Improvement to Misclassification)

> Entropy measures impurity
>
> Goal is to minimize the Entropy
>
> Typically does better than misclassification for complex problems

<img src="images/paste-CE94A4BD.png" width="550" />

### Method 3 - Information Gain

<img src="images/paste-3CB63AA7.png" width="550" />

### Method 4 - Information Gain *Ratio*

<img src="images/paste-073C1C41.png" width="550" />

### Method 5 - Gini Index

<img src="images/paste-F90DABD7.png" width="550" />
