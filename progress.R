library(doSNOW)
library(tcltk)

cl <- makeSOCKcluster(3)
registerDoSNOW(cl)

pb <- tkProgressBar(max=100)
progress <- function(n) setTkProgressBar(pb, n)
opts <- list(progress=progress)
r <- foreach(i=1:100, .options.snow=opts) %dopar% {
  Sys.sleep(3)
  sqrt(i)
}
close(pb)

progress <- function() cat('.')
opts <- list(progress=progress)
r <- foreach(i=1:100, .options.snow=opts) %dopar% {
  Sys.sleep(3)
  sqrt(i)
}
cat('\n')

progress <- function(n, tag) cat(sprintf('Task %d completed\n', tag))
opts <- list(progress=progress)
r <- foreach(i=1:100, .options.snow=opts) %dopar% {
  Sys.sleep(i %% 10)
  sqrt(i)
}

progress <- function(n, tag) stop(tag)
opts <- list(progress=progress)
r <- foreach(i=1:100, .options.snow=opts) %dopar% {
  Sys.sleep(i %% 10)
  sqrt(i)
}

stopCluster(cl)
