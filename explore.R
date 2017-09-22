library("dplyr")
library("lubridate")
library(data.table)
library(ggplot2)

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

# remove journeys longer than 90 minutes (these usually involve errands on the way to work)
journeys <- subset(journeys, journeys$Total <= 90)


# add start time for convenience
journeys$StartTime <- as.numeric(journeys$Start-trunc(journeys$Start, "days"))

# add day of week as ordered factor
journeys$dow <- factor(weekdays(journeys$Date), levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))

# plot total journey time by date


# plot total journey time by start time
ggplot(journeys, aes(StartTime, Total)) + geom_point() + geom_smooth(method="lm")


# fit total vs start time for different days of the week
ggplot(journeys, aes(StartTime, Total)) + geom_point() + geom_smooth(method="lm") + facet_grid(.~dow)


# plot total journey time by day of week
#qplot(weekdays(Date), as.numeric(Total), data=journeys, geom="boxplot")



# examples from course
# qplot(displ, hwy, data=mpg, geom=c("point", "smooth"), facets=.~drv)

#g <- ggplot(mpg,aes(displ,hwy))
#g+geom_point()
#g+geom_point() + geom_smooth()
#g+geom_point() + geom_smooth(method="lm")
#g+geom_point() + geom_smooth(method="lm") + facet_grid(.~drv)

# colour by facet
#g+geom_point(size=4, alpha=1/2, aes(color=drv))

## facet grid
#g+geom_point()+facet_grid(drv~cyl, margins = TRUE)

#g+geom_point()+facet_grid(drv~cyl, margins = TRUE) + geom_smooth(method="lm", se=FALSE, size=2, color="black")

#qplot(carat, price, data=diamonds, color=cut) + geom_smooth(method="lm")


#qplot(carat, price, data=diamonds, color=cut, facets=.~cut) + geom_smooth(method="lm")

# boxplot with facets
#ggplot(diamonds, aes(carat, price)) + geom_boxplot() + facet_grid(.~cut)


