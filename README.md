# Europmc crawler

This repository downloads papers from the europmc using the [tidypmc](https://github.com/ropensci/tidypmc) library. [neuron-to-tp-paper](https://github.com/VirtualFlyBrain/neuron-to-paper-nlp) library depends on this repository to access VirtualFlyBrain related publications.

Crawler reads s set of PMC identifires from a file (see [IDs_file.txt](data/IDs_file.txt)), and tries to download the paper contents in a tabular format; sections, paragraphs, sentences.


## Build

To build the project, please run the following commands in the project root folder. 

```
docker build -t virtualflybrain/europmc_crawler .

docker run --volume=`pwd`/data:/data/ -e IDs_file=/data/IDs_file.txt -e output_folder=/data/output/ virtualflybrain/europmc_crawler
```