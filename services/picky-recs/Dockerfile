FROM python:3.12-slim

RUN pip install --no-cache-dir uv

WORKDIR /opt/dagster/app

COPY pyproject.toml ./pyproject.toml
COPY uv.lock* ./

COPY services/picky-recs/pyproject.toml ./services/picky-recs/pyproject.toml

RUN uv sync --frozen --no-dev --no-install-project --package picky-recs

COPY services/picky-recs/picky_recs ./services/picky-recs/picky_recs
COPY services/picky-recs/definitions.py ./services/picky-recs/definitions.py

RUN uv sync --frozen --no-dev --package picky-recs

ENV DAGSTER_HOME=/opt/dagster/dagster_home
RUN mkdir -p ${DAGSTER_HOME}

COPY services/dagster/dagster_home/dagster.yaml ${DAGSTER_HOME}/dagster.yaml

EXPOSE 4000

ENTRYPOINT ["uv", "run", "--package", "picky-recs", "dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "4000", "-m", "picky_recs"]
