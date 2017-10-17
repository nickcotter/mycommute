# fit total vs start time for different days of the week

png(file="total_by_start_dow.png")
p <- ggplot(journeys, aes(StartTime, Total)) + geom_point() + geom_smooth(method="lm") + facet_grid(.~dow)
print(p)
dev.off()