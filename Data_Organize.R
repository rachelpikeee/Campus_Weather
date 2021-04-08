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
if (UserInputs[1,2] == TRUE | UserInputs[1,2] == FALSE){
  InitialRunFlag <- UserInputs[1,2]
} else{
  print("InitialRunFlag must be a boolean (either TRUE or FALSE). Try again.")
}


#### ONLY RUN ONE TIME ----
if (InitialRunFlag == TRUE){
# Creating large data frame for all data from meter sensor 
# First create column names vector
ColNames <- c("Date","SolRad","Precip","LightningAct","LightningDist","WindDir","WindSpeed",
              "GustSpeed","AirTemp","VaporPr","AtmosPr","XLevel","YLevel","MaxPrecip",
              "SensorTemp","VPD","BatPct","BatVolt","RefPr","LogTemp", "sFlag", 
              "lFlag", "TempFlag","SolFlag", "AtmFlag", "Date_Format", "DOY", "DecYear", "Year", "Hour", "Minute")

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
                      NA, NA, NA, NA, NA, "mdy_hm", "Day", "Year", "Year", "Hour", "Minute")
colnames(MeterUnits) <- c("Measurement", "Units")

# Creating data frame to count NA values
NAcount <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(NAcount) <- c("Date", "SolarNA", "WindNA", "TempNA", "TotalNA")
NAcount$Date <- as.Date(NAcount$Date)

# Creating data frame for user inputs
UserInputsAll <- data.frame(matrix(ncol = 7, nrow = 0))
UserCols <- c("Version", "InitialRunFlag", "DOLD", "NADate", "SnowStart", "SnowEnd", "TZ")
colnames(UserInputsAll) <- UserCols

} else {

#### RUN EVERY TIME NEW DATA IS DOWNLOADED ----
UserInputsAll <- read.csv(paste0(DirFinal[user], "/UserInputsAllv4.csv"), colClasses = c("NULL", rep(NA,7)))
MeterData <- read.csv(paste0(DirFinal[user], "/MeterData", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA, 31)))
MeterUnits <- read.csv(paste0(DirFinal[user], "/MeterUnits", UserInputsAll[nrow(UserInputsAll), 1], ".csv"))
NAcount <- read.csv(paste0(DirFinal[user], "/NACount", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA,5)))
NAcount$Date <- as.Date(NAcount$Date)

ColNames <- c("Date","SolRad","Precip","LightningAct","LightningDist","WindDir","WindSpeed",
              "GustSpeed","AirTemp","VaporPr","AtmosPr","XLevel","YLevel","MaxPrecip",
              "SensorTemp","VPD","BatPct","BatVolt","RefPr","LogTemp", "sFlag", 
              "lFlag", "TempFlag","SolFlag", "AtmFlag", "Date_Format", "DOY", "DecYear", "Year", "Hour", "Minute")


# Create total NA variable to help keep track of sensor's QC tactics
total_NA <- as.numeric(sum(NAcount[,5]))

# Reading in most recent data
# Character string of Date of Last Download -> change this every time
#   Make sure it is the format DayMonYear-Time.csv (ex: 07Jan21-1510.csv)
#   This should match the name of the file for the data on Google Drive
if (is.character(UserInputs[1,3])){
  DOLD <- UserInputs[1,3]
} else{
  print("DOLD must be a character string of the date of last downlaod.
        It needs to have the form DayMonYear-Time.csv (ex: 07Jan21-1510.csv). Try again.")
}

# Read in the csv, skipping the first three columns
print("Reading in the new data")
NewMeterData <- read.csv(paste0(DirMeter[user], DOLD), header = FALSE, skip = 3,
                         na.strings = "#N/A")
# Add flag columns
NewMeterData <- add_column(.data = NewMeterData, sFlag = NA, lFlag = NA, TempFlag = NA,
                           SolFlag = NA, AtmFlag = NA)

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
  NAcount[i,1] <<- mdy_hm(Date)
  NAcount[i,2] <<- as.numeric(sum(is.na(NewMeterData$SolRad)))
  NAcount[i,3] <<- as.numeric(sum(is.na(NewMeterData$WindSpeed)))
  NAcount[i,4] <<- as.numeric(sum(is.na(NewMeterData$AirTemp)))
  NAcount[i,5] <<- sum(NAcount[i,2:4])
}

