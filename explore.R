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
colnames(start) <- c("DateTime")
colnames(expressway) <- c("DateTime")
colnames(end) <- c("DateTime")

# convert date into date and time
start$DateTime <- as.Date(start$DateTime, format("%b %d, %Y at %H:%M%p"))

# remove outliers (all should be between 6am and 10am)



# combine into one tidy data set - match by date
# date
# start time
# express way time
# end time
