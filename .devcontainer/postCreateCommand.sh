curl -LO https://github.com/dbt-labs/dbt-cli/releases/download/v0.29.5/dbt_0.29.5_linux_arm64.tar.gz
tar -xzf dbt_0.29.5_linux_arm64.tar.gz
CURRENT_DIR=$(pwd)
export PATH=$PATH:$CURRENT_DIR
echo "export PATH=\$PATH:$CURRENT_DIR" >> ~/.bashrc
source ~/.bashrc
