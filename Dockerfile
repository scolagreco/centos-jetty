FROM scolagreco/centos-java:1.15.0.2

ENV JETTY_VERSION 11.0.0
ENV JETTY_HOME /opt/jetty-home
ENV JETTY_BASE /opt/jetty-base
ENV TMPDIR /tmp/jetty
ENV PATH $JETTY_HOME/bin:$PATH
ENV JETTY_TGZ_URL https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/$JETTY_VERSION/jetty-home-$JETTY_VERSION.tar.gz

RUN mkdir -p "$JETTY_HOME" \
    && cd $JETTY_HOME \
    && wget "$JETTY_TGZ_URL" \
    && tar -zxvf jetty-home-$JETTY_VERSION.tar.gz --strip-components=1 \
    && rm -Rf jetty-home-$JETTY_VERSION.tar.gz \
    && mkdir -p "$JETTY_BASE" \
    && cd $JETTY_BASE \
    && java -jar "$JETTY_HOME/start.jar" --create-startd --add-to-start="server,http,deploy,jsp,jstl,ext,resources,websocket" \
    && mkdir "$TMPDIR" \
    && groupadd -r jetty && useradd -r -g jetty jetty \
    && chown -R jetty:jetty "$JETTY_HOME" "$JETTY_BASE" "$TMPDIR" \
    && usermod -d $JETTY_BASE jetty \ 
    && 	rm -rf /tmp/hsperfdata_root \
    && 	rm -fr $JETTY_HOME/jetty.tar.gz* \
    &&	rm -fr /jetty-keys $GNUPGHOME \
    &&	rm -rf /tmp/hsperfdata_root

# Metadata params
ARG BUILD_DATE
ARG VERSION="11.0.0"
ARG VCS_URL="https://github.com/scolagreco/centos-jetty.git"
ARG VCS_REF

# Metadata
LABEL maintainer="Stefano Colagreco <stefano@colagreco.it>" \
        org.label-schema.name="CentOS + OpenJDK + Jetty" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.version=$VERSION \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.description="Docker Image CentOS + OpenJDK + Jetty"

WORKDIR $JETTY_BASE
COPY docker-entrypoint.sh generate-jetty-start.sh /

USER jetty
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["java","-jar","/opt/jetty-home/start.jar"]
