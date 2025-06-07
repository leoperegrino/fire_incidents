ARG PYTHON_VERSION=3.11

FROM apache/airflow:2.10.5-python${PYTHON_VERSION}

ARG PYTHON_VERSION

# USER root
#
# RUN <<-EOF
# 	apt-get update
# 	apt-get install -y libpq-dev postgresql-client build-essential
#     apt-get clean
#     rm -rf /var/lib/apt/lists/*
# EOF

USER airflow
WORKDIR /opt/airflow

COPY requirements.txt .

RUN <<-EOF
	pip install --no-cache-dir -r requirements.txt
EOF
