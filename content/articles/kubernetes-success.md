+++
title = "Succeeding with Kubernetes"
slug = "kubernetes-success"
date = "2024-06-06T17:48:00+01:00"
description = "Patterns and practices for Kubernetes"
draft = true
categories = ["automation", "devops", "kubernetes"]
tags = ["automation", "devops", "kubernetes"]
+++

[Kubernetes](https://kubernetes.io/) is now a standard framework for operating applications on clusters.

## Your Tools

The essential tools for working with Kubernetes clusters are:

- [k9s](https://k9scli.io/) - Text-based interface for Kubernetes clusters
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) - Standard command-line tool for Kubernetes
- [Stern](https://github.com/stern/stern) - Streaming log viewer for Kubernetes

You may also decide to use:

- [Buildah](https://buildah.io/) - Container image builder
- [Flux](https://fluxcd.io) - Configuration automation for Kubernetes clusters
- [Git](https://git-scm.com/) - Version control system
- [Helm](https://helm.sh/) - Package manager for Kubernetes
- [Trivy](https://aquasecurity.github.io/trivy) - Security scanner

If you are using EKS, you will also need these tools:

- [AWS CLI](https://aws.amazon.com/cli/)
- [eksctl](https://eksctl.io/)
