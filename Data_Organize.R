library(dplyr)
library(tidyr)
library(lubridate)

# Started 2/17/2021
# Script to read in, clean, and organize campus weather data

#### Setting up directories

# Creating user numbers for each person
Users = c(1, # Rachel
          2) # Professor Kropp 

DirMeter = c("/Volumes/GoogleDrive/.shortcut-targets-by-id/1sRKN7b9U7odoX9ABwoUqoeY1G-kRMjHC/campus_weather/METER/",
             "")
DirTOMST = c("/Volumes/GoogleDrive/.shortcut-targets-by-id/1sRKN7b9U7odoX9ABwoUqoeY1G-kRMjHC/campus_weather/TOMST/",
             "")

# Select user - change if needed
user = 1


#### Reading in Meter Data ----

# Only run ONCE when setting up data frames!!
# Creating large data frame for all data from meter sensor 
# First create column names vector
ColNames <- c("Date","SolRad","Precip","LightningAct","LightningDist","WindDir","WindSpeed",
              "GustSpeed","AirTemp","VaporPr","AtmosPr","XLevel","YLevel","MaxPrecip",
              "SensorTemp","VPD","BatPct","BatVolt","RefPr","LogTemp")

# Create empty data frame and rename columns
MeterData <- data.frame(matrix(ncol = 20, nrow = 0))
colnames(MeterData) <- ColNames


# Reading in most recent data -- RUN EVERY TIME NEW DATA IS DOWNLOADED

# Character string of Date of Last Download -> change this every time
#   Make sure it is the format DayMonYear-Time.csv (ex: 07Jan21-1510.csv)
#   This should match the name of the file for the data on Google Drive
DOLD <- "07Jan21-1510.csv"

# Read in the csv, skipping the first three columns
MeterData <- read.csv(paste0(DirMeter[user], DOLD), header = FALSE, skip = 3)

# Rename columns
colnames(MeterData) <- ColNames

#### Cleaning Data ----
# make flags/corrections based on field notebook notes
# flag approach for snow/ice, other data that still exists/is potentially usable
# procedure for data that is not reliable
#   checking for unreasonable temps -- set extreme thresholds, checks between sensors


# Rounds of quality control
# round 1 = based on metadata / field observations / user assessment
#   ex: weather station broken --> remove data completely
#   ex: snow/ice/other things covering the sensor --> flag
#   ex: weird spikes/abnormal data --> need to see if something happened
#   NOTE: meter data has own QC checks --> look for NA's in the data
# if there are any that have these types, go through data more manually to fix problem

# Meter data steps
# Read in data - both in own table and to old table
# Create table with date of download/observation and user notes
# Count NA's since last download and cumulatively (its own QC checks)
# Check for extreme values / spikes in the data

# Separate script for TOMST data -- more complicated

#### Base Analysis of Data ----

#### Metadata ----
# Make this into 2 Columns instead of two rows
MeterUnits <- data.frame(t(c("Date", "W/m^2","mm","N/A","km","˚","m/s","m/s","˚C",
                           "kPa","kPa","˚","˚","mm/h","˚C","kPa","%","mV","kPa","˚C")))
colnames(MeterUnits) <- ColNames

# missing data from 12/12 - 12/19 = weather station unplugged

# Save final clean data tables (data, metadata, etc.) back into the google drive folder
