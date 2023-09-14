# 02 Create or mutate in place ----

## Add or modify a variable ----

library(tidyverse)

### Function to produce a fresh example data frame -----
new_df <- function() {
  dplyr::tribble(
    ~ name, ~ age,
    "Reed",   14L,
    "Wesley", 12L,
    "Eli",    12L,
    "Toby",    1L
  )
}


## The `df$var <- ...` syntax ----

# How to create or modify a variable is a fairly loww stakes matter, i.e. really
# a matter of taste.
# This is not a hill you should die on, but here are two cents:
# Of course, `df$var <- ...` absolutely works for creating new variables or
# modifying existing ones.
# The downsides are:
# - Silent recycling is a risk
# - `df` is not special. It is not the implied place to look first for things.
# - Aesthetic concerns

df <- new_df()
df$eyes <- 2L # Will be recycled
df$snack <- c("chips", "cheese") # Cannot be recycled
df$uname <- toupper(df$name)
df


## `dplyr::mutate()` works "inside the box" ----

# `dplyr::mutate()` is the tidyverse way to work on a variable. Note the following
# features:
# - Only a length one input can be recycled.
# - `df` is the first place to look for things.
# - It is pipe-freindly
# - It is more aesthetic
new_df() |> 
  mutate(
    eyes = 2L,
    snack = c("chips", "cheese"),
    uname = toupper(name)
  )
# Error: the variables in "snack" cannot be recycled.
new_df() |> 
  mutate(
    eyes = 2L,
    snack = c("chips", "cheese", "mixed nuts", "nerf bullets"),
    uname = toupper(name)
  )

# END