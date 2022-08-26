# create_webpage_scripts.R
# 
# Author: Paul Carvalho (paul.carvalho@noaa.gov)
#
# Description: Automagically create CalFishTrack study page markdown scripts using information from .csv file

rm(list = ls())

# Load libraries --------------------------------------------------------------------------------------------------
library(tidyverse)


# Set working directory -------------------------------------------------------------------------------------------


# Functions -------------------------------------------------------------------------------------------------------
source("webpage_script_functions.R") # load functions save in separate script

# Read study spreadsheet ------------------------------------------------------------------------------------------
# Check existing .Rmd files in the folder
rmd_files <- data.frame(files = list.files()) %>%
             filter(str_detect(files, "Rmd"))

# Read in metadata for study pages and find metadata rows not in the folder yet
metadata <- read.csv("study_pages.csv") %>%
            filter(!(script_name %in% rmd_files$files) | update == "Y")

# Create Markdown scripts -----------------------------------------------------------------------------------------
if(nrow(metadata > 0)){
   for(i in 1:nrow(metadata)){
      metadata_tmp <- metadata[i,] 
      
      # Create yaml
      yaml <- create_yaml()
      
      # Set up libraries (R code chunk)
      setup <- create_setup()
      
      # Set page style
      style <- create_style()
      
      # Logos (R code chunk)
      logos <- create_logos()
      
      # Picture(R code chunk)
      pic <- create_pic(metadata_tmp$picture_file)
      
      # Study header, name and year
      study_header  <- create_header(metadata_tmp$study_name, metadata_tmp$study_year, metadata_tmp$study_template)
      
      # Project status
      project_status <- create_proj_status(metadata_tmp$study_ID, metadata$release_time)
      
      # Print table with fish release details (R code chunk)
      fish_release <- create_fish_release(metadata_tmp$release_groups, metadata_tmp$release_breaks)
      
      # Map of realtime detections
      map <- create_map()
      
      # Detection and flow figurs
      detections_figures <- create_detection_figures(metadata_tmp$release_region)
      
      # Survival and routing probability
      survival_tables <- create_survival_tables(metadata_tmp$release_region, metadata_tmp$georgiana)
      
      # Detection statistics
      detection_stats <- create_detection_stats()
      
      # Write script to .Rmd file
      write(c(yaml, setup, style, logos, pic, study_header, project_status, fish_release, map, detections_figures, survival_tables, detection_stats),
            file = paste0(here(), "/", metadata_tmp$script_name),
            append = FALSE)
      
      # Print file created
      cat(paste0(metadata_tmp$script_name, ' created\n'))
      
      # Update metadata
      metadata$update[i] <- 'N'
      metadata$last_updated <- Sys.time()
   }
   
   # Update csv file
   row.names(metadata) <- NULL
   write.csv(metadata, file = "study_pages.csv", row.names = FALSE)
   
} else {
   cat('All files in "study_pages.csv" already exist.')
}












