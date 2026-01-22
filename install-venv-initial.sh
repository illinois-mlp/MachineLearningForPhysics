#!/usr/bin/env bash
set -e

echo "=== VENV Setup ==="

# Detect OS
OS="$(uname -s)"
echo "Detected OS: $OS"

if [[ "$OS" == "Darwin" ]]; then
    echo "Setting up for macOS..."
    
    # Ensure Homebrew is installed
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install Python 3.11 via Homebrew
    brew install python@3.11 || true

    PYTHON_BIN="$(brew --prefix python@3.11)/bin/python3.11"
    VENV_PYTHON="$PYTHON_BIN"

    # Install HDF5 for PyTables
    brew install hdf5 || true
    export HDF5_DIR="$(brew --prefix hdf5)"

elif [[ "$OS" == "Linux" ]]; then
    echo "Setting up for Ubuntu/Linux..."
    
    sudo apt update
    sudo apt install -y software-properties-common curl build-essential
    
    # Ubuntu 24.x has python3.13 available
    PYTHON_BIN="/usr/bin/python3.13"
    sudo apt install -y python3.13 python3.13-venv python3.13-dev python3-pip

else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Create .venv
$PYTHON_BIN -m venv .venv
source .venv/bin/activate

# Upgrade pip and build tools
pip install --upgrade pip wheel setuptools

# Install core packages
pip install numpy pandas matplotlib scipy tables seaborn scikit-learn jupyter notebook jupyter-book

# Configure VS Code for this .venv
mkdir -p .vscode
cat > .vscode/settings.json <<EOL
{
    "python.pythonPath": "\${workspaceFolder}/.venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "jupyter.notebookFileRoot": "\${workspaceFolder}"
}
EOL

echo "✅ Setup complete!"
echo "Activate the environment anytime with: source .venv/bin/activate"
echo "VS Code is configured to use this .venv for terminals and notebooks."