FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y r-base-core git gcc libcurl4-openssl-dev libssl-dev libgit2-dev

RUN \
	R -e 'install.packages("remotes"); remotes::install_github("jeroen/universe")'

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
