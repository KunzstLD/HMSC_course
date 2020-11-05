library(Hmsc)

#samples_list = c(5,250,250)
#thin_list = c(1,1,10)
#nChains = 4
#for (Lst in 1:length(thin_list)) {
#thin = thin_list[Lst]
#samples = samples_list[Lst]

thin = 1
samples = 5
print(paste0("thin = ",as.character(thin),"; samples = ",as.character(samples)))
filename_in = paste("models/models_thin_", as.character(thin),
                    "_samples_", as.character(samples),
                    "_chains_",as.character(nChains),
                    ".Rdata",sep = "")
load(file = filename_in) #models, modelnames
nm = length(models)

MF = list()
MFCV = list()
WAIC = list()

for(model in 1:nm){
  print(paste0("model = ",as.character(model)))
  m = models[[model]]
  preds = computePredictedValues(m)
  MF[[model]] = evaluateModelFit(hM=m, predY=preds)
  partition = createPartition(m, nfolds = 2)
  preds = computePredictedValues(m,partition=partition) #nParallel = nChains
  MFCV[[model]] = evaluateModelFit(hM=m, predY=preds)
  WAIC[[model]] = computeWAIC(m)
}

filename_out = paste("models/tmp_MF_thin_", as.character(thin),
                                            "_samples_", as.character(samples),
                                            "_chains_",as.character(nChains),
                                            ".Rdata",sep = "")
save(MF,MFCV,WAIC,modelnames,file = filename_out)
