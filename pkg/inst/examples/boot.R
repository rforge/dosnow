library(doSNOW)
cl <- makeSOCKcluster(4)
registerDoSNOW(cl)

junk <- matrix(0, 1000000, 8)
print(object.size(junk))

x <- iris[which(iris[,5] != "setosa"), c(1,5)]

trials <- 10000

ptime <- system.time({
  r <- foreach(icount(trials), .combine=cbind,
               .export='junk') %dopar% {
    ind <- sample(100, 100, replace=TRUE)
    result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
    coefficients(result1)
  }
})[3]
cat('parallel foreach:\n')
print(ptime)

ptime2 <- system.time({
  snowopts <- list(preschedule=TRUE)
  r <- foreach(icount(trials), .combine=cbind,
               .export='junk', .options.snow=snowopts) %dopar% {
    ind <- sample(100, 100, replace=TRUE)
    result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
    coefficients(result1)
  }
})[3]
cat('parallel foreach with prescheduling:\n')
print(ptime2)

ptime3 <- system.time({
  chunks <- getDoParWorkers()
  r <- foreach(n=idiv(trials, chunks=chunks), .combine=cbind,
               .export='junk') %dopar% {
    y <- lapply(seq_len(n), function(i) {
      ind <- sample(100, 100, replace=TRUE)
      result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
      coefficients(result1)
    })
    do.call('cbind', y)
  }
})[3]
cat('chunked parallel foreach:\n')
print(ptime3)

ptime4 <- system.time({
  mkworker <- function(x, junk) {
    force(x)
    force(junk)
    function(i) {
      ind <- sample(100, 100, replace=TRUE)
      result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
      coefficients(result1)
    }
  }
  y <- parLapply(cl, seq_len(trials), mkworker(x, junk))
  r <- do.call('cbind', y)
})[3]
cat('parLapply:\n')
print(ptime4)

stime <- system.time({
  y <- lapply(seq_len(trials), function(i) {
    ind <- sample(100, 100, replace=TRUE)
    result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
    coefficients(result1)
  })
  r <- do.call('cbind', y)
})[3]
cat('sequential lapply:\n')
print(stime)

stime2 <- system.time({
  r <- foreach(icount(trials), .combine=cbind) %do% {
    ind <- sample(100, 100, replace=TRUE)
    result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
    coefficients(result1)
  }
})[3]
cat('sequential foreach:\n')
print(stime2)

stopCluster(cl)
