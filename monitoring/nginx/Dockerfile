FROM nginx:alpine
LABEL maintainer="dro@arrakis.it"

EXPOSE 9091

ENV PROMETHEUS_HOST="prometheus" \
    USER="" \
    PASSWORD=""

RUN apk add --no-cache apache2-utils
RUN mkdir -p /config/
ADD nginx.tmpl.conf /nginx.tmpl.conf
ADD entrypoint.sh entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]