% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query_property_functions.R
\name{query_location_property_1}
\alias{query_location_property_1}
\title{Query Wikidata for property using the administrative entity (1)}
\usage{
query_location_property_1(city_code)
}
\arguments{
\item{city_code}{The Wikidata identifier ('Q____')}
}
\value{
The list of Wikidata items' categories that are geolocated into that administrative entity with Wikidata identifier
}
\description{
This functions query for Wikidata items' property ('Instance of' statement, P31) using the administrative entity. You have to look first for the wikidata location identifier on wikidata.org ('Q_____')
}

