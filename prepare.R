<<<<<<< HEAD:prepare.R
require(dplyr)
require(plyr)
require(lubridate)
require(data.table)
require(ggplot2)
=======
library(dplyr)
library(lubridate)
library(data.table)
library(ggplot2)
>>>>>>> 770897df4c306da88466f7ccb89dc5832003af9a:explore.R

august_start <- fread("data/august/start.csv", select=c(1), col.names=c("datetime"))
august_expressway <- fread("data/august/expressway.csv", select=c(1), col.names=c("datetime"))
august_end <- fread("data/august/end.csv", select=c(1), col.names=c("datetime"))


october_start <- fread("data/october/start.csv", select=c(1), col.names=c("datetime"))
october_expressway <- fread("data/october/expressway.csv", select=c(1), col.names=c("datetime"))
october_end <- fread("data/october/end.csv", select=c(1), col.names=c("datetime"))


start <- rbindlist(list(august_start, october_start));
expressway <- rbindlist(list(august_expressway, october_expressway));
end <- rbindlist(list(august_end, october_end));


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

# remove outliers (all should be between 6am and 10am) and bad readings
journeys <- subset(journeys, am(journeys$Start) & hour(journeys$Start) > 6 & hour(journeys$Start) < 10 & hour(journeys$End) < 10 & am(journeys$End))
journeys <- subset(journeys, journeys$Start < journeys$End)
journeys <- subset(journeys, journeys$ExpressWay < journeys$End)
journeys <- subset(journeys, journeys$ExpressWay > journeys$Start)

# add segment travel times
journeys$StartToExpressWay <- difftime(journeys$ExpressWay, journeys$Start)
journeys$ExpressWayToEnd <- difftime(journeys$End, journeys$ExpressWay)
journeys$Total <- difftime(journeys$End, journeys$Start)

# remove journeys longer than 90 minutes (these usually involve errands on the way to work)
journeys <- subset(journeys, journeys$Total <= 90)


# add start time for convenience
journeys$StartTime <- as.numeric(journeys$Start-trunc(journeys$Start, "days"))

# add day of week as ordered factor
journeys$dow <- factor(weekdays(journeys$Date), levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))