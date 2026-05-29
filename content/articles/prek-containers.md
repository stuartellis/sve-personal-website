+++
title = "Using Container Images with prek and pre-commit"
slug = "prek-containers"
date = "2026-05-29T08:23:00+01:00"
description = "Using container images with Git hooks"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

The [prek](https://prek.j178.dev/) tool manages Git hooks and enables you to run the same actions at any time, not just when you commit changes. It can download the other runtimes and tools that the hooks need. This means that it can provide a cross-platform way to install and run a complete set of tools for formatting and checking code.

For security and consistency, use container images to provide the tools. This ensures that all of the contributors to a project run the same container images, and that CI systems also use those images. For better supply chain security, you can specify images that are distributed through your own container registries.

> The [prek](https://prek.j178.dev/) tool supersedes [pre-commit](https://pre-commit.com/). It can use hooks that are written for `pre-commit`, and works with existing `pre-commit` project configurations.

## Set Up

> Running [docker_image](https://prek.j178.dev/languages/#docker_image) or [docker](https://prek.j178.dev/languages/#docker) hooks requires either Podman or Docker.

### Installing prek

To install `prek`, use either [Homebrew](https://brew.sh/) or a [version manager tool](https://www.stuartellis.name/articles/version-managers/):

```shell
brew install prek
```

### Adding prek To a Project

> Both `prek` and `pre-commit` use a `.pre-commit-config.yaml` file, if it is present. By default, the configuration file for `prek` is `prek.toml`.

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

This configuration enables hooks that are built-in to `prek`. You can then add [docker_image](https://prek.j178.dev/languages/#docker_image) hooks to run other tools with container images.

To activate the configuration, run `prek install`. This adds the hooks to the Git configuration for your copy of the project, so that the tools automatically run on the staged changes each time that you commit.

```shell
cd my-project
prek install
```

> Since this configuration file is YAML, it can automatically be formatted and checked by YAML maintenance tools that the hook manager runs itself.

## Adding Hooks

To add a hook that uses a container image, you can either specify a remote hook configuration that uses containers, or define the hook directly in the configuration file. Many Open Source projects provide remote hook configurations for the tools that they produce.

Avoid using remote hook configurations. The remote configuration could be changed by either the maintainer or anyone who gains access to the remote repository. You can create hooks in your `prek` configuration files that have the same behaviour as a remote hook configuration. This also enables you to have full control over which container image is used by the hook.

For example, you may want to use a hook to detect secrets in code, and decide to use [gitleaks](https://gitleaks.io/) for this. The Gitleaks project provides three hooks in the [remote hook configuration](https://raw.githubusercontent.com/gitleaks/gitleaks/refs/heads/master/.pre-commit-hooks.yaml) that it publishes:

```yaml
- id: gitleaks
  name: Detect hardcoded secrets
  description: Detect hardcoded secrets using Gitleaks
  entry: gitleaks git --pre-commit --redact --staged --verbose
  language: golang
  pass_filenames: false
- id: gitleaks-docker
  name: Detect hardcoded secrets
  description: Detect hardcoded secrets using Gitleaks
  entry: zricethezav/gitleaks git --pre-commit --redact --staged --verbose
  language: docker_image
  pass_filenames: false
- id: gitleaks-system
  name: Detect hardcoded secrets
  description: Detect hardcoded secrets using Gitleaks
  entry: gitleaks git --pre-commit --redact --staged --verbose
  language: system
```

You could call the `docker_image` hook as a remote hook, but it would be safer to copy the hook into your own configuration file. You can then specify the exact container image that your project hook uses. Here is an example of a complete configuration file:

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

  - repo: local
    hooks:
      - id: gitleaks-docker
        name: Detect hardcoded secrets
        description: Detect hardcoded secrets using Gitleaks
        entry: zricethezav/gitleaks@sha256:c00b6bd0aeb3071cbcb79009cb16a60dd9e0a7c60e2be9ab65d25e6bc8abbb7f git --pre-commit --redact --staged --verbose
        language: docker_image
        pass_filenames: false
```

We use the SHA index digest to specify the version of the image, rather than `latest` or a version tag. Tags can be updated to point to new images. If a container repository is compromised by an attacker, the attacker may change the image tags to point to images that contain malware.

> You can see the SHA digest for a container image in the Web interface of the container registry that publishes it. For example, Gitleaks is published to Docker Hub, and the tags are listed on [this page](https://hub.docker.com/r/zricethezav/gitleaks/tags).

If a project does not provide a `docker_image` hook, you can copy the configuration for a hook that they publish, and adapt it. To convert a hook configuration to use a container image, the `language` must be set to `docker_image` and the entry must start with the required container image, like this:

```yaml
entry: zricethezav/gitleaks@sha256:c00b6bd0aeb3071cbcb79009cb16a60dd9e0a7c60e2be9ab65d25e6bc8abbb7f git --pre-commit --redact --staged --verbose
language: docker_image
```

## Using Hooks

The hooks automatically run on the staged changes each time that you commit. To run a tool without commiting a change, use `prek run`. If you add the option `--all-files` it will check the current files in the project, not just staged changes.

For example, to run the `check-json` hook on the project, use this command:

```shell
prek run check-json --all-files
```

To run all of the hooks on the project, use this command:

```shell
prek run --all-files
```

## Resources

- The [prek documentation](https://prek.j178.dev/)
