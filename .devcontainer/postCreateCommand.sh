BIN_DIR="/usr/local/bin"
<<<<<<< HEAD
CLI_VERSION="0.34.9"
=======
CLI_VERSION="0.34.7"
>>>>>>> 47739c292d9a92a51dc30d4ee1aaa48782679c13
curl -LO "https://github.com/dbt-labs/dbt-cli/releases/download/v${CLI_VERSION}/dbt_${CLI_VERSION}_linux_amd64.tar.gz"
sudo tar -xzf "dbt_${CLI_VERSION}_linux_amd64.tar.gz" -C "$BIN_DIR" dbt
export PATH=$PATH:$$BIN_DIR
echo "export PATH=\$PATH:$BIN_DIR" >> ~/.bashrc
rm "dbt_${CLI_VERSION}_linux_amd64.tar.gz"
. ~/.bashrc
pip install -r .devcontainer/requirements.txt
mkdir ~/.dbt
eval "echo \"$(cat .devcontainer/dbt_cloud.yml)\"" >> ~/.dbt/dbt_cloud.yml
