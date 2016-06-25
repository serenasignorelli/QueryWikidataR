api_url <- "https://query.wikidata.org/bigdata/namespace/wdq/sparql?query="
wikidata_url <- 'https://www.wikidata.org/wiki/Special:EntityData/'

#' Read the list of properties with its identifier
#'
#' This function reads the list of properties that has been downloaded with each identifier (of the property). You should use this function ONLY when you need to search for classes.
#' @param city_code The Wikidata identifier ('Q____')
#' @return A dataframe with the Wikidata identifier of the property and its label
#' @export

read_property_identifier <- function(city_code){
  json <- jsonlite::fromJSON(paste0('./wikidata_properties/', city_code, '.txt'), simplifyDataFrame = TRUE)
  json_property <-json$results$bindings$property
  json_property_Label <- json$results$bindings$propertyLabel
  property <- json_property %>%
    mutate(item = gsub('http://www.wikidata.org/entity/', '', value)) %>%
    select (-type, -value) %>%
    mutate(property = json_property_Label$value) %>%
    distinct()
  return(property)
}

#' Get list of class from the identifier of the properties
#'
#' This function gets the list of class from Wikidata property items' identifier that has been obtained through the query_location_property functions and read through the read_property_identifier function
#' @param items The list of property items' identifiers in a dataframe format (as output from read_property_identifier)
#' @param lang Language of the name of Wikidata items. If not specified, English will be the default language
#' @return This functions simply performs ther query and downloads the JSON files, so you will have to launch the read_property_class to have a result
#' @export

query_property_class <- function(items, lang = "en") {
  dir.create('./wikidata_classes', showWarnings = FALSE)
  items_list <- items$item
  for (i in 1:length(items_list)) {
    query <- paste0('SELECT%20%3FclassLabel%20%0AWHERE%20%7B%0A%20%20wd%3A', items_list[i], '%20wdt%3AP279%20%3Fclass%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22', lang, '%22%20%7D%0A%7D%0A%0A')
    download.file(paste0(api_url, query, "&format=json"), paste0('./wikidata_classes/', items_list[i], '.txt'))
  }
}

#' Read the list of classes just queries from the query_property_class function
#'
#' This function reads the list of classes from Wikidata property items' identifier that has been obtained through the query_property_class function.
#' @param items The list of property items' identifiers in a dataframe format (as output from read_property_identifier)
#' @return A dataframe with two variables: Wikidata property items' identifier and the class to which this property belongs to
#' @export

read_property_class <- function(items) {
  items_list <- items$item
  class_df <- data.frame(item = character(), class = character())
  for (i in 1:length(items_list)) {
  json <- jsonlite::fromJSON(paste0('./wikidata_classes/', items_list[i], '.txt'), simplifyDataFrame = TRUE)
  if (!length(json$results$bindings) == 0) {
    class <-json$results$bindings$classLabel
    item <- data.frame(item = rep.int(items_list[i], nrow(class)))
    df <- item %>%
      mutate(class = class$value) %>%
      distinct()
    class_df <- rbind(class_df, df)
  } else {
      class <- NA
      item <- data.frame(item = items_list[i])
      df <- item %>%
        mutate(class = class) %>%
        distinct()
      class_df <- rbind(class_df, df)
    }
  }
  return(class_df)
}

#' Link the list of Wikidata items with their properties to the list of classes
#'
#' This function links the list of Wikidata properties id (from read_property_identifier) to the list of classes (from read_property_class) and then to the list of properties (from read_property_list)
#' @param properties_id The list of properties obtained from read_property_identifier
#' @param classes The list of classes obtained from read_property_class
#' @param properties The list of classes obtained from read_property_list
#' @return A dataframe with three variables: Wikidata items identifier (not property identifier), property and class
#' @export

link_property_class <- function(properties_id, classes, properties) {
  linked <- properties_id %>%
    full_join(classes, by = 'item')%>%
    select(-item)%>%
    right_join(properties, by = 'property')%>%
    select(item, property, class)
  return(linked)
}
