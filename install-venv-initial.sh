#!/usr/bin/env bash
# =============================================================================
# install-venv-initial.sh
#
# Detects OS and sets up a Python virtual environment for MachineLearningForPhysics
# macOS → Python 3.11 (auto-installed if missing)
# Ubuntu → Python 3.13
# Installs scientific packages and configures VS Code auto-activation
# =============================================================================

set -e
set -o pipefail

echo "=== MachineLearningForPhysics: VENV Setup ==="

OS="$(uname -s)"
echo "Detected OS: $OS"

if [[ "$OS" == "Darwin" ]]; then
    echo "Setting up for macOS..."

    # Check if python3.11 exists
    if ! command -v python3.11 >/dev/null 2>&1; then
        echo "Python 3.11 not found. Installing via Homebrew..."
        brew install python@3.11
    fi

    PYTHON=python3.11

    # Ensure Python 3.11 is first in PATH
    export PATH="/usr/local/opt/python@3.11/bin:$PATH"

    # Verify version
    PYTHON_VERSION=$($PYTHON -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if [[ "$PYTHON_VERSION" != "3.11" ]]; then
        echo "❌ Failed to set Python 3.11 in PATH. Detected Python $PYTHON_VERSION."
        exit 1
    fi

    # Install HDF5 via Homebrew if missing
    if ! brew list hdf5 >/dev/null 2>&1; then
        echo "Installing HDF5..."
        brew install hdf5
    fi
    export HDF5_DIR="$(brew --prefix hdf5)"

elif [[ "$OS" == "Linux" ]]; then
    echo "Setting up for Ubuntu/Linux..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-venv python3-dev python3-pip build-essential pkg-config libhdf5-dev
    PYTHON=python3

else
    echo "❌ Unsupported OS: $OS"
    exit 1
fi

# Remove old venv if exists
rm -rf .venv

# Create new virtual environment
echo "Creating virtual environment .venv with $PYTHON..."
$PYTHON -m venv .venv

# Activate venv
source .venv/bin/activate
echo "Virtual environment activated."
python --version
pip --version

# Upgrade pip, wheel, setuptools
echo "Upgrading pip, wheel, setuptools..."
python -m pip install --upgrade pip wheel setuptools

# Install scientific packages
echo "Installing scientific packages..."
pip install numpy pandas matplotlib scipy tables seaborn scikit-learn jupyter notebook jupyterlab jupyter-book

# Optional: install frozen requirements if present
if [ -f requirements-freeze.txt ]; then
    echo "Installing frozen requirements from requirements-freeze.txt..."
    pip install -r requirements-freeze.txt
else
    echo "No requirements-freeze.txt found — skipping."
fi

# Configure VS Code auto-activation
mkdir -p .vscode
cat > .vscode/settings.json <<'EOL'
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true
}
EOL

echo "✅ Setup complete!"
echo "Activate the venv anytime with: source .venv/bin/activate"
python --version
pip --version

