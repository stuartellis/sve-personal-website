+++
title = "Configuring Kubernetes with Helmfile"
slug = "helmfile"
date = "2025-09-05T07:23:00+01:00"
description = "Managing Kubernetes configurations with Helmfile"
categories = ["automation", "devops", "kubernetes"]
tags = ["automation", "devops", "kubernetes"]
+++

[Helmfile](https://helmfile.readthedocs.io/en/stable/) is a command-line tool for deploying sets of configuration to Kubernetes clusters. You could use Helmfile to manage development Kubernetes clusters on laptops, or as part of a CI process that deploys a configuration to clusters on demand. This means that you can use it as the equivalent of Docker Compose for Kubernetes.

Many administrators use [GitOps](https://www.gitops.tech/) systems like [Flux](https://fluxcd.io/flux/) or [Argo CD](https://argo-cd.readthedocs.io/en/stable/) that run on a Kubernetes cluster and continuously apply a configuration. You can deploy a GitOps system on a cluster with Helmfile, or use it to manage all of the configuration of the cluster.

> This article is written for Helmfile 1.1.6 and above.

## How It Works

Helmfile enables you to define a configuration for Kubernetes that includes multiple Helm charts, kustomizations and Kubernetes manifests. This configuration supports both templating and lookups that query data sources.

Helmfile uses the templating and lookups to generate [Helm](https://helm.sh) releases that it can apply to Kubernetes clusters. You can specify [selectors](https://helmfile.readthedocs.io/en/stable/#labels-overview) to generate YAML that only includes some of the Helm releases that are defined in the configuration. This enables you to develop and apply targeted changes.

Helmfile uses [the Go template package](https://pkg.go.dev/text/template) for templating the configuration. It also includes the template functions of the [Sprig](https://masterminds.github.io/sprig/) library and [HCL](https://helmfile.readthedocs.io/en/stable/hcl_funcs/#standard-library).

Helmfile can lookup values from [a wide range of data sources](https://github.com/helmfile/vals?tab=readme-ov-file#supported-backends), because it includes [vals](https://github.com/helmfile/vals), and it can also use [helm-secrets](https://github.com/jkroepke/helm-secrets) to work with [SOPS](https://getsops.io/).

Helmfile also supports [lockfiles](https://helmfile.readthedocs.io/en/stable/#deps) for the Helm charts. You specify a version requirement for each Helm chart, and Helmfile will resolve the required version. The versions are written to a lockfile which you can store in version control to ensure that the same versions are used consistently, just like the lockfile that you would use in programming projects. [Renovate supports Helmfile](https://docs.renovatebot.com/modules/manager/helmfile/), so that you can use Renovate to help you maintain Kubernetes configurations.

Helmfile is designed to be extremely flexible. Helmfile itself uses YAML for the configurations, with a [published schema](https://www.schemastore.org/helmfile.json). Each Helmfile configuration can be one or more files, and you can define multiple [environments](https://helmfile.readthedocs.io/en/stable/#environment) within the same Helmfile configuration.

> If you define more than one environment in a Helmfile configuration, you should have [a separate lockfile for each environment](https://helmfile.readthedocs.io/en/stable/advanced-features/#lockfile-per-environment).

You can always use multiple configurations on the same Kubernetes cluster if you wish, since Helmfile produces standard Helm releases and each Helmfile configuration will only affect the releases that it manages.

## Quick Examples

To create a Helmfile configuration, make a directory that contains a file with the name _helmfile.yaml.gotmpl_ and add some configuration to the file. The simplest Helmfile configuration looks like this:

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

This example configuration defines the values for the Helm chart as part of the block for the release. In most cases, you will create separate files and use templating to provide the values for Helm charts.

> Use the file extension _.yaml.gotmpl_ for the main Helmfile configuration file, and any other files with templated values. Helmfile only applies templating to files that have _.gotmpl_ as part of their file extension.

To use a Helmfile configuration, ensure that you have set the correct Kubernetes context to access the target cluster, and change your working directory to the directory for the main file. Then run Helmfile commands:

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

To completely remove a release, we set the `installed` option for the release to `false`, and run `helmfile apply`.

To see the complete set of YAML that Helmfile generates, rather than a diff between the generated YAML and the cluster, use `helmfile template`:

```shell
helmfile template
```

Add `--debug` to get more information about how Helmfile generates the YAML, with warnings and error messages for any issues:

```shell
helmfile template --debug
```

To force Helmfile to delete releases from a cluster, use `destroy`:

```shell
helmfile destroy
```

Deleting Helm releases removes all of the resources that they manage. Helmfile `destroy` will not delete namespaces.

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

> Helmfile uses these plugins for Helm: [diff](https://github.com/databus23/helm-diff), [helm-git](https://github.com/aslafy-z/helm-git), [s3](https://github.com/hypnoglow/helm-s3) and [secrets](https://github.com/jkroepke/helm-secrets).

### Enabling Autocompletion

To enable autocompletion for Helmfile in a shell, use `helmfile completion`. For example, to add autocompletion for the fish shell, run this command:

```shell
helmfile completion fish > ~/.config/fish/completions/helmfile.fish
```

Helmfile currently provides completion support for Bash, fish and zsh.

## Resources

- [Official Helmfile Documentation](https://helmfile.readthedocs.io/)
- The [Helmfile best practices guide](https://helmfile.readthedocs.io/en/stable/writing-helmfile/#the-helmfile-best-practices-guide).
- [Even more powerful Helming with Helmfile](https://www.hackerstack.org/even-more-powerful-helming-with-helmfile/) - A tutorial for Helmfile by _Gmkziz_
- [Renovate support for Helmfile](https://docs.renovatebot.com/modules/manager/helmfile/).

### Videos

- [Helmfile - How to manage Kubernetes Helm releases](https://www.youtube.com/watch?v=qIJt8Iq8Zb0), from AI & DevOps Toolkit, 29 minutes, posted 4 years ago
- [Complete Helm Chart Tutorial: From Beginner to Expert Guide](https://www.youtube.com/watch?v=DQk8HOVlumI) - by Rahul Wagh, 2 hours, includes Helmfile
