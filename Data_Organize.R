library(dplyr)
library(tidyr)
library(lubridate)
library(naniar)
library(tibble)

# Started 2/17/2021
# Script to read in, clean, and organize campus weather data

# to do:
#   - organize by what needs to be done every time and what should only be done once

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

#### ONLY RUN ONE TIME ----
# Creating large data frame for all data from meter sensor 
# First create column names vector
ColNames <- c("Date","SolRad","Precip","LightningAct","LightningDist","WindDir","WindSpeed",
              "GustSpeed","AirTemp","VaporPr","AtmosPr","XLevel","YLevel","MaxPrecip",
              "SensorTemp","VPD","BatPct","BatVolt","RefPr","LogTemp", "sFlag", 
              "lFlag", "exFlag")

# Create empty data frame and rename columns
MeterData <- data.frame(matrix(ncol = length(ColNames), nrow = 0))
colnames(MeterData) <- ColNames

# Create total NA variable to help keep track of sensor's QC tactics
total_NA <- 0

# Creating data frame for field notes
#   DATE - date of data download
#   TIME - time of data download
#   GEN CONDITOINS - General weather, snow, other conditions from trip
#   METER CONDITIONS - Specific notes on condition of meter sensors
#   TOMST CONDITIONS - Specific notes on condition of TOMST sensors
FieldNotes <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(FieldNotes) <- c("Date", "General Conditions", "Meter Conditions", 
                          "TOMST Conditions")
FieldNotes$Date <- as_datetime(FieldNotes$Date)

# Creating data frame to keep track of units for Meter Data
MeterUnits <- data.frame(ColNames)
MeterUnits$Units <- c("Date", "W/m^2","mm",NA,"km","˚","m/s","m/s","˚C",
                      "kPa","kPa","˚","˚","mm/h","˚C","kPa","%","mV","kPa","˚C",
                      NA, NA, NA)
colnames(MeterUnits) <- c("Measurement", "Units")

################################################################################

#### RUN EVERY TIME NEW DATA IS DOWNLOADED ----
# Adding field observations to data frame
# Keeping track of current row - MAKE SURE TO RUN!!!
current_row = nrow(FieldNotes)+1
# Change the date to most recent download - keep the same format!
FieldNotes[current_row, "Date"] <- as_datetime("2020-12-19 12:00:00", tz = "EST")
# Add field observations here
FieldNotes[current_row, "General Conditions"] <-"Sunny with about .4m of snow"
FieldNotes[current_row, "Meter Conditions"] <- "Good conditions"
FieldNotes[current_row, "TOMST Conditions"] <- "Only .5m sensor visible above snow"

# Reading in most recent data
# Character string of Date of Last Download -> change this every time
#   Make sure it is the format DayMonYear-Time.csv (ex: 07Jan21-1510.csv)
#   This should match the name of the file for the data on Google Drive
DOLD <- "07Jan21-1510.csv"

# Read in the csv, skipping the first three columns
NewMeterData <- read.csv(paste0(DirMeter[user], DOLD), header = FALSE, skip = 3)
# Cleaning up NA values
NewMeterData <- replace_with_na_all(NewMeterData, condition = ~.x == "#N/A")
# Count NAs in new data (only use one row to count NA observations not total 
#                        NA cells)
new_NA <- as.numeric(sum(is.na(NewMeterData$V2)))
# add to total
total_NA <- total_NA + new_NA
# remove NAs from data frame
NewMeterData <- drop_na(NewMeterData)
# Add flag columns
NewMeterData <- add_column(.data = NewMeterData, sFlag = NA, lFlag = NA, exFlag = NA)
# Rename columns
colnames(NewMeterData) <- ColNames

# Making each column the appropriate type of data -- cant convert to datetime without seconds
NewMeterData$Date <- as_datetime(NewMeterData$Date, tz = "EST")
NewMeterData$SolRad <- as.numeric(NewMeterData$SolRad)
NewMeterData$Precip <- as.numeric(NewMeterData$Precip)
NewMeterData$LightningAct <- as.numeric(NewMeterData$LightningAct)
NewMeterData$LightningDist <- as.numeric(NewMeterData$LightningDist)
NewMeterData$WindDir <- as.numeric(NewMeterData$WindDir)
NewMeterData$WindSpeed <- as.numeric(NewMeterData$WindSpeed)
NewMeterData$GustSpeed <- as.numeric(NewMeterData$GustSpeed)
NewMeterData$AirTemp <- as.numeric(NewMeterData$AirTemp)
NewMeterData$VaporPr <- as.numeric(NewMeterData$VaporPr)
NewMeterData$AtmosPr <- as.numeric(NewMeterData$AtmosPr)
NewMeterData$XLevel <- as.numeric(NewMeterData$XLevel)
NewMeterData$YLevel <- as.numeric(NewMeterData$YLevel)
NewMeterData$MaxPrecip <- as.numeric(NewMeterData$MaxPrecip)
NewMeterData$SensorTemp <- as.numeric(NewMeterData$SensorTemp)
NewMeterData$VPD <- as.numeric(NewMeterData$VPD)

# Adding flags for level
for (i in 1:nrow(NewMeterData)){
  NewMeterData$lFlag[i] <- ifelse(NewMeterData[i, "XLevel"]>2 | NewMeterData[i, "XLevel"]<(-2)
                               | NewMeterData[i, "YLevel"]>2 | NewMeterData[i, "YLevel"]<(-2),
                               "X", NA)
}
  
# TO DO:
# Add method for snow and extreme value flags
# Combine new meter data with big data set
# Check for overlap
# Save files google drive

# QUESTIONS:
#   changing date as datetime format -- no seconds, function doesn't work
#   easier way to make all columns numeric?

# NOTES:
#   Separate script for TOMST data -- more complicated
#   Save final clean data tables (data, metadata, etc.) back into the google drive folder
#   Add some check for clock / time of observation -> need to think about this more
