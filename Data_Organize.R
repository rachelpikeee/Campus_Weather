library(dplyr)
library(tidyr)
library(lubridate)
library(naniar)
library(tibble)

# Started 2/17/2021
# Script to read in, clean, and organize campus weather data

#### Setting up directories

# Creating user numbers for each person
Users = c(1, # Rachel
          2) # Professor Kropp 

# File path for meter data
DirMeter = c("/Volumes/GoogleDrive/.shortcut-targets-by-id/1sRKN7b9U7odoX9ABwoUqoeY1G-kRMjHC/campus_weather/METER/",
             "")
# File path for TOMST data
DirTOMST = c("/Volumes/GoogleDrive/.shortcut-targets-by-id/1sRKN7b9U7odoX9ABwoUqoeY1G-kRMjHC/campus_weather/TOMST/",
             "")
# File path to save final data
DirFinal = c("/Volumes/GoogleDrive/.shortcut-targets-by-id/1sRKN7b9U7odoX9ABwoUqoeY1G-kRMjHC/campus_weather/Final_Data",
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

# Adding flag for snow
# Check field notes data frame for dates with notes about snow
#     if there is a note about snow covering the data, fill in the following code

# Start and end dates for period with snow on sensor (change these values)
start_date = as_datetime("enter date here", tz = "EST")
end_date = as_datetime("enter date here", tz = "EST")
# For indexing
i = 0
# Loop through until dates match and while we are still in time period, add an
#   "X" to the snow flag column
for (date in NewMeterData$Date){
  i = i + 1
  if (date == start_date){
    while(date != end_date){
      NewMeterData[i, "sFlag"] = "X"
      i = i + 1
    }
  }
}

# Adding flag for extreme values
#   (see questions)
  

# Combining new meter data with larger data frame (not tested)
MeterData <- rbind(MeterData, NewMeterData)

# Checking for overlap (note tested)
MeterData <- MeterData[!duplicated(MeterData$Date), ]

# Saving all files back into Google Drive
# Field notes
write.csv(FieldNotes, paste0(DirFinal[user], "/FieldNotes.csv"))
# Meter data
write.csv(MeterData, paste0(DirFinal[user], "/MeterData.csv"))
# Meter unit data
write.csv(MeterUnits, paste0(DirFinal[user], "/MeterUnits.csv"))
# TOMST data
write.csv(TOMSTData, paste0(DirFinal[user], "/TOMSTData.csv"))
# TOMST unit data
write.csv(TOMSTUnits, paste0(DirFinal[user], "/TOMSTUnits.csv"))

# TO DO:
# Test untested functions

# QUESTIONS:
#   changing date as datetime format -- no seconds, function doesn't work
#   easier way to make all columns numeric?
#   haven't tested the the snow flag loop -- need to fix date format first
#   which columns should I be checking for extremes? should the flag be if any
#     measurement is extreme?
#   should I be checking for extremes that last more than a certain period of
#     time? only mark flags if they're extreme values for more than a certain 
#     time period?

# NOTES:
#   Separate script for TOMST data -- more complicated
#   Save final clean data tables (data, metadata, etc.) back into the google drive folder
#   Add some check for clock / time of observation -> need to think about this more
