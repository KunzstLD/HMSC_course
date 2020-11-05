---
output:
  pdf_document: default
  html_document: default
---
# Table of Contents
- [Table of Contents](#table-of-contents)
- [Organisation](#organisation)
- [Introduction to community ecology & Typical data collected in community ecology](#introduction-to-community-ecology--typical-data-collected-in-community-ecology)
  - [Community ecology: Assemblage and their interactions](#community-ecology-assemblage-and-their-interactions)
  - [Typical data collected in community ecology?](#typical-data-collected-in-community-ecology)
- [Overview of the structure of HMSC](#overview-of-the-structure-of-hmsc)
  - [Theoretical](#theoretical)
  - [Practical](#practical)
- [How HMSC models variation in species niches?](#how-hmsc-models-variation-in-species-niches)
  - [How to utilize traits and phylogeny?](#how-to-utilize-traits-and-phylogeny)
    - [Traits](#traits)
    - [Phylogeny](#phylogeny)
- [Case Studies](#case-studies)
  - [Pipeline:](#pipeline)
- [Break out groups (04.11. and 05.11)](#break-out-groups-0411-and-0511)
  - [Model selection](#model-selection)
  - [Traits](#traits-1)
- [How to write materials and methods when using HMSC](#how-to-write-materials-and-methods-when-using-hmsc)
- [How to write the results section?](#how-to-write-the-results-section)


# Organisation
  - Break-out groups Wednesday and Thursday for Europe
  - The course covers more or less the whole book


# Introduction to community ecology & Typical data collected in community ecology

## Community ecology: Assemblage and their interactions

*John H. Lawton (1999)*: Are there general laws in ecology?

Although conceptual frameworks have been developed in the last decades

HMSC follows the definition from *Fauth et al. (2016)*: Simplifying the Jargon of Community Ecology: A conceptual approach 

Prevailing theories: 
- Assembly rules framework:

  $\rightarrow$ restricted species combinations to which competitive interactions can lead (see *Diamond (1975)*)

  $\rightarrow$ nowadays assembly processes: filters act at various spatial scales 
  
  $\rightarrow$ ecological assembly rules: environmental filtering ($\beta$), biotic filtering ($\Omega$), dispersal ($\alpha$), stochasticity ($R^2$)
  
  $\rightarrow$ species traits ($\gamma$) influence $\Omega$, $\alpha$ and $\beta$

  $\rightarrow$ phylogeographic assembly rules

- Metacommunity theory
- Vellends theory of ecological communities 

$\rightarrow$ HMSC components can be related to ecological theory

Four archetypes of metacommunity theory: 
- Neutral paradigm
- Patch dynamics
- species sorting
- mass effects

**Read**: *Ovaskainen et al: What can observational data reveal about metacommunity processes?*

## Typical data collected in community ecology?

Lab experiments & field experiments (manipulative) & field data (non-manipulative)

$\rightarrow$ non-manipulative field data are shaped by full complexity of assembly processes

$\rightarrow$ Abundances/rel. Abundances, presence-absence, spatial-temporal design, environmental covariates, traits, phylogeny


# Overview of the structure of HMSC


## Theoretical 

Multivariate hierarchical generalized linear mixed model fitted with Bayesian inference

HMSC is a correlative model!

* HMSC is a joined distribution modelling approach, not stacked:

    $\rightarrow$ There is random variation in pairs of species (co-occurrences, species associations)

    $\rightarrow$ Share information across species while modelling

* **Q:** Species associations are modelled as random effect:

    $\rightarrow$ Dimensionality problem (cannot put too many as predictors/as fixed effects)

    $\rightarrow$ Species occurrences are the response variable, HMSC creators refrain from putting species to explanatory variable part

Species associations are modelled using a latent approach, otherwise to computational intensive

## Practical

1) Setting model structure and fit the model

    $\rightarrow$ call *Hmsc()*
     
    $\rightarrow$ model is defined but not fitted!
    (unlike *lm()* for example)

    $\rightarrow$ prior: default prior applies too most datasets (according to Ovaskainen)

    $\rightarrow$ call: *sampleMcmc()* for model fitting. Start always with a small amount of thinning! 

2) Examining MCMC convergence (how good is the sample of the posterior distribution
    
    $\rightarrow$ represent the posterior distribution)

    $\rightarrow$ Use *library(coda)* utilities (loaded when loading HMSC package)

    $\rightarrow$ Effective Size (should be close to actual sample size), Gelman diagnostics, Trace plots

    $\rightarrow$ Run the whole pipeline also with bad convergence to obtain preliminary results

3) Evaluating model fit and comparing model

    $\rightarrow$ Bigger issue than variable selection: Should one include traits, phylogeny, spatial structure and how?

    $\rightarrow$ WAIC (widely applicable AIC)
    
    $\rightarrow$ Predictive power (how well does the model predict/explain the data?). Gives insight in how models differ (prediction difference, bias etc.) 
    
    $\rightarrow$ CV used for predictive power (the more variables one includes the less good predictions will be with this approach?), without CV for all data than model fitted for all data for explanatory purposes $\rightarrow$ Output: $TjurR^2$ (range from -1 to 1), $AUC$ (range from 0 to 1)
    
    $\rightarrow$ CV can be done across sampling units and also across **species**! (conditional predictions)

    $\rightarrow$ Predictive values can be checked for variance in residuals 

4) Exploring parameter estimates

    $\rightarrow$ One joint posterior distribution for all parameters

    $\rightarrow$ Could use tools of the coda package, or Hmsc functions, e.g.: 
    *plotBeta(m, post, supportLevel)*

    positive, zero or negative slope of beta parameters (species niches); 
    supportLevel: how much posterior probability?

    $\rightarrow$ Association plots: *corrplot(computeAssociations(m))*

    $\rightarrow$ Variance partitioning: how much variation is explained by different compartments of the model? (*computeVariancePartitioning(m)*)
    
    $\rightarrow$ How is variance partitioning calculated? See section 5.5. in *Joint Species Distributions Modelling*

 
5) Making predictions

    5.1 prepare predictions: predictor variables of env. covariates + predictor values of spatio-temporal context

    $\rightarrow$ e.g.:
    
    *Gradient <- constructGradient(m, focalVariable)* 

    *pred <- predict(m, Gradient)*

    *plotGradient(m, Gradient, pred, measure, showData)*
    

    5.2 Make predictions (Y new) with uncertainty estimate (95 % credible interval):

    - General: 
  
       $\rightarrow$ Construct gradient of new data for variable of interest (focalvariable) to make predictions on

      $\rightarrow$ The non.focalvariables are the other variables needed for predictions (e.g. *list(hab = 1)* uses the most common type)

      $\rightarrow$ predict model on gradient with *predict()* function (creates posterior predicted distribution, see MCMC)

      $\rightarrow$ expected = TRUE: predicting probabilities; expected = FALSE: predicting realisations (e.g. Presence-absence) mean over this gives the posterior mean  

    - Spatial predictions: 
  
      $\rightarrow$ New X Data & new spatial data 

      $\rightarrow$ Prediction for each posterior sample

    5.3 Post-processing and interpretation (species richness, community-weighted mean traits, ...)

# How HMSC models variation in species niches?

- Full HMSC case: multiple species, environ. covariates, traits, phylogeny

- Linear predictor is now a matrix! $L_{ij}$ , $i =$ sampling unit, $j =$ species

- $\beta$ is also a matrix
  
- Environ. variables do not depend on species (i.e. $x_{ik}$, where $k =$ covariate, but it can be changed to be species-specific  

- Joint species distribution model: model is fitted simultaneously, so species models are dependent on each other

- How are species niches structured? HMSC implements continuous variation in species niches (in contrast to *Hui et al.* species archetype models)

- Parameters estimated $\rightarrow$ used to estimate Variance-Covariance matrix ?
 
  $\rightarrow$ Borrowing information from other species

## How to utilize traits and phylogeny?

See chapter 6

### Traits

- Modelled as regression to species traits

- Expected value $\mu$ is specific to the trait expressed by each species ($t_{jl}$, $t =$ trait value) and can thus be modified by the trait information
  
- $\gamma_{kl}$ parameter: How species niches depend on species traits (one parameter for community as response to covariate, e.g. climatic conditions)

### Phylogeny

- Phylogenetic tree or taxonomic table

- Correlation between species in phylogenetic trees: That's the fraction of shared evolutionary history. Can be expressed in a correlation matrix. 

- Residual variation in species niches (Matrix $M$, expected species niches) is modelled as a weighted average of correlation matrix and (modified) identity matrix ($W$)

- $W = \rho C + (1- \rho)I$

- $\rho$ measures the strength of the phylogenetic signal in species niches 

# Case Studies

## Pipeline:
1) Read data
2) Define models

    Random effect: 

    - For plots that repeat (in studyDesign matrix) spatial data should not repeat (xy matrix)
    - *HmscRandomLevel()* function; could use sData for spatial or units for temporal data or site names 

3) Fit models
   
    - Always start with a model for smaller data for checking (full model will take long)

    - E.g.: 1,5 - Thinning 1, 5 samples per Chain

    - iterations = (samples* thinning + transient)* nchains
    
    - thinning: iterations considered (not all iterations are considered, this would be too big otherwise)

    - samples taken from the posterior distribution 
    
    - transient: first iterations that are "thrown away" 

    - chains: independent runs sampling the posterior distribution (the more the better)

4) Evaluate convergence
    - Potential scale reduction factors: Model creates several latent random factors, the first one is the most important to look at
5) Compute model fit
    - Explanatory and predictive power (using CV); if one adds more covariates predictive power might go down at some point while the explanatory power will always go up when adding covariates
    - WAIC: theoretically corresponds to leave-one out CV $\rightarrow$ quite sensitive to convergence
    - $AUC$ and $TjurR^2$ are less sensitive to convergence
    - Model fit can mean: Accuracy, discrimination, calibration & precision, e.g., model comparison paper from *Norberg et al. 2019*
    - $AUC$ and $TjurR^2$ measure discrimination
6) Show model fit
7) Show parameter estimates
8) Make predictions


# Break out groups (04.11. and 05.11)

04.11: 

## Model selection

Possible: 
- Select a priori: e.g. with correlation community data axis (Y) related to covariates (X)
  
  Approach Mirkka Jones (said earlier):
  *In fitting pilot models, where people did not suggest 2-3 X covariates themselves,
   I did the following as a quick route to selecting from among numerous X-predictors: I calculated the correlations between the X-predictors and the first couple of axes of an ordination of community composition based on the full Y-matrix. I included those X variables in the hmsc model that had a high positive or negative correlations with the first couple of ordination axes (but excluding any X covariates that covaried strongly).*

- Use ecological theory!
- Strong collinear environmental variables should be removed (but which - left to the researcher)

## Traits

- Use of PCA or similar techniques (fuzzy PCA/Correspondence analysis) to obtain trait syndromes.

  Jari Oksanen:
  *There are different styles and philosophies. Personally I don’t like using PC axes, 
  because you don’t know too well how they relate to your observations. I also prefer to pick up single tangible variables. But there are two viewpoints here. Moreover, these PCs only select among collinear X-variates independent of their explanatory power to Y.* 
- Interpretation of Gamma plots: Follows the interpretation of the Beta plots if single traits are used

    - If traits are combined into a trait syndroms (e.g. via PCA) need to look at how the taxa are distributed along the PCA axis used and how much covariance is in the data?
    $\rightarrow$ Jari Oksanen is not a fan of this approach  

- Variance that traits explain in species niches and in species occurrences can be found in matrix $V$ (TODO check again chapter 6.3)

- Trait interactions can be included!  
  
05.11:

- Q1) Plotting: inherits from *plot()* function, can use las for example, Name order and names can be changed by changing parameter VP

- Q2) Hurdle-models with more than two levels, is this possible? E.g. Community: bushes with wasps with parasites -> Problem is independent chains of the parameter estimates, one can't compare MCMC samples  

- Q3) There are no hierarchical levels for **Y** (yet)

- Q4) Missing values: can be missing in **Y**, but HMSC cannot impute values (e.g. for **X**)

- Jari's wisdom: 
  - When evaluating $\lambda$ parameter, run more chains if possible because that's quite complicated to determine

  - For MCMC convergence, thinning is important!

- Q5) eDNA Data: How to handle millions of data?
  - Jari: Millions is too much dude!

- (Jumped into Tikhonov's session) 
- Q6) Combination of trait values and indicator values is possible (Question was complicated about the wasps, galls and parasites and all what hangs around)

- Q7) Several plots exposed to some treatment -> random effects are correlated with treatment effects. Needs to be specified in **X** matrix? 
    - Treatment is fixed effect, plot as random effect $\rightarrow$ effect of variation in plot can be estimated
    - Variation within the treatment is difficult to answer
    - Is the distribution of the random effects across the treatments the same?
    - Include one random unit per treatment and plot; remaining plots which get another treatment get assigned another fake unit $\rightarrow$ see section 7.5 Covariate-dependent species associations

- (jumped back to Mirkka's session)

- What was the question? Residuals of **Y** can be ordinated (RDA) $\rightarrow$ goes into random effects in HMSC

- Q8) What is the benefit of HMSC compared to "traditional" methods, especially for variance partitioning?

    - Generally borrowing information from other species
    
    - Including traits and phylogeny 
 
    - Jari: Variance partitioning for every species can be obtained, can be actually done with RDA but don't tell Legrande! 
  
    - Even with just Y and X this approach is more informative, because it's species oriented instead of being site oriented (which are the traditional methods)
    
    - Integrating spatial structure as well is nice! In practice all other methods can only have one (i.e. traits, phylogeny, spatial structure) 

- Q9) Interactions in JSDM: Problem with some interaction patterns like asymmetric interactions? (what are these actually?)
    
    -  All interactions in HMSC are symmetric. What one sees in HMSC are patterns which means one has to study deeper what actually happens (theory!) if a pattern emerges.

