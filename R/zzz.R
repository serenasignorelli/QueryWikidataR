
api_url <- function() 'https://query.wikidata.org/bigdata/namespace/wdq/sparql?query='
wikidata_url <- function() 'https://www.wikidata.org/wiki/Special:EntityData/'

get_lat_long <- function(x) {
  # http://stackoverflow.com/a/19253799
  as.numeric(unlist(regmatches(x, gregexpr("[[:digit:]]+\\.*[[:digit:]]*", x))))
}
