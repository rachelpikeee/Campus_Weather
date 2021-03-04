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

# Creating marker for initial run --> if this is true the first section of code
#   will run, if false the second section will run.
InitialRunFlag <- TRUE

#### ONLY RUN ONE TIME ----
if (InitialRunFlag == TRUE){
# Creating large data frame for all data from meter sensor 
# First create column names vector
ColNames <- c("Date","SolRad","Precip","LightningAct","LightningDist","WindDir","WindSpeed",
              "GustSpeed","AirTemp","VaporPr","AtmosPr","XLevel","YLevel","MaxPrecip",
              "SensorTemp","VPD","BatPct","BatVolt","RefPr","LogTemp", "sFlag", 
              "lFlag", "exFlag",  "Date_Format", "DOY", "DecYear", "Year", "Hour", "Minute")

# Create empty data frame and rename columns
MeterData <- data.frame(matrix(ncol = length(ColNames), nrow = 0))
colnames(MeterData) <- ColNames

# Create total NA variable to help keep track of sensor's QC tactics
total_NA <- 0

# Creating data frame to keep track of units for Meter Data
MeterUnits <- data.frame(ColNames)
MeterUnits$Units <- c("Date Chr",
                      "W/m^2","mm",NA,"km","˚","m/s","m/s","˚C",
                      "kPa","kPa","˚","˚","mm/h","˚C","kPa","%","mV","kPa","˚C",
                      NA, NA, NA, "mdy_hm", "Day", "Year", "Year", "Hour", "Minute")
colnames(MeterUnits) <- c("Measurement", "Units")

# Creating data frame to count NA values
NAcount <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(NAcount) <- c("Date", "SolarNA", "WindNA", "TempNA", "TotalNA")
NAcount$Date <- as.Date(NAcount$Date)
} else {

#### RUN EVERY TIME NEW DATA IS DOWNLOADED ----

# Reading in most recent data
# Character string of Date of Last Download -> change this every time
#   Make sure it is the format DayMonYear-Time.csv (ex: 07Jan21-1510.csv)
#   This should match the name of the file for the data on Google Drive
DOLD <- "07Jan21-1510.csv"

# Read in the csv, skipping the first three columns
NewMeterData <- read.csv(paste0(DirMeter[user], DOLD), header = FALSE, skip = 3,
                         na.strings = "#N/A")
# Add flag columns
NewMeterData <- add_column(.data = NewMeterData, sFlag = NA, lFlag = NA, exFlag = NA)

# Adding other date-related colunmns
# Column with date in correct format
NewMeterData$Date_Format <- mdy_hm(NewMeterData[,1])
# Day of Year columns
NewMeterData$DOY <- yday(NewMeterData$Date_Format)
# Year column
NewMeterData$Year <- year(NewMeterData$Date_Format)
# Hour column
NewMeterData$Hour <- hour(NewMeterData$Date_Format)
# Minute Column
NewMeterData$Minute <- minute(NewMeterData$Date_Format)
# Decimal Year Column
NewMeterData$DecYear <- round(NewMeterData$Year + ((NewMeterData$DOY - 1 + (NewMeterData$Hour/24) + 
                                                      (NewMeterData$Minute/1440))/
                                                     ifelse(leap_year(NewMeterData$Year),
                                                            366,365)), digits = 6)
# Rename columns
colnames(NewMeterData) <- ColNames

# Function to add NA values to NA dataframe
CountNA <- function(Date){
  i = nrow(NAcount) + 1
  NAcount[i,1] = mdy_hm("12/11/20 14:30")
  NAcount[i,2] = as.numeric(sum(is.na(NewMeterData$SolRad)))
  NAcount[i,3] = as.numeric(sum(is.na(NewMeterData$WindSpeed)))
  NAcount[i,4] = as.numeric(sum(is.na(NewMeterData$AirTemp)))
  NAcount[i,5] = sum(NAcount[i,2:4])
}

# Function doesn't work right now (?)
CountNA("12/11/20 14:30")

# testing function outside -- works fine
i = nrow(NAcount) + 1
NAcount[i,1] = mdy_hm("12/11/20 14:30")
NAcount[i,2] = as.numeric(sum(is.na(NewMeterData$SolRad)))
NAcount[i,3] = as.numeric(sum(is.na(NewMeterData$WindSpeed)))
NAcount[i,4] = as.numeric(sum(is.na(NewMeterData$AirTemp)))
NAcount[i,5] = sum(NAcount[i,2:4])


# Adding flags for level
# Should I make this a function?
for (i in 1:nrow(NewMeterData)){
  NewMeterData$lFlag[i] <- ifelse(NewMeterData[i, "XLevel"]>2 | NewMeterData[i, "XLevel"]<(-2)
                               | NewMeterData[i, "YLevel"]>2 | NewMeterData[i, "YLevel"]<(-2),
                               "X", NA)
}

# Adding flag for snow
# Start and end dates for period with snow on sensor (change these values in user script
#     based on field notes)
sFlag = rep(NA, nrow(NewMeterData))

# Snow flag function
SnowFlag <- function(start_date, end_date, tz){
  sFlag1 = rep(NA, nrow(NewMeterData))
  if (tz == "EST"){
    for (i in 1:length(start_date)){
      sFlag1 = ifelse(NewMeterData$Date_Format >= mdy_hm(start_date[i]) & 
                     NewMeterData$Date_Format <= mdy_hm(end_date[i]), 
                     1, sFlag)
      
    }
    NewMeterData$sFlag <- sFlag1
  } else{
  print("Error: wrong time zone, use EST for data entry")
  }
}
NewMeterData$SnowFlag <- sFlag

SnowFlag(c("12/11/20 14:30", "1/1/21 14:30"), 
         c("12/13/20 14:30", "1/3/21 14:30"),
         "EST")

start_date = c("12/11/20 14:30", "1/1/21 14:30")

sFlag <- ifelse(NewMeterData$Date_Format >= mdy_hm("12/11/20 14:30") & 
                NewMeterData$Date_Format <= mdy_hm("12/13/20 14:30"), 
                1,NewMeterData$sFlag)

sFlag <- ifelse(NewMeterData$Date_Format >= mdy_hm("1/1/21 14:30") & 
                NewMeterData$Date_Format <= mdy_hm("1/3/21 14:30"), 
                1, NewMeterData$sFlag)

NewMeterData$sFlag <- sFlag


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
}

# TO DO:
# Look in meta data for what sensor does at daylight savings
# Add extreme temp flag / function
# Figure out why functions aren't working

# QUESTIONS:
#   Should I make all operations functions? Or should some just run on their own?
#   In the "user script", will they have to call the functions separately from what
#     runs when the initial flag is false?
#   should I be checking for extremes that last more than a certain period of
#     time? only mark flags if they're extreme values for more than a certain 
#     time period?

# extreme temps --> just compare to a threshold (does it make sense ex: >1000)
# sol rad < 0 
# air temp > something high
# check manual for wind info
# atmospheric pressure value for area


# NOTES:
#   Separate script for TOMST data -- more complicated
#   Add some check for clock / time of observation -> need to think about this more
