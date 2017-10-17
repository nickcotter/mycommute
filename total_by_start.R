# plot total journey time by start time

png(file="total_by_start.png")
p <- ggplot(journeys, aes(StartTime, Total)) + geom_point() + geom_smooth(method="lm")
print(p)
dev.off()