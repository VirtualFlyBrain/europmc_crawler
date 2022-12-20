# Europmc crawler

This repository downloads papers from the europmc using the [tidypmc](https://github.com/ropensci/tidypmc) library. [neuron-to-paper-nlp](https://github.com/VirtualFlyBrain/neuron-to-paper-nlp) library depends on this repository to access VirtualFlyBrain related publications.

Crawler reads a set of PMC identifires from a file (see [IDs_file.txt](data/IDs_file.txt)), and tries to download the paper contents in a tabular format; sections, paragraphs, sentences. Sample output files can be found in the [/data/output](data/output) folder.


## Docker

To build the project, please run the following command in the project root folder.

```
docker build -t virtualflybrain/europmc_crawler .
```

To run the container, provide an ftp folder where a file with PMCIDs are located or a local copy of the same file (see [/data/pmcid_new_vfb_fb_2022_06.tsv](data/pmcid_new_vfb_fb_2022_06.tsv) for the sample file format). 

```
docker run --volume=`pwd`/data:/data/ -e FTP_folder=https://ftp.mydomain/my_folder/ -e output_folder=/data/output/ virtualflybrain/europmc_crawler
```
or
```
docker run --volume=`pwd`/data:/data/ -e IDs_file=/data/IDs_file.txt -e output_folder=/data/output/ virtualflybrain/europmc_crawler
```

## Local Run

To run the code in your local, install the following dependencies:

```
sudo apt-get install libxml2-dev
sudo apt-get install libssl-dev
sudo apt-get install libcurl4-openssl-dev
```

Enable the environment variable setting comment lines in the [tidypmc_runner.R](tidypmc_runner.R).

```R
Sys.setenv(IDs_file = "/my/local/IDs_file.txt")
Sys.setenv(output_folder = "/my/local/output/")
```

Then run the [install_packages.R](install_packages.R) and [tidypmc_runner.R](tidypmc_runner.R) scripts in order.