- Q10) Maximum Number of covariates to include in an HMSC model?
    
    - Env. covariates limited by number of samples 
   
    - For traits it's the number of taxa    

- Q11) Follow up: Would you recommend combining covariates related to some special factor (e.g. data on soil fertility)

    - Depends on the data, e.g. soil chemistry data based on sampling, super!
    - Or again use PCA or related

- Q12) Missed the question because Andi came in, something general about sample size yada yada

    - Think about environmental gradient (long gradient better to see any pattern)

- Q13) Taxonomic resolution in data, including more data but having a coarser taxonomic level?

    - Depends on the goal, there might be high variation within genera for example
    - Could use dummy taxa per genera 

- Q14) Time series?
  
    - Can be done with even one site! And then evaluate change over time 

- Q15) Very small datasets?
    
    - High uncertainty in the parameter estimates, but you could do it 

- Q16) Sampling multiple times? 

    - That increases sample size 

- Q17) Something about within plot environmental variation which I didn't get 

- Q18) What influences runtime the most?

    - Species more than number of rows
    - Spatial effects need long
    - If one adds traits and phylogeny it even takes longer of course
    - Jari doesn't know when he runs a model beforehand how long it takes, try with very small samples and then multiply the time (gives usually good estimate about the true time)
    - Mac, Linux runs faster, Don't forget to parallize as well! 
    - Update BLAS(), LPAC()! (obtained by sessionInfo())
    - Jari's speed demon settings: *BLAS: /System/Library/Frameworks/Accelerate.framework/Versions/A/ Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
    LAPACK: /Library/Frameworks/R.framework/Versions/4.0/Resources/lib/libRlapack.dylib *
    - See also: https://csantill.github.io/RPerformanceWBLAS/
 
