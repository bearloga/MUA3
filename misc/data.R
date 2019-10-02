library(magrittr)

affiliation_bonuses <- "misc/raw/bonuses.tsv" %>%
  readr::read_tsv(col_types = "ccddd") %>%
  janitor::clean_names() %>%
  tidyr::gather(n, bonus, -c(team, stat)) %>%
  dplyr::mutate(n = dplyr::case_when(
    n == "x2" ~ 2,
    n == "x3" ~ 3,
    n == "x4" ~ 4
  ))

temp_affiliations <- "misc/raw/affiliations.tsv" %>%
  readr::read_tsv(col_types = "cc") %>%
  janitor::clean_names() %>%
  `[[`("affiliated_heroes") %>%
  purrr::map(strsplit, split = ", ") %>%
  purrr::map(~ .x[[1]])

max_affiliated_heroes <- max(purrr::map_int(temp_affiliations, length))

tidy_affiliations <- "misc/raw/affiliations.tsv" %>%
  readr::read_tsv(col_types = "cc") %>%
  janitor::clean_names() %>%
  tidyr::separate(affiliated_heroes, paste("h", 1:max_affiliated_heroes), sep = ", ", fill = "right") %>%
  tidyr::gather(spot, hero, -team) %>%
  dplyr::select(-spot) %>%
  dplyr::filter(!is.na(hero))

# affiliation_matrix <- tidy_affiliations %>%
#   xtabs(~ hero + team, data = .) %>%
#   as.data.frame.matrix
# affiliations <- sort(unique(tidy_affiliations$team))

heroes <- sort(unique(tidy_affiliations$hero))

saveRDS(heroes, "mua3-app/data/heroes.rds")
saveRDS(tidy_affiliations, "mua3-app/data/tidy_affiliations.rds")
saveRDS(affiliation_bonuses, "mua3-app/data/affiliation_bonuses.rds")
