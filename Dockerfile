FROM tomcat:7-jre7

MAINTAINER Juha Kovanen <juha.kovanen@gmail.com>

# To update, check https://bintray.com/jfrog/artifactory/artifactory/view
ENV ARTIFACTORY_VERSION 4.11.2
ENV ARTIFACTORY_SHA256 d765046bca9debf7bf1bdac391846fa767c9671ba95b2aeb32c7c73a88f42c33

# Disable Tomcat's manager application.
RUN rm -rf webapps/*

# Redirect URL from / to artifactory/ using UrlRewriteFilter
COPY urlrewrite/WEB-INF/lib/urlrewritefilter.jar /
COPY urlrewrite/WEB-INF/urlrewrite.xml /
RUN \
  mkdir -p webapps/ROOT/WEB-INF/lib && \
  mv /urlrewritefilter.jar webapps/ROOT/WEB-INF/lib && \
  mv /urlrewrite.xml webapps/ROOT/WEB-INF/

# Fetch and install Artifactory OSS war archive.
RUN \
  echo $ARTIFACTORY_SHA256 artifactory.zip > artifactory.zip.sha256 && \
  curl -L -o artifactory.zip https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-${ARTIFACTORY_VERSION}.zip && \
  sha256sum -c artifactory.zip.sha256 && \
  unzip -j artifactory.zip "artifactory-*/webapps/artifactory.war" -d webapps && \
  rm artifactory.zip

# Expose tomcat runtime options through the RUNTIME_OPTS environment variable.
#   Example to set the JVM's max heap size to 256MB use the flag
#   '-e RUNTIME_OPTS="-Xmx256m"' when starting a container.
RUN echo 'export CATALINA_OPTS="$RUNTIME_OPTS"' > bin/setenv.sh

# Artifactory home
RUN mkdir -p /artifactory
ENV ARTIFACTORY_HOME /artifactory

VOLUME /artifactory/backup
VOLUME /artifactory/data
VOLUME /artifactory/logs

WORKDIR /artifactory