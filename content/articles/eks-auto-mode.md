+++
title = "Low Maintenance Kubernetes with EKS Auto Mode"
slug = "eks-auto-mode"
date = "2025-04-06T19:52:00+01:00"
description = "Using EKS with Auto Mode"
draft = true
categories = ["automation", "aws", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "kubernetes"]
+++

[Kubernetes](https://kubernetes.io/) is now a standard framework for operating applications on clusters. This article explains how to set up a Kubernetes cluster on [Amazon EKS](https://docs.aws.amazon.com/eks/) with Infrastructure as Code. The EKS cluster will use [Auto Mode](https://docs.aws.amazon.com/eks/latest/userguide/automode.html) for maintenance and the cluster configuration will be managed by [Flux](https://fluxcd.io/).

> See GitHub for [the example project](https://github.com/stuartellis/eks-auto-example).

## Design Decisions

- Use one repository for all of the code
- Use AWS services wherever possible
- Where possible, delegate control of services to automation that runs on the Kubernetes cluster
- Use an Infrastructure as Code tool to manage AWS resources that are not controlled by the Kubernetes cluster itself
- Use a GitOps tool to manage the configuration of the Kubernetes cluster

We delegate control of resources to controllers in the cluster so that the systems can be as automated as possible. This also reduces the complexity of administration, because almost all of the changes will be handled by GitOps.

### Tools

This article uses a specific set of tools and patterns to set up and maintain your cluster. Each of these has been chosen because it is well-known and well-supported. If you have non-standard requirements then you might deliberately decide to replace some of these choices.

The set of tools that we use are:

- [Flux](https://fluxcd.io/) for GitOps
- [Helm](https://helm.sh/) for Kubernetes packages
- [Task](https://taskfile.dev) for organising developer tasks
- [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/) for Infrastructure as Code

> I refer to Terraform and OpenTofu as _TF_. The two tools work identically for the purposes of this article.

We use [Helm](https://helm.sh/) to deploy packaged configuration to our clusters. You do not need to use Helm for your custom configuration. Helm charts provide a format for projects to give users reusable sets of Kubernetes configuration. [Flux](https://fluxcd.io/) supports deploying templated configuration with Kustomize, as well as deploying Helm charts.

### Project Structure and Tooling

For convenience, the example code for this article uses [my template for a TF project](https://github.com/stuartellis/copier-tf-tools). This template provides a set of TF tasks for the [Task](https://taskfile.dev) runner. Like this article, these tasks are highly opinionated, and are designed to minimise maintenance.

### Design Decisions for TF

I have made several decisions in the example TF code:

- The example code uses the [EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) from the [terraform-modules](https://registry.terraform.io/namespaces/terraform-aws-modules) project. This module enables you to deploy an EKS cluster by setting a relatively small number of values.
- We use a setting in the TF provider for AWS to apply tags on all AWS resources. This ensures that resources have a consistent set of tags with minimal code.
- To ensure that resource identifiers are unique, the TF code always constructs names as _locals_.
- The constructed names of resources always include a _variant_, which is set as a tfvar. The _variant_ is either the name of the current TF workspace, or a random identifier for TF test runs.
- The code supports TF test, the built-in testing framework for TF. You may decide to use other testing frameworks. TF test lacks features to output formatted test results.

### Out of Scope

This article does not cover how to set up container registries or maintain container images. These will be specific to the applications that you run on your cluster.

This article also does not cover how to set up the requirements to run TF. You should always use remote state storage with these tools, but you should decide how to host the remote state.

If you use S3 for remote state storage, define an IAM role specifically for access to the remote state. This role should be different and more limited than the roles that your TF code use to manage resources.

I highly recommend that you host the remote state for TF outside of the AWS account(s) that contains the resources that are managed by the remote state. For example, you could use S3 buckets that are in a different AWS account to store remote state.

## Requirements

### Development Workstation

Required tools for this project:

- [AWS CLI](https://aws.amazon.com/cli/)
- [eksctl](https://eksctl.io/)
- [Flux CLI](https://fluxcd.io/flux/cmd/)
- [Git](https://git-scm.com/)
- [Helm](https://helm.sh/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Task](https://taskfile.dev)
- [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/)

### Automation

To automate operations, we need a Git repository that is available to your development workstation, the resources on your AWS accounts and your continuous integration system.

Required:

- A hosted Git repository

Recommended:

- Continuous integration

Flux causes the configuration of the cluster to update from the Git repository. This means that you do not need continuous integration to deploy changes. However, you should use continuous integration to test configurations before they are merged to the _main_ branch of the repository and applied to the cluster by Flux.

### AWS Requirements

You will require an AWS account to host the EKS cluster and other resources. I recommend that the AWS account that hosts the live cluster is not used to store user accounts, backups or TF remote state. There is no charge for an AWS account, only for the resources that you use, so always have more than one.

EKS clusters have various [network requirements](https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html). To avoid issues, each EKS cluster should have:

- A VPC
- Three subnets attached to the VPC, one per availability zone
- A DNS zone in Amazon Route 53

Each subnet should be a _/24_ or larger CIDR block. By default, every instance of every pod on a Kubernetes cluster will use an IP address. This means that every node will consume up to four IP addresses for Elastic Network Interfaces, plus one IP address per pod that it hosts.

I recommend that you define a separate Route 53 zone for each cluster as a child zone for a DNS domain that you own. This enables you to delegate control of the child zone to automation. Specifically this enables you to use the External DNS controller to register load balancers with DNS.

## One: Customise Configuration

You will need to fork [the example repository](https://github.com/stuartellis/eks-auto-example) and change the configuration for your own infrastructure:

- AWS region
- IAM roles
- S3 bucket for TF remote state

## Two: Deploy the Infrastructure with TF

Use the tasks to deploy _amc_. This is a Terraform root module.

If you are running the TF deployment from your own system, ensure that you have AWS credentials in your shell session:

```shell
eval $(aws configure export-credentials --format env --profile your-aws-profile)
```

Next, run the tasks to initialise, plan and apply the TF code:

```shell
TFT_STACK=amc TFT_CONTEXT=dev task tft:init
TFT_STACK=amc TFT_CONTEXT=dev task tft:plan
TFT_STACK=amc TFT_CONTEXT=dev task tft:apply
```

The `apply` will take several minutes to complete.

> The IAM principal that originally created the EKS cluster is automatically granted _system:masters_ in the cluster. In our example code, this principal is the IAM role that TF uses. To enable operators to access the cluster, the TF code includes an access entry for another IAM role.

## Three: Configure Your Kubernetes Tools

Use eksctl to register the new cluster with your kubectl configuration.

If you are running the TF deployment from your own system, first ensure that you have AWS credentials in your shell session:

```shell
eval $(aws configure export-credentials --format env --profile your-aws-profile)
```

Run the eksctl command to add the cluster to your kubectl configuration:

```shell
aws eks update-kubeconfig --name dev-amc-default
```

To set this cluster as the default context for your Kubernetes tools, run this command:

```shell
kubectl config set-context $EKS-CLUSTER-ARN
```

To test the connection to the API endpoint for the cluster, first assume the IAM role for operators. Run this command to get the credentials:

```shell
aws sts assume-role --role-arn $HUMAN-OPS-ROLE-ARN --role-session-name human-ops-session
```

Set these values as environment variables:

- AccessKeyId -> AWS_ACCESS_KEY_ID
- SecretAccessKey -> AWS_SECRET_ACCESS_KEY
- SessionToken -> AWS_SESSION_TOKEN

Next, run this command to get a response the cluster:

```shell
kubectl version
```

The command should return output like this:

```shell
Client Version: v1.32.3
Kustomize Version: v5.5.0
Server Version: v1.32.3-eks-bcf3d70
```

## Four: Enable Flux

This process requires the [Flux CLI](https://fluxcd.io/flux/cmd/) to be installed on your system.

> You must set your access token for your Git hosting provider as an environment variable before you run this command.

TODO

## Resources

- [Amazon EKS Auto Mode ENABLED - Build your super-powered cluster](https://community.aws/content/2sV2SNSoVeq23OvlyHN2eS6lJfa/amazon-eks-auto-mode-enabled-build-your-super-powered-cluster) - A walk-through EKS Auto Mode with TF
- [EKS Workshop](https://eksworkshop.com/) - Official AWS training for EKS
