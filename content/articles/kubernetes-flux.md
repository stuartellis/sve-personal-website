+++
title = "Managing Kubernetes Configurations with Flux"
slug = "kubernetes-flux"
date = "2025-05-26T23:44:00+01:00"
description = "Managing Kubernetes Configurations with Flux"
draft = true
categories = ["automation", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "gitops", "kubernetes"]
+++

[Flux](https://fluxcd.io/flux/) implements the principles of [GitOps](https://www.gitops.tech/) to continuously apply the expected configuration to running Kubernetes clusters. This enables you to have continuous delivery for the applications and infrastructure that is hosted by a Kubernetes cluster. By design, Flux relies on the native features of Kubernetes.

> Flux only manages configuration of running clusters. You must use other tools to deploy your Kubernetes clusters.

## How Flux Works

The Flux installation in each cluster updates the configuration of that cluster from a source Git repository. This Flux installation includes several different Controllers. Each Controller supports a different technology. For example, it supports Controllers for [Helm](https://helm.sh) packages and resource definitions with [Kustomize](https://kustomize.io/).

The Source and Notification controllers provide triggers for Flux operations. The Source Controller polls a repository. The Notification Controller includes support for [inbound webhooks](https://fluxcd.io/flux/guides/webhook-receivers/), so that you can trigger the deployment process. The Helm and Kustomize controllers then apply any required changes to the cluster.

Flux also has other capabilities. For example, the Image Automation Controller can poll OCI repositories and apply updates based on policy and configuration that you define.

> By default, the Source controller reconciles with the source repository every 10 minutes.

### Using Helm with Flux

The [Helm Controller](https://fluxcd.io/flux/components/helm/) manages Helm chart releases with Kubernetes manifests. The desired state of a Helm release is described through a Kubernetes Custom Resource named _HelmRelease_. Based on the creation, mutation or removal of a _HelmRelease_ resource in the cluster, Helm actions are performed by the controller.

### Flux and Kustomize

The [Kustomize Controller](https://fluxcd.io/flux/components/kustomize/) processes Kubernetes manifests with Kustomize.

## The Notification Controller

The [Notification Controller](https://fluxcd.io/flux/components/notification/) is a Kubernetes operator, specialized in handling inbound and outbound events.

The controller handles events coming from external systems and notifies the GitOps toolkit controllers about source changes. These events can be sent by GitHub, GitLab, Bitbucket, Harbor, Jenkins.

The controller also handles events emitted by the GitOps toolkit controllers (Source, Kustomize, Helm) and dispatches them to external systems (Slack, Microsoft Teams, Discord, Rocker) based on event severity and involved objects.

## Upgrading Flux

Flux has an [upgrade process](https://fluxcd.io/flux/installation/upgrade/).

## Extra Capabilities of Flux

### Managing Images

the Image Automation Controller can poll OCI repositories and apply updates based on policy and configuration that you define. See [the documentation on image controllers](https://fluxcd.io/flux/components/image/) for more details.

The _image-reflector-controller_ and _image-automation-controller_ work together to update a Git repository when new container images are available.

- The _image-reflector-controller_ scans image repositories and reflects the image metadata in Kubernetes resources.
- The _image-automation-controller_ updates YAML files based on the latest images scanned, and commits the changes to a given Git repository.

### Flagger

[Flagger](https://fluxcd.io/flagger/) is a progressive delivery tool that automates the release process for applications running on Kubernetes. It reduces the risk of introducing a new software version in production by gradually shifting traffic to the new version while measuring metrics and running conformance tests.

Flagger implements several deployment strategies (Canary releases, A/B testing, Blue/Green mirroring) using a service mesh (App Mesh, Istio, Linkerd, Kuma, Open Service Mesh) or an ingress controller (Contour, Gloo, NGINX, Skipper, Traefik, APISIX) for traffic routing.

For release analysis, Flagger can query Prometheus, InfluxDB, Datadog, New Relic, CloudWatch, Stackdriver or Graphite and for alerting it uses Slack, MS Teams, Discord and Rocket.

### Multi-Tenancy

Flux uses Kubernetes RBAC via impersonation and supports multiple Git repositories.

Multi-cluster infrastructure and apps work with the Cluster API. This means that Flux can use one Kubernetes cluster to manage apps in either the same or other clusters, spin up additional clusters themselves, and manage clusters including lifecycle and fleets.

Flux has support for [tenants with namespaces in preview](https://fluxcd.io/flux/cmd/flux_create_tenant/).

## Resources

- [Flux Documentation](https://fluxcd.io/flux/)
- [Comparison: Flux vs Argo CD](https://earthly.dev/blog/flux-vs-argo-cd/)

### Learning

- [Full GitOps Tutorial: Getting started with Flux CD](https://www.youtube.com/watch?v=5u45lXmhgxA) by Anais Urlichs
- [Video: Managing Kubernetes the GitOps way with Flux - Jeff French - NDC Oslo 2023](https://www.youtube.com/watch?v=1DuxTlvmaNM)
- [EKS Workshop for Flux](https://eksworkshop.com/docs/automation/gitops/)
- [GitLab with Flux](https://docs.gitlab.com/ee/user/clusters/agent/gitops/flux_tutorial.html)

### Examples

- [Example repository for Flux](https://github.com/moonswitch-workshops/terraform-eks-flux) - Referenced by Jeff French video
- [Official example Flux repository](https://github.com/fluxcd/flux2-kustomize-helm-example) - Simple example from the Flux project
- [Big Bang](https://repo1.dso.mil/big-bang/bigbang) - US DoD declarative, continuous delivery tool
