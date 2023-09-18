BIN_DIR="/usr/local/bin"
curl -LO https://github.com/dbt-labs/dbt-cli/releases/download/v0.29.5/dbt_0.29.5_linux_amd64.tar.gz
sudo tar -xzf dbt_0.29.5_linux_amd64.tar.gz -C $BIN_DIR dbt
export PATH=$PATH:$$BIN_DIR
echo "export PATH=\$PATH:$BIN_DIR" >> ~/.bashrc
rm dbt_0.29.5_linux_amd64.tar.gz
. ~/.bashrc
pip install -r .devcontainer/requirements.txt
mkdir ~/.dbt/
./.devcontainer/create_profile.py > ~/.dbt/profiles.yml
