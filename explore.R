library("dplyr")
library("lubridate")
library(data.table)

# function to turn date string into date
# function to turn date string into time
# > unlist(strsplit("June 06, 2017 at 09:03AM", "at"))

start <- fread("data/august/start.csv", select=c(1))
expressway <- fread("data/august/expressway.csv", select=c(1))
end <- fread("data/august/end.csv", select=c(1))

# column names
colnames(start) <- c("RawDateTime")
colnames(expressway) <- c("RawDateTime")
colnames(end) <- c("RawDateTime")

# convert date into date and time
start$Date <- as.Date(start$RawDateTime, format("%b %d, %Y at %H:%M%p"))
start$DateTime <- as.POSIXct(start$RawDateTime, format="%b %d, %Y at %H:%M%p")
start <- subset(start, select=c(2:3))

expressway$Date <- as.Date(expressway$RawDateTime, format("%b %d, %Y at %H:%M%p"))
expressway$DateTime <- as.POSIXct(expressway$RawDateTime, format="%b %d, %Y at %H:%M%p")
expressway <- subset(expressway, select=c(2:3))

end$Date <- as.Date(end$RawDateTime, format("%b %d, %Y at %H:%M%p"))
end$DateTime <- as.POSIXct(end$RawDateTime, format="%b %d, %Y at %H:%M%p")
end <- subset(end, select=c(2:3))


# combine into one tidy data set - match by date
# date
# start time
# express way time
# end time

# join together by date

start_to_expressway <- inner_join(start, expressway, by=c("Date" = "Date"), suffix=c(".start", ".xway"))
journeys <- inner_join(start_to_expressway, end, by=c("Date" = "Date"))
colnames(journeys) <- c("Date", "Start", "ExpressWay", "End")

# remove outliers (all should be between 6am and 10am)
journeys <- subset(journeys, am(journeys$Start) & hour(journeys$Start) > 6 & hour(journeys$Start) < 10 & hour(journeys$End) < 10 & am(journeys$End))
journeys <- subset(journeys, journeys$Start < journeys$End)

# add segment travel times
journeys$StartToExpressWay <- difftime(journeys$ExpressWay, journeys$Start)
journeys$ExpressWayToEnd <- difftime(journeys$End, journeys$ExpressWay)
journeys$Total <- difftime(journeys$End, journeys$Start)

# plot total journey time by date


# plot total journey time by start time
qplot(as.numeric(Start-trunc(Start, "days")), Total, data=journeys, 
      geom=c("point", "smooth")) + xlab("Start Time") + ylab("Travel Time (minutes)")


# plot total journey time by day of week
#qplot(weekdays(Date), as.numeric(Total), data=journeys, geom="boxplot")