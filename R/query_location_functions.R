api_url <- "https://query.wikidata.org/bigdata/namespace/wdq/sparql?query="
wikidata_url <- 'https://www.wikidata.org/wiki/Special:EntityData/'
dir.create('./wikidata_lists', showWarnings = FALSE)

#' Query Wikidata using the administrative entity (1)
#'
#' This functions query for Wikidata items using the administrative entity. You have to look first for the wikidata location identifier on wikidata.org ('Q_____')
#' @param city_code The Wikidata identifier ('Q____')
#' @param lang Language of the name of Wikidata items. If not specified, English will be the default language
#' @return The list of Wikidata items that are geolocated into that administrative entity
#' @export
query_location_1 <- function(city_code, lang = "en"){
  query <- paste0('SELECT%20DISTINCT%20%3Fitem%20%3Fname%20%3Fcoord%20%0AWHERE%20%7B%0A%20%20%20%20%3Fitem%20wdt%3AP131*%20wd%3A', city_code, '%20.%0A%20%20%20%20%3Fitem%20wdt%3AP625%20%3Fcoord%20.%0A%20%20%20SERVICE%20wikibase%3Alabel%20%7B%0A%20%20%20%20%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22%.%0A%20%20%20%20%20%3Fitem%20rdfs%3Alabel%20%3Fname%0A%20%20%20%20%7D%0A%7D%0AORDER%20BY%20ASC%20(%3Fname)')
  download.file(paste0(api_url, query, "&format=json"), paste0('/wikidata_lists/', city_code, '.txt'))
}

#' Query Wikidata using a radius around the city (2)
#'
#' This functions query for Wikidata items using a radius around the city. You have to look first for the wikidata location identifier on wikidata.org ('Q_____') and to set a radius in km.
#' @param city_code The Wikidata identifier ('Q____')
#' @param radius A number that represents the radius in kilometers
#' @param lang Language of the name of Wikidata items. If not specified, English will be the default language
#' @return The list of Wikidata items that are geolocated into that radius around the location with Wikidata identifier
#' @export

query_location_2 <- function(city_code, radius, lang = "en"){
  query <- paste0('SELECT%20%3Fitem%20%3Fname%20%3Fcoord%20%0AWHERE%20%7B%0A%20wd%3A', city_code, '%20wdt%3AP625%20%3FmainLoc%20.%20%0A%20SERVICE%20wikibase%3Aaround%20%7B%20%0A%20%3Fitem%20wdt%3AP625%20%3Fcoord%20.%20%0A%20bd%3AserviceParam%20wikibase%3Acenter%20%3FmainLoc%20.%20%0A%20bd%3AserviceParam%20wikibase%3Aradius%20%22', radius, '%22%20.%20%0A%20%7D%0A%20SERVICE%20wikibase%3Alabel%20%7B%0A%20%20%20%20%20%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22.%0A%20%20%20%20%20%3Fitem%20rdfs%3Alabel%20%3Fname%0A%20%7D%0A%7D%0AORDER%20BY%20ASC%20(%3Fname)%0A')
  download.file(paste0(api_url, query, "&format=json"), paste0('/wikidata_lists/', city_code, '.txt'))
}

#' Query Wikidata using a box around the location (3)
#'
#' This functions query for Wikidata items using a box around the location. You have to look first for the wikidata location identifier on wikidata.org ('Q_____') and to set two other locations that will become the corners of the box. Look for the identifier of these two locations and set at which corner they are in the format 'NorthEast', 'NorthWest', 'SouthEast', 'SouthWest'.
#' @param city_code The Wikidata identifier ('Q____')
#' @param first_corner_city_code The Wikidata identifier of the first box location('Q____')
#' @param first_city_corner The corner at which the first box location is ('NorthEast', 'NorthWest', 'SouthEast', 'SouthWest')
#' @param second_corner_city_code The Wikidata identifier of the second box location('Q____')
#' @param second_city_corner The corner at which the second box location is ('NorthEast', 'NorthWest', 'SouthEast', 'SouthWest')
#' @param lang Language of the name of Wikidata items. If not specified, English will be the default language
#' @return The list of Wikidata items that are geolocated into that box around the location with Wikidata identifier
#' @export

query_location_3 <- function(city_code, first_corner_city_code, first_city_corner, second_corner_city_code, second_city_corner, lang = "en"){
  query <- paste0('SELECT%20%3Fitem%20%3Fname%20%3Fcoord%20%0AWHERE%20%7B%0A%20%20wd%3A', first_corner_city_code, '%20wdt%3AP625%20%3FFirstloc%20.%0A%20%20wd%3A', second_corner_city_code, '%20wdt%3AP625%20%3FSecondloc%20.%0A%20%20SERVICE%20wikibase%3Abox%20%7B%0A%20%20%20%20%20%20%3Fitem%20wdt%3AP625%20%3Fcoord%20.%0A%20%20%20%20%20%20bd%3AserviceParam%20wikibase%3Acorner',first_city_corner,  '%20%3FFirstloc%20.%0A%20%20%20%20%20%20bd%3AserviceParam%20wikibase%3Acorner', second_city_corner, '%20%3FSecondloc%20.%0A%20%20%20%20%7D%0ASERVICE%20wikibase%3Alabel%20%7B%0A%20%20%20%20%20%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22.%0A%20%20%20%3Fitem%20rdfs%3Alabel%20%3Fname%0A%20%7D%0A%7D%0AORDER%20BY%20ASC%20(%3Fname)%0A%0A')
  download.file(paste0(api_url, query, "&format=json"), paste0('/wikidata_lists/', city_code, '.txt'))
}

#' Read the list of items that have been queried
#'
#' This functions reads the list of items downloaded
#' @param city_code The Wikidata identifier ('Q____')
#' @return A dataframe with the identifier of the item, its name (if it exists, otherwise it will be equal to the identifier), latitude and longitude of the item
#' @export

read_items_list <- function(city_code){
  json <- jsonlite::fromJSON(paste0('/wikidata_lists/', city_code, '.txt'), simplifyDataFrame = TRUE)
  json_item <-json$results$bindings$item
  json_name <-json$results$bindings$name
  json_coord <-json$results$bindings$coord
  items_list <- json_item %>%
    mutate(item = gsub('http://www.wikidata.org/entity/', '', value)) %>%
    select (-type, -value) %>%
    mutate(name = json_name$value,
           point = json_coord$value,
           lat = substr(point, 7, regexpr(" ", point)-1),
           long = substr(point, regexpr(" ", point), regexpr(")", point)-1)) %>%
    select(-point) %>%
    distinct()
  return(items_list)
}

