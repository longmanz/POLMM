% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/POLMM.R
\name{POLMM}
\alias{POLMM}
\title{Test for association between genetic variants and an ordinal categorical variable via Proportional Odds Logistic Mixed Model (POLMM)}
\usage{
POLMM(
  objNull,
  Geno.mtx,
  chrVec,
  SPAcutoff = 2,
  minMAF = 1e-04,
  maxMissing = 0.15,
  impute.method = "fixed",
  G.model = "Add",
  G.missing = NA
)
}
\arguments{
\item{objNull}{the output of the POLMM_Null_Model() function}

\item{Geno.mtx}{a numeric genotype matrix with each row as a subject and each column as a marker. 
Column names of marker IDs and row names of individual IDs are required.
Missng genotype should be coded as in argument 'G.missing'. Both hard-called and imputed genotype are supported.}

\item{chrVec}{a character or a character vector to specify chromosome(s) of the markers in Geno.mtx. Must be specified unless LOCO = F.}

\item{SPAcutoff}{a standard deviation cutoff (default=2). If the standardized test statistic < SPAcutoff, normal approximation is used, otherwise, saddlepoint approximation is used.}

\item{minMAF}{a cutoff of the minimal minor allele frequencies (MAFs). Any markers with MAF < minMAF will be excluded from the analysis.}

\item{maxMissing}{a cutoff of the maximal missing rate. Any markers with missing rate > maxMissing will be excluded from the analysis.}

\item{impute.method}{a character string (default: "fixed") to specify the method to impute missing genotypes.
"fixed" imputes missing genotypes (NA) by assigning the mean genotype value (i.e. 2p where p is MAF).}

\item{G.model}{a character string (default: "Add") to specify additive ("Add"), dominant ("Dom"), or recessive ("Rec") model. 
If "Dom", GVec = ifelse(GVec >= 1, 1, 0), if "Rec", GVec = ifelse(GVec <= 1, 0, 1). Be very careful if the gneotyp is imputed data.}

\item{G.missing}{the code for missing genotype (default=NA). For plink input, G.missing = -9.}
}
\value{
an R matrix with the following elements
\item{ID}{Marker IDs from colnames(Geno.mtx)}
\item{chr}{Chromosome name from chrVec}
\item{MAF}{MAFs of the markers}
\item{missing.rate}{Missing rates of the markers}
\item{Stat}{Score statistics}
\item{VarW}{Estimated variance (VarW) from non-mixed model}
\item{VarP}{Estimated variance after adjusting for variance ratio r (VarP = VarW * r)}
\item{beta}{Estimated effect size: Stat / VarP}
\item{pval.norm}{p values calculated from normal approximation}
\item{pval.spa}{p values calculated from saddlepoint approximation}
\item{switch.allele}{a logical value indicating if the REF/ALT alleles were switched, if AF > 0.5, we use GVec = 2-GVec, and then give switch.allele=T. This is useful to estimate the effect direction.}
}
\description{
Test for association between genetic variants and an ordinal categorical variable via Proportional Odds Logistic Mixed Model (POLMM)
}
\examples{
## We use a Plink file with 10,000 markers and 1,000 subjects to constract GRM for demonstration. 
## For real data analysis, we recommend >= 100,000 common markers (MAF > 0.05 or 0.01).
## Selection of the common markers is similar as in Principle Components Analysis (PCA).
famFile = system.file("extdata", "nSNPs-10000-nsubj-1000-ext.fam", package = "POLMM")
PlinkFile = gsub("-ext.fam","-ext",famFile)
dataFile = system.file("extdata", "POLMM_data.csv", package = "POLMM")

egData = data.table::fread(dataFile)

## Fit the null POLMM using the Dense GRM
objNull = POLMM_Null_Model(as.factor(outcome)~Cova1+Cova2, 
                           data=egData, PlinkFile = PlinkFile, subjData = egData$IID)

## If control$seed is not changed, objNull$tau should be 0.7353
objNull$tau

## Fit the null POLMM using the Sparse GRM
SparseGRMFile = system.file("SparseGRM", "SparseGRM.RData", package = "POLMM")
load(SparseGRMFile)   ## check getSparseGRM() for more details about how to make an R object of "SparseGRM" using Plink files. 
objNull = POLMM_Null_Model(as.factor(outcome)~Cova1+Cova2, 
                           SparseGRM = SparseGRM,
                           data=egData, PlinkFile = PlinkFile, subjData = egData$IID)
                           
## If control$seed is not changed, objNull$tau should be 0.8506
objNull$tau

## when using function POLMM(), argument chrVec should be from
names(objNull$LOCOList)

set.seed(123)
Geno.mtx = matrix(rbinom(10000,2,0.3),1000,10)
rownames(Geno.mtx) = egData$IID
colnames(Geno.mtx) = paste0("rs",1:10)
chrVec = "1"  # equivalant to chrVec = rep("1", ncol(Geno.mtx))
outPOLMM = POLMM(objNull, Geno.mtx, chrVec)

outPOLMM
round(as.numeric(outPOLMM$pval.spa),2)
## [1] 0.89 0.46 0.82 0.71 0.34 0.30 0.20 0.82 0.25 0.71 # using dense GRM
## [1] 0.82 0.46 0.76 0.68 0.36 0.23 0.21 0.80 0.24 0.71 # using sparse GRM

}
