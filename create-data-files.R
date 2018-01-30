require(data.table)

unzip("data/export-150817.zip", exdir="unpacked")
unzip("data/export-171017.zip", exdir="unpacked")
unzip("data/export-300118.zip", exdir="unpacked")

readdata <- function(f) {
  fread(f, select=c(1), col.names=c("datetime"))
}

start <- rbindlist(lapply(list.files(path="unpacked", pattern="start.csv", full.names = TRUE, recursive = TRUE), readdata))
expressway <- rbindlist(lapply(list.files(path="unpacked", pattern="expressway.csv", full.names = TRUE, recursive = TRUE), readdata))
end <- rbindlist(lapply(list.files(path="unpacked", pattern="end", full.names = TRUE, recursive = TRUE), readdata))
