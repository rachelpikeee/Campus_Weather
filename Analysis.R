# Started 4/21/2021
# Initial Visualizations for Campus Weather Data

library(dplyr)
library(ggplot2)

# Reading in latest versions of data
# CHANGE THE VERSION IN THE USER INPUTS ALL FILE TO MOST RECENT IN THE FOLDER
UserInputsAll <- read.csv(paste0(DirFinal[user], "/UserInputsAllv6.csv"), colClasses = c("NULL", rep(NA,7)))
MeterData <- read.csv(paste0(DirFinal[user], "/MeterData", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA, 31)))
MeterUnits <- read.csv(paste0(DirFinal[user], "/MeterUnits", UserInputsAll[nrow(UserInputsAll), 1], ".csv"))
NAcount <- read.csv(paste0(DirFinal[user], "/NACount", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA,5)))
NAcount$Date <- as.Date(NAcount$Date)
TomstSData <- read.csv(paste0(DirFinal[user], "/TomstSData", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA, 15)))
Tomst5mData <- read.csv(paste0(DirFinal[user], "/Tomst5mData", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA, 12)))
Tomst25mData <- read.csv(paste0(DirFinal[user], "/Tomst25mData", UserInputsAll[nrow(UserInputsAll), 1], ".csv"), colClasses = c("NULL", rep(NA, 12)))

# Plot of temperature data for 2021
MeterData21 <- MeterData[MeterData$Year == 2021, ]
ggplot(MeterData21, aes(x = DecYear, y = AirTemp))+
  geom_line(col = "Firebrick4")+
  labs(title = "Air Temperature in 2021", subtitle = "Data from METER Sensor",
       y = "Temperature (˚C)", x = "Decimal Year")+
  theme_classic()

Tomst5m21 <- Tomst5mData[Tomst5mData$Year == 2021, ]
colnames(Tomst5m21) <- c("Date", "TZ", "AirTemp","Shake", "Error","TempFlag",
                         "Date_Format", "DOY","Year", "Hour", "Minute", "DecYear")
ggplot(Tomst5m21, aes(x = DecYear, y = AirTemp))+
  geom_line(col = "Firebrick4")+
  labs(title = "Air Temperature in 2021", subtitle = "Data from TOMST 0.5m Sensor",
       y = "Temperature (˚C)", x = "Decimal Year")+
  theme_classic()

# Change column name of TOMST to match (?)
ggplot(MeterData21, aes(x = DecYear, y = AirTemp))+
  geom_line(col = "Firebrick4")+
  geom_line(data = Tomst5m21, col = alpha("deepskyblue3", 0.5))+
  labs(title = "Air Temperature in 2021",
       y = "Temperature (˚C)", x = "Decimal Year")+
  theme_classic()
