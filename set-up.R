library(dplyr)
library(readr)

team_members = c(
  "Rachael Bainbridge",
  "Andrew Mooney",
  "Jenny Armstrong",
  "Alice Byers",
  "David Carr",
  "Ruth Gordon",
  "Lauren Dickson",
  "Deanna Campbell",
  "Jaroslaw Lang",
  "James McMahon",
  "Ryan Harris",
  "Rachel Porteous",
  "Jennifer Noall",
  "James McNally",
  "Hannah Jones",
  "Federico Centoni",
  "Peter McClurg",
  "Bateman McBride",
  "Martin Moench"
)

tibble(
  name = team_members,
  last_chaired = rep(NA),
  last_minuted = rep(NA),
  times_chaired = rep(0),
  times_minuted = rep(0)
) %>%
  mutate_at(c("last_chaired", "last_minuted"), as.character) %>%
  mutate_at(c("times_chaired", "times_minuted"), as.integer) %>%
  arrange(name) %>%
  write_rds("InOut/log.rds")
