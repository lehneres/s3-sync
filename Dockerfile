FROM ubuntu:18.04

RUN apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y awscli curl && \
  rm -rf /var/lib/apt/lists/*

ADD sync.sh /sync.sh

CMD /sync.sh
