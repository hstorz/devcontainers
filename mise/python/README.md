# Python Projects

## Prerequisites

Install mise: https://mise.jdx.dev/getting-started.html

```bash
# macOS
brew install mise

# Linux
curl https://mise.run | sh
```

## Setup

```bash
# Install Python (defined in mise.toml)
mise install

# Create virtual environment and install dependencies
mise run setup

# Or install dependencies manually:
pip install -r requirements.txt
```

## Install all Dependencies

```bash
pip install -r requirements.txt
```

## Usage

Activate the virtual environment:

```bash
source .venv/bin/activate
```

Run Python scripts:

```bash
python example.py
```

Deactivate when done:

```bash
deactivate
```
