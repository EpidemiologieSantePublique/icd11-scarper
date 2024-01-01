# ICD 11 Crawler and Scraper
#
# This R script utilizes the ICD 11 API v2 to crawl and scrape content from the
# International Classification of Diseases (ICD) 11 release 2023-01.

#
# Author:  MK. Guerchani aka Epidemiologie SantePublique
# Date: 1/1/2024
#
# Dependencies:
# - R (https://www.r-project.org/)
# - ICD 11 API (https://icd.who.int/icdapi)
# - httr (https://cran.r-project.org/web/packages/httr/index.html)
# - jsonlite (https://cran.r-project.org/web/packages/jsonlite/index.html)
#
# Usage:
# 1. Ensure that R is properly installed on your local machine.
# 2. This script uses the ICD 11 API installed locally, ensure that it is properly installed on your local machine.
# 3. For online API usage, consult the documentation regarding authentication.
# 4. Modify the necessary parameters such as API endpoints, language settings, etc.
# 5. Run the script to initiate the crawling and scraping process.
#
# Note: This script is intended for educational purposes and personal use only. Make sure to comply
# with the terms of use and licensing agreements of the ICD 11 API.
#
# GitHub Repository: https://github.com/EpidemiologieSantePublique/icd11-scarpe
#
# Feel free to contribute or provide feedback!


library(httr)
library(jsonlite)

endpoint.url <- 'http://localhost:6382/icd/release/11/2023-01/mms' # default endpoin for local installation
hostname <-'localhost:6382'# For local installation only
language <-'en' # Read API documentation to include language support for local installation
version <-'v2' # Version 2


## Get start entity
start.entity <- content(GET(endpoint.url, add_headers(
  accept='application/json',
  'API-Version'=version,
  'Accept-Language'= language
)))

cat(url,'\n')



## Get chapter entities

chapter.urls<-start.entity$child
n<-length(chapter.urls)
cat('Number of chapters is ', n,'/n')

i<-0
chapter.entities<-lapply(chapter.urls, function(url){
  url_parts <- parse_url(url)
  url_parts$hostname <- hostname
  url_parts$query$include <- 'ancestor,descendant,diagnosticCriteria'
  url <- build_url(url_parts)
  response <- GET(url, add_headers(
    accept='application/json',
    'API-Version'=version,
    'Accept-Language'= language
  ))
  cat(url,'\n')
  i<<-i+1
  cat('Get chapter : ', i, '\n')
  flush.console()
  content (response)
})


## Get chapter descendant entities
chapter.descendant.entity.urls <- unlist(lapply(chapter.entities, function(x) x$descendant))
n<-length(chapter.descendant.entity.urls)
cat('Number of chapter decendant entities is ', n,'/n')
i<-0

chapter.descendant.entities<-lapply(chapter.descendant.entity.urls, function(url){
  url_parts <- parse_url(url)
  url_parts$hostname <- hostname
  url_parts$query$include <- 'ancestor,descendant,diagnosticCriteria'
  url <- build_url(url_parts)
  response <- GET(url, add_headers(
    accept='application/json',
    'API-Version'=version,
    'Accept-Language'= language
  ))
  cat(url,'\n')
  i<<-i+1
  cat('Get entity details : ', i, '/',n, '\n')
  flush.console()
  content (response)
})

## Merge entities
icd11.entities<-(c(list(start.entity), chapter.entities, chapter.descendant.entities))
icd11.entities.flatten<-jsonlite:::simplify(icd11.entities, flatten = T)