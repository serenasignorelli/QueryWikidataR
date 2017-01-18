api_url <- "https://query.wikidata.org/bigdata/namespace/wdq/sparql?query="
wikidata_url <- 'https://www.wikidata.org/wiki/Special:EntityData/'

#' Query Wikidata for an item associated with a property
#'
#' This function query for Wikidata items that are associated with a specific property. You have to look first for the wikidata location identifier on wikidata.org ('Q_____')
#' @param property The Wikidata identifier of the property ('P____')
#' @param code The number that you choose to set for the property
#' @return The list of Wikidata items that are linked to that specific code
#' @export
query_item_from_property_code <- function(property, code){
  dir.create('./wikidata_items', showWarnings = FALSE)
  api_url <- "https://query.wikidata.org/bigdata/namespace/wdq/sparql?query="
  query <- paste0('SELECT%20%3FpropertyLabel%20%3Fcode%20%3Fproperty%0AWHERE%20%0A%7B%0A%09%3Fproperty%20wdt%3A', property, '%20%3Fcode%20.%0A%09FILTER%20(%0A%09%09%20%3Fcode%20in%20(%22', code, '%22)%0A%09)%0A%09SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22en%22%20%7D%0A%7D%0A')
  download.file(paste0(api_url, query, "&format=json"), paste0('./wikidata_items/', property, '.', code,'.txt'))
}

#' This function reads the list of items that has been downloaded
#' @param property The Wikidata identifier of the property ('P____')
#' @param code The number that you choose to set for the property
#' @return A dataframe with the Wikidata label of the item, the code that you set and the identifier of the item
#' @export
read_item_from_property_code <- function(property, code){
  library(dplyr)
  json <- jsonlite::fromJSON(paste0('./wikidata_items/', property, '.', code, '.txt'), simplifyDataFrame = TRUE)
  json_label <-json$results$bindings$propertyLabel
  json_code <- json$results$bindings$code
  json_item <- json$results$bindings$property
  if (!is.null(json_label) & !is.null(json_code) & !is.null(json_item)) {
      property <- json_item %>%
      mutate(item = gsub('http://www.wikidata.org/entity/', '', value)) %>%
      select (-type, -value) %>%
      mutate(label = json_label$value,
             code = json_code$value) %>%
      distinct()
    return(property)
  } else {
    property <- data.frame(item = "", label = "", code = code)
    return(property)
  }
}


