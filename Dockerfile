FROM alpine:3.24 AS base

RUN apk --no-cache add openjdk25

FROM base AS build-vnu

RUN apk add git python3 apache-ant maven

RUN git clone -n https://github.com/validator/validator.git

RUN cd validator \
    && git fetch \
    && git checkout fdabf092e60dfb5a3da810f3003266a19b582452

RUN cd validator \
    && JAVA_HOME=/usr/lib/jvm/java-25-openjdk python checker.py dldeps

RUN cd validator \
    && JAVA_HOME=/usr/lib/jvm/java-25-openjdk python checker.py --offline build jar

FROM base

RUN apk --no-cache add build-base linux-headers ruby-dev
RUN apk --no-cache add curl
RUN gem install html-proofer -v 5.2.1

RUN apk --no-cache add bash

COPY --from=build-vnu /validator/build/dist/vnu.jar /bin/vnu.jar

COPY entrypoint.sh proof-html.rb /

ENTRYPOINT ["/entrypoint.sh"]
