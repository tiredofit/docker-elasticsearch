ARG DISTRO="alpine"
ARG DISTRO_VARIANT="3.19"

FROM docker.io/tiredofit/${DISTRO}:${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG ELASTICSEARCH_VERSION

### Set Environment Variables
ENV ELASTICSEARCH_VERSION=${ELASTICSEARCH_VERSION:-"7.17.17"} \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk \
    PATH=/usr/share/elasticsearch/bin:$PATH \
    ES_TMPDIR=/usr/share/elasticsearch/tmp \
    ES_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ " \
    IMAGE_NAME="tiredofit/elasticsearch:7" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-elasticsearch/"

### Add Users
RUN source /assets/functions/00-container && \
    set -x && \
    addgroup -S elasticsearch -g 9200 && \
    adduser -S -G elasticsearch -u 9200 elasticsearch && \
    \
### Add Dependencies
    package update && \
    package upgrade && \
    package install .elasticsearch-run-deps \
                    openjdk11 \
                    && \
    \
    mkdir -p /usr/share/elasticsearch && \
    curl -sSL https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}-no-jdk-linux-x86_64.tar.gz | tar xvfz - --strip 1 -C /usr/share/elasticsearch && \
    cd /usr/share/elasticsearch && \
    mkdir -p config/scripts data logs plugins tmp && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment && \
    chown -R elasticsearch:elasticsearch * && \
    rm -rf /usr/share/elasticsearch/modules/x-pack-ml/platform/linux-x86_64 && \
    rm -rf /usr/share/elasticsearch/jdk && \
    package cleanup

WORKDIR /usr/share/elasticsearch

EXPOSE 9200 9300

COPY install /
