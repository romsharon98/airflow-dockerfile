FROM apache/airflow:2.8.4
ADD requirements.txt .

USER root

# this lines fix apache-airflow-providers-apache-hdfs errors
# change from gcc to g++ to prevent 'gcc: fatal error: cannot execute ‘cc1plus’: execvp: Permission denied' error '/bin/sh: 1: krb5-config: Permission denied' when installing gssapi
# https://forums.docker.com/t/cant-figure-out-this-error-command-krb5-config-libs-gssapi-returned-non-zero-exit-status-127/135633/3
# https://stackoverflow.com/questions/56489802/unable-to-install-sasl-using-pip-due-to-gcc-errors we got this error when installing sasl (for connecting to kerberos), installing libsasl2-dev fixed it
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         g++ \
         heimdal-dev \
         libsasl2-dev \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER airflow
RUN pip install "apache-airflow==2.8.4" -r requirements.txt --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.8.4/constraints-3.8.txt"
