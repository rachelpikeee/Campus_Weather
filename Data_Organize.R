library(dplyr)
library(tidyr)
library(lubridate)
library(naniar)

# Started 2/17/2021
# Script to read in, clean, and organize campus weather data

# to do:
#   organize by what needs to be done every time and what should only be done once

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
NewMeterData <- data.frame(matrix(ncol = 20, nrow = 0))
colnames(NewMeterData) <- ColNames

# Character string of Date of Last Download -> change this every time
#   Make sure it is the format DayMonYear-Time.csv (ex: 07Jan21-1510.csv)
#   This should match the name of the file for the data on Google Drive
DOLD <- "07Jan21-1510.csv"

# Read in the csv, skipping the first three columns
NewMeterData <- read.csv(paste0(DirMeter[user], DOLD), header = FALSE, skip = 3)
# Rename columns
colnames(NewMeterData) <- ColNames
# Cleaning up NA values
NewMeterData <- replace_with_na_all(NewMeterData, condition = ~.x == "#N/A")

#### Cleaning Data ----
# Create total NA variable
total_NA <- 0
# Count NAs in new data in one row - RUN EACH TIME
new_NA <- as.numeric(sum(is.na(NewMeterData$SolRad)))
# add to total - RUN EACH TIME
total_NA <- total_NA + new_NA

# remove NAs from data frame
NewMeterData <- drop_na(NewMeterData)

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

#### Combine Data Frames ----

#### Metadata ----
# Creating data frame for field notes -> ONLY RUN ONCE
#   DATE - date of data download
#   TIME - time of data download
#   GEN CONDITOINS - General weather, snow, other conditions from trip
#   METER CONDITIONS - Specific notes on condition of meter sensors
#   TOMST CONDITIONS - Specific notes on condition of TOMST sensors
FieldNotes <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(FieldNotes) <- c("Date", "General Conditions", "Meter Conditions", 
                          "TOMST Conditions")
FieldNotes$Date <- as_datetime(FieldNotes$Date)

# ADD FIELD OBSERVATIONS HERE - DO EVERY TIME YOU DOWNLOAD
# Keeping track of current row - MAKE SURE TO RUN!!!
current_row = nrow(FieldNotes)+1
# Change the date to most recent download - keep the same format!
FieldNotes[current_row, "Date"] <- as_datetime("2021-2-7 15:00:00", tz = "EST")
# Add field observations here
FieldNotes[current_row, "General Conditions"] <-"Sunny with about .3m snow"
FieldNotes[current_row, "Meter Conditions"] <- "Good conditions"
FieldNotes[current_row, "TOMST Conditions"] <- "Only .5m sensor visible, good conditions"

# Creating data frame to keep track of units for Meter Data
MeterUnits <- data.frame(ColNames)
MeterUnits$Units <- c("Date", "W/m^2","mm","N/A","km","˚","m/s","m/s","˚C",
                      "kPa","kPa","˚","˚","mm/h","˚C","kPa","%","mV","kPa","˚C")
colnames(MeterUnits) <- c("Measurement", "Units")



# missing data from 12/12 - 12/19 = weather station unplugged

# Save final clean data tables (data, metadata, etc.) back into the google drive folder
