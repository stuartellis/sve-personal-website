+++
title = "Low-Maintenance Kubernetes with EKS Auto Mode"
slug = "eks-auto-mode"
date = "2025-05-19T03:04:00+01:00"
description = "Using EKS with Auto Mode"
categories = ["automation", "aws", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "kubernetes"]
+++

[Kubernetes](https://kubernetes.io/) is now a standard technology for high-availability clusters. This article steps you through an example project for setting up Kubernetes clusters on [Amazon EKS](https://docs.aws.amazon.com/eks/) with Infrastructure as Code. The EKS clusters use [Auto Mode](https://docs.aws.amazon.com/eks/latest/userguide/automode.html), which automates the scaling and update of nodes, manages several components in the cluster, and simplifies cluster upgrades. The configuration is managed by [Terraform](https://www.terraform.io/) and [Flux](https://fluxcd.io/).

The code for this project is published on both GitLab and GitHub:

- [GitLab: sve-projects/eks-auto-example](https://gitlab.com/sve-projects/eks-auto-example)
- [GitHub: stuartellis/eks-auto-example](https://github.com/stuartellis/eks-auto-example)

## Components of EKS Auto Mode

[EKS Auto Mode](https://docs.aws.amazon.com/eks/latest/userguide/automode.html) adds a number of components for maintenance and AWS integration to each cluster. Each of these components is installed and updated on EKS cluster by AWS, so that you can customize the configurations but do not need to carry out any work to use their features.

The most important components relate to the cluster nodes. EKS Auto Mode always uses [Bottlerocket](https://bottlerocket.dev), a minimal Linux-based operating system that is specifically designed to be used for nodes. [Karpenter](https://karpenter.sh/docs/) reads the cluster configuration and automatically launches EC2 instances as needed. To ensure that security issues are resolved, Karpenter also automatically replaces older nodes. The [node monitoring agent](https://docs.aws.amazon.com/eks/latest/userguide/node-health.html) detects unhealthy nodes, so that they can be rebooted or replaced.

> You can customise the behaviour of Karpenter by deploying configuration into the Kubernetes cluster.

EKS Auto Mode also provides components to integrate the clusters with AWS, such as the [Application Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/) and [AWS VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s). It includes [CoreDNS](https://coredns.io/) for name resolution, but you must provide a method to register your cluster applications with DNS, such as [ExternalDNS](https://kubernetes-sigs.github.io/external-dns/latest/). EKS Auto Mode uses [IAM roles](https://docs.aws.amazon.com/eks/latest/userguide/automode.html) to enable AWS access for identities in the Kubernetes cluster and supports the newer EKS Pod Identities, as well as IAM Roles for Service Accounts (IRSA).

> [This document explains the differences between IRSA and Pod Identities](https://docs.aws.amazon.com/eks/latest/userguide/service-accounts.html#service-accounts-iam).

EKS Auto Mode does not provide observability components, so that you can install the logging and monitoring that is appropriate to your needs. For example, you can install Prometheus and Grafana on the cluster itself, or deploy the Datadog operator so that the cluster is monitored as part of a Datadog enterprise account, or use [Amazon CloudWatch Observability](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html) to integrate the cluster with AWS monitoring services.

## More About This Project

The project uses a specific set of tools and patterns to set up and maintain your clusters. The main technologies are [Terraform](https://www.terraform.io/) (_TF_) and [Flux](https://fluxcd.io/). The project also includes tasks for the [Task](https://taskfile.dev) runner. The tasks for TF are provided by [my tooling for TF](https://www.stuartellis.name/articles/tf-monorepo-tooling/). Like this article, these tasks are opinionated, and are designed to minimise maintenance.

> I refer to Terraform and OpenTofu as _TF_. The two tools work identically for the purposes of this article.

To make it a working example, the project deploys a Web application to each cluster. The [podinfo](https://github.com/stefanprodan/podinfo) application produces a Web interface and a REST API.

### Design Decisions

The general principles for this project are:

- Use one repository for all of the code
- Provide a configuration that can be quickly deployed with minimal changes. The code can be customised to add features or enhance security.
- Choose well-known and well-supported tools
- Support the deployment of multiple clusters for development and production
- Use AWS services wherever possible
- Use an Infrastructure as Code tool to manage the AWS resources that are needed to run each cluster
- Use automation on the cluster to control AWS resources that are used by the applications, so that there is a single point of control.
- Use [GitOps](https://www.gitops.tech/) to manage application configuration.

The combination of delegated control and GitOps means that the live configurations for applications are automatically synchronized with the copy in source control and matching AWS resources are created and updated as needed.

The design principles lead to these specific technical choices:

- Integrate Kubernetes and AWS identities with the established IAM Roles for Service Accounts (IRSA) method, rather than the newer EKS Pod Identities. [This document explains the differences](https://docs.aws.amazon.com/eks/latest/userguide/service-accounts.html#service-accounts-iam).
- Use [Amazon CloudWatch Observability](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html) for the clusters. This automatically adds [Fluent Bit](https://fluentbit.io/) for log capture.
- Use [Flux](https://fluxcd.io/flux/) for manage application configuration on the cluster

### Out of Scope

This article does not cover how to set up container registries or maintain container images. These will be specific to the applications that you run on your cluster.

This article also does not cover how to set up the requirements to run TF. You should always use remote state storage with TF, but you should decide how to host the remote state. By default, the example code uses S3 for [remote state](https://opentofu.org/docs/language/state/remote/). I recommend that you store TF remote state outside of the cloud accounts that you use for working systems. When you use S3 for TF remote state, use a separate AWS account.

> The TF tooling enables you to use [local files for state](https://opentofu.org/docs/language/settings/backends/local/) instead of remote storage. Only use local state for testing. Local state means that the cloud resources can only be managed from a computer that has access to the state files.

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

Flux can use [Helm](https://helm.sh/) to manage packages on your clusters, but you do not need to install the Helm command-line tool.

### Version Control and Continuous Integration

To automate operations, you need a Git repository that is available to your development workstation, the resources on your AWS accounts and your continuous integration system.

Flux updates the configuration of the cluster from this Git repository. This means that you do not need continuous integration to deploy changes. However, you should use continuous integration to test configurations before they are merged to the _main_ branch of the repository and applied to the production cluster by Flux.

This example uses [GitLab](https://gitlab.com/) as the provider for Git hosting. GitLab also provides continuous integration services. You can use [GitHub or other services](https://fluxcd.io/flux/installation/bootstrap/) for hosting and continuous integration instead of GitLab.

### AWS Account Requirements

You will require at least one AWS account to host an EKS cluster and other resources. I recommend that you store user accounts, backups and TF remote state in separate AWS accounts to the clusters.

You will need two IAM roles to deploy an EKS cluster with TF:

- An IAM role for Terraform
- An IAM role for human administrators

The example code defines a _dev_ and _prod_ configuration, so that you can have separate development and production clusters. These copies can be in the same or separate AWS accounts.

### AWS Requirements for Each EKS Cluster

EKS clusters have various [network requirements](https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html). To avoid issues, each EKS cluster should have:

- A VPC
- Three subnets attached to the VPC, one per availability zone
- A DNS zone in Amazon Route 53

Each subnet should be a _/24_ or larger CIDR block. By default, every instance of every pod on a Kubernetes cluster will use an IP address. This means that every node will consume up to four IP addresses for Elastic Network Interfaces, plus one IP address per pod that it hosts.

> Each subnet that will be used for load balancers must have tags to authorize the Kubernetes controller for AWS Load Balancers to use them. Subnets for public-facing Application Load Balancers must have a tag of _kubernetes.io/role/elb_ with the _Value_ of _1_.

I recommend that you define a separate Route 53 zone for each cluster. Create these as child zones for a DNS domain that you own. This enables you to configure the ExternalDNS controller on a cluster to manage DNS records for applications on that cluster without enabling it to manage records on the parent DNS zone.

## 1: Prepare Your Repository

Clone or fork the example project to your own Git repository. To use the provided Flux configuration, use GitLab as the Git hosting provider. The example code for this project is published on both [GitLab](https://gitlab.com/sve-projects/eks-auto-example) and [GitHub](https://github.com/stuartellis/eks-auto-example).

Create a _dev_ branch on the repository. The Flux configuration on _development_ clusters will synchronize from this _dev_ branch. The Flux configuration on _production_ clusters will synchronize from the _main_ branch.

## 2: Customise Configuration

Next, change the configuration for your own infrastructure.

The relevant directories for configuration are:

- _flux/apps/dev/_ - Flux configuration for _development_ clusters
- _flux/apps/prod/_ - Flux configuration for _production_ clusters
- _tf/contexts/dev/_ - TF configuration for _development_ clusters
- _tf/contexts/prod/_ - TF configuration for _production_ clusters

Change each value that is marked as _Required_. In addition, specify the settings for the TF backend in the `tf/contexts/context.json` file for _dev_ and _prod_.

> The IAM principal that creates an EKS cluster is automatically granted membership of the _system:masters_ group in that cluster. In our example code, this principal is the IAM role that TF uses. The TF code also enables administrator access on the cluster to the IAM role for human system administrators.

## 3: Set Credentials

This process needs access to both AWS and your Git hosting provider.

To work with GitLab, set an [access token](https://docs.gitlab.com/user/profile/personal_access_tokens/) as the environment variable `GITLAB_TOKEN`.

If you are running the TF deployment from your own system, ensure that you have AWS credentials in your shell session:

```shell
eval $(aws configure export-credentials --format env --profile your-aws-profile)
```

If you want to use [local TF state](https://opentofu.org/docs/language/settings/backends/local/), you also need to set the environment variable `TFT_REMOTE_BACKEND` as `false`:

```shell
TFT_REMOTE_BACKEND=false
```

## 4: Deploy the Infrastructure with TF

Run the tasks to initialise, plan and apply the TF code for each module. For example:

```shell
TFT_STACK=amc-gitlab TFT_CONTEXT=dev task tft:init
TFT_STACK=amc-gitlab TFT_CONTEXT=dev task tft:plan
TFT_STACK=amc-gitlab TFT_CONTEXT=dev task tft:apply
```

Apply the modules in this order:

1. _amc-gitlab_ - Creates a deploy key on GitLab for Flux
2. _amc_ - Deploys a Kubernetes cluster on Amazon EKS
3. _amc-flux_ - Adds Flux to a Kubernetes Cluster with the GitLab deploy key

> The `apply` to create a cluster on EKS will take several minutes to complete.

## 5: Register Your Cluster with Kubernetes Tools

Use the AWS command-line tool to register the new cluster with your kubectl configuration.

If you are running the TF deployment from your own system, first ensure that you have AWS credentials in your shell session:

```shell
eval $(aws configure export-credentials --format env --profile $AWS-PROFILE)
```

Run this command to add the cluster to your kubectl configuration:

```shell
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME
```

To set this cluster as the default context for your Kubernetes tools, run this command:

```shell
kubectl config set-context $EKS-CLUSTER-ARN
```

## 6: Test Your Cluster

To test the connection to the API endpoint for the cluster, first assume the IAM role for human operators. Run this command to get the credentials:

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

Once you can successfully connect to a cluster, you can use the _flux_ command-line tool to work with Flux on that cluster. The example project provides tasks for this.

To check the current status of Flux on the cluster:

```shell
task flux:status
```

Flux checks the Git branches and applies changes to the cluster every few minutes. Use this task to trigger Flux on the cluster, rather than waiting for a scheduled run:

```shell
task flux:apply
```

## 7: Going Further

The code in the example project is a minimal configuration for an EKS Auto Mode cluster, along with a simple example Web application that is managed by Flux and Helm. You can use [EKS add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) or Flux to deploy additional applications and services on the clusters. Flux also provides a range of management capabilities, including [automated update of container images](https://fluxcd.io/flux/components/image/) and [notifications](https://fluxcd.io/flux/monitoring/alerts/).

The initial configuration is designed to work with minimal tuning. To harden the systems:

1. Replace the generated IAM policies that are provided with custom policies.
2. Disable public access to the cluster endpoint.
3. Deploy the EKS clusters to private subnets and deploy the load balancers to public subnets.

The current version of this project does not include continuous integration with GitLab. If you decide to use GitLab to manage changes, consider installing the [GitLab cluster agent](https://docs.gitlab.com/user/clusters/agent/).

## Extra: How the TF Code Works

The tasks for TF are provided by [my tooling template](https://github.com/stuartellis/tf-tasks).

I have made several decisions in the example TF code for this project:

- The example code uses the [EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) from the [terraform-modules](https://registry.terraform.io/namespaces/terraform-aws-modules) project. This module enables you to deploy an EKS cluster by setting a relatively small number of values.
- We use a setting in the TF provider for AWS to apply tags on all AWS resources. This ensures that resources have a consistent set of tags with minimal code.
- To ensure that resource identifiers are unique, the TF code always constructs resource names in _locals_. The code for resources then uses these locals.
- The code supports [TF test](https://opentofu.org/docs/cli/commands/test/), the built-in testing framework for TF. You may decide to use other testing frameworks.
- The constructed names of AWS resources include a _variant_, which is set as a tfvar. The _variant_ is either the name of the current TF workspace, or a random identifier for TF test runs.

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