- Q19) What was the question?
  -  Random effects don't have to be hierarchical
  -  Study design has the name of the plots/ row.names(xy) = unique_sample_ID (see example scripts)
  
# How to write materials and methods when using HMSC

1) Overview of HMSC
      - Taylored to the specific study (e.g. how is it spatially structured?)
2) Study design and data selection
     - How many species
     - Where surveyed?
     - Exclusion of rare species? (otherwise convergence issues)
     - Additional models for the raw species? (some regression model with env. variables for robustness checks)
3) Sampling units and response variable
    - Sampling units, e.g. individual visits
    - Response: Counts, presence-absence
    - Nature of the data: e.g. "zero-inflated, thus we applied a hurdle model"
    - Which error distribution (e.g. probit in presence-absence, linear regr. for transformed count data...)
    - Transformation & potential scaling of count data 
4) Predictors (how was the model defined)
   - Fixed effects (sampling units times covariates matrix)
   - Main interest is the effect of...
   - Include traits, examine how responses of species are influenced by traits
   - Include phylogeny, e.g.: We examined if variation in species niches was phylogenetically structured (closely related species had more similar responses than distantly related species). Phylogenetic tree derived from XXX
   - Random effects: to account for the spatial nature of the study design...
5) Model fitting
   - Fitted the model with the R-package HMSC assuming the default prior distributions (see Chapter 8 of Ovaskainen and Abrego 2020 book).
   - How was the posterior distribution sampled? (Chains, samples, iterations $\rightarrow$ thinning, transient/burn-in)
   - Examination of MCMC convergence: Scale reduction factors (refer to SI)
