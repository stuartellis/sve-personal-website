+++
title = "Managing Kubernetes Configurations with Flux"
slug = "kubernetes-flux"
date = "2025-05-24T11:25:00+01:00"
description = "Managing Kubernetes Configurations with Flux"
draft = true
categories = ["automation", "aws", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "gitops", "kubernetes"]
+++

[Flux](https://fluxcd.io/flux/) provides a way to manage the configuration of running Kubernetes clusters. It applies the principles of [GitOps](https://www.gitops.tech/) to continuously apply the expected configuration to the clusters.

Flux updates the configuration of the cluster from source Git repository. This means that you do not need continuous integration to deploy changes. However, you should use continuous integration to test configurations before they are merged to the _main_ branch of the repository and applied to the production cluster by Flux.

## The Flux Controllers

Flux includes several different Controllers. Each Controller supports a different technology. For example, it supports Controllers for [Helm](https://helm.sh) packages and resource definitions with [Kustomize](https://kustomize.io/).

The Source and Notification controllers provide triggers for Flux operations. The Source Controller polls a repository. The Notification Controller includes support for [inbound webhooks](https://fluxcd.io/flux/guides/webhook-receivers/), so that you can trigger the deployment process. The Image Automation Controller can poll OCI repositories and apply updates based on policy and configuration that you define.

> By default, the Source controller reconciles with the source repository every 10 minutes.

### Using Helm with Flux

The desired state of a Helm release is described through a Kubernetes Custom Resource named _HelmRelease_. Based on the creation, mutation or removal of a _HelmRelease_ resource in the cluster, Helm actions are performed by the controller.

### Flux and Kustomize

## The Notification Controller

The Notification Controller is a Kubernetes operator, specialized in handling inbound and outbound events.

The controller handles events coming from external systems (GitHub, GitLab, Bitbucket, Harbor, Jenkins, etc) and notifies the GitOps toolkit controllers about source changes.

The controller handles events emitted by the GitOps toolkit controllers (source, kustomize, helm) and dispatches them to external systems (Slack, Microsoft Teams, Discord, Rocker) based on event severity and involved objects.

## Upgrading Flux

Flux has an [upgrade process](https://fluxcd.io/flux/installation/upgrade/).

## Extra Capabilities of Flux

### Managing Images

See [the documentation on image controllers](https://fluxcd.io/flux/components/image/).

The _image-reflector-controller_ and _image-automation-controller_ work together to update a Git repository when new container images are available.

- The _image-reflector-controller_ scans image repositories and reflects the image metadata in Kubernetes resources.
- The _image-automation-controller_ updates YAML files based on the latest images scanned, and commits the changes to a given Git repository.

### Flagger

[Flagger](https://fluxcd.io/flagger/) is a progressive delivery tool that automates the release process for applications running on Kubernetes. It reduces the risk of introducing a new software version in production by gradually shifting traffic to the new version while measuring metrics and running conformance tests.

Flagger implements several deployment strategies (Canary releases, A/B testing, Blue/Green mirroring) using a service mesh (App Mesh, Istio, Linkerd, Kuma, Open Service Mesh) or an ingress controller (Contour, Gloo, NGINX, Skipper, Traefik, APISIX) for traffic routing.

For release analysis, Flagger can query Prometheus, InfluxDB, Datadog, New Relic, CloudWatch, Stackdriver or Graphite and for alerting it uses Slack, MS Teams, Discord and Rocket.

### Multi-Tenancy

Flux uses Kubernetes RBAC via impersonation and supports multiple Git repositories.

Multi-cluster infrastructure and apps work out of the box with Cluster API: Flux can use one Kubernetes cluster to manage apps in either the same or other clusters, spin up additional clusters themselves, and manage clusters including lifecycle and fleets.

Flux has support for [tenants with namespaces in preview](https://fluxcd.io/flux/cmd/flux_create_tenant/).
