library(tidypmc)
library(tidyverse)
library(europepmc)


crawl_pmcid <- function(pmcid, FBrf_ID, output_folder) {
  doc <- pmc_xml(pmcid)
  
  txt <- pmc_text(doc)
  write.table(txt, file= paste(output_folder, pmcid, ".tsv", sep=""), quote=FALSE, sep='\t', col.names = NA)
  
  metadata <- pmc_metadata(doc)
  metadata['FBrf_ID'] <- c(FBrf_ID)
  write.table(metadata, file= paste(output_folder, pmcid, "_metadata.tsv", sep=""), quote=FALSE, sep='\t', col.names = NA)
  
  captions <- pmc_caption(doc)
  write.table(captions, file= paste(output_folder, pmcid, "_captions.tsv", sep=""), quote=FALSE, sep='\t', col.names = NA)
  
  tables <- pmc_table(doc)
  write.table(tables, file= paste(output_folder, pmcid, "_tables.tsv", sep=""), quote=FALSE, sep='\t', col.names = NA)
}

crawl_articles <- function(ids_filepath, output_folder) {
  dir.create(file.path(output_folder), showWarnings = FALSE)
  con = file(ids_filepath, "r")
  linn <-readLines(con)
  for (i in 1:length(linn)){
    line = str_trim(linn[i])
    if (length(line) > 0 & !startsWith(line, "#") & grepl('\t', line, fixed = TRUE)) {
      fields <- strsplit(line, '\t') [[1]]
      FBrf_ID <- fields[1]
      PMCID <- fields[2]
      tryCatch(
        {
          crawl_pmcid(PMCID, FBrf_ID, output_folder)
        },
        error = function(e){
          message(paste0("Error occured during crawling: ", PMCID))
          print(e$message)
        }
      )
    }
  }
  close(con)
}

get_next_month <- function(year, month) {
  if (month == 12) {
    next_year <- year + 1
    next_month <- 1 
  } else {
    next_year <- year
    next_month <- month + 1 
  }
  list(year = next_year, month = next_month)
}

get_previous_month <- function(year, month) {
  if (month == 1) {
    prev_year <- year - 1
    prev_month <- 12 
  } else {
    prev_year <- year
    prev_month <- month - 1 
  }
  list(year = prev_year, month = prev_month)
}

download_latest_ids_file <- function(ftp_folder, status_file, current_year, current_month) {
  if (file.exists(status_file)){
    con = file(status_file, "r")
    linn <-readLines(con)
    for (i in 1:length(linn)){
      line = str_trim(linn[i])
      if (length(line) > 0 & !startsWith(line, "#") & grepl('-', line, fixed = TRUE)) {
        fields = strsplit(line, '-') [[1]]
        last_crawl_year <- as.integer(fields[1])
        last_crawl_month <- as.integer(fields[2])
      }
    }
    close(con)
  } else {
    prev_date <- get_previous_month(current_year, current_month)
    last_crawl_year <- prev_date$year
    last_crawl_month <- prev_date$month
  }
  
  if(!endsWith(ftp_folder, "/")){
    ftp_folder <- paste0(ftp_folder,"/")
  }
  
  # try next 6 months' files
  next_date <- get_next_month(last_crawl_year, last_crawl_month)
  test_year <- next_date$year
  test_month <- next_date$month
  download_file <- NULL
  crawl_year <- NULL
  crawl_month <- NULL
  for (i in 1:6) {
    # https://ftp.flybase.net/flybase/associated_files/vfb/pmcid_new_vfb_fb_2022_06.tsv
    url <- paste0(ftp_folder, "pmcid_new_vfb_fb_", test_year, "_", str_pad(test_month, width=2, side="left", pad="0"), ".tsv")
    print(paste0("Trying url: ", url))
    hd <- httr::HEAD(url)
    status <- hd$all_headers[[1]]$status
    if (status == 200) {
      download_file <- paste0(output_folder, "pmcid_new_vfb_fb_", test_year, "_", str_pad(test_month, width=2, side="left", pad="0"), ".tsv")
      download.file(url, destfile=download_file, method="libcurl")
      crawl_year <- test_year
      crawl_month <- test_month
      break
    } else {
      next_date <- get_next_month(test_year, test_month)
      test_year <- next_date$year
      test_month <- next_date$month
    }
  }
  
  list(download_file=download_file, crawl_year=crawl_year, crawl_month=crawl_month)
}

save_crawl_status <- function(crawling_status_file, year, month) {
  status_file<-file(crawling_status_file)
  writeLines(c("## This file stores the latest data crawling status.", "# Latest crawl date:", paste(year, month, sep="-")), status_file)
  close(status_file)
}


# Sys.setenv(FTP_folder = "https://ftp.flybase.net/flybase/associated_files/vfb/")
# Sys.setenv(IDs_file = "/home/huseyin/R_workspace2/europmc_crawler/data/pmcid_new_vfb_fb_2022_06_short.tsv")
# Sys.setenv(output_folder = "/home/huseyin/R_workspace2/europmc_crawler/data/output2/")

today <- Sys.Date()
year <- as.integer(format(today, "%Y"))
month <- as.integer(format(today, "%m"))
day <- as.integer(format(today, "%d"))
print(paste0("Crawling started: ", year, "-", month, "-", day))

output_folder <- Sys.getenv("output_folder")
if(!endsWith(output_folder, "/")){
  output_folder <- paste0(output_folder,"/")
}
crawling_status_file <- paste0(output_folder, "crawling_status.txt")

# either FTP_folder or IDs_file should be provided
ftp_folder <- Sys.getenv("FTP_folder")
if ( !is.null(ftp_folder) & ftp_folder != '') {
  crawl_result <- download_latest_ids_file(ftp_folder, crawling_status_file, year, month)
  IDs_file <- crawl_result$download_file
  crawl_year <- crawl_result$crawl_year
  crawl_month <- crawl_result$crawl_month
} else {
  IDs_file <- Sys.getenv("IDs_file")  
  crawl_year <- year
  crawl_month <- month
}

if (!is.null(IDs_file)) {
  target_folder <- paste0(output_folder, crawl_year, "_", str_pad(crawl_month, width=2, side="left", pad="0"), "/")
  crawl_articles(IDs_file, target_folder)
  save_crawl_status(crawling_status_file, year, month)
  print(paste0("Outputs are successfully written to ", target_folder))
}  

print("SUCCESS")

