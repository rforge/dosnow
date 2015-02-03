library(doSNOW)
library(tcltk)

cl <- makeSOCKcluster(3)
registerDoSNOW(cl)

pb <- txtProgressBar(max=100, style=3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress=progress)
r <- foreach(i=1:100, .options.snow=opts) %dopar% {
  Sys.sleep(1)
  sqrt(i)
}
close(pb)

pb <- tkProgressBar(max=100, title="doSNOW Progress Bar Test")
progress <- function(n, tag) setTkProgressBar(pb, n,
                label=sprintf("last completed task: %d", tag))
opts <- list(progress='progress')
r <- foreach(i=1:100, .options.snow=opts) %dopar% {
  Sys.sleep(1)
  sqrt(i)
}
close(pb)

progress <- function() cat('.')
opts <- list(progress='progress')
r <- foreach(i=1:50, .options.snow=opts) %dopar% {
  Sys.sleep(0.5)
  sqrt(i)
}
cat('\n')

progress <- function(n, tag) cat(sprintf('Task %d completed\n', tag))
opts <- list(progress=progress)
r <- foreach(i=1:10, .options.snow=opts) %dopar% {
  Sys.sleep(10 - i)
  sqrt(i)
}

progress <- function(n, tag) stop(tag)
opts <- list(progress='progress')
r <- foreach(i=1:10, .options.snow=opts) %dopar% {
  Sys.sleep(10 - i)
  sqrt(i)
}

stopCluster(cl)
