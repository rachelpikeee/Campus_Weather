library(dplyr)
library(tidyr)
library(lubridate)
library(naniar)
library(tibble)

# Started 2/17/2021
# Script to read in, clean, and organize campus weather data from TOMST sensor

#### Setting up directories

# Creating user numbers for each person
Users = c(1, # Rachel
          2) # Professor Kropp 

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
  # Creating large data frame for all data from soil sensor                       "Shake", "Error")
  
  # Create empty data frame and rename columns
  TomstSData <- data.frame(matrix(ncol = length(TomstSColNames), nrow = 0))
  colnames(TomstSData) <- TomstSColNames
  
  
  # Creating data frame to keep track of units for Soil Data
  TomstSUnits <- data.frame(TomstSColNames)
  TomstSUnits$Units <- c("Date Chr", "TZ Chr", "˚C", "˚C", "˚C", NA,
                        NA, NA, NA, "Date Time", "Day", "Num", 
                        "Year", "Hour", "Minute")
  colnames(TomstSUnits) <- c("Measurement", "Units")
  
  # Creating large data frame for all data from .5m sensor 
  # Create empty data frame and rename columns
  Tomst5mData <- data.frame(matrix(ncol = length(Tomst5mColNames), nrow = 0))
  colnames(Tomst5mData) <- Tomst5mColNames
  
  
  # Creating data frame to keep track of units for Soil Data
  Tomst5mUnits <- data.frame(Tomst5mColNames)
  Tomst5mUnits$Units <- c("Date Chr", "TZ Chr", "˚C", NA, NA, NA, "Date Time",
                          "Day", "Num", "Year", "Hour", "Minute")
  colnames(Tomst5mUnits) <- c("Measurement", "Units")
  
  # Creating large data frame for all data from .5m sensor 
  # Create empty data frame and rename columns
  Tomst25mData <- data.frame(matrix(ncol = length(Tomst25mColNames), nrow = 0))
  colnames(Tomst25mData) <- Tomst25mColNames
  
  # Creating data frame to keep track of units for .25m Data
  Tomst25mUnits <- data.frame(Tomst25mColNames)
  Tomst25mUnits$Units <- c("Date Chr", "TZ Chr", "˚C", NA, NA, NA, "Date Time",
                           "Day", "Num", "Year", "Hour", "Minute")
  colnames(Tomst25mUnits) <- c("Measurement", "Units")
  
  # Creating data frame for user inputs
  UserInputsAll <- data.frame(matrix(ncol = 7, nrow = 0))
  UserCols <- c("Version", "InitialRunFlag", "DOLD", "NADate", "SnowStart", "SnowEnd", "TZ")
  colnames(UserInputsAll) <- UserCols
  
} else {
  
  #### RUN EVERY TIME NEW DATA IS DOWNLOADED ----
  # Reading in old data to make sure global environment is up to date
  # CHANGE THE VERSION IN THE USER INPUTS ALL FILE TO MOST RECENT IN THE FOLDER
  UserInputsAll <- read.csv(paste0(DirFinal[user], "/UserInputsAllv5.csv"), colClasses = c("NULL", rep(NA,7)))
  TomstSData <- read.csv(paste0(DirFinal[user], "/TomstSData", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA, 15)))
  Tomst5mData <- read.csv(paste0(DirFinal[user], "/Tomst5mData", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA, 12)))
  Tomst25mData <- read.csv(paste0(DirFinal[user], "/Tomst25mData", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA, 12)))
  TomstSUnits <- read.csv(paste0(DirFinal[user], "/MeterUnits", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", "NULL","NULL", NA, NA))
  Tomst5mUnits <- read.csv(paste0(DirFinal[user], "/MeterUnits", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", "NULL","NULL", NA, NA))
  Tomst25mUnits <- read.csv(paste0(DirFinal[user], "/MeterUnits", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", "NULL","NULL", NA, NA))
  
  
  
  # 
  TomstSColNames <- c("Date", "TZ", "Temp1", "Temp2", "Temp3", "SoilMoist",
                "Shake", "Error","TempFlag","Date_Format", "DOY", "DecYear", 
                "Year", "Hour", "Minute")
  
  Tomst5mColNames <- c("Date", "TZ", "Temp1","Shake", "Error","TempFlag",
                       "Date_Format", "DOY","Year", "Hour", "Minute", "DecYear")

  Tomst25mColNames <- c("Date", "TZ", "Temp1","Shake", "Error","TempFlag",
                        "Date_Format", "DOY","Year", "Hour", "Minute", "DecYear")  
  # Reading in most recent data
  # Character string of Date of Last Download -> change this every time
  #   Make sure it is the format DayMonYear-Time.csv (ex: 07Jan21-1510.csv)
  #   This should match the name of the file for the data on Google Drive
  if (is.character(UserInputs[1,3])){
    DOLD <- UserInputs[1,3]
  } else{
    print("DOLD must be a character string of the date of last downlaod.
        It needs to have the form DayMonYear-Time (ex: 07Jan21-1510). Try again.")
  }

  # Read in the SOIL csv, skipping first column
  print("Reading in the new soil data")
  NewTomstSData <- read.table(paste0(DirTOMST[user], "Soil-", DOLD), sep =";", header = FALSE, colClasses = c("NULL", rep(NA,8)))
  
  # Read in the .5m csv, skipping first column
  print("Reading in the new .5m data")
  NewTomst5mData <- read.table(paste0(DirTOMST[user], "5m-", DOLD), sep =";", header = FALSE, colClasses = c("NULL", rep(NA,8)))
  
  # Read in the .25m csv, skipping first column
  print("Reading in the new .25m data")
  NewTomst25mData <- read.table(paste0(DirTOMST[user], "25m-", DOLD), sep =";", header = FALSE, colClasses = c("NULL", rep(NA,8)))

  # Getting rid of three middle columns for Thermologger Data
  NewTomst5mData <- NewTomst5mData[,-c(4:6)]
  NewTomst25mData <- NewTomst25mData[,-c(4:6)]
  
  # Getting rid of data before installation - ONLY UNCOMMENT IF YOU RE READ IN
  #   ALL DATA
  # NewTomstSData <- NewTomstSData[-c(1:2754), ]
  # NewTomst5mData <- NewTomst5mData[-c(1:4513), ]
  # NewTomst25mData <- NewTomst25mData[-c(1:2754), ]

  # Add flag columns
  NewTomstSData <- add_column(.data = NewTomstSData, TempFlag = NA)
  NewTomst5mData <- add_column(.data = NewTomst5mData,TempFlag = NA)
  NewTomst25mData <- add_column(.data = NewTomst25mData, TempFlag = NA)
  

  # Adding other date-related colunmns to soil data
  # Column with date in correct format -- NEED TO TEST
  # might not change the physical time
  NewTomstSData$Date_Format <- strptime(NewTomstSData[,1],format="%Y.%m.%d %H:%M", tz = "UTC")
  NewTomstSData$Date_Format <- with_tz(NewTomstSData$Date_Format, "EST")

  # Day of Year columns
  NewTomstSData$DOY <- yday(NewTomstSData$Date_Format)
  # Year column
  NewTomstSData$Year <- year(NewTomstSData$Date_Format)
  # Hour column
  NewTomstSData$Hour <- as.numeric(format(NewTomstSData$Date_Format, "%H"))
  # Minute Column
  NewTomstSData$Minute <- as.numeric(format(NewTomstSData$Date_Format, "%M"))
  # Decimal Year Column
  NewTomstSData$DecYear <- round(NewTomstSData$Year + ((NewTomstSData$DOY - 1 + (NewTomstSData$Hour/24) + 
                                                        (NewTomstSData$Minute/1440))/
                                                       ifelse(leap_year(NewTomstSData$Year),
                                                              366,365)), digits = 6)
  NewTomstSData$Date_Format <- as.character(NewTomstSData$Date_Format)
  
  # Adding other date-related colunmns to .5m data
  # Column with date in correct format -- NEED TO TEST
  NewTomst5mData$Date_Format <- strptime(NewTomst5mData[,1],format="%Y.%m.%d %H:%M", tz = "UTC")
  NewTomst5mData$Date_Format <- with_tz(NewTomst5mData$Date_Format, "EST")
  # Day of Year columns
  NewTomst5mData$DOY <- yday(NewTomst5mData$Date_Format)
  # Year column
  NewTomst5mData$Year <- year(NewTomst5mData$Date_Format)
  # Hour column
  NewTomst5mData$Hour <- as.numeric(format(NewTomst5mData$Date_Format, "%H"))
  # Minute Column
  NewTomst5mData$Minute <- as.numeric(format(NewTomst5mData$Date_Format, "%M"))
  # Decimal Year Column
  NewTomst5mData$DecYear <- round(NewTomst5mData$Year + ((NewTomst5mData$DOY - 1 + (NewTomst5mData$Hour/24) + 
                                                            (NewTomst5mData$Minute/1440))/
                                                           ifelse(leap_year(NewTomst5mData$Year),
                                                                  366,365)), digits = 6)
  NewTomst5mData$Date_Format <- as.character(NewTomst5mData$Date_Format)
  
  # Adding other date-related colunmns to .25m data
  # Column with date in correct format -- NEED TO TEST
  NewTomst25mData$Date_Format <- strptime(NewTomst25mData[,1],format="%Y.%m.%d %H:%M", tz = "UTC")
  NewTomst25mData$Date_Format <- with_tz(NewTomst25mData$Date_Format, "EST")
  # Day of Year columns
  NewTomst25mData$DOY <- yday(NewTomst25mData$Date_Format)
  # Year column
  NewTomst25mData$Year <- year(NewTomst25mData$Date_Format)
  # Hour column
  NewTomst25mData$Hour <- as.numeric(format(NewTomst25mData$Date_Format, "%H"))
  # Minute Column
  NewTomst25mData$Minute <- as.numeric(format(NewTomst25mData$Date_Format, "%M"))
  # Decimal Year Column
  NewTomst25mData$DecYear <- round(NewTomst25mData$Year + (((NewTomst25mData$DOY - 1) + (NewTomst25mData$Hour/24) + 
                                                          (NewTomst25mData$Minute/1440))/
                                                         ifelse(leap_year(NewTomst25mData$Year),
                                                                366,365)), digits = 6)
  NewTomst25mData$Date_Format <- as.character(NewTomst25mData$Date_Format)
  
   

  
  # Rename columns
  colnames(NewTomstSData) <- TomstSColNames
  colnames(NewTomst5mData) <- Tomst5mColNames
  colnames(NewTomst25mData) <- Tomst25mColNames
  

  # Adding flag for extreme temp values
  print("Adding flag for extreme values for soil")
  for (i in 1:nrow(NewTomstSData)){
    NewTomstSData$TempFlag[i] <- ifelse(NewTomstSData[i, 3]>100 | NewTomstSData[i, 3]<(-100) |
                                          NewTomstSData[i, 4]>100 | NewTomstSData[i, 4]<(-100) |
                                          NewTomstSData[i, 5]>100 | NewTomstSData[i, 5]<(-100),
                                       "X", NA)
  }
  
  print("Adding flag for extreme values for 5m")
  for (i in 1:nrow(NewTomst5mData)){
    NewTomst5mData$TempFlag[i] <- ifelse(NewTomst5mData[i, 3]>100 | NewTomst5mData[i, 3]<(-100),
                                        "X", NA)
  }
  
  print("Adding flag for extreme values for 5m")
  for (i in 1:nrow(NewTomst25mData)){
    NewTomst25mData$TempFlag[i] <- ifelse(NewTomst25mData[i, 3]>100 | NewTomst25mData[i, 3]<(-100),
                                         "X", NA)
  }
  
  
  # Combining new Tomst Soil data with larger data frame
  print("Combining the new and old soil data frames.")
  TomstSData <- rbind(TomstSData, NewTomstSData)
  
  # Getting rid of overlap
  TomstSData <- TomstSData[!duplicated(TomstSData$Date), ]
  
  # Combining new Tomst .5m data with larger data frame
  print("Combining the new and old .5m data frames.")
  Tomst5mData <- rbind(Tomst5mData, NewTomst5mData)
  
  # Getting rid of overlap
  Tomst5mData <- Tomst5mData[!duplicated(Tomst5mData$Date), ]
  
  # Combining new Tomst .25m data with larger data frame
  print("Combining the new and old .25m data frames.")
  Tomst25mData <- rbind(Tomst25mData, NewTomst25mData)
  
  # Getting rid of overlap
  Tomst25mData <- Tomst25mData[!duplicated(Tomst25mData$Date), ]
  
  
  # Combining recent user inputs with complete data frame
  UserInputsAll <- rbind(UserInputsAll, UserInputs)
  # Getting rid of overlap
  UserInputsAll <- UserInputsAll[!duplicated(UserInputsAll$Version), ]
  
  
  # Saving all files back into Google Drive
  print("Saving files to Google Drive.")
  # Soil data
  write.csv(TomstSData, paste0(DirFinal[user], "/TomstSData", UserInputs[1, 1], ".csv"))
  # Soil unit data
  write.csv(TomstSUnits, paste0(DirFinal[user], "/TomstSUnits", UserInputs[1, 1], ".csv"))
  # .5m data
  write.csv(Tomst5mData, paste0(DirFinal[user], "/Tomst5mData", UserInputs[1, 1], ".csv"))
  # .5m unit data
  write.csv(Tomst5mUnits, paste0(DirFinal[user], "/Tomst5mUnits", UserInputs[1, 1], ".csv"))
  # Soil data
  write.csv(Tomst25mData, paste0(DirFinal[user], "/Tomst25mData", UserInputs[1, 1], ".csv"))
  # Soil unit data
  write.csv(Tomst25mUnits, paste0(DirFinal[user], "/Tomst25mUnits", UserInputs[1, 1], ".csv"))
  # User Inputs
  write.csv(UserInputsAll, paste0(DirFinal[user], "/UserInputsAll", UserInputs[1, 1], ".csv"))
}

print("All done! Double check that everything looks good in the files.")

# TO DO:
#   commenting code for audience that is new to coding 
#   double check that temps from TOMST match meter data

