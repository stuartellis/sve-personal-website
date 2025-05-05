+++
title = "Low Maintenance Kubernetes with EKS Auto Mode"
slug = "eks-auto-mode"
date = "2025-05-05T16:51:00+01:00"
description = "Using EKS with Auto Mode"
categories = ["automation", "aws", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "kubernetes"]
+++

[Kubernetes](https://kubernetes.io/) is now a standard technology for high-availability clusters. This article explains an approach for setting up Kubernetes clusters on [Amazon EKS](https://docs.aws.amazon.com/eks/) with Infrastructure as Code. The EKS clusters use [Auto Mode](https://docs.aws.amazon.com/eks/latest/userguide/automode.html), and cluster configuration is managed by [Flux](https://fluxcd.io/).

## More About This Project

The code for this project is published on both [GitHub](https://github.com/stuartellis/eks-auto-example) and [GitLab](https://gitlab.com/sve-projects/eks-auto-example).

This project uses a specific set of tools and patterns to set up and maintain your clusters. Each of these has been chosen because it is well-known and well-supported. If you have non-standard requirements then you might deliberately decide to replace some of these choices.

For example, the project includes tasks for the [Task](https://taskfile.dev) runner. The tasks for TF are provided by [my template for a TF project](https://github.com/stuartellis/tf-tasks). Like this article, these tasks are opinionated, and are designed to minimise maintenance.

> I refer to Terraform and OpenTofu as _TF_. The two tools work identically for the purposes of this article.

To make it a working example, the project deploys a Web application to each cluster. The [podinfo](https://github.com/stefanprodan/podinfo) application produces a Web interface and a REST API.

### Design Decisions

- Use one repository for all of the code
- Choose well-known and well-supported tools
- Use AWS services wherever possible
- Support separate development and production clusters
- Use an Infrastructure as Code tool to manage AWS resources for the cluster itself
- Delegate control of AWS resources for the applications on the cluster to automation that also runs on the cluster
- Use a [GitOps](https://www.gitops.tech/) tool to manage application configuration

### Out of Scope

This article does not cover how to set up container registries or maintain container images. These will be specific to the applications that you run on your cluster.

This article also does not cover how to set up the requirements to run TF. You should always use remote state storage with these tools, but you should decide how to host the remote state.

If you use S3 for remote state storage, define an IAM role specifically for access to the remote state. This role should be different and more limited than the roles that your TF code use to manage resources.

I highly recommend that you host the remote state for TF outside of the AWS account(s) that contains the resources that are being managed. For example, you could use S3 buckets that are in a different AWS account to store remote state.

## Requirements

### Required Tools on Your Computer

This project uses several command-line tools. You can install all of these tools on Linux or macOS with [Homebrew](https://brew.sh/).

The required command-line tools are:

- [AWS CLI](https://aws.amazon.com/cli/) - `brew install awscli`
- [Flux CLI](https://fluxcd.io/flux/cmd/) - `brew install flux`
- [Git](https://git-scm.com/) - `brew install git`
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) - `brew install kubernetes-cli`
- [Task](https://taskfile.dev) - `brew install go-task`
- [Terraform](https://www.terraform.io/) - Use [these installation instructions](https://developer.hashicorp.com/terraform/install#darwin)

Flux uses [Helm](https://helm.sh/) to manage packages on your clusters, but you do not need to install the Helm command-line tool.

### Version Control and Continuous Integration

To automate operations, you need a Git repository that is available to your development workstation, the resources on your AWS accounts and your continuous integration system.

Flux causes the configuration of the cluster to update from this Git repository. This means that you do not need continuous integration to deploy changes. However, you should use continuous integration to test configurations before they are merged to the _main_ branch of the repository and applied to the cluster by Flux.

This example uses [GitLab](https://gitlab.com/) as the provider for Git hosting and continuous integration. You can use [GitHub or other services](https://fluxcd.io/flux/installation/bootstrap/) instead of GitLab.

### AWS Requirements

You will require at least one AWS account to host an EKS cluster and other resources. I recommend that the AWS account that hosts the live cluster is not used to store user accounts, backups or TF remote state.

You will need these AWS resources to deploy an EKS cluster:

- An S3 bucket for remote state
- An IAM role for Terraform
- An IAM role for human administrators

The S3 bucket should be in the same AWS region as the EKS cluster.

You can use these resources for multiple EKS clusters. The example code defines a _dev_ and _prod_ configuration, so that you can have separate development and production clusters. These copies can be in the same or separate AWS accounts.

### AWS Requirements for Each EKS Cluster

EKS clusters have various [network requirements](https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html). To avoid issues, each EKS cluster should have:

- A VPC
- Three subnets attached to the VPC, one per availability zone
- A DNS zone in Amazon Route 53

Each subnet should be a _/24_ or larger CIDR block. By default, every instance of every pod on a Kubernetes cluster will use an IP address. This means that every node will consume up to four IP addresses for Elastic Network Interfaces, plus one IP address per pod that it hosts.

> Each subnet that will be used for load balancers must have tags to authorize the Kubernetes controller for AWS Load Balancers to use them. Subnets for public-facing Application Load Balancers must have a tag of _kubernetes.io/role/elb_ with the _Value_ of _1_.

I recommend that you define a separate Route 53 zone for each cluster. Create these as child zones for a DNS domain that you own. This enables you to configure the ExternalDNS controller on a cluster to manage DNS records for applications on that cluster without enabling it to manage records on the parent DNS zone.

## One: Customise Configuration

You will need to clone or fork the example repository and change the configuration for your own infrastructure:

- AWS region
- IAM role for TF
- IAM role for human system administrators
- S3 bucket for TF remote state

The IAM principal that creates an EKS cluster is automatically granted _system:masters_ in that cluster. In our example code, this principal is the IAM role that TF uses. The TF code also enables administrator access on the cluster to the IAM role for human system administrators.

> For simplicity, this example allows the TF module for EKS to create a KMS key that is unique to the cluster. If you want to use an existing KMS key, you will need to edit the TF code in the _amc_ module.

## Two: Set Credentials

> This process needs access to both AWS and your Git hosting provider. Set an access token for GitLab as the environment variable `GITLAB_TOKEN` before you run this command.

This example configures Flux to use a GitLab deploy key. This means that the Kubernetes cluster must have SSH access to the GitLab repository for the project.

If you are running the TF deployment from your own system, first ensure that you have AWS credentials in your shell session:

```shell
eval $(aws configure export-credentials --format env --profile your-aws-profile)
```

## Three: Deploy the Infrastructure with TF

Run the tasks to initialise, plan and apply the TF code for each module. For example:

```shell
TFT_STACK=amc-gitlab TFT_CONTEXT=dev task tft:init
TFT_STACK=amc-gitlab TFT_CONTEXT=dev task tft:plan
TFT_STACK=amc-gitlab TFT_CONTEXT=dev task tft:apply
```

Apply the modules in this order:

1. _amc-gitlab_ - Creates a deploy key on GitLab for Flux
2. _amc_ - Deploys a Kubernetes cluster on Amazon EKS
3. _amc-flux_ - Adds Flux to a Kubernetes Cluster

> The `apply` to create a cluster on EKS will take several minutes to complete.

## Four: Register Your Cluster with Kubernetes Tools

Use the AWS command-line tool to register the new cluster with your kubectl configuration.

If you are running the TF deployment from your own system, first ensure that you have AWS credentials in your shell session:

```shell
eval $(aws configure export-credentials --format env --profile your-aws-profile)
```

Run this command to add the cluster to your kubectl configuration:

```shell
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME
```

To set this cluster as the default context for your Kubernetes tools, run this command:

```shell
kubectl config set-context $EKS-CLUSTER-ARN
```

## Five: Test Your Cluster

To test the connection to the API endpoint for the cluster, first assume the IAM role for operators. Run this command to get the credentials:

```shell
aws sts assume-role --role-arn $HUMAN-OPS-ROLE-ARN --role-session-name human-ops-session
```

Set these values as environment variables:

- AccessKeyId -> AWS_ACCESS_KEY_ID
- SecretAccessKey -> AWS_SECRET_ACCESS_KEY
- SessionToken -> AWS_SESSION_TOKEN

Next, run this command to get a response from the cluster:

```shell
kubectl version
```

The command should return output like this:

```shell
Client Version: v1.32.3
Kustomize Version: v5.5.0
Server Version: v1.32.3-eks-bcf3d70
```

Once you can successfully connect to a cluster, use the _flux_ command-line tool to check the status of Flux management:

```shell
task flux:status
```

## How the TF Code Works

The tasks for TF are provided by [my template for a TF project](https://github.com/stuartellis/tf-tasks).

I have made several decisions in the example TF code for this project:

- The example code uses the [EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) from the [terraform-modules](https://registry.terraform.io/namespaces/terraform-aws-modules) project. This module enables you to deploy an EKS cluster by setting a relatively small number of values.
- We use a setting in the TF provider for AWS to apply tags on all AWS resources. This ensures that resources have a consistent set of tags with minimal code.
- To ensure that resource identifiers are unique, the TF code always constructs resource names in _locals_. The code for resources then uses these locals.
- The code supports [TF test](https://opentofu.org/docs/cli/commands/test/), the built-in testing framework for TF. You may decide to use other testing frameworks. TF test lacks features to output formatted test results.
- The constructed names of resources always include a _variant_, which is set as a tfvar. The _variant_ is either the name of the current TF workspace, or a random identifier for TF test runs.

## Resources

### Amazon EKS

- [Official Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [EKS Workshop](https://eksworkshop.com/) - Official AWS training for EKS
- [Amazon EKS Auto Mode Workshop](https://catalog.workshops.aws/eks-auto-mode/en-US)
- [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- [Amazon EKS Auto Mode ENABLED - Build your super-powered cluster](https://community.aws/content/2sV2SNSoVeq23OvlyHN2eS6lJfa/amazon-eks-auto-mode-enabled-build-your-super-powered-cluster) - A walk-through EKS Auto Mode with TF

### GitLab

- [Official GitLab documentation for integrating with Kubernetes clusters](https://docs.gitlab.com/user/clusters/agent/)

### Flux

- [Official Flux Documentation](https://fluxcd.io/flux/)
- [Example Repository for Flux](https://github.com/fluxcd/flux2-kustomize-helm-example)
