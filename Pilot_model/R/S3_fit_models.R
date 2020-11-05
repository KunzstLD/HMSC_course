library(Hmsc)

load(file = "models/unfitted_models") #models, modelnames

#samples_list = c(5,250,250,250,250)
#thin_list = c(1,1,10,100,1000)
#nChains = 4
#for(Lst in 1:length(samples_list))
#thin = thin_list[Lst]
#samples = samples_list[Lst]

thin = 1
samples = 5
print(paste0("thin = ",as.character(thin),"; samples = ",as.character(samples)))
nm = length(models)
for (model in 1:nm) {
  print(paste0("model = ",modelnames[model]))
  m = models[[model]]
  m = sampleMcmc(m, samples = samples, thin=thin,
                 adaptNf=rep(ceiling(0.4*samples*thin),m$nr), 
                 transient = ceiling(0.5*samples*thin),
                 nChains = nChains) # nParallel = nChains
}
filename = paste("models/tmp_models_thin_", as.character(thin),
                 "_samples_", as.character(samples),
                 "_chains_",as.character(nChains),
                 ".Rdata",sep = "")
save(models,modelnames,file=filename)
