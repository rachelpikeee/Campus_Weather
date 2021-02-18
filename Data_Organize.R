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


#### Reading in Data ----
ColNames <- c("Date",
              "SolRad",
              "Precip",
              "LightningAct",
              "LightningDist",
              "WindDir",
              "WindSpeed",
              "GustSpeed",
              "AirTemp",
              "VaporPr",
              "AtmosPr",
              "XLevel",
              "YLevel",
              "MaxPrecip",
              "SensorTemp",
              "VPD",
              "BatPct",
              "BatVolt",
              "RefPr",
              "LogTemp")
MeterData <- data.frame(matrix(ncol = 20, nrow = 0))
colnames(MeterData) <- ColNames                     

#### Cleaning Data ----


#### Base Analysis of Data ----

#### Metadata ----
UnitInfo <- data.frame()



