# 05 - Row-wise thinking vs. column-wise thinking ----

library(tidyverse)

## If you must sweat, compare row-wise work vs. column-wise work ---

# The approach you use in the first example is not always the one that scales up the best.
x <- list(
  list(
    name = "sue",
    number = 1,
    veg = c("onion", "carrot")
  ),
  list(
    name = "doug",
    number = 2,
    veg = c("potato", "beet")
  )
)

# row binding

# frustrating base attempts
rbind(x)
# [,1]   [,2]  
# x list,3 list,3

do.call(what = rbind, args = x)
# name   number veg        
# [1,] "sue"  1      character,2
# [2,] "doug" 2      character,2

do.call(what = rbind, args = x) |> str()

# tidyverse fail
dplyr::bind_rows(x)
# This works!

purrr::map_dfr(.x = x, .f = ~ .x[c("name", "number")])
# works

tibble(
  name = map_chr(.x = x, .f = "name"),
  number = map_dbl(.x = x, .f = "number"),
  veg = map(.x = x, .f = "veg")
)

# END