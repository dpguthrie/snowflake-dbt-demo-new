BIN_DIR="/usr/local/bin"

# Fetch the latest release version from GitHub API
CLI_VERSION=$(curl -s "https://api.github.com/repos/dbt-labs/dbt-cli/releases/latest" | jq -r '.tag_name' | sed 's/v//')

# If CLI_VERSION is empty, exit the script
if [ -z "$CLI_VERSION" ]; then
    echo "Failed to fetch the latest dbt-cli version."
    exit 1
fi

# Download the latest version
curl -LO "https://github.com/dbt-labs/dbt-cli/releases/download/v${CLI_VERSION}/dbt_${CLI_VERSION}_linux_amd64.tar.gz"

# Extract to the BIN_DIR and remove the archive
sudo tar -xzf "dbt_${CLI_VERSION}_linux_amd64.tar.gz" -C "$BIN_DIR" dbt

# Export and append the BIN_DIR to PATH
export PATH=$PATH:$$BIN_DIR
echo "export PATH=\$PATH:$BIN_DIR" >> ~/.bashrc

# Remove the archive
rm "dbt_${CLI_VERSION}_linux_amd64.tar.gz"

# Source the bash profile and install the requirements
. ~/.bashrc
pip install -r .devcontainer/requirements.txt

# Create the dbt_cloud.yml file used for cloud CLI
mkdir ~/.dbt
eval "echo \"$(cat .devcontainer/dbt_cloud.yml)\"" >> ~/.dbt/dbt_cloud.yml