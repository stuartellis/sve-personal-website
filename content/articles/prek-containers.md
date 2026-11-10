+++
categories = ["automation", "containers", "devops", "programming"]
date = "2026-11-09T07:21:00+01:00"
description = "Using container images with Git hooks"
slug = "prek-containers"
tags = ["automation", "containers", "devops"]
title = "Using Container Images with prek and pre-commit"
+++

The [prek](https://prek.j178.dev/) tool manages Git hooks, and enables you to run the same hooks whenever you wish, not
just when you commit changes. This means that it can provide a cross-platform way to install and run a set of tools for
formatting and checking your code.

For security and consistency, use container images to provide the tools for these hooks. This ensures that the
contributors to a project run the same container images, and that CI systems also use those same images. For better
supply chain security, you can specify images that you distribute through your own container registries.

> The [prek](https://prek.j178.dev/) tool supersedes [pre-commit](https://pre-commit.com/). It can use the same hooks as
> `pre-commit`, and works with existing `pre-commit` project configurations.

## Installing prek

> Running [docker_image](https://prek.j178.dev/languages/#docker_image) or
> [docker](https://prek.j178.dev/languages/#docker) hooks requires a container runtime such as Podman, Docker or Apple
> Container. By default, `prek`
> [automatically detects the container runtime](https://prek.j178.dev/reference/environment-variables/#prek_container_runtime).

To install `prek` on a development system, use the packages from the [npm](https://www.npmjs.com/package/@j178/prek) or
[Python](https://pypi.org/project/prek/) registries. If you use a package management tool like
[npm](https://docs.npmjs.com/cli), [pipx](https://pipx.pypa.io/stable/), or [uv](https://docs.astral.sh/uv/), you can
specify which version of `prek` it installs:

```shell
npm install -g @j178/prek@0.5.10
```

```shell
pipx install prek==0.5.10
```

The `prek` project releases [container images](https://prek.j178.dev/integrations/#docker), so that you can run the same
hooks on your CI system, using the same version of `prek` that you run on development systems.

You can also install `prek` with [Homebrew](https://brew.sh/). Homebrew always installs the latest version of `prek`:

```shell
brew install prek
```

## Adding prek to a Project

By default, `prek` uses the configuration file `prek.toml`. Both `prek` and `pre-commit` can use a
`.pre-commit-config.yaml` file. Consider using the YAML format, because the YAML maintenance tools that the hook manager
runs for other products will then run on the configuration.

Create the hooks configuration in a file called `.pre-commit-config.yaml` file. Save this file in the root directory of
your project:

```yaml
---
minimum_prek_version: "0.5.0"

repos:
  - repo: builtin
    hooks:
      - id: check-added-large-files
      - id: check-case-conflict
      - id: check-json
      - id: check-json5
      - id: check-jsonc
      - id: check-merge-conflict
      - id: check-symlinks
      - id: check-toml
      - id: check-vcs-permalinks
      - id: check-xml
      # Allow multiple documents in a file when using GitLab Pipelines
      - id: check-yaml
        args: [--allow-multiple-documents]
      - id: destroyed-symlinks
      - id: end-of-file-fixer
      - id: fix-byte-order-marker
      - id: mixed-line-ending
      - id: trailing-whitespace
```

This configuration enables [built-in to `prek`](https://prek.j178.dev/builtin/) hooks. You can then add
[docker_image](https://prek.j178.dev/languages/#docker_image) hooks to run other tools with container images.

> To make this example configuration compatible with `pre-commit`, you would need to replace the `builtin` hooks with
> [remote hooks](https://github.com/pre-commit/pre-commit-hooks).

To activate the configuration, run `prek install`. This adds the hooks to the Git configuration for your copy of the
project, so that the tools automatically run on the staged changes each time that you commit.

```shell
cd my-project
prek install
```

## Adding Hooks to a Project

To add a hook that uses a container image, you can either specify a remote hook configuration that uses containers, or
define the hook directly in the configuration file. Many Open Source projects provide remote hook configurations for the
tools that they produce.

> Once you create a configuration file with remote Git hooks, run `prek update --freeze`. This replaces the version
> `refs` of any remote hooks with hashes, which protects you from supply-chain attacks against the remote hook
> repositories.

If possible, avoid using remote hook configurations altogether. Instead, create hooks in your `prek` configuration
files. This enables you to have full control over the configuration of the hook and which container image it runs.

For example, you may want to use a hook to detect secrets in code, and decide to use the latest version of
[Betterleaks](https://betterleaks.com/) for this. The Betterleaks project provides three hooks in the
[remote hook configuration](https://raw.githubusercontent.com/betterleaks/betterleaks/refs/heads/main/.pre-commit-hooks.yaml)
that it publishes:

```yaml
- id: betterleaks
  name: Detect hardcoded secrets
  description: Detect hardcoded secrets using Betterleaks
  entry: bash -o pipefail -c 'git diff --cached --no-ext-diff --no-textconv --no-color --src-prefix=a/ --dst-prefix=b/ | betterleaks stdin --git-diff --redact'
  language: golang
  pass_filenames: false

# This pinned release retains its legacy staged command until the next image release.
- id: betterleaks-docker
  name: Detect hardcoded secrets
  description: Detect hardcoded secrets using Betterleaks
  entry: ghcr.io/betterleaks/betterleaks:v2.0.0-rc.1 git --staged --redact
  language: docker_image
  pass_filenames: false

- id: betterleaks-system
  name: Detect hardcoded secrets
  description: Detect hardcoded secrets using Betterleaks
  entry: bash -o pipefail -c 'git diff --cached --no-ext-diff --no-textconv --no-color --src-prefix=a/ --dst-prefix=b/ | betterleaks stdin --git-diff --redact'
  language: system
  pass_filenames: false
```

You could call the `docker_image` hook as a remote hook, but it is safer to copy the hook into a configuration file for
your project. You can then specify the exact container image that your project hook uses.

To copy a hook, take the configuration for that hook and add it to the `hooks` that are listed under the section for
`repo: local`.

Once you have copied the hook, look up the current version of the product. Many remote hooks specify an older version of
a product, because the file is not changed as new versions are released. Use the container image for the current
version. Newer versions of products may have slightly different command options. For example, current versions of
`betterleaks` do not use the `--staged` option.

Always use the SHA index digest to specify the image, rather than `latest` or a version tag. If an attacker gains access
to the container registry they might change the image tags to point to images that contain malware. You can see the SHA
digests for a container image in the Web interface of the container registry that publishes it, or by running the
`inspect` command for Podman or Docker:

```shell
podman inspect ghcr.io/betterleaks/betterleaks:v2.0.0-rc.7
```

The `inspect` command outputs the details of the image in JSON format. The `Digest` attribute provides the SHA digest
that you use to identify the exact image:

```json
[
     {
          "Id": "a74bae16d053205e049bf86756e0797ffe9a94d3aa973743230ef736e4d04ec3",
          "Digest": "sha256:af51ddce3addcce5656a550c51e6476e5fe028dc142ef2ebe2d8c766d6bd14ef",
          "RepoTags": [
               "ghcr.io/betterleaks/betterleaks:v2.0.0-rc.7"
          ],
```

Here is a complete example of a project configuration file:

<!-- rumdl-disable MD013 -->

```yaml
---
minimum_prek_version: "0.5.0"

repos:
  - repo: builtin
    hooks:
      - id: check-added-large-files
      - id: check-case-conflict
      - id: check-illegal-windows-names
      - id: check-json
      - id: check-json5
      - id: check-jsonc
      - id: check-merge-conflict
      - id: check-symlinks
      - id: check-toml
      - id: check-vcs-permalinks
      - id: check-xml
        # Allow multiple documents in a file when using GitLab Pipelines
      - id: check-yaml
        args: [--allow-multiple-documents]
      - id: destroyed-symlinks
      - id: end-of-file-fixer
      - id: fix-byte-order-marker
      - id: mixed-line-ending
      - id: trailing-whitespace

  - repo: local
    hooks:
      - id: betterleaks
        name: Detect hardcoded secrets
        description: Detect hardcoded secrets using Betterleaks
        entry: ghcr.io/betterleaks/betterleaks@sha256:af51ddce3addcce5656a550c51e6476e5fe028dc142ef2ebe2d8c766d6bd14ef git --redact
        language: docker_image
        pass_filenames: false
```

<!-- rumdl-enable MD013 -->

If a project does not provide a `docker_image` hook, you can copy the configuration for a hook that they publish, and
adapt it. To convert a hook configuration to use a container image, set the `language` to `docker_image` and update the
entry to start with required container image, like this:

<!-- rumdl-disable MD013 -->

```yaml
entry: ghcr.io/betterleaks/betterleaks@sha256:af51ddce3addcce5656a550c51e6476e5fe028dc142ef2ebe2d8c766d6bd14ef git --redact
language: docker_image
```

<!-- rumdl-enable MD013 -->

You can replace the container image that a hook uses at any time.

### Container Images and CPU Architectures

To avoid issues with different systems using different CPU architectures, use _multi-architecture_ container images
where possible.

If you cannot, container images may run with CPU emulation. Docker Desktop automatically emulates the required CPU
architecture as needed, but other runtimes like Podman require extra configuration to run images with CPU emulation.

## Using Hooks

The hooks automatically run on the staged changes each time that you commit. To run a tool without commiting a change,
use `prek run`. If you add the option `--all-files` it will check the current files in the project, not just staged
changes.

For example, to run the `betterleaks` hook on the project, use this command:

```shell
prek run betterleaks --all-files
```

To run every hook on the project, use this command:

```shell
prek run --all-files
```
