+++
title = "Using Container Images with prek and pre-commit"
slug = "prek-containers"
date = "2026-06-01T22:35:00+01:00"
description = "Using container images with Git hooks"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

The [prek](https://prek.j178.dev/) tool manages Git hooks, and enables you to run the same hooks at any time, not just when you commit changes. It downloads the tools and runtimes for the hooks as needed. This means that it can provide a cross-platform way to install and run a complete set of tools for formatting and checking code.

For security and consistency, use container images to provide the tools that are used by these hooks. This ensures that all of the contributors to a project run the same container images, and that CI systems also use those same images. For better supply chain security, you can specify images that are distributed through your own container registries.

> The [prek](https://prek.j178.dev/) tool supersedes [pre-commit](https://pre-commit.com/). It can use hooks that are written for `pre-commit`, and works with existing `pre-commit` project configurations.

## Installing prek

> Running [docker_image](https://prek.j178.dev/languages/#docker_image) or [docker](https://prek.j178.dev/languages/#docker) hooks requires Podman, Docker or Apple Container. By default, the [container runtime will automatically be detected](https://prek.j178.dev/reference/environment-variables/#prek_container_runtime).

To install `prek` on a development system, use the packages from the [npm](https://www.npmjs.com/package/@j178/prek) or [Python](https://pypi.org/project/prek/) registries. If you use a package management tool like [npm](https://docs.npmjs.com/cli), [pipx](https://pipx.pypa.io/stable/), or [uv](https://docs.astral.sh/uv/), you can specify which version of `prek` it installs:

```shell
npm install -g @j178/prek@0.4.3
```

```shell
pipx install prek==0.4.3
```

The `prek` project releases [container images](https://prek.j178.dev/integrations/#docker), so that you can run the same hooks on your CI system, using the same version of `prek` that you run on development systems.

You can also install `prek` with [Homebrew](https://brew.sh/). Homebrew always installs the latest version of `prek`:

```shell
brew install prek
```

## Adding prek To a Project

By default, the configuration file for `prek` is `prek.toml`. Both `prek` and `pre-commit` use a `.pre-commit-config.yaml` file, if it is present. Consider using the YAML format, because it can automatically be formatted and checked by the same YAML maintenance tools that the hook manager runs for other products that use YAML.

Create the hooks configuration in a file called `.pre-commit-config.yaml` file. Save this file in the root directory of your project:

```yaml
---
minimum_prek_version: "0.4.0"

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

This configuration enables hooks that are [built-in to `prek`](https://prek.j178.dev/builtin/). You can then add [docker_image](https://prek.j178.dev/languages/#docker_image) hooks to run other tools with container images.

To activate the configuration, run `prek install`. This adds the hooks to the Git configuration for your copy of the project, so that the tools automatically run on the staged changes each time that you commit.

```shell
cd my-project
prek install
```

### Adding Hooks

To add a hook that uses a container image, you can either specify a remote hook configuration that uses containers, or define the hook directly in the configuration file. Many Open Source projects provide remote hook configurations for the tools that they produce.

Avoid using remote hook configurations. Instead, create hooks in your `prek` configuration files. This enables you to have full control over the configuration of the hook and which container image it runs.

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
minimum_prek_version: "0.4.0"

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

Here, we use the SHA index digest to specify the version of the image, rather than `latest` or a version tag. If a container repository is compromised by an attacker, the attacker may change the image tags to point to images that contain malware. You can see the SHA digests for a container image in the Web interface of the container registry that publishes it. For example, Gitleaks is published to Docker Hub, and the tags are listed on [this page](https://hub.docker.com/r/zricethezav/gitleaks/tags).

> To avoid issues with different systems using different CPU architectures, use _multi-architecture_ container images where possible. If you cannot, container images may run with CPU emulation. Docker Desktop automatically emulates the required CPU architecture as needed, but other runtimes like Podman require extra configuration to run images with CPU emulation.

If a project does not provide a `docker_image` hook, you can copy the configuration for a hook that they publish, and adapt it. To convert a hook configuration to use a container image, the `language` must be set to `docker_image` and the entry must start with the required container image, like this:

```yaml
entry: zricethezav/gitleaks@sha256:c00b6bd0aeb3071cbcb79009cb16a60dd9e0a7c60e2be9ab65d25e6bc8abbb7f git --pre-commit --redact --staged --verbose
language: docker_image
```

You can replace the container image that a hook uses at any time. This example uses the [Docker Hardened Image for gitleaks](https://hub.docker.com/hardened-images/catalog/dhi/gitleaks/images), which is a multi-architecture image:

```yaml
- repo: local
  hooks:
    - id: gitleaks-docker
      name: Detect hardcoded secrets
      description: Detect hardcoded secrets using Gitleaks
      entry: dhi.io/gitleaks:8@sha256:3ffd6debb567b711bb6cd741caf084d76904ece99f7fe88d906cc57501b53469 git --pre-commit --redact --staged --verbose
      language: docker_image
      pass_filenames: false
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
