# 04 Working with non-vectorized functions ----

## purrr::map() can be used to work with functions that aren't vectorized:
df_list <- list(
  iris = head(iris, n = 2),
  mtcars = head(mtcars, n = 3)
)

df_list

# This does not work.
# nrow() expects a single data frame as input:
nrow(df_list)
# NULL

# purrr::map() applies nrow() to each element of df_list:
library(purrr)
map(.x = df_list, .f = nrow)
# $iris
# 2

# $mtcars
# 3

# Different calling styles make sense in more complicated situations.
map(.x = df_list, .f = ~ nrow(.x))

df_list |> 
  map(.f = nrow)

# If you know what the return type is, or should be, use a type-specific variant of map():
map_int(.x = df_list, .f = ~ nrow(.x))
# iris mtcars
# 2    3
# map_int() returned a named vector of integer elements.

# END