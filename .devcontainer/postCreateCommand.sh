mkdir -p /usr/local/bin \
    && curl -SL https://github.com/dbt-labs/dbt-cli/releases/download/v0.29.5/dbt_0.29.5_linux_arm64.tar.gz \
    | tar -xJC /usr/local/bin \
    && make -C /usr/local/bin all

PATH="${PATH}:/usr/local/bin/dbt"