FROM python:3.13-slim

RUN pip install --no-cache-dir \
    dagster \
    dagster-webserver \
    dagster-postgres

ENV DAGSTER_HOME=/opt/dagster/dagster_home

RUN mkdir -p ${DAGSTER_HOME} /opt/dagster/app

COPY svc/dagster/dagster_home/dagster.yaml ${DAGSTER_HOME}/dagster.yaml
COPY svc/dagster/workspace.yaml /opt/dagster/app/workspace.yaml

WORKDIR /opt/dagster/app
