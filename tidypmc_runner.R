library(tidypmc)
library(tidyverse)
library(europepmc)


crawl_pmcid <- function(pmcid, output_folder) {
  doc <- pmc_xml(pmcid)
  txt <- pmc_text(doc)
  
  write.table(txt, file= paste(output_folder, pmcid, ".tsv", sep=""), quote=FALSE, sep='\t', col.names = NA)
  
  tables <- pmc_table(doc)
  write.table(tables, file= paste(output_folder, pmcid, "_tables.tsv", sep=""), quote=FALSE, sep='\t', col.names = NA)
  
  captions <- pmc_caption(doc)
  write.table(captions, file= paste(output_folder, pmcid, "_captions.tsv", sep=""), quote=FALSE, sep='\t', col.names = NA)
}

crawl_articles <- function(ids_filepath, output_folder) {
  con = file(ids_filepath, "r")
  while ( TRUE ) {
    line = readLines(con, n = 1)
    if ( length(line) == 0 ) {
      break
    }
    tryCatch(
      {
        crawl_pmcid(line, output_folder)
      },
      error = function(e){
        message(paste("Error occured during crawling: ", line, sep=""))
        print(e$message)
      }
    )
  }
  close(con)
}

# Sys.setenv(IDs_file = "/home/huseyin/R_workspace/IDs_file.txt")
# Sys.setenv(output_folder = "/home/huseyin/R_workspace/europmc_crawler/results/")

IDs_file <- Sys.getenv("IDs_file")  
output_folder <- Sys.getenv("output_folder")  

crawl_articles(IDs_file, output_folder)

