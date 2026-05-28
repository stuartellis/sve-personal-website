+++
title = "Using Container Images with prek and pre-commit"
slug = "prek-containers"
date = "2026-05-28T06:37:00+01:00"
draft = true
description = "Using container images with Git hooks"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

The [prek](https://prek.j178.dev/) tool manages Git hooks and enables you to run the same actions at any time, not just when you commit changes. It can download the other runtimes and tools that the hooks need. This means that it can provide a cross-platform way to install and run a complete set of tools for formatting and checking code. To avoid supply chain attacks and manage the tools more efficiently, use container images to provide the tools.

> The [prek](https://prek.j178.dev/) tool supersedes [pre-commit](https://pre-commit.com/). It can use hooks that are written for `pre-commit`, and works with existing `pre-commit` project configurations.

## Installing prek

To install `prek`, use either [Homebrew](https://brew.sh/) or a [version manager tool](https://www.stuartellis.name/articles/version-managers/):

```shell
brew install prek
```

## Adding Hooks To a Project

> Both `prek` and `pre-commit` use a `.pre-commit-config.yaml` file if it is present. By default, the configuration file for `prek` is `prek.toml`.

Create the hooks configuration in a file called `.pre-commit-config.yaml` file. Save this file in the root directory of your project:

```yaml
---
repos:
  - repo: builtin
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-json
      - id: check-toml
      - id: check-yaml
      - id: check-added-large-files
```

This configuration enables built-in hooks.

To activate the configuration, run `prek install`. This adds the hooks to the Git configuration for your copy of the project, so that the tools automatically run on the staged changes each time that you commit.

```shell
cd my-project
prek install
```

> Since the configuration file is YAML, it can automatically be formatted and checked by the same tools that the hook manager runs itself.

## Using Hooks

The tools automatically run on the staged changes each time that you commit. To run a tool without commiting a change, use `prek run`. If you add the option `--all-files` it will check the current files in the project, not just staged changes.

For example, to run the `check-json` hook on the project, use this command:

```shell
prek run check-json --all-files
```

To run all of the hooks on the project, use this command:

```shell
prek run --all-files
```

## Updating Hooks

To update all of the hooks to their current version, run this command:

```shell
prek auto-update
```

It automatically edits the configuration file to update the versions of the hooks. You then commit this change to source control, so that other copies of the repository will use the same versions.

## Resources

- The [prek documentation](https://prek.j178.dev/)
