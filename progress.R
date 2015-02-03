library(doSNOW)
library(tcltk)

cl <- makeSOCKcluster(3)
registerDoSNOW(cl)
pb <- tkProgressBar(max=100)
progress <- function(n, tag) setTkProgressBar(pb, n)
opts <- list(progress=progress)

r <- foreach(i=1:100, .options.snow=opts) %dopar% {
  Sys.sleep(3)
  sqrt(i)
}

close(pb)
stopCluster(cl)
