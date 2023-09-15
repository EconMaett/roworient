# 07 - Are you SURE you need to iterate over groups? ----

# What if you need to work on groups of rows?

# Such as the groups induced by the levels of a factor.

# You do not need to split the data frame into mini-data-frames,
# loop over them, and glue them back together.

# Instead, use `dplyr::group_by()` followed by `dplyr::summarize()`
# to compute group-wide summaries.
library(tidyverse)

iris |> 
  group_by(Species) |> 
  summarise(pl_avg = mean(Petal.Length), pw_avg = mean(Petal.Width))

# What if you want to return summaries that are not just a single number?

# This does not "just work":
try(
  iris |> 
    group_by(Species) |> 
    summarise(pl_qtile = quantile(Petal.Length, probs = c(0.25, 0.5, 0.75)))
)
# This works.

# Warning message: Returning more or less than 1 row per `summarise()` group is deprecated.
# Use `reframe()` instead.

# Solution: Package as a length-1 list that contains 3 values, creating a list-column.
iris |> 
  group_by(Species) |> 
  summarise(pl_qtile = list(quantile(Petal.Length, probs = c(0.25, 0.5, 0.75))))


# Question: How can you unnest the final output so that it is a data frame with a 
# factor column "quantile" with levels 25%, 50%, and 75%?

# Answer: map() tibble::enframe() on the new list column, to convert each entry
# from the named list to a two-column data frame.
# Then use tidyr::unnest() to get rid of the list-column and return a data frame,
# and convert "quantile" into a facor:
iris |> 
  group_by(Species) |> 
  summarise(pl_qtlie = list(quantile(Petal.Length, probs = c(0.25, 0.5, 0.75)))) |>
  mutate(pl_qtlie = map(pl_qtlie, enframe, name = "quantile")) |> 
  unnest(cols = c(pl_qtlie)) |> 
  mutate(quantile = factor(quantile))

# If something like this comes up a lot in an analysis, you could package the key 
# "moves" on a function, like so:
enquantile <- function(x, ...) {
  qtile <- enframe(quantile(x, ...), name = "quantile")
  qtile$quantile <- factor(qtile$quantile)
  return(list(qtile))
}

# This makes repeated downstream usage more concise:
iris |> 
  group_by(Species) |> 
  summarise(pl_qtile = enquantile(Petal.Length, c(0.25, 0.5, 0.75))) |> 
  unnest(cols = c(pl_qtile))

# END