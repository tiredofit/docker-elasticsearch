FROM docker.io/tiredofit/alpine:3.16
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

### Set Environment Variables
ENV ELASTICSEARCH_VERSION=7.17.6 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk \
    PATH=/usr/share/elasticsearch/bin:$PATH \
    ES_TMPDIR=/usr/share/elasticsearch/tmp \
    ES_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ " \
    IMAGE_NAME="tiredofit/elasticsearch:7" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-elasticsearch/"

### Add Users
RUN set -x && \
    addgroup -S elasticsearch -g 9200 && \
    adduser -S -G elasticsearch -u 9200 elasticsearch && \
    \
### Add Dependencies
    apk update && \
    apk upgrade && \
    apk add -t .elasticsearch-run-deps \
        openjdk11 \
        && \
    \
### Fetch and Install Elasticsearch
    mkdir -p /usr/share/elasticsearch && \
    curl -sSL https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}-no-jdk-linux-x86_64.tar.gz | tar xvfz - --strip 1 -C /usr/share/elasticsearch && \
    cd /usr/share/elasticsearch && \    
    mkdir -p config/scripts data logs plugins tmp && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment && \
    chown -R elasticsearch:elasticsearch * && \
    rm -rf /usr/share/elasticsearch/modules/x-pack-ml/platform/linux-x86_64 && \
    rm -rf /usr/share/elasticsearch/jdk && \
    \
### Cleanup
    rm -rf /var/cache/apk/*

### Entrypoint
WORKDIR /usr/share/elasticsearch

### Networking Configuration
EXPOSE 9200 9300

### Files Add
ADD install /
