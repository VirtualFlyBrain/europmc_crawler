FROM r-base

ENV IDs_file=/home/huseyin/R_workspace/IDs_file.txt
ENV output_folder=/home/huseyin/R_workspace/europmc_crawler/results/

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxml2-dev && \
    apt-get install -y libssl-dev && \
    apt-get install -y libcurl4-openssl-dev

COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts

RUN Rscript /usr/local/src/myscripts/install_packages.R
CMD ["Rscript", "tidypmc_runner.R"]