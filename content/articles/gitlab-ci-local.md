+++
title = "Running GitLab Pipelines Locally with gitlab-ci-local"
slug = "gitlab-ci-local"
date = "2026-03-23T06:56:00+00:00"
description = "Running GitLab Pipelines on local systems with gitlab-ci-local"
categories = ["automation", "devops", "gitlab", "programming"]
tags = ["automation", "devops", "gitlab"]
+++

[gitlab-ci-local](https://github.com/firecow/gitlab-ci-local) is a command-line tool that enables you to run [GitLab Pipelines](https://docs.gitlab.com/ee/ci/pipelines/) on any computer. It works without a GitLab installation and only requires Docker or Podman on the system. This means that you can run the same pipelines on your laptop and on test systems, as well as on any instance of GitLab, including [GitLab.com](https://gitlab.com).

> The `gitlab-ci-local` tool is maintained by an independent Open Source project. It is not a supported product of GitLab, Inc.

## How It Works

[gitlab-ci-local](https://github.com/firecow/gitlab-ci-local) is a command-line tool that run pipelines with any Git repository that contains a `gitlab-ci.yml` file. It runs on Microsoft Windows, macOS and Linux.

It implements the features of [GitLab Pipelines](https://docs.gitlab.com/ee/ci/pipelines/), including:

- [Components](https://docs.gitlab.com/ci/components/)
- [Services](https://docs.gitlab.com/ci/services/)
- [Parallel jobs](https://docs.gitlab.com/ci/yaml/#parallel), with support for [matrix expressions](https://docs.gitlab.com/ci/yaml/matrix_expressions/)
- [Artifact](https://docs.gitlab.com/ci/jobs/job_artifacts/) creation

If the pipeline configuration specifies container images to use, the `gitlab-ci-local` tool acts as a [Docker executor](https://docs.gitlab.com/runner/executors/docker/). This means that it will use Docker or Podman to pull the specified images and run the jobs in containers. If the pipeline configuration does not specify any images or you set the option to force shell execution then it runs as a [Shell executor](https://docs.gitlab.com/runner/executors/shell/).

For example, this GitLab Pipelines file specifies a default `image`, so `gitlab-ci-local` will run it, acting as a Docker executor:

```yaml
---
image: python:3.14.3-slim-trixie

include:
  - component: $CI_SERVER_FQDN/components/secret-detection/secret-detection@2.3.0

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  paths:
    - .cache/pip

check-python:
  stage: build
  script:
    - which python3
    - python3 --version
```

If you set the working directory to the project and enter `gitlab-ci-local`, it will run all of the jobs in the pipeline configuration:

```shell
gitlab-ci-local
```

> The tool creates artifacts and compiled pipeline definitions in the `.gitlab-ci-local/` directory in the project. Exclude this directory from version control.

The `--list-all` option shows the jobs in the GitLab configuration:

```shell
$ gitlab-ci-local --list-all
parsing and downloads finished in 105 ms.
json schema validated in 495 ms
name              description  stage   when        allow_failure  needs
check-python                   build   on_success  false
secret_detection               test    always      true
```

You set variables for pipelines either in [files or as environment variables](https://github.com/firecow/gitlab-ci-local?tab=readme-ov-file#cli-options). You can set configuration options for `gitlab-ci-local` in the same ways, as well as by passing options on the command-line.

## Setting Up gitlab-ci-local

You can install `gitlab-ci-local` on macOS or Linux with [Homebrew](https://brew.sh/):

```shell
brew install gitlab-ci-local
```

You can also install `gitlab-ci-local` on any supported operating system that has [NodeJS](https://nodejs.org) by using `npm`:

```shell
npm install -g gitlab-ci-local
```

> To run on Windows systems, `gitlab-ci-local` requires [additional tools](https://github.com/firecow/gitlab-ci-local?tab=readme-ov-file#windows-git-bash) to be installed.

If you are using [Podman](https://podman.io/) you must either specify Podman with the `--container-executable` option, or enable an alias, so that Podman responds to the `docker` command. On Red Hat-based Linux systems, you add the alias by installing the `docker-podman` package:

```shell
dnf install docker-podman
```

### Enabling Autocompletion

To enable autocompletion in a shell, use `gitlab-ci-local --completion`. This command adds autocompletion for Bash shells:

```shell
gitlab-ci-local --completion >> ~/.bashrc
```

> Bash is currently the only type of shell that is supported for autocompletion.

## Using gitlab-ci-local

If you set the working directory to the project and enter `gitlab-ci-local`, it will run all of the jobs in the pipeline configuration:

```shell
gitlab-ci-local
```

To run a specific job, add the name of the job:

```shell
gitlab-ci-local secret_detection
```

To run all of the jobs for a specific stage, use the `--stage` option:

```shell
gitlab-ci-local --stage test
```

The `--list-all` option shows the jobs in the GitLab configuration:

```shell
$ gitlab-ci-local --list-all
parsing and downloads finished in 105 ms.
json schema validated in 495 ms
name              description  stage   when        allow_failure  needs
check-python                   build   on_success  false
secret_detection               test    always      true
```

## Documentation

- [The README file for the project](https://github.com/firecow/gitlab-ci-local)
- [The DeepWiki summary of the project architecture and features](https://deepwiki.com/firecow/gitlab-ci-local)
