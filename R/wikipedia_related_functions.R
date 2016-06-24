dir.create('./wikidata_items', showWarnings = FALSE)

#' Get Wikidata items'content
#'
#' This function gets the Wikidata items files, saves them in a cache and extract from them the Wikidata content
#' @param items The list of items in a dataframe format (as output from read_items_list)
#' @return A list of Wikidata content from the items'files
#' @export

get_wikidata <- function(items) {
  items_list <- items$item
  for (i in 1:length(items_list)) {
    file_name <- paste0('./wikidata_items/item_', items_list[i], '.txt')
    # Find out which files need to be downloaded
    to_download <- !file.exists(file_name)
    print(paste0("Files to download:", sum(to_download)))
    # Download files not in the cache
    if (any(to_download)) {
      url <- paste0(wikidata_url, items_list[i], '.json')
      download.file(url[to_download], file_name[to_download])
    }
  }
  # Read json files and extract wikidata
  res <- vector("list", length = length(items_list))
  counter <- 0
  file_list <- paste0("./wikidata_items/item_", items_list, ".txt")
  for (one_file in file_list) {
    text <- readLines(one_file)
    if (jsonlite::validate(text)) {
      json <- jsonlite::fromJSON(text)
      wikidata <- json$entities[[1]]
      trans <- wikidata$`*`
      names(trans) <- wikidata$lang
      if (is.null(wikidata)) {
        wikidata <- "ERROR: wikidata is null"
        warning(paste("null wikidata in "), substr(one_file, 57, regexpr(".", one_file)-1))
      }
    }
    counter <- counter + 1
    res[[counter]] <- wikidata
  }
  # Return wiki markup of articles
  return(res)
}

#' Get list of Wikipedia articles with languages
#'
#' This function gets the list of Wikipedia articles with languages from the Wikidata items
#' @param items The list of items in a dataframe format (as output from read_items_list)
#' @return A dataframe with three variables: item identifier, Wikipedia article title and Wikipedia article language
#' @export

get_wikipedia_articles <- function(items) {
  # get wikidata
  wikidata <- get_wikidata(items)
  # transform wikidata list
  wikidata <- do.call(cbind, wikidata)
  # transpose wikidata list
  wikidata <- t(wikidata)
  # create dataframe and filter considering only wikipedia items
  wikidata <- as.data.frame(wikidata)%>%
    select(-pageid, -ns, -title, -lastrevid, -modified, -type, -labels, -descriptions, -aliases, -claims)
  # split column sitelinks
  wikidata <- splitstackshape::concat.split.multiple(wikidata, "sitelinks", seps=",", "long")
  # consider only rows with title and url
  wikidata <- wikidata %>%
    filter(grepl("title =", sitelinks) | grepl("url =", sitelinks))%>%
    tidyr::separate(sitelinks, sep = "=", c('delete', 'keep'))
  # prepare datasets with articles and urls
  title <- wikidata %>%
    filter(delete == "title ") %>%
    mutate(article = gsub("\"", "", stringr::str_trim(keep, side = c("left")))) %>%
    select(-delete, -keep)
  url <- wikidata %>%
    filter(delete == "url ") %>%
    mutate(lang = substr(keep, regexpr("https://", keep)+8, regexpr("wikipedia", keep)-2),
           site = substr(keep, regexpr("https://", keep)+8+nchar(lang)+1, regexpr(".org", keep)-1)) %>%
    select(-delete, -keep)
  # unify datasets
  wikidata2 <- cbind(title, url) %>%
    mutate(item = id) %>%
    select(-id) %>%
    mutate(site = gsub(lang, "", site)) %>%
    filter(site == "wikipedia") %>%
    select(-id, -site)%>%
    mutate(item = unlist(item))
  wikidata2 <- as.data.frame(wikidata2)
  #return output
  return(wikidata2)
}
