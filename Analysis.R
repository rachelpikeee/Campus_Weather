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

# METER 2021
MeterData21 <- MeterData[MeterData$Year == 2021, ]
ggplot(MeterData21, aes(x = DecYear, y = AirTemp))+
  geom_line(col = "Firebrick4")+
  labs(title = "Air Temperature in 2021", subtitle = "Data from METER Sensor",
       y = "Temperature (˚C)", x = "Decimal Year")+
  theme_classic()

# TOMST 2021
Tomst5m21 <- Tomst5mData[Tomst5mData$Year == 2021, ]
colnames(Tomst5m21) <- c("Date", "TZ", "AirTemp","Shake", "Error","TempFlag",
                         "Date_Format", "DOY","Year", "Hour", "Minute", "DecYear")
ggplot(Tomst5m21, aes(x = DecYear, y = AirTemp))+
  geom_line(col = "Deepskyblue3")+
  labs(title = "Air Temperature in 2021", subtitle = "Data from TOMST Sensor",
       y = "Temperature (˚C)", x = "Decimal Year")+
  theme_classic()

# Both on same plot
plot(MeterData21$DecYear, MeterData21$AirTemp,
     type = "l",
     lwd = 2, 
     col =  "tomato3",
     xlab = "Decimal Year",
     ylab = "Temperature (Celsius)",
     main = "Air Temperature in Clinton, NY in 2021",
     sub = "Data collected from Hamilton College weather station")
lines(Tomst5m21$DecYear, Tomst5m21$AirTemp,
      lwd = 2, 
      col = alpha("skyblue", 0.5))
legend("topleft", c("METER Data", "TOMST Data"), col = c("tomato3","skyblue"), lwd = 2, bty="n")

# Looking at weird METER data behavior
MeterDataSub <- MeterData[MeterData$DecYear>2021.16 & MeterData$DecYear<2021.19, ]
TomstDataSub <- Tomst5mData[Tomst5mData$DecYear>2021.16 & Tomst5mData$DecYear<2021.19, ]
# Both on same plot
plot(MeterDataSub$DecYear, MeterDataSub$AirTemp,
     type = "l",
     lwd = 2, 
     col =  "tomato3",
     xlab = "Decimal Year",
     ylab = "Temperature (Celsius)",
     main = "Air Temperature in Clinton, NY in 2021",
     sub = "Data collected from Hamilton College weather station")
lines(TomstDataSub$DecYear, TomstDataSub$Temp1,
      lwd = 2, 
      col = alpha("skyblue", 0.5))
legend("topleft", c("METER Data", "TOMST Data"), col = c("tomato3","skyblue"), lwd = 2, bty="n")

# Plot of solar radiation
plot(MeterData21$DecYear, MeterData21$SolRad,
     type = "l",
     lwd = 2, 
     col =  "tomato3",
     xlab = "Decimal Year",
     ylab = "Solar Radiation (W/m^2)",
     main = "Solar Radiation in Clinton, NY in 2021",
     sub = "Data collected from Hamilton College weather station")

# ggplot version
ggplot(MeterData21, aes(x = DecYear, y = SolRad))+
  geom_line(col = "Deepskyblue3")+
  labs(title = "Solar Radiation in 2021", subtitle = "Data from METER Sensor",
       y = "Solar Radiation (W/m^2)", x = "Decimal Year")+
  theme_classic()

# Plot of precipitation
plot(MeterData21$DecYear, MeterData21$Precip,
     type = "h",
     lwd = 3, 
     col =  "tomato3",
     xlab = "Decimal Year",
     ylab = "Solar Radiation (mm)",
     main = "Solar Radiation in Clinton, NY in 2021",
     sub = "Data collected from Hamilton College weather station")

ggplot(MeterData21, aes(x = DOY, y = Precip))+
  geom_col(col = "Deepskyblue3", fill = "Deepskyblue3")+
  labs(title = "Precipitation in 2021", subtitle = "Data from METER Sensor",
       y = "Precipitation (mm)", x = "Day of Year")+
  theme_classic()
