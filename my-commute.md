---
title: "My Commute"
author: "Nick Cotter"
date: "10 April 2018"
output:
  html_document:
    keep_md: yes
---



## Libraries


```r
require(dplyr)
require(lubridate)
require(data.table)
require(ggplot2)
```

## TODO: summary

## TODO: data structure and point map


## Load The Data


```r
unzip("data/export-150817.zip", exdir="unpacked")
unzip("data/export-171017.zip", exdir="unpacked")
unzip("data/export-300118.zip", exdir="unpacked")
```

## Preprocess The Data


```r
# function to extract date & time from raw data
readdata <- function(f) {
  fread(f, select=c(1), col.names=c("datetime"))
}

# create data frames for start, express way and end points reached
start <- rbindlist(lapply(list.files(path="unpacked", pattern="start.csv", full.names = TRUE, recursive = TRUE), readdata))
expressway <- rbindlist(lapply(list.files(path="unpacked", pattern="expressway.csv", full.names = TRUE, recursive = TRUE), readdata))
end <- rbindlist(lapply(list.files(path="unpacked", pattern="end", full.names = TRUE, recursive = TRUE), readdata))

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

# combine into one tidy data set where each row is a journey

# join together by date
start_to_expressway <- inner_join(start, expressway, by=c("Date" = "Date"), suffix=c(".start", ".xway"))
journeys <- inner_join(start_to_expressway, end, by=c("Date" = "Date"))
colnames(journeys) <- c("Date", "Start", "ExpressWay", "End")

# TODO explain outliers
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
```

## Plots

# Total Journey Time By Start Time


```r
ggplot(journeys, aes(StartTime, Total)) + geom_point() + geom_smooth(method="lm") + scale_y_continuous(expand = c(0,0))
```

![](my-commute_files/figure-html/totalbystart-1.png)<!-- -->


# Total Journey Time By Start Time For Each Day Of The Week


```r
ggplot(journeys, aes(StartTime, Total)) + geom_point() + geom_smooth(method="lm") + facet_grid(.~dow) + scale_y_continuous(expand = c(0,0))
```

![](my-commute_files/figure-html/totalbystartdow-1.png)<!-- -->

# Express Way To EndTtime Versus Start Time


```r
ggplot(journeys, aes(StartTime, ExpressWayToEnd)) + geom_point() + geom_smooth(method="lm") + scale_y_continuous(expand = c(0,0))
```

![](my-commute_files/figure-html/expresswaybystart-1.png)<!-- -->
