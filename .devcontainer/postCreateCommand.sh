BIN_DIR="/usr/local/bin"
CLI_VERSION="0.35.4"
curl -LO "https://github.com/dbt-labs/dbt-cli/releases/download/v${CLI_VERSION}/dbt_${CLI_VERSION}_linux_amd64.tar.gz"
sudo tar -xzf "dbt_${CLI_VERSION}_linux_amd64.tar.gz" -C "$BIN_DIR" dbt
export PATH=$PATH:$$BIN_DIR
echo "export PATH=\$PATH:$BIN_DIR" >> ~/.bashrc
rm "dbt_${CLI_VERSION}_linux_amd64.tar.gz"
. ~/.bashrc
pip install -r .devcontainer/requirements.txt
mkdir ~/.dbt
eval "echo \"$(cat .devcontainer/dbt_cloud.yml)\"" >> ~/.dbt/dbt_cloud.yml
