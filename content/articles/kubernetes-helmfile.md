+++
title = "Managing Kubernetes Configurations with Helmfile"
slug = "kubernetes-helmfile"
date = "2025-07-06T09:57:00+01:00"
description = "Managing Kubernetes configurations with Helmfile"
draft = true
categories = ["automation", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "kubernetes"]
+++

[Helmfile](https://helmfile.readthedocs.io/en/stable/) is a command-line tool for deploying sets of configuration to Kubernetes clusters. Many administrators use [GitOps](https://www.gitops.tech/) systems like [Flux](https://fluxcd.io/flux/) or [Argo CD](https://argo-cd.readthedocs.io/en/stable/) that run on a cluster and continuously apply a configuration. You can deploy a GitOps system on a cluster with Helmfile, or use it to manage all of the configuration of the cluster. For example, you could use Helmfile to manage development Kubernetes clusters on laptops, or as part of a CI process that deploys a configuration to clusters on demand.

## Requirements

Helmfile itself is a single executable file. It does rely on [Helm](https://helm.sh) and several plugins for Helm:

- [diff](https://github.com/databus23/helm-diff)
- [helm-git](https://github.com/aslafy-z/helm-git)
- [s3](https://github.com/hypnoglow/helm-s3)
- [secrets](https://github.com/jkroepke/helm-secrets)

## Installing Helmfile

To install Helmfile on macOS and Linux, you can use [Homebrew](https://brew.sh/):

```shell
brew install helmfile
```

> Homebrew will also install Helm as a dependency of Helmfile.

Once you have Helmfile, run the `init` command to add the required plugins to your Helm installation:

```shell
helmfile init
```

### Enabling Autocompletion

To enable autocompletion for Helmfile in a shell, use `helmfile completion`. For example, to add autocompletion for the fish shell, run this command:

```shell
helmfile completion fish > ~/.config/fish/completions/helmfile.fish
```

Helmfile currently provides completion support for Bash, fish and zsh.
