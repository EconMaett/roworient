# 09 Row-wise mean or sum ----

# For rowSums(), mtcars |> mutate(rowsum = pmap_dbl(., sum)) works but what is
# a tidy oneliner for mean() or sd() per row?

library(tidyverse)

df <- dplyr::tribble(
  ~ name, ~ t1, ~ t2, ~ t3,
  "Abby", 1, 2, 3,
  "Bess", 4, 5, 6,
  "Carl", 7, 8, 9
)

# Use `rowSums()` and `rowMeans()` inside of `dplyr::mutate()` ----

# One "tidy version" of rowSums() is to just stick to rowSums() inside of a tidyverse
# pipeline.
# This works because rowSums(), rowMeans() etc. have a method for `data.frame`s.
df %>% 
  mutate(t_sum = rowSums(select_if(.tbl = ., .predicate = is.numeric)))

df %>%
  mutate(t_avg = rowMeans(select(., -name)))

# Above we demonstrate the use of `select(., SOME_EXPRESSION)`.
# This comes up a lot in row-wise work with data frames, because 
# the variables inside a data frame can be of different types.


## Devil's Advocate: can't you just use `rowMeans()` alone? ----

# If rowMeans() gets the job done, why use pmap() inside mutate()?

# There are a few reasons:
# - You might want to take the median or standard deviation instead of a mean or a sum.
# - You might have several variables beside "name" that need to be retained, but should not
#   be forwarded to `rowMeans()`. 


## How to use an arbitrary function inside `purrr::pmap()`? ----

# What if you need to apply `foo()` to rows and the universe has not provided a 
# special-purpose `rowFoos()` function?
# Now you need to use `pmap()` ro a type-stable variant, with `foo()` playing the role
# of `.f`.
# This works especially well with `sum()`:
df |> 
  mutate(t_sum = pmap_dbl(.l = list(t1, t2, t3), .f = sum))

df %>% 
  mutate(t_sum = pmap_dbl(.l = select(., starts_with("t")), .f = sum))
# Note that if you want to refer to the original data frame "df"
# later in the pipe with the dot operator ( . ), you need to use
# the magrittr-pipe ( %>% ) instead of the base-pipe ( |> ).

# Look at the signature of `sum()` versus a few other numerical summaries:
# sum(..., na.rm = TRUE)
# mean(x, trim = 0, na.rm = FALSE)
# median(x, na.rm = FALSE, ...)
# var(x, y = NULL, na.rm = FALSE, use)

# `sum()` is especially `pmap()`-friendly because it takes an ellipsis ( `...` )
# as its **primary** argument.

# In contrast, `mean()` takes a vector `x` as primary argument.

# The "purrr" package has a family of `lift_*()` functions that help you ocnvert
# between these two forms.

# Here, we apply `purrr::lift_vd()` to `mean()`, so we can use it inside of `pmap()`.
# The "vd" says I want to convert a function that takes a **v**ector into one
# that takes **d**ots.
df |> 
  mutate(t_avg = pmap_dbl(.l = list(t1, t2, t3), .f = lift_vd(mean)))
# `lift_vd()` is deprecated.

?purrr::lift_vd

# Try it without lifting:
df |> 
  mutate(t_avg = pmap_dbl(.l = list(t1, t2, t3), .f = lift_vd(mean)))
# Works perfectly.


## Strategies that use reshaping and joins ----

### Gather, group, summarise ----
(s <- df |> 
   gather(key = "time", value = "val", starts_with("t")) |> 
   group_by(name) |> 
   summarise(t_avg = mean(val), t_sum = sum(val))) 

df |> 
  left_join(s)


### Group then summarise, with explicit `c()` ----
(s <- df |> 
   group_by(name) |> 
   summarise(t_avg = mean(c(t1, t2, t3))))

df |> 
  left_join(s)


### Nesting ----
(s <- df |> 
   gather(key = "key", value = "value", -name) |> 
   nest(data = -name) |> 
   mutate(
     sum = map(.x = data, .f = "value") |> map_dbl(sum),
     mean = map(.x = data, .f = "value") |> map_dbl(mean)
   ) |> 
   select(-data))


## Yet another way to use `rowMeans()` ----
(s <- df |> 
   column_to_rownames(var = "name") |> 
   rowMeans() |> 
   enframe())

df |> 
  left_join(s)


## Maybe you should use a matrix ----

# If you truly have data where each row is:
# - Identifier for this observational unit
# - Homogeneous vector of length n for the unit
# then  you do want to use a matrix with row names.
m <- matrix(
  1:9,
  byrow = TRUE,
  nrow = 3,
  dimnames = list(c("Abby", "Bess", "Carl"), paste0("t", 1:3))
)

m

cbind(m, rowsum = rowSums(m))

cbind(m, rowmean = rowMeans(m))

# END