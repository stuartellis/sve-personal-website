+++
title = "Configuring Kubernetes with Helmfile"
slug = "helmfile"
date = "2025-09-04T06:58:00+01:00"
description = "Managing Kubernetes configurations with Helmfile"
categories = ["automation", "devops", "kubernetes"]
tags = ["automation", "devops", "kubernetes"]
+++

[Helmfile](https://helmfile.readthedocs.io/en/stable/) is a command-line tool for deploying sets of configuration to Kubernetes clusters. You could use Helmfile to manage development Kubernetes clusters on laptops, or as part of a CI process that deploys a configuration to clusters on demand. This means that you can use it as the equivalent of [Compose](https://compose-spec.io/) for Kubernetes.

Many administrators use [GitOps](https://www.gitops.tech/) systems like [Flux](https://fluxcd.io/flux/) or [Argo CD](https://argo-cd.readthedocs.io/en/stable/) that run on a cluster and continuously apply a configuration. You can deploy a GitOps system on a cluster with Helmfile, or use it to manage all of the configuration of a cluster.

> This article is written for Helmfile 1.1.5 and above.

## How It Works

Helmfile enables you to define a configuration for Kubernetes that includes multiple Helm charts, kustomizations and Kubernetes manifests. This configuration is written in YAML files and support templating. Helmfile can lookup values from [a wide range of data sources](https://github.com/helmfile/vals?tab=readme-ov-file#supported-backends), because it includes [vals](https://github.com/helmfile/vals) and can also use [helm-secrets](https://github.com/jkroepke/helm-secrets) to work with [SOPS](https://getsops.io/).

> Helmfile uses [the Go template package](https://pkg.go.dev/text/template) for templating the configuration. It also includes the template functions of the [Sprig](https://masterminds.github.io/sprig/) library and [HCL](https://helmfile.readthedocs.io/en/stable/hcl_funcs/#standard-library).

Each time that you use Helmfile, it generates a configuration that can be applied to Kubernetes clusters. It can also run the relevant Kubernetes tools on your behalf: [Helm](https://helm.sh) and [Kustomize](https://kustomize.io/) to apply the generated configuration. You can specify [selectors](https://helmfile.readthedocs.io/en/stable/#labels-overview) to generate a configuration that only includes some of the Helm releases. This enables you to develop and apply targeted changes.

Helmfile also support a [lockfile](https://helmfile.readthedocs.io/en/stable/#deps) for the Helm charts. You specify a version requirement for each Helm chart, and Helmfile will resolve the required version. The versions are written to a lockfile which you can store in version control, just like the lockfile that you would use in programming projects. [Renovate supports Helmfile](https://docs.renovatebot.com/modules/manager/helmfile/), so that you can use Renovate to help you maintain Kubernetes configurations.

Helmfile is designed to be extremely flexible. Each Helmfile configuration can be one or more files, and you can define multiple [environments](https://helmfile.readthedocs.io/en/stable/#environment) within the same Helmfile configuration. If you define multiple environments in a Helmfile configuration, you can have [a separate lockfile for each environment](https://helmfile.readthedocs.io/en/stable/advanced-features/#lockfile-per-environment).

> You can always use multiple Helmfile configurations on the same Kubernetes cluster if you wish, since each Helmfile configuration will only affect the resources that it manages.

## Quick Examples

To create a Helmfile configuration, make a directory that contains a file with the name _helmfile.yaml.gotmpl_. This file is the main configuration file. It can reference other files.

> Use the file extension _.yaml.gotmpl_ for the main Helmfile configuration file. Helmfile only applies templating to files that have _.gotmpl_ as part of their file extension.

The simplest Helmfile configuration is a single file that looks like this:

```yaml
---
repositories:
  - name: prometheus-community
    url: https://prometheus-community.github.io/helm-charts

releases:
  - name: prom-norbac
    namespace: monitoring
    chart: prometheus-community/prometheus
    version: '>27.33.0'
    installed: true
    set:
      - name: rbac.create
        value: false
```

To use this configuration, ensure that you have set the correct Kubernetes context to access the target cluster, and then run Helmfile commands:

```shell
# Generates a lock file for Helm chart versions
helmfile deps

# Shows the differences between the current Helmfile configuration and the configuration of the target cluster
helmfile diff

# Applies the changes between the current Helmfile configuration and the configuration of the target cluster
helmfile apply
```

> The namespace for a release will be automatically created if it does not already exist. Helmfile operations do not delete namespaces.

To update the configuration on the cluster, we change the Helmfile configuration and run `helmfile apply` again.

To completely remove a release, we set the `installed` option for the release to `false`, and run `helmfile apply` again.

This example configuration defines the values for the Helm chart as part of the block for the release. In most cases, you will create separate files and use templating to provide the values for Helm charts.

The configuration below uses templating, and also has [labels](https://helmfile.readthedocs.io/en/latest/#labels-overview) for the release definitions. We use labels to scope Helmfile commands.

> For examples of configurations that use a directory structure, see my [example EKS project](https://github.com/stuartellis/eks-auto-example). This project uses two Helmfile configurations: _helmfile/local/_ and _helmfile/aws/_.

## Requirements

Helmfile itself is a single executable file. It relies on [Helm](https://helm.sh) and several Helm plugins. It also uses the `kustomize` command-line tool, in order to manage [Kustomizations](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/).

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
