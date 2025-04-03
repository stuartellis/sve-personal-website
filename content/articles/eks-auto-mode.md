+++
title = "Low Maintenance Kubernetes with EKS Auto Mode"
slug = "eks-auto-mode"
date = "2025-04-02T19:18:00+01:00"
description = "EKS Auto Mode"
draft = true
categories = ["automation", "aws", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "kubernetes"]
+++

[Kubernetes](https://kubernetes.io/) is now a standard framework for operating applications on clusters, large and small. This article explains how to set up a Kubernetes cluster on AWS EKS, using Auto Mode. It is highly opinionated.

> I refer to Terraform and OpenTofu as _TF_ in this article. The two tools work identically for the purposes of this article.

## Assumptions

This article uses a specific set of tools and patterns to set up and maintain your cluster. Each of these has been chosen because it is well-known and well-supported. If you have non-standard requirements then you might deliberately decide to replace some of these choices.

For convenience, the example code for this article uses my template for a TF project. This template provides a set of TF tasks for the Task runner. Like this article, the tasks are highly opinionated, and are designed to minimise maintenance.

### Design Decisions

- Use AWS services whereever possible
- Where possible, delegate control of services to automation in the Kubernetes cluster
- Use TF to manage AWS resources that are not controlled by the Kubernetes cluster itself
- Use FluxCD to manage the configuration of the Kubernetes cluster
- Use Helm for packaged Kubernetes configurations

We delegate control of resources to controllers in the cluster so that the systems can be as automated as possible. This also reduces the complexity of administration, because almost all of the changes will be handled by FluxCD.

You do not need to use Helm for your custom configuration. Helm charts provide a format for projects to give users reusable sets of Kubernetes configuration. FluxCD supports deploying templated configuration with Kustomize, as well as deploying Helm charts.

### Naming Conventions

Every instance of a resource in cloud infrastructure must have a unique identifier, such as a name. Avoid assuming that you will only deploy one instance of a resource in the same context. For example, TF test generates and destroys resources on each test run. Similarly, the workspaces feature of TF enables you to deploy multiple instances of resources for development.

In general, cloud resource names should be valid in DNS, so that you can use the same name consistently. This means that names should start with a lowercase letter and should only contain:

- Lowercase letters
- Numbers
- Hyphens (dashes)

To ensure that resource identifiers are unique, the TF code always constructs names as _locals_. These constructed names always include a _variant_ string. The _variant_ string is either the name of the TF workspace, or a random identifier for TF test runs.

> If you do not specify a TF workspace, it uses the _default_ workspace.

AWS provides tags to allow you to identify sets of resources. The TF code in this project sets tags on all AWS resources.

### Out of Scope

This article does not cover how to set up container registries or maintain container images. These will be specific to the applications that you run on your cluster.

This article also does not cover how to set up the requirements to run TF. You should always use remote state storage with these tools, but you should decide how to host the remote state.

> I highly recommend that you host the remote state for TF outside of the AWS account(s) that contains the resources that are managed by the remote state. For example, you could use S3 buckets that are in a different AWS account to store remote state.

## Requirements

### Development Workstation

Required tools:

- AWS CLI
- Git
- helm
- kubectl
- Task
- Terraform or OpenTofu

Recommended tools:

- FluxCD CLI
- Trivy

### Automation

To automate operations, we need a Git repository that is available to your development workstation, the resources on your AWS accounts and your continuous integration system.

Required:

- A hosted Git repository

Recommended:

- Continuous integration

FluxCD causes the configuration of the cluster to update from the Git repository. This means that you do not need continuous integration to deploy changes. However, you should use continuous integration to test configurations before they are merged to the _main_ branch of the repository and applied to the cluster by FluxCD.

### AWS Requirements

You will require an AWS account to host the EKS cluster and other resources. I recommend that the AWS account that hosts the live cluster is not used to store user accounts, backups or TF remote state. There is no charge for an AWS account, only for the resources that you use, so always have more than one.

Each EKS cluster should have:

- A VPC
- Three subnets attached to the VPC, one per availability zone
- A DNS zone in Amazon Route 53

Each subnet should be a _/24_ or larger CIDR block. Every instance of every pod on a Kubernetes cluster will use an IP address. This means that every node will consume four IP addresses for Elastic Network Interfaces, plus one IP address per pod that it hosts.

I recommend that you define a separate Route 53 zone for each cluster as a child zone for a DNS domain that you own. This enables you to delegate control of the child zone to automation.