6) Postprocessing of results 
   - Model fit: 
     - explanatory and predictive power:
       - $AUC$ and $Tjur's R^2$ $\rightarrow$ probit models
       - abundance COP: $R^2$
     - What does explanatory and predictive power mean? (Model predictions based on all data or on based on CV)
    - Parameter values:  
       - To quantify drivers of community structure, we partitioned the explained variation among the fixed and random effects
       - Main study questions: e.g. Beta parameters (positive or negative response with measure of statistical uncertainty like 95 % posterior probability)

# How to write the results section?

- Start with descriptive statistics of the data
- MCMC convergence
    - Report: "Potential scale reduction factors for the $\beta$ parameters (response of species to env. covariates) $\rightarrow$ were on average XXX (maximum) for presence-absence model and (if other models used) ..."
    - Same also for $\gamma$ parameters
    - $\beta$ plots give the marginal effect
- Model fit
    - "Mean $TjurR^2$ for model ... is on average XXX for explanatory power and XXX for the predictive power"
- What explains variation in the data?
    - How is explanatory power distributed across taxa? look on taxonomy
    - Could also group by traits, e.g.  Which traits taxa which have a high explanatory power express?
    - Model fit vs species prevalence  $\rightarrow$ Species that are rare and those that occur everywhere will also have low explanatory power
- Phylogenetic signal if the data exist
    - Posterior probability of $\rho$ in used models and expected $\rho$ 
    - How does the phylogenetic signal corresponds to the environmental covariate 
- Possibly traits if trait data exist