# Use function
print("Counting the total NA values in the new data")

if (is.character(UserInputs[1,4])){
  CountNA(UserInputs[1,4])
} else{
  print("NADate must be a character string of the date of last downlaod.
        It needs to have the form 'Month/Day/Year Time' (ex: 2/26/21 12:00). Try again.")
}


# Adding flags for level
print("Adding flag for errors with the level.")
for (i in 1:nrow(NewMeterData)){
  NewMeterData$lFlag[i] <- ifelse(NewMeterData[i, "XLevel"]>2 | NewMeterData[i, "XLevel"]<(-2)
                               | NewMeterData[i, "YLevel"]>2 | NewMeterData[i, "YLevel"]<(-2),
                               "X", NA)
}

# Adding flag for snow
# Start and end dates for period with snow on sensor 
# Snow flag function
SnowFlag <- function(start_date, end_date, tz){
  sFlag1 = rep(NA, nrow(NewMeterData))
  for (i in 1:length(start_date)){
    sFlag1 <- ifelse(NewMeterData$Date_Format >= mdy_hm(start_date[i]) & 
                     NewMeterData$Date_Format <= mdy_hm(end_date[i]), 
                     1, sFlag1)
      
  }
  NewMeterData$sFlag <<- sFlag1
}

# Use Function
print("Adding flag for periods with snow/ice")
if (is.character(UserInputs[1,5]) & is.character(UserInputs[1,6]) & is.character(UserInputs[1,7])){
  SnowFlag(UserInputs[1,5], UserInputs[1,6], UserInputs[1,7])
} 
  else if (is.na(UserInputs[1,5]) & is.na(UserInputs[1,6]) & is.character(UserInputs[1,7])){
    SnowFlag(UserInputs[1,5], UserInputs[1,6], UserInputs[1,7])
  }
  else{
    print("SnowStart and SnowEnd must be a character string of the date of the start
          and end of the period where the sensor was compromised. It needs to have the 
          form 'Month/Day/Year Time' (ex: 2/26/21 12:00). Time zone must also be 
          a character string. Try again.")
}


# Adding flag for extreme temp values
print("Adding flag for extreme values.")
for (i in 1:nrow(NewMeterData)){
  NewMeterData$TempFlag[i] <- ifelse(NewMeterData[i, "AirTemp"]>100 | NewMeterData[i, "AirTemp"]<(-100),
                                  "X", NA)
}

# Adding flag for extreme solar values
for (i in 1:nrow(NewMeterData)){
  NewMeterData$SolFlag[i] <- ifelse(NewMeterData[i, "SolRad"]<0,
                                     "X", NA)
}

# Adding flag for extreme temp values
for (i in 1:nrow(NewMeterData)){
  NewMeterData$AtmFlag[i] <- ifelse(NewMeterData[i, "AtmosPr"]>150 | NewMeterData[i, "AtmosPr"]<(50),
                                     "X", NA)
}

# Combining new meter data with larger data frame
print("Combining the new and old data frames.")
MeterData <- rbind(MeterData, NewMeterData)

# Getting rid of overlap
MeterData <- MeterData[!duplicated(MeterData$Date), ]

# Combining recent user inputs with complete data frame
UserInputsAll <- rbind(UserInputsAll, UserInputs)

# Saving all files back into Google Drive
print("Saving files to Google Drive.")
# Meter data
write.csv(MeterData, paste0(DirFinal[user], "/MeterData", UserInputs[1, 1], ".csv"))
# Meter unit data
# move to top -- only needs to be run once
write.csv(MeterUnits, paste0(DirFinal[user], "/MeterUnits", UserInputs[1, 1], ".csv"))
# NA Count
write.csv(NAcount, paste0(DirFinal[user], "/NAcount", UserInputs[1, 1], ".csv"))
# User Inputs
write.csv(UserInputsAll, paste0(DirFinal[user], "/UserInputsAll", UserInputs[1, 1], ".csv"))
}

print("All done! Double check that everything looks good in the files.")

# TO DO:
# test with errors
# write TOMST script
#   adjust for GMT / daylight savings time
#   naming scheme for files
#   download from manual date -> correct for overlap in same day obs
#   update instruction sheet with TOMST stuff

