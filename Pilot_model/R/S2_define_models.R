
#### Load data #### 
library(Hmsc)

#_________________________________________________________________________________________________
# Mirkkas script:
# setwd("P:/h572/hmsc_course/kunz_stefan")
# # OR ON A MAC:
# # setwd("/Volumes/group/h572/hmsc_course/kunz_stefan")
# localDir = "."
# ModelDir = file.path(localDir, "models")
# DataDir = file.path(localDir, "data")
# library(Hmsc)
# 
load(file=file.path(getwd(),
                    "Pilot_model",
                    "Data",
                    "allData.R")) #S,X,Y,Tr,P & Tax (where P is based on Tax)
#_________________________________________________________________________________________________

# loaded from disk, P is missing
SXY <- read.csv(file.path(getwd(), 
                          "Pilot_model",
                          "Data",
                          "study_data_HMSC.csv"),
                stringsAsFactors = TRUE) # or use read.csv2 when values are semicolon-separated

# Modify the next three lines to split your SXY file to components that relate to
# S: study design, including units of study and their possible coordinates 
# (named as Route_x and Route_y to indicate that they relate to the units of Route)
# X: covariates to be used as predictors
# Y: species data
# If you don't have variables that define the study design, indicate this by S=NULL
# If you don't have covariate data, indicate this by X=NULL
S <- SXY[, c("Date", "Site")]
X <- SXY[, c("Cl",
             "El_cond",
             "Nh4",
             "No2",
             "No3",
             "Ph",
             "Po4",
             "So4",
             "Water_temp",
             "Land_use")]
Y <- SXY[, -grep(paste0(c(names(S), names(X)), collapse = "|"), names(SXY))]

# traits
Tr <- read.csv(
  file.path(getwd(), 
            "Pilot_model",
            "Data",
            "traits_taxonomy_HMSC.csv"),
  stringsAsFactors = TRUE,
  row.names = 1
)

# Aquatic macroinvertebrate abundance data. 39 taxa. 

# Taxonomic resolution varies from species to genus and family. A taxonomic tree (P)
# has been coded to the species level using dummy species and dummy genera for those 
# to include those taxa that originally lacked a species and/or genus resolution taxonomy.

# Traits are fuzzy (proportions per taxon per trait category).

# Most sites have been sampled twice, in April and June 2016.
# Three sites (reference sites judged to have low anthropogenic impacts) have 
# only been sampled once, in May.
#_________________________________________________________________________________________________

#### Species richness/prevlacence etc ####

# Check for absent (0) or ubiquitous taxa (1).
range(colMeans(Y>0))

range(colSums(Y>0))
# =1-40.

# Check how many taxa are very rare (prevalence < 5 samples) vs 
# abundant (prevalence > 156 samples). 

# Run a pilot hurdle model with 1) presence-absence model removing both the rarest and the most 
# abundant taxa; 2) a model of taxon abundance conditional on presence,
# including all but the rarest taxa.

remove_pa = which(colSums(Y>0)<5|colSums(Y>0)>37)
length(remove_pa)
# = 21. Leaving 18 taxa in the presence-absence analysis.

remove_abu = which(colSums(Y>0)<5)
length(remove_abu)
# = 20. Leaving 19 taxa in the abundance analysis.

Ypa = Y[,-remove_pa]
Yabu = Y[,-remove_abu]

hist(colMeans(Ypa>0),main="prevalence")

hist(as.matrix(log(Yabu[Yabu>0])),main="log abundance conditional on presence")

# Many taxa are rare (absent in many samples) - need zero-inflated model. Choice for the
# pilot model is a hurdle model: taxon presence-absence and log(abundance) separately.

hist(rowSums(Y>0))
# taxon richness across sites.

names(X)

#### Environmental covariates ####

# Three environmental variables from X have been selected for the pilot model (see also Readme/Methods files)
# Water_temp, El_cond and Land_use. For the two continuous variables, this initial selection is based on their 
# correlation with species compositional turnover among sites as epresented by the first two axes
# of an NMDS ordination.

plot(X[, c("El_cond", "Water_temp", "Land_use")])
cor(X[, c("El_cond", "Water_temp")])
X = data.frame(X[, c("El_cond", "Water_temp", "Land_use")])

X$Land_use = factor(X$Land_use)

XFormula = ~El_cond + Water_temp + Land_use

#### Traits #### 
Tr = data.frame(Tr[, -c(1:6)])

# Our suggestion for entering the trait data in the pilot models is to
# run a PCA on the standardized trait variables and extract the first 
# two PCA axes as descriptors of among-taxon trait differences. 
# Only 2 axes are entered in the pilot model, because the
# size of the dataset is very small (41 observations).

# Excluded one level of each trait category (feeding, etc.)
pca_result = prcomp(Tr[, -c(6, 9, 12,15)], scale = TRUE)

Tr$PCA1 = pca_result$x[,1]

Tr$PCA2 = pca_result$x[,2]

TrData_pa = Tr[-remove_pa,]
TrData_abu = Tr[-remove_abu,]

TrFormula = ~PCA1 + PCA2
head(S)

#### Spatial structure #### 

# Dates range from April to June in 2016. 
# Sites are coded from A-Z (sites visited twice, in April and June, except for the 
# three reference sites, which were sampled in May only. 

# Spatial coordinates are not provided. 

# Created a factor called month in the Study Design.
S$Month <- NA
for(n in 4:6)
{
  S$Month[grep(paste0("-0",n,"-"), S$Date)] = n
}

studyDesign = data.frame(site = as.factor(S$Site), month = as.factor(S$Month))

St = studyDesign$site
rL.site = HmscRandomLevel(units = levels(St))

Mo = studyDesign$month
rL.month = HmscRandomLevel(units = levels(Mo))

Ypa = 1*(Ypa>0)
Yabu[Yabu==0] = NA
Yabu=log(Yabu)

# hurdle mode:
# presence-absence
m1 = Hmsc(Y=Ypa, XData = X,  XFormula = XFormula,
          TrData = TrData_pa, TrFormula = TrFormula,
          phyloTree = P,
          distr="probit",
          studyDesign=studyDesign,
          ranLevels={list("site" = rL.site, "month" = rL.month)})

# abundance conditional on presence
m2 = Hmsc(Y=Yabu, YScale = TRUE,
          XData = X,  XFormula = XFormula,
          TrData = TrData_abu, TrFormula = TrFormula, 
          phyloTree = P,
          distr="normal",
          studyDesign=studyDesign,
          ranLevels={list("site" = rL.site, "month" = rL.month)})

models = list(m1,m2)
modelnames = c("presence_absence","abundance_COP")

save(models,modelnames,file = file.path(ModelDir, "unfitted_models"))
