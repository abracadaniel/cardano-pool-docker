FROM prom/prometheus:latest
LABEL maintainer="dro@arrakis.it"

EXPOSE 9090

            #alias/host:port
ENV TARGETS="relay1/relay1:12798,producing1/producing1:12798"

USER root
ADD config.tmpl.yml /config.tmpl.yml
ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
RUN mkdir /config/

ENTRYPOINT ["/entrypoint.sh"]
