# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (dir): status of run

base_dir <- "C:/Users/danie/Desktop/aichiTest/aichiTest"
repo_dir <- "C:/Users/danie/Desktop/aichiTest/aichiTest/src"

#here for troubleshooting. 

master_run <- function(species) {
  # build a datframe that captures the total run time for a process.  
  time_df <- data.frame(matrix(ncol = 2, nrow = 0))
  x <- c("functionUsed", "runTime")
  colnames(time_df) <- x
  
  startTime <- Sys.time()
  
    #error message
  message = "OK"
  status = TRUE
  final_function= character()
  speciecs <- as.character(species)  
  tryCatch({
    print(paste0("Start ",species))

    #load config function
    #source(paste(repo_dir,"/config.R",sep=""))

    t1a <- Sys.time()
    #create directories
    #source(paste(repo_dir,"/tools/create_sp_dirs.R",sep=""))
    cat("...creating directories\n")
    spp_dirs <- create_sp_dirs(species)
    final_function = "0.create_sp_dirs was done"
    #calculate time 
    time_df <- rbind(time_df, data.frame(functionUsed="create_sp_dir",  runTime=difftime(Sys.time(), t1a, units='secs')))
    
    
    t1a <- Sys.time()
    #step 2.1-clean sea
    #source(paste(repo_dir,"/0_cleaning/clean_sea.R",sep=""))
    cat("...cleaning species\n")
    spp_clean <- clean_sea(species)
    final_function = "1.clean_sea was done"
    #calculate time 
    time_df <- rbind(time_df, data.frame(functionUsed="clean_sea", runTime=difftime(Sys.time(), t1a, units='secs')))
    
    t1a <- Sys.time()
    #step 2.1.1-sampling ocurrences
    spp_samp <- sampling(species)
    final_function = "1.1.sampling ocurrences was done"
    #calculate time 
    time_df <- rbind(time_df, data.frame(functionUsed="sampling", runTime=difftime(Sys.time(), t1a, units='secs')))
    
    
    t1a <- Sys.time()
    #step 2.2-create native area
    #source(paste(repo_dir,"/1_modeling/nat_area_shp.R",sep=""))
    cat("...creating native area shapefile\n")
    narea_shp <- nat_area_shp(species)
    final_function = "2.nat_area_sh was done"
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="nat_area_shp", runTime=difftime(Sys.time(), t1a, units='secs')))
  
    t1a <- Sys.time()
    #step 2.3-crop bioclim
    #source(paste(repo_dir,"/1_modeling/nat_area_mask.R",sep=""))
    cat("...masking bioclim layers to native area\n")
    crop_bio <- nat_area_mask(species)
    final_function = "2.1.nat_area_mask was done"
    #### Issue here is that the script is looking for species file based on the numerical id not the name. 
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="nat_area_mask", runTime=difftime(Sys.time(), t1a, units='secs')))
    
    t1a <- Sys.time()
    #step 3-modeling (#only calibration)
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/modeling_approach.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/create_mx_args.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/do_projections.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/evaluating.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/nullModelAUC.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_2_alternatives/create_buffers.R",sep=""))
    cat("...maxent modelling\n")
    spmod <- spModeling(species)
    final_function = "3.spModeling was done"
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="sModeling", runTime=difftime(Sys.time(), t1a, units='secs')))

  
    t1a <- Sys.time()
    #step 4.1-exsitu gap analysis
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/srs.R",sep=""))
    cat("...exsitu srs\n")
    srs_ex <- srs_exsitu(species)
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="srs_ex", runTime=difftime(Sys.time(), t1a, units='secs')))
  
    t1a <- Sys.time()
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/grs.R",sep=""))
    cat("...exsitu grs\n")
    grs_ex <- grs_exsitu(species)
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="grs_ex", runTime=difftime(Sys.time(), t1a, units='secs')))
  
    t1a <- Sys.time()
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/ers.R",sep=""))
    cat("...exsitu ers\n")
    ers_ex <- ers_exsitu(species)
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="ers_ex", runTime=difftime(Sys.time(), t1a, units='secs')))
  
    t1a <- Sys.time()
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/fcs.R",sep=""))
    cat("...exsitu fcs\n")
    fcs_ex <- fcs_exsitu(species)
    final_function = "4. fcs_exsitu was calculated"
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="fcs_ex", runTime=difftime(Sys.time(), t1a, units='secs')))

    t1a <- Sys.time()
    #step 4.2-insitu gap analysis
    #source(paste(repo_dir,"/2_gap_analysis/insitu/grs.R",sep=""))
    cat("...insitu grs\n")
    grs_in <- calculate_grs(species)
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="grs_in", runTime=difftime(Sys.time(), t1a, units='secs')))
  
    t1a <- Sys.time()
    #source(paste(repo_dir,"/2_gap_analysis/insitu/ers.R",sep=""))
    cat("...insitu ers\n")
    ers_in <- calculate_ers(species)
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="ers_in", runTime=difftime(Sys.time(), t1a, units='secs')))
  
    t1a <- Sys.time()
    #source(paste(repo_dir,"/2_gap_analysis/insitu/fcs.R",sep=""))
    cat("...insitu fcs\n")
    fcs_in <- calculate_fcs(species)
    final_function = "5. fcs_in was calculated"
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="fcs_in", runTime=difftime(Sys.time(), t1a, units='secs')))

  
    t1a <- Sys.time()
    #step 4.3-combine insitu and exsitu
    #source(paste(repo_dir,"/2_gap_analysis/combined/fcs_combine.R",sep=""))
    cat("...combine exsitu and insitu fcs\n")
    fcs_comb <- fcs_combine(species)
    final_function = "6. fcs combined was calculated"
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="fcs_comb", runTime=difftime(Sys.time(), t1a, units='secs')))

 
    #calculate time 
    time_df<- rbind(time_df, data.frame(functionUsed="totalTime", runTime=difftime(Sys.time(), startTime, units='secs')))
    
    time_df$minutes <- time_df$runTime / 60 
    sp_dir <- paste(gap_dir,"/",species,"/",run_version,sep="")
    write.csv(time_df, paste0(sp_dir, "/runTimes.csv"))
    
    #return status data.frame
  #  return (data.frame(species = species, status = status, message = message))
  },error = function(e) {
    print(paste0("Error ",species))
    message = e[[1]]
    status = FALSE
  }, finally = {
    print(paste0("End ",species))
    return(data.frame(species = species, status = status, message = message, final_function = final_function))
  })
}
