% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wikipedia_related_functions.R
\name{get_wikidata}
\alias{get_wikidata}
\title{Get Wikidata items'content}
\usage{
get_wikidata(items)
}
\arguments{
\item{items}{The list of items in a dataframe format (as output from read_items_list)}
}
\value{
A list of Wikidata content from the items'files
}
\description{
This function gets the Wikidata items files, saves them in a cache and extract from them the Wikidata content
}

