library(doSNOW)

cl <- makeSOCKcluster(3)
registerDoSNOW(cl)
ntasks <- 1e+6
comb <- function(...) {
  gc()
  x <- max(...)
  cat(x, '')
  x
}

r <- foreach(x=irnorm(1e+3, sd=1000, count=ntasks), .init=-Inf,
    .combine='comb', .maxcombine=1001, .inorder=FALSE) %dopar% {
  max(x)
}
print(r)

close(pb)
stopCluster(cl)
