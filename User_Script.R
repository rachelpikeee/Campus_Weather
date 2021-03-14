# USER SCRIPT FOR DOWNLOADING DATA

# Creating user numbers for each person
Users = c(1, # Rachel
          2) # Professor Kropp 

# File path for data_organize code
DirCode = c("/Users/rachelpike/Desktop/GitHub/Campus_Weather",
            "")

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

# Creating user input data frame
UserInputs <- data.frame(matrix(ncol = 7, nrow = 0))
UserCols <- c("Version", "InitialRunFlag", "DOLD", "NADate", "SnowStart", "SnowEnd", "TZ")
colnames(UserInputs) <- UserCols

# UPDATE INPUTS HERE!!!!
# Version: This is the title of this version of data. Can be anything, but 
#          could follow format 1.1, or v1, v2.1, etc. 
UserInputs[1,1] <- "v3"
# InitialRunFlag: TRUE or FALSE, make TRUE if this is the first time the script is
#                 run, otherwise put false
UserInputs[1,2] <- FALSE
# DOLD: Date of last download, this is to read in the data, make sure it is in the
#       format format DayMonYear-Time.csv (ex: 07Jan21-1510.csv). This should 
#       match the name of the file for the data on Google Drive.
UserInputs[1,3] <- "26Feb21-1351.csv"
# NADate: This is the same date as day of last download. It will go into the data
#         frame that keeps track of NA values. The format for this date is 
#         mm/dd/yy hh:mm (ex: 12/11/20 14:30)
UserInputs[1,4] <- "02/26/21 13:51"
# SnowStart: If in your field notes, you indicate a period where the sensor was 
#            covered by snow or ice, this is the start date for that period. The
#            format for this date is mm/dd/yy hh:mm (ex: 12/11/20 14:30)
UserInputs[1,5] <- NA
# SnowEnd: If in your field notes, you indicate a period where the sensor was 
#            covered by snow or ice, this is the end date for that period. The
#            format for this date is mm/dd/yy hh:mm (ex: 12/11/20 14:30)
UserInputs[1,6] <- NA
# TZ: This is the time zone for the observations. Should be either "EST" or "EDT"
#     depending on daylight savings. Between March-November, use EDT.
UserInputs[1,7] <- "EST"


# Run Data_Organize script
source(paste0(DirCode[user], "/Data_Organize.R"))


# TO DO:
# tests for mistakes
# print errors as the script runs

