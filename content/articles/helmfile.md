+++
title = "Configuring Kubernetes with Helmfile"
slug = "helmfile"
date = "2025-09-06T08:38:00+01:00"
description = "Managing Kubernetes configurations with Helmfile"
categories = ["automation", "devops", "kubernetes"]
tags = ["automation", "devops", "kubernetes"]
+++

[Helmfile](https://helmfile.readthedocs.io/en/stable/) is a command-line tool for describing and applying configurations to Kubernetes clusters. It enables you to define sets of configuration for Kubernetes that each include multiple Helm charts, kustomizations and manifests. Helmfile supports templating in the configuration and lookups that can query [local or remote data sources](https://github.com/helmfile/vals?tab=readme-ov-file#supported-backends), such as secrets storage, configuration services and external files.

Many administrators use [GitOps](https://www.gitops.tech/) systems like [Flux](https://fluxcd.io/flux/) or [Argo CD](https://argo-cd.readthedocs.io/en/stable/) that run on a Kubernetes cluster and continuously apply a configuration. You can deploy a GitOps system on a cluster with Helmfile, or you could manage all of the configuration of a cluster with just Helmfile.

Helmfile is particularly useful for clusters that are temporary or should change rapidly as part of another process. For example, you might use it to configure development Kubernetes clusters on laptops, or as part of a CI process that deploys test clusters on demand.

> This article is written for Helmfile 1.1 and above.

## How It Works

Each Helmfile configuration consists of one of more YAML files that describe a set of [Helm releases](https://helm.sh/docs/intro/using_helm/#three-big-concepts). These YAML files can include templating and lookups. You can define multiple [environments](https://helmfile.readthedocs.io/en/stable/#environment) within the same Helmfile configuration.

> There is a [published YAML schema for Helmfile configuration](https://www.schemastore.org/helmfile.json), so that you can validate your configuration files with standard tools.

Helmfile runs [Helm](https://helm.sh) and [Kustomize](https://kustomize.io/) to work with releases and kustomizations. It is designed to build on other existing tools and services as much as possible. The templating uses [the standard Go template package](https://pkg.go.dev/text/template) with functions from the [Sprig](https://masterminds.github.io/sprig/) library and [HCL](https://helmfile.readthedocs.io/en/stable/hcl_funcs/#standard-library). Helmfile includes the [vals](https://github.com/helmfile/vals) package to lookup values from [a wide range of data sources](https://github.com/helmfile/vals?tab=readme-ov-file#supported-backends), and it works with [SOPS](https://getsops.io/) by using the Helm plugin for [secrets](https://github.com/jkroepke/helm-secrets).

Helmfile will use Helm charts from either remote repositories or the filesystem. It can also maintain [lockfiles](https://helmfile.readthedocs.io/en/stable/#deps) for the Helm charts from repositories. If you specify a version constraint for each chart in the configuration then Helmfile can resolve the exact version that is required for each chart. It writes these to a lockfile which you can store in version control. This ensures that the same versions are used consistently.

> If you define more than one environment in a Helmfile configuration, you should have [a separate lockfile for each environment](https://helmfile.readthedocs.io/en/stable/advanced-features/#lockfile-per-environment).

When you run Helmfile, it reads the configuration and the lockfile to generate the YAML for Helm releases, using templating and lookups to get values as needed. It only applies this generated configuration if you run the specific commands that change the state of the target cluster. This means that you can develop a configuration and compare it with the deployed releases on a target cluster without making any changes to the current state of that cluster.

You can develop and apply targeted changes by specifying [selectors](https://helmfile.readthedocs.io/en/stable/#labels-overview). To use selectors, ensure that your Helmfile configuration sets labels in release definitions and for included files. You can then specify one or more selectors in any Helmfile commands and they will generate YAML that only includes the relevant releases.

If you need to deploy Kubernetes manifests that are not part of a Helm chart then you can specify a directory as a source, instead of the location of a Helm chart. The directory only needs to contain YAML files for the manifests and any kustomizations that you want to apply to them. Helmfile will automatically create a temporary Helm chart for the directory and generate a release for it, alongside the Helm releases that it generates for existing charts.

Helmfile runs Helm and produces standard Helm releases, so it is compatible with other Kubernetes management tools. Each Helmfile configuration only affects the Helm releases that it manages. This means that you can use multiple Helmfile configurations that each manage different features on the same Kubernetes cluster, or use of a combination of Helmfile and other tools. I would recommend only using one configuration for each namespace, to avoid issues.

> If you would like to use Helmfile and Argo CD on the same Kubernetes clusters, first read the documentation on [Argo CD integration](https://helmfile.readthedocs.io/en/stable/#argocd-integration).

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
# Generate a lock file for Helm chart versions
helmfile deps

# Show the differences between the Helmfile configuration and the configuration of the target cluster
helmfile diff

# Apply the changes between the Helmfile configuration and the configuration of the target cluster
helmfile apply
```

> The namespace for a release will be automatically created if it does not already exist. Helmfile operations do not delete namespaces.

To update the configuration on the cluster, we change the Helmfile configuration and run `helmfile apply` again.

To see the complete set of YAML that Helmfile generates, rather than a diff between the generated YAML and the cluster, use `helmfile template`:

```shell
helmfile template
```

Add `--debug` to get more information about how Helmfile generates the YAML, with warnings and error messages for any issues:

```shell
helmfile template --debug
```

To remove a specific release, we set the `installed` option for the release definition to `false`, and run `helmfile apply`. To delete all of the releases from a cluster, use `destroy`:

```shell
helmfile destroy
```

Deleting a Helm release removes all of the resources that it manages. Helmfile will not delete namespaces.

## Other Examples of Helmfile Configurations

For examples of configurations that use a directory structure, see my [example EKS project](https://github.com/stuartellis/eks-auto-example). This project uses three Helmfile configurations:

- _helmfile/aws/_ - AWS EKS Auto Mode
- _helmfile/kind/_ - Docker Desktop (Kubernetes in Docker)
- _helmfile/minikube/_ - Minikube

## Requirements

Helmfile itself is a single executable file. It relies on [Helm](https://helm.sh) and several Helm plugins. It also uses the `kustomize` command-line tool to manage [Kustomizations](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/). This means that both Helm and Kustomize must be installed on the system.

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
- The [Helmfile best practices guide](https://helmfile.readthedocs.io/en/stable/writing-helmfile/#the-helmfile-best-practices-guide)
- [Even more powerful Helming with Helmfile](https://www.hackerstack.org/even-more-powerful-helming-with-helmfile/) - A tutorial for Helmfile by _Gmkziz_
- [Renovate support for Helmfile](https://docs.renovatebot.com/modules/manager/helmfile/)

### Videos

- [Helmfile - How to manage Kubernetes Helm releases](https://www.youtube.com/watch?v=qIJt8Iq8Zb0), from _AI & DevOps Toolkit_, 29 minutes
- [Complete Helm Chart Tutorial: From Beginner to Expert Guide](https://www.youtube.com/watch?v=DQk8HOVlumI) - by _Rahul Wagh_, 2 hours, includes Helmfile
