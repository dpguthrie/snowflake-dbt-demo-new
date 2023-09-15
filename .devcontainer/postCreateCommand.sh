BIN_DIR="/usr/local/bin"
curl -LO https://github.com/dbt-labs/dbt-cli/releases/download/v0.29.5/dbt_0.29.5_linux_amd64.tar.gz
sudo tar -xzf dbt_0.29.5_linux_amd64.tar.gz -C $BIN_DIR dbt
export PATH=$PATH:$$BIN_DIR
echo "export PATH=\$PATH:$BIN_DIR" >> ~/.bashrc
echo "export DBT_CLOUD_API_KEY=$DBT_CLOUD_API_KEY" >> ~/.bashrc
source ~/.bashrc
