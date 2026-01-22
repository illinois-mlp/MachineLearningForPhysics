#!/usr/bin/env bash
set -e

echo "=== MachineLearningForPhysics: VENV Setup ==="

OS="$(uname)"
echo "Detected OS: $OS"

# --- macOS setup ---
if [[ "$OS" == "Darwin" ]]; then
    echo "Setting up for macOS..."
    
    # Ensure Python 3.11 is installed via Homebrew
    if ! command -v python3.11 >/dev/null 2>&1; then
        echo "Installing Python 3.11 via Homebrew..."
        brew install python@3.11
    fi
    
    python3.11 -m venv .venv
    source .venv/bin/activate
    
    # Install HDF5 if not already installed
    brew list hdf5 >/dev/null 2>&1 || brew install hdf5
    export HDF5_DIR="$(brew --prefix hdf5)"

# --- Linux / Ubuntu setup ---
elif [[ "$OS" == "Linux" ]]; then
    echo "Setting up for Ubuntu/Linux..."
    
    # Use system Python 3.13 for Ubuntu 23.10+
    if ! command -v python3 >/dev/null 2>&1; then
        echo "Please install Python 3 first!"
        exit 1
    fi

    PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    echo "System Python version: $PYTHON_VERSION"

    python3 -m venv .venv
    source .venv/bin/activate

else
    echo "Unsupported OS: $OS"
    exit 1
fi

# --- Common setup ---
echo "Upgrading pip, wheel, setuptools..."
pip install --upgrade pip wheel setuptools

echo "Installing Python packages..."
pip install numpy pandas matplotlib scipy tables seaborn scikit-learn jupyter notebook jupyter-book

# Optional: install requirements-freeze.txt if present
if [[ -f requirements-freeze.txt ]]; then
    echo "Installing pinned dependencies from requirements-freeze.txt..."
    pip install -r requirements-freeze.txt
else
    echo "No requirements-freeze.txt found — skipping"
fi

# --- Configure VS Code ---
mkdir -p .vscode
cat > .vscode/settings.json <<EOL
{
    "python.pythonPath": "\${workspaceFolder}/.venv/bin/python",
    "python.terminal.activateEnvironment": true
}
EOL

echo "✅ Setup complete! Activate with: source .venv/bin/activate"

