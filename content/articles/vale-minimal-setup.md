+++
categories = ["automation", "documentation", "programming"]
date = "2026-10-25T07:16:00+01:00"
description = "Vale for spelling and style checking"
draft = true
slug = "vale"
tags = ["automation", "documentation", "markdown"]
title = "Starting with Vale for Linting Prose"
+++

[Vale](https://vale.sh/) is a single tool that provides spelling, grammar and style guide checks for text files, such as
source code, Markdown and Jupyter notebooks. We can run it in text editors, on the command-line and in continuous
integration pipelines. This ensures that the prose in every document follows the same standards.

## Installing Vale

A copy of Vale is a single executable file. The project provides versions for Linux, macOS and Microsoft Windows.

You can install Vale on Linux and macOS with [Homebrew](https://brew.sh/). Homebrew always installs the latest version
of Vale:

```shell
brew install vale
```

> The Vale packages for Python and `npm` are not maintained by the project. These packages may provide older versions of
> Vale.

## Example Configuration Files for Vale

This example configuration file for a project enables the features that Vale provides, including
[checking spelling](https://docs.vale.sh/checks/spelling) with US English, and style checks from the
[write-good](https://vale.sh/explorer/write-good) package:

```ini
StylesPath = .vale/styles
MinAlertLevel = suggestion
Packages = write-good

[*.md]
BasedOnStyles = Vale, write-good
```

Add these lines to the `.gitignore` file for your project:

```text
# Vale
.vale/styles/
```

The `styles` directory holds copies of downloaded Vale style packages, such as
[write-good](https://vale.sh/explorer/write-good). Run the `sync` command to download the style packages:

```shell
vale sync
```

## Using Vale in Your Editor

Set up integrations with your text editors to automatically receive feedback as you work and enable the editor to format
Markdown documents with Vale.

### Enabling Visual Studio Code Integration

To use Vale with Visual Studio Code or a compatible editor, install the
[vale-vscode](https://github.com/chrischinchilla/vale-vscode) extension.

### Enabling Integration with JetBrains IDEs

To enable support for Vale in JetBrains IDEs such as PyCharm, install the
[vale-cli](https://plugins.jetbrains.com/plugin/19613-vale-cli/docs) plugin.

## Automating Checks with `prek` or `pre-commit`

To automate checks for your project, you can add Git hooks. The most popular tools for managing hooks are
[prek](https://prek.j178.dev/) and [pre-commit](https://pre-commit.com/). The [prek](https://prek.j178.dev/) tool
supersedes [pre-commit](https://pre-commit.com/). It can use existing `pre-commit` hooks, and also works with existing
`pre-commit` project configurations.

This example `.pre-commit-config.yaml` configuration file for a project uses the copy of Vale on the system:

```yaml
---
minimum_prek_version: "0.4.0"

repos:
  - repo: builtin
    hooks:
      - id: check-added-large-files
      - id: check-case-conflict
      - id: check-illegal-windows-names
      - id: check-json
      - id: check-merge-conflict
      - id: check-symlinks
      - id: check-toml
      - id: check-vcs-permalinks
      - id: check-xml
      - id: check-yaml
      - id: destroyed-symlinks
      - id: end-of-file-fixer
      - id: fix-byte-order-marker
      - id: mixed-line-ending
      - id: trailing-whitespace

  - repo: local
    hooks:
      - id: vale-sync
        name: vale sync
        language: system
        pass_filenames: false
        entry: vale
        args: [sync]

      - id: vale-check
        name: vale check
        language: system
        entry: vale
        # Override the .vale.ini configuration file
        args: [--output=line, --minAlertLevel=error]
        types: [markdown]
```

> For security, the example above uses `builtin` hooks. To make it compatible with `pre-commit`, you would need to
> replace these with [remote hooks](https://github.com/pre-commit/pre-commit-hooks).

To run a tool without committing a change, use `prek run`. If you add the option `--all-files` it will check the current
files in the project, not just staged changes. For example, to run the `vale-check` hook on the project, use this
command:

```shell
prek run vale-check --all-files
```

To run every hook on the project, use this command:

```shell
prek run --all-files
```
