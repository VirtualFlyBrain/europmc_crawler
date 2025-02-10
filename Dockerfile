FROM r-base:4.0.1

ENV FTP_folder=https://ftp.flybase.net/flybase/associated_files/vfb/
ENV output_folder=/data/output2/

# Install gnupg2 to manage keys
RUN apt-get update && \
    apt-get install -y gnupg2

# Import the required public keys
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9 6ED0E7B82643E131

# Now update and install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxml2-dev libssl-dev libcurl4-openssl-dev

COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts

RUN Rscript /usr/local/src/myscripts/install_packages.R
CMD ["Rscript", "tidypmc_runner.R"]
