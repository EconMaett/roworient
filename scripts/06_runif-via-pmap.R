# 06 - Generate data from different distributions via `purrr::pmap()` ----

## Uniform[min, max] via `runif()` ----

# Consider:
# runif(n, min = 0, max = 1)

# Want to do this for several triples of (n, min, max).

# Store each triple as a row in a data frame.

# Now iterate over the rows.

library(tidyverse)

# Notice how df's variable names are the same as runif()'s argument names.
# Do this when you can!
df <- tribble(
  ~ n, ~ min, ~ max,
  1L,   0,    1,
  2L,  10,  100,
  3L, 100, 1000
)
df
#     n   min   max
# <int> <dbl> <dbl>
#    1     0     1
#    2    10   100
#    3   100  1000

# Set seed to make this repeatedly random.
set.seed(123)

# Practice on single rows.
(x <- df[1, ])
#    n   min   max
# <int> <dbl> <dbl>
#    1     0     1

runif(n = x$n, min = x$min, max = x$max)
# 0.2875775

x <- df[2, ]
runif(n = x$n, min = x$min, max = x$max)
# 80.94746 46.80792

x <- df[3, ]
runif(n = x$n, min = x$min, max = x$max)
# 894.7157 946.4206 141.0008


# Think out loud in pseudo-code.

## x <- df[i, ]
## runif(n = x$n, min = x$min, max = x$max)

## runif(n = df$n[i], min = df$min[i], max = df$max[i])
## runif with all args from the i-th row of df

# Just. Do. It. with `purrr::pmap()`.
set.seed(123)
purrr::pmap(.l = df, .f = runif)
# [[1]]
# [1] 0.2875775
# 
# [[2]]
# [1] 80.94746 46.80792
# 
# [[3]]
# [1] 894.7157 946.4206 141.0008


## Finessing variable and argument names ----
# Question: What if you can't arrange it so that variable names and argument names are the same?
foofy <- tibble(
  alpha = 1:3,
  beta = c(0, 10, 100),
  gamma = c(1, 100, 1000)
)

foofy

# Answer: Rename the variables on-the-fly, on the way in:
set.seed(123)
foofy |> 
  rename(n = alpha, min = beta, max = gamma) |> 
  pmap(.f = runif)

# Answer: Write a wrapper around runif() to say how df vars <-> runif args

## wrapper option #1:
## ARGNAME = l$VARNAME
my_runif <- function(...) {
  l <- list(...)
  runif(n = l$alpha, min = l$beta, max = l$gamma)
}

set.seed(123)
purrr::pmap(.l = foofy, .f = my_runif)

## wrapper option #2:
my_runif <- function(alpha, beta, gamma, ...) {
  runif(n = alpha, min = beta, max = gamma)
}

set.seed(123)
purrr::pmap(.l = foofy, .f = my_runif)


# You can use `..i` to refer to input by position.
set.seed(123)
pmap(.l = foofy, .f = ~ runif(n = ..1, min = ..2, max = ..3))

# Use this with *extreme caution*. Easy to shoot yourself in the foot.


## Extra variables in the data frame ----

# What if a data frame includes variables that should not be passed to `.f()`?
df_oops <- tibble(
  n = 1:3,
  min = c(0, 10, 100),
  max = c(1, 100, 1000),
  oops = c("please", "ignore", "me")
)

df_oops

# This will not work!
set.seed(123)
try(purrr::pmap(.l = df_oops, .f = runif))
# Error : In index: 1. Caused by error in `.f()`: unused argument 
# (oops = .l[[4]][[i]])

# Answer: Use `dplyr:.select()` to limit the variables passed to `purrr::pmap()`.
set.seed(123)
df_oops |> 
  select(n, min, max) |> 
  pmap(.f = runif)

set.seed(123)
df_oops |> 
  select(-oops) |> 
  pmap(.f = runif)


## Add the generated data to the data frame as a list-column ----
set.seed(123)
(df_aug <- df %>%
    mutate(data = pmap(., runif)))
# Note: This works with the %>% pipe, but not with the |> pipe!
View(df_aug)

# What about computing within a data frame, in the presence of the complications discussed above?
# Use `list()` in the place of the dot (.) placeholder above to select the target
# variables and, if necessary, map() variable names to argument names.

# How to address variable anmes != argument names:
foofy <- tibble(
  alpha = 1:3,
  beta = c(0, 10, 100),
  gamma = c(1, 100, 1000)
)

set.seed(123)
foofy %>%
  mutate(data = pmap(.l = list(n = alpha, min = beta, max = gamma), .f = runif))

# How to address the presence of "extra variables with either an inclusion or exclusion mentality?
df_oops <- tibble(
  n = 1:3,
  min = c(0, 10, 100),
  max = c(1, 100, 1000),
  oops = c("please", "ignore", "me")
)


set.seed(123)
df_oops %>%
  mutate(data = pmap(.l = list(n, min, max), .f = runif))

df_oops %>% 
  mutate(data = pmap(.l = select(., -oops), .f = runif))


# END