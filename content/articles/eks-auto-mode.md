+++
title = "Low Maintenance Kubernetes with EKS Auto Mode"
slug = "eks-auto-mode"
date = "2025-04-05T21:33:00+01:00"
description = "Using EKS with Auto Mode"
draft = true
categories = ["automation", "aws", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "kubernetes"]
+++

[Kubernetes](https://kubernetes.io/) is now a standard framework for operating applications on clusters. This article explains how to set up a Kubernetes cluster on AWS EKS, using Auto Mode. It is highly opinionated.

## Design Decisions

- Use AWS services whereever possible
- Where possible, delegate control of services to automation in the Kubernetes cluster
- Use TF to manage AWS resources that are not controlled by the Kubernetes cluster itself
- Use FluxCD to manage the configuration of the Kubernetes cluster
- Use Helm for packaged Kubernetes configurations
- Use one repository for all of the code. Multiple repositories make management significantly more complicated.

We delegate control of resources to controllers in the cluster so that the systems can be as automated as possible. This also reduces the complexity of administration, because almost all of the changes will be handled by FluxCD.

You do not need to use Helm for your custom configuration. Helm charts provide a format for projects to give users reusable sets of Kubernetes configuration. FluxCD supports deploying templated configuration with Kustomize, as well as deploying Helm charts.

### Tools

This article uses a specific set of tools and patterns to set up and maintain your cluster. Each of these has been chosen because it is well-known and well-supported. If you have non-standard requirements then you might deliberately decide to replace some of these choices.

The set of tools that we use are:

- FluxCD
- Helm
- Task
- Terraform or OpenTofu

> I refer to Terraform and OpenTofu as _TF_ in this article. The two tools work identically for the purposes of this article.

### Project Structure and Tooling

For convenience, the example code for this article uses my template for a TF project. This template provides a set of TF tasks for the Task runner. Like this article, the tasks are highly opinionated, and are designed to minimise maintenance.

### Design Decisions for TF

I have made several decisions in the example TF code:

- The example code uses the EKS module from the terraform-modules project. This module enables you to deploy an EKS cluster by setting a relatively small number of values.
- We use a setting in the TF provider for AWS to apply tags on all AWS resources. This ensures that resources have a consistent set of tags with minimal code.
- To ensure that resource identifiers are unique, the TF code always constructs names as _locals_.
- The constructed names of resources always include a _variant_, which is set as a tfvar. The _variant_ is either the name of the current TF workspace, or a random identifier for TF test runs.
- The code supports TF test, the built-in testing framework for TF. You may decide to use other testing frameworks. TF test lacks features to output formatted test results.

### Out of Scope

This article does not cover how to set up container registries or maintain container images. These will be specific to the applications that you run on your cluster.

This article also does not cover how to set up the requirements to run TF. You should always use remote state storage with these tools, but you should decide how to host the remote state.

If you use S3 for remote state storage, remember that the IAM role to access the remote state should be different and more limited than the roles that your TF code uses.

I would highly recommend that you host the remote state for TF outside of the AWS account(s) that contains the resources that are managed by the remote state. For example, you could use S3 buckets that are in a different AWS account to store remote state.

## Requirements

### Development Workstation

Required tools for this project:

- AWS CLI
- FluxCD CLI
- Git
- Helm
- Kubectl
- Task
- Terraform or OpenTofu

I would also recommend these tools:

- k9s
- Stern
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

EKS clusters have various [network requirements](https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html). To avoid issues, each EKS cluster should have:

- A VPC
- Three subnets attached to the VPC, one per availability zone
- A DNS zone in Amazon Route 53

Each subnet should be a _/24_ or larger CIDR block. By default, every instance of every pod on a Kubernetes cluster will use an IP address. This means that every node will consume up to four IP addresses for Elastic Network Interfaces, plus one IP address per pod that it hosts.

I recommend that you define a separate Route 53 zone for each cluster as a child zone for a DNS domain that you own. This enables you to delegate control of the child zone to automation. Specifically this enables you to use the External DNS controller to register load balancers with DNS.

## Resources

- [Amazon EKS Auto Mode ENABLED - Build your super-powered cluster](https://community.aws/content/2sV2SNSoVeq23OvlyHN2eS6lJfa/amazon-eks-auto-mode-enabled-build-your-super-powered-cluster)
