#!/usr/bin/env sh

# SPDX-FileCopyrightText: 2024-present Stuart Ellis <stuart@stuartellis.name>
#
# SPDX-License-Identifier: MIT
#
# Bootstrap Dev Container environment
#
# This installs just and Trivy,
# then immediately runs the bootstrap recipe in the project justfile.
#
# Example:
#
# sh .devcontainer/bootstrap.sh
#
# Websites:
#
# just: https://just.systems
# Trivy: https://aquasecurity.github.io/trivy
#

set -eu

BIN_DIR=$HOME/.local/bin
JUST_VERSION=$(python3 -c "import tomllib; print(tomllib.load(open('pyproject.toml', 'rb'))['tool']['project']['utilities']['just'])")
TRIVY_VERSION=$(python3 -c "import tomllib; print(tomllib.load(open('pyproject.toml', 'rb'))['tool']['project']['utilities']['trivy'])")

# Install just
sh ./.devcontainer/install-just.sh --to "$BIN_DIR" --tag "$JUST_VERSION" --force
just --completions bash >> "$HOME/.bashrc"

# Install Trivy
sh ./.devcontainer/install-trivy.sh --to "$BIN_DIR" --tag "$TRIVY_VERSION" --force

# Run just recipe
just bootstrap
