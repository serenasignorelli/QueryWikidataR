% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query_location_functions.R
\name{read_items_list}
\alias{read_items_list}
\title{Read the list of items that have been queried}
\usage{
read_items_list(city_code)
}
\arguments{
\item{city_code}{The Wikidata identifier ('Q____')}
}
\value{
A dataframe with the identifier of the item, its name (if it exists, otherwise it will be equal to the identifier), latitude and longitude of the item
}
\description{
This functions reads the list of items downloaded
}

