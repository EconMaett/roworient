# 03 - Are you SURE you need to iterate over rows? ----

library(tidyverse)

### Function to give example data frame ----
new_df <- function() {
  dplyr::tribble(
    ~ name, ~ age,
    "Reed", 14L,
    "Wesley", 12L,
    "Eli", 12L,
    "Toby", 1L
  )
}


## Single-row example can cause tunnel vision ----

# It is easy to fixate on an unfavorable way of accomplishing something, 
# because it feels like a natural extension of a successful small-scale experiment.

# Let's create a string from row 1 of the data frame:
df <- new_df()
paste(df$name[1], "is", df$age[1], "years old")
# "Reed is 14 years old"

# I want to scale up, therefore I must loop over all rows:
n <- nrow(df)
s <- vector(mode = "character", length = n)
for (i in seq_len(n)) {
  s[i] <- paste(df$name[i], "is", df$age[i], "years old")
}
print(s)
# "Reed is 14 years old" "Wesley is 12 years old" "Eli is 12 years old" "Toby is 1 years old"

# HOLD ON! The function paste() is already vectorized over its arguments:
paste(df$name, "is", df$age, "years old")
# "Reed is 14 years old" "Wesley is 12 years old" "Eli is 12 years old" "Toby is 1 years old"

# Whenever you want to write an explicit loop, it should always give you pause.
# Has someone already written this loop for you?
# Ideally in C, C++, or FORTRAN, and inside a package that is being regularly checked,
# with high test coverage.
# Then this is usually the better choice.


## Don't forget to work "inside the box" ----

# For this string interpolation task, we can even work with a vectorized function that is
# happy to do lookup inside a data frame.
# The "glue" package is doing the work under the hood, but its greatest functions are
# now re-exported by the "stringr" package, which we already attached via `library(tidyverse)`.
stringr::str_glue_data(.x = df, "{name} is {age} years old")
# Reed is 14 years old
# Wesley is 12 years old
# Eli is 12 years old
# Toby is 1 years old

# Yu can use the simpler form, stringr::str_glue(), inside of dplyr::mutate(),
# because the other variables in `df` are automatically available for use:
df |> 
  mutate(sentence = str_glue("{name} is {age} years old"))

# The tidyverse style is to manage data holistically in a data frame and provide a
# user interface that encourages self-explaining code with low "syntactical noise".

# END