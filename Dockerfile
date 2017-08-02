# ---- Draft :: API parser and validator ----
FROM apiaryio/drafter AS drafter
FROM docker.dev.salonpicker.ru/env/centos AS env

# ---- Apiary CLI tool ----
FROM apiaryio/client
LABEL maintaner="Alexander Komlev <a.komlev@yclients.com>"
LABEL name="tools/apiary"
LABEL lifetime="8600"

ARG APIARY_API_KEY

ENV APIARY_API_KEY=$APIARY_API_KEY \
    API_NAME=yclients

RUN apk update && apk add \
    git \
    openssh

COPY --from=env /root/.ssh /root/.ssh
COPY --from=drafter /usr/local/bin/drafter /usr/local/bin/drafter
COPY --from=drafter /usr/lib/libstdc++.so.6 /usr/lib/libstdc++.so.6
COPY --from=drafter /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1
COPY --from=drafter /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY files/entrypoints /entrypoints
RUN chmod -R +x /entrypoints

RUN git clone git@gitlab.dev.salonpicker.ru:yclients/api-blueprint.git /opt/api-blueprint

WORKDIR /opt/api-blueprint

RUN apiary fetch --api-name=$API_NAME
RUN /usr/local/bin/drafter apiary.apib -l
