# 01 - Leave your data in the data frame ----

## Don't create odd little excerpts and copies of your data ----

# Code style that results from minimizing the number of key presses:
sl <- iris[51:100, 1]
pw <- iris[51:100, 4]
plot(sl ~ pw)
graphics.off()

# This clutters the workspace with loose parts sl and pw.
ls()
# "pw" "sl"
# Very soon you forget what they are, which Species of iris they represent,
# and what the relationship between them is.


## Leave the data *in situ* and reveal intent in your code ----

# More verbose code conveys intent.
# Eliminating the Magic Numbers makes the code less likely to be, or become, wrong.
library(tidyverse)

ggplot(data = filter(iris, Species == "versicolor"), mapping = aes(x = Petal.Width, y = Sepal.Length)) +
  geom_point()

graphics.off()

# Another tidyverse approach is using the pipe operator ( |> ):
iris |> 
  filter(Species == "versicolor") |> 
  ggplot(mapping = aes(x = Petal.Width, y = Sepal.Length)) +
  geom_point()

graphics.off()

# A base solution that still follows the principles of:
# - Leave the data in the data frame
# - Convey intent
plot(
  Sepal.Length ~ Petal.Width,
  data = subset(iris, subset = Species == "versicolor")
)

graphics.off()

# END