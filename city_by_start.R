# express way to end time versus start time

png(file="city_by_start.png")
p <- ggplot(journeys, aes(StartTime, ExpressWayToEnd)) + geom_point() + geom_smooth(method="lm")
print(p)
dev.off()