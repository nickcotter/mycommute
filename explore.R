require("dplyr")
require("lubridate")

# function to turn date string into date
# function to turn date string into time
# > unlist(strsplit("June 06, 2017 at 09:03AM", "at"))

start <- read.csv("data/august/start.csv")
expressway <- read.csv("data/august/expressway.csv")
end <- read.csv("data/august/end.csv")

# convert date into date and time

# remove outliers (all should be between 6am and 10am)



# combine into one tidy data set - match by date
# date
# start time
# express way time
# end time
