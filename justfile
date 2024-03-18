# SPDX-FileCopyrightText: 2024-present Stuart Ellis <stuart@stuartellis.name>
#
# SPDX-License-Identifier: MIT
#
# Configuration for the just task runner
#
# See https://just.systems

mod hugo
mod pre-commit
mod project

# List available recipes
help:
    @just --unstable --list

# Install tools and dependencies, then set up environment for development
bootstrap:
    @just --unstable install
    @just --unstable setup

# Build artifacts
build:
    @just --unstable hugo::build

# Delete generated files
clean:
    @just --unstable hugo::clean
    @just --unstable project::clean

# Run test coverage analysis
coverage:
    @echo "Not implemented"

# Deploy Website
deploy:
    @just --unstable hugo::deploy

# Display documentation in a Web browser
doc:
    @just --unstable hugo::serve

# Format code
fmt:
    @echo "Not implemented"

# Install project tools and dependencies
install:
    @echo "Not implemented"

# Run all checks
lint:
    @just --unstable pre-commit::check

# Set up environment for development
setup:
    @just --unstable pre-commit::setup

# Run tests for project
test:
    @just --unstable lint
