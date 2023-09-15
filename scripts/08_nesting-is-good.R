# 08 Group and nest -----

# Why nesting is worth the awkwardness
library(tidyverse)
library(gapminder)

# gapminder data for Asia only
gap <- gapminder |> 
  filter(continent == "Asia") |> 
  mutate(yr1952 = year - 1952)

ggplot(data = gap, mapping = aes(x = lifeExp, y = country)) +
  geom_point()

graphics.off()

# Countries are in alphabetical order.

# Set the factor levels with intent.
# Example: order based on life expectancy in 2007,
# the last year in this dataset.
# Imagine you want this to persist across an entire analysis.

gap <- gap |> 
  mutate(country = fct_reorder2(country, .x = year, .y = lifeExp))

ggplot(data = gap, mapping = aes(x = lifeExp, y = country)) +
  geom_point()

graphics.off()

# Much better!

# Now imagine we want to fit a model to each country and look at dot plots
# of slope and intercept.
# `dplyr::group_by()` + `tidyr::nest()` created a *nested data frame* as
# an alternative to splitting into country-specific data frames.

# Those data frames end up in a list-column.
# The `country` variable remains a normal factor.
gap_nested <- gap |> 
  group_by(country) |> 
  nest()

gap_nested

gap_nested[[1]]

gap_fitted <- gap_nested |> 
  mutate(fit = map(data, ~ lm(lifeExp ~ yr1952, data = .x)))

gap_fitted

gap_fitted$fit[[1]]

gap_fitted <- gap_fitted |> 
  mutate(
    intercept = map_dbl(fit, ~ coef(.x)[["(Intercept)"]]),
    slope = map_dbl(fit, ~ coef(.x)[["yr1952"]])
  )

head(gap_fitted)

ggplot(data = gap_fitted, mapping = aes(x = intercept, y = country)) +
  geom_point()

graphics.off()

ggplot(data = gap_fitted, mapping = aes(x = slope, y = country)) +
  geom_point()

graphics.off()


# The `split()` + `lapply()` + `do.call(rbind, ...)` appriach:
# Split gap into many data fraems, one per country.
gap_split <- split(x = gap, f = gap$country)

# Fit a model to each country:
gap_split_fits <- lapply(X = gap_split, FUN = function(df) {
  lm(lifeExp ~ yr1952, data = df)
})
# Error in lm.fit(x, y, offset = offset, singular.ok = singular.ok, ...) :
# 0 (non-NA) cases

# The unused levels of "country" are a problem
# (empty data frames in our list).

# We drop the unused levels in "country" and split():
gap_split <- split(x = droplevels(gap), f = droplevels(gap)$country)
head(gap_split, n = 2)

# Fit a model to each country and get the coefs():
gap_split_coefs <- lapply(
  X = gap_split,
  FUN = function(df) {
    coef(lm(lifeExp ~ yr1952, data = df))
  }
)

head(gap_split_coefs, n = 2)

# Now we need to put everything back together.
# rbind() the list() of coef()s.
# Coerce from matrix() back to data.frame().
gap_split_coefs <- as.data.frame(do.call(what = rbind, args = gap_split_coefs))

# Restore "country" variable form row names:
gap_split_coefs$country <- rownames(gap_split_coefs)
str(gap_split_coefs)

ggplot(data = gap_split_coefs, mapping = aes(x = `(Intercept)`, y = country)) +
  geom_point()

graphics.off()

# Uh-oh, we lost the order of the "country" factor, due to coercion from a factor()
# to a character() (list() and then rownames()).

# Teh nest() approach allows you to keep data as data vs. in attributes,
# such as list() or rownames().
# It preserves the factors() and their levels() or integer() variables.

# END