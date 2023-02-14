FROM r-base:4.0.1

ENV FTP_folder=https://ftp.flybase.net/flybase/associated_files/vfb/
ENV output_folder=/data/output2/

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxml2-dev && \
    apt-get install -y libssl-dev && \
    apt-get install -y libcurl4-openssl-dev

COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts

RUN Rscript /usr/local/src/myscripts/install_packages.R
CMD ["Rscript", "tidypmc_runner.R"]
