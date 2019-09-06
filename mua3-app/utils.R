calculate_bonuses <- function(selected_heroes) {
  tidy_affiliations %>%
    dplyr::filter(hero %in% selected_heroes) %>%
    dplyr::count(team) %>%
    dplyr::filter(n > 1) %>%
    dplyr::left_join(affiliation_bonuses, by = c("team", "n")) %>%
    dplyr::group_by(stat) %>%
    dplyr::summarize(bonus = sum(bonus)) %>%
    dplyr::mutate(stat = factor(stat, c("STR", "DUR", "MAS", "RES", "VIT", "ENE")))
}

potential_bonuses <- function(selected_heroes) {
  assertthat::assert_that(length(selected_heroes) == 3)
  potential_heroes <- heroes[!heroes %in% selected_heroes] %>% set_names(., .)
  potential_bonuses <- potential_heroes %>%
    purrr::map_dfr(~ calculate_bonuses(c(selected_heroes, .x)), .id = "hero")
  return(potential_bonuses)
}

produce_recommendations <- function(selected_heroes) {
  assertthat::assert_that(length(selected_heroes) == 3)
  possible_bonuses <- potential_bonuses(selected_heroes)
  recommendations <- list(
    "per-stat maximization" = {
      possible_bonuses %>%
        dplyr::group_by(stat) %>%
        dplyr::top_n(1, bonus) %>%
        dplyr::group_by(hero) %>%
        dplyr::summarize(maximizes = paste0(stat, collapse = ", "))
    },
    "most bonuses" = {
      possible_bonuses %>%
        dplyr::count(hero) %>%
        dplyr::top_n(1, n) %>%
        dplyr::select(hero)
    },
    "average" = {
      possible_bonuses %>%
        dplyr::group_by(hero) %>%
        dplyr::summarize(`average bonus` = mean(bonus)) %>%
        dplyr::top_n(1, `average bonus`) %>%
        dplyr::select(hero)
    },
    "total" = {
      possible_bonuses %>%
        dplyr::group_by(hero) %>%
        dplyr::summarize(`total bonus` = sum(bonus)) %>%
        dplyr::top_n(1, `total bonus`) %>%
        dplyr::select(hero)
    }
  )
  recommendations$`repeat` <- recommendations %>%
    purrr::map_dfr(~ dplyr::distinct(.x, hero), .id = "criterion") %>%
    dplyr::count(hero) %>%
    dplyr::top_n(1, n) %>%
    dplyr::select(hero)

  recommendations_table <- recommendations[c("most bonuses", "average", "total", "repeat")] %>%
    dplyr::bind_rows(.id = "criterion") %>%
    dplyr::mutate(present = emo::ji("check")) %>%
    tidyr::spread(criterion, present) %>%
    dplyr::mutate_all(~ ifelse(is.na(.x), emo::ji("x"), .x)) %>%
    dplyr::select(hero, `most bonuses`, average, total, `repeat`)
  recommendations_max <- recommendations$`per-stat maximization` %>%
    dplyr::left_join(possible_bonuses, by = "hero") %>%
    tidyr::spread(stat, bonus, fill = 0)
  return(list(
    maximizations = recommendations_max,
    table = recommendations_table
  ))
}
