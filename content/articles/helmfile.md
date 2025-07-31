+++
title = "Configuring Kubernetes with Helmfile"
slug = "helmfile"
date = "2025-07-31T21:18:00+01:00"
description = "Managing Kubernetes configurations with Helmfile"
draft = true
categories = ["automation", "devops", "kubernetes"]
tags = ["automation", "devops", "kubernetes"]
+++

[Helmfile](https://helmfile.readthedocs.io/en/stable/) is a command-line tool for deploying sets of configuration to Kubernetes clusters. Many administrators use [GitOps](https://www.gitops.tech/) systems like [Flux](https://fluxcd.io/flux/) or [Argo CD](https://argo-cd.readthedocs.io/en/stable/) that run on a cluster and continuously apply a configuration. You can deploy a GitOps system on a cluster with Helmfile, or use it to manage all of the configuration of the cluster.

You could use Helmfile to manage development Kubernetes clusters on laptops, or as part of a CI process that deploys a configuration to clusters on demand. This means that you can use it as the equivalent of [Compose](https://compose-spec.io/) for Kubernetes.

> This article is written for Helmfile 1.1.3 and above.

## Requirements

Helmfile itself is a single executable file. It relies on [Helm](https://helm.sh) and several Helm plugins. It also uses the `kustomize command-line tool, in order to manage Kustomizations.

To install Helmfile on macOS and Linux, you can use [Homebrew](https://brew.sh/):

```shell
brew install helmfile kustomize
```

> Homebrew will install Helm as a dependency of Helmfile.

Once you have Helmfile, run the `init` command to add the required plugins to your Helm installation:

```shell
helmfile init
```

Helmfile requires these plugins for Helm:

- [diff](https://github.com/databus23/helm-diff)
- [helm-git](https://github.com/aslafy-z/helm-git)
- [s3](https://github.com/hypnoglow/helm-s3)
- [secrets](https://github.com/jkroepke/helm-secrets)

### Enabling Autocompletion

To enable autocompletion for Helmfile in a shell, use `helmfile completion`. For example, to add autocompletion for the fish shell, run this command:

```shell
helmfile completion fish > ~/.config/fish/completions/helmfile.fish
```

Helmfile currently provides completion support for Bash, fish and zsh.

## Resources

- [Official Helmfile Documentation](https://helmfile.readthedocs.io/)
- [Even more powerful Helming with Helmfile](https://www.hackerstack.org/even-more-powerful-helming-with-helmfile/) - A tutorial for Helmfile by _Gmkziz_
- [Renovate support for Helmfile](https://docs.renovatebot.com/modules/manager/helmfile/).

### Videos

- [Helmfile - How to manage Kubernetes Helm releases](https://www.youtube.com/watch?v=qIJt8Iq8Zb0), from AI & DevOps Toolkit, 29 minutes, posted 4 years ago
- [Complete Helm Chart Tutorial: From Beginner to Expert Guide](https://www.youtube.com/watch?v=DQk8HOVlumI) - by Rahul Wagh, 2 hours, includes Helmfile
