## ---- echo = TRUE, message = FALSE--------------------------------------------
library(DRR)
set.seed(123)

## ---- echo = TRUE, warning = FALSE, error = FALSE-----------------------------
data(iris)

in_data <- iris[, 1:4]

npoints <- nrow(in_data)
nvars <- ncol(in_data)
for (i in seq_len(nvars)) in_data[[i]] <- as.numeric(in_data[[i]])
my_data <- scale(in_data[sample(npoints), ], scale = FALSE)

## ---- echo = TRUE, results = "hide", warning = FALSE, error = FALSE, message = FALSE----
t0 <- system.time(pca   <- prcomp(my_data, center = FALSE, scale. = FALSE))
t1 <- system.time(drr.1 <- drr(my_data, verbose = FALSE))
t2 <- system.time(drr.2 <- drr(my_data, fastkrr = 2, verbose = FALSE))
t3 <- system.time(drr.3 <- drr(my_data, fastkrr = 5, verbose = FALSE))
t4 <- system.time(drr.4 <- drr(my_data, fastkrr = 2, fastcv = TRUE,
                               verbose = FALSE))

## ---- echo = FALSE, results = "hold"------------------------------------------
pairs(my_data,           gap = 0, main = "iris")
pairs(pca$x,             gap = 0, main = "pca")
pairs(drr.1$fitted.data, gap = 0, main = "drr.1")
pairs(drr.2$fitted.data, gap = 0, main = "drr.2")
pairs(drr.3$fitted.data, gap = 0, main = "drr.3")
pairs(drr.4$fitted.data, gap = 0, main = "drr.4")

## ---- echo = TRUE, tidy = TRUE------------------------------------------------
rmse <- matrix(NA_real_, nrow = 5, ncol = nvars,
               dimnames = list(c("pca", "drr.1", "drr.2", "drr.3", "drr.4"),
                               seq_len(nvars)))

for (i in seq_len(nvars)){
    pca_inv <-
        pca$x[, 1:i, drop = FALSE] %*%
        t(pca$rotation[, 1:i, drop = FALSE])
    rmse["pca",   i] <-
        sqrt( sum( (
            my_data - pca_inv
        ) ^ 2 ) )
    rmse["drr.1", i] <-
        sqrt( sum( (
            my_data - drr.1$inverse(drr.1$fitted.data[, 1:i, drop = FALSE])
        ) ^ 2 ) )
    rmse["drr.2", i] <-
        sqrt( sum( (
            my_data - drr.2$inverse(drr.2$fitted.data[, 1:i, drop = FALSE])
        ) ^ 2) )
    rmse["drr.3", i] <-
        sqrt( sum( (
            my_data - drr.3$inverse(drr.3$fitted.data[, 1:i, drop = FALSE])
        ) ^ 2) )
    rmse["drr.4", i] <-
        sqrt( sum( (
            my_data - drr.4$inverse(drr.4$fitted.data[, 1:i, drop = FALSE])
        ) ^ 2) )
}

## ---- echo = FALSE------------------------------------------------------------
print(rmse)

## ---- echo = FALSE------------------------------------------------------------
print(rbind(pca = t0, drr.1 = t1, drr.2 = t2, drr.3 = t3, drr.4 = t4)[, 1:3])

