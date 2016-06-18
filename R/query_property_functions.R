api_url <- "https://query.wikidata.org/bigdata/namespace/wdq/sparql?query="
wikidata_url <- 'https://www.wikidata.org/wiki/Special:EntityData/'
dir.create('./wikidata_properties', showWarnings = FALSE)

#' Query Wikidata for property using the administrative entity (1)
#'
#' This functions query for Wikidata items' property ('Instance of' statement, P31) using the administrative entity. You have to look first for the wikidata location identifier on wikidata.org ('Q_____')
#' @param city_code The Wikidata identifier ('Q____')
#' @param lang Language of the name of Wikidata items. If not specified, English will be the default language
#' @return The list of Wikidata items' categories that are geolocated into that administrative entity with Wikidata identifier
#' @export
query_location_property_1 <- function(city_code, lang = "en"){
  query <- paste0('SELECT%20DISTINCT%20%3Fitem%20%3Fproperty%20%3FpropertyLabel%20%0AWHERE%20%7B%0A%20%20%3Fitem%20wdt%3AP131*%20wd%3A', city_code, '%20.%0A%20%20%23Looking%20for%20items%20with%20coordinate%20locations(P625)%0A%20%20%3Fitem%20wdt%3AP625%20%3Fcoord%20.%20%0A%20%20%3Fitem%20wdt%3AP31%20%3Fproperty%20.%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22.%0A%20%20%20%20%3Fitem%20rdfs%3Alabel%20%3Fname%0A%20%20%7D%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22%20%7D%0A%7D%0A%23Get%20the%20ordered%20output%0AORDER%20BY%20ASC%20(%3Fname)')
  download.file(paste0(api_url, query, "&format=json"), paste0('./wikidata_properties/', city_code, '.txt'))
}

#' Query Wikidata for property using a radius around the city (2)
#'
#' This functions query for Wikidata items's property using a radius around the city. You have to look first for the wikidata location identifier on wikidata.org ('Q_____') and to set a radius in km.
#' @param city_code The Wikidata identifier ('Q____')
#' @param radius A number that represents the radius in kilometers
#' @param lang Language of the name of Wikidata items. If not specified, English will be the default language
#' @return The list of Wikidata items' categories that are geolocated into that radius around the location with Wikidata identifier
#' @export
query_location_property_2 <- function(city_code, radius, lang = "en"){
  query <- paste0('SELECT%20%3Fitem%20%3Fproperty%20%3FpropertyLabel%20%0AWHERE%20%7B%0A%20%20wd%3A', city_code, '%20wdt%3AP625%20%3FmainLoc%20.%0A%20%20SERVICE%20wikibase%3Aaround%20%7B%20%0A%20%20%20%20%3Fitem%20wdt%3AP625%20%3Fcoord%20.%20%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Acenter%20%3FmainLoc%20.%20%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Aradius%20%22', radius, '%22%20.%20%0A%20%20%7D%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22.%0A%20%20%20%20%3Fitem%20rdfs%3Alabel%20%3Fname%0A%20%20%7D%0A%20%20%3Fitem%20wdt%3AP31%20%3Fproperty%20.%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22%20%7D%0A%7D%0AORDER%20BY%20ASC%20(%3Fname)')
  download.file(paste0(api_url, query, "&format=json"), paste0('./wikidata_properties/', city_code, '.txt'))
}

#' Query Wikidata using a box around the location (3)
#'
#' This functions query for Wikidata items' categories using a box around the location. You have to look first for the wikidata location identifier on wikidata.org ('Q_____') and to set two other locations that will become the corners of the box. Look for the identifier of these two locations and set at which corner they are in the format 'NorthEast', 'NorthWest', 'SouthEast', 'SouthWest'.
#' @param city_code The Wikidata identifier ('Q____')
#' @param first_corner_city_code The Wikidata identifier of the first box location('Q____')
#' @param first_city_corner The corner at which the first box location is ('NorthEast', 'NorthWest', 'SouthEast', 'SouthWest')
#' @param second_corner_city_code The Wikidata identifier of the second box location('Q____')
#' @param second_city_corner The corner at which the second box location is ('NorthEast', 'NorthWest', 'SouthEast', 'SouthWest')
#' @param lang Language of the name of Wikidata items. If not specified, English will be the default language
#' @return The list of Wikidata items' categories that are geolocated into that box around the location with Wikidata identifier
#' @export
query_location_property_3 <- function(city_code, first_corner_city_code, first_city_corner, second_corner_city_code, second_city_corner, lang = "en"){
  query <- paste0('SELECT%20%3Fitem%20%3Fproperty%20%3FpropertyLabel%20%0AWHERE%20%7B%0A%20%20wd%3A', first_city_code, '%20wdt%3AP625%20%3FFirstloc%20.%0A%20%20wd%3A', second_city_code, '%20wdt%3AP625%20%3FSecondloc%20.%0A%20%20SERVICE%20wikibase%3Abox%20%7B%0A%20%20%20%20%3Fitem%20wdt%3AP625%20%3Fcoord%20.%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Acorner',first_city_corner, '%20%3FFirstloc%20.%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Acorner', second_city_corner, '%20%3FSecondloc%20.%0A%20%20%7D%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22.%0A%20%20%20%20%3Fitem%20rdfs%3Alabel%20%3Fname%0A%20%20%7D%0A%20%20%3Fitem%20wdt%3AP31%20%3Fproperty%20.%0A%20%20%3Fproperty%20wdt%3AP279%20%3Fclass%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22%20%7D%0A%7D%0AORDER%20BY%20ASC%20(%3Fname)')
  download.file(paste0(api_url, query, "&format=json"), paste0('./wikidata_properties/', city_code, '.txt'))
}

#' Read the list of properties related to items
#'
#' This function reads the list of categories that has been downloaded
#' @param city_code The Wikidata identifier ('Q____')
#' @return A dataframe with the Wikidata identifier of the item and its property (there could be multiple categories for each item)
#' @export
read_property_list <- function(city_code){
  json <- jsonlite::fromJSON(paste0('./wikidata_properties/', city_code, '.txt'), simplifyDataFrame = TRUE)
  json_item <-json$results$bindings$item
  json_property <- json$results$bindings$propertyLabel
  property <- json_item %>%
    mutate(item = gsub('http://www.wikidata.org/entity/', '', value)) %>%
    select (-type, -value) %>%
    mutate(property = gsub('http://www.wikidata.org/entity/', '', json_property$value)) %>%
    distinct()
  return(property)
}
