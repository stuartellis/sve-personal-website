+++
title = "Kubernetes with Helmfile and EKS Auto Mode"
slug = "eks-auto-mode"
date = "2025-07-27T12:25:00+01:00"
description = "Kubernetes with Helmfile and EKS Auto Mode"
draft = true
categories = ["automation", "aws", "devops", "kubernetes"]
tags = ["automation", "aws", "devops", "kubernetes"]
+++

This article steps you through an example project for Kubernetes clusters that supports both local development and [Amazon EKS](https://docs.aws.amazon.com/eks/).

The project uses [Helmfile](https://helmfile.readthedocs.io/en/stable/), a command-line tool for deploying sets of configuration to Kubernetes clusters. Many administrators use [GitOps](https://www.gitops.tech/) systems like [Argo CD](https://argo-cd.readthedocs.io/en/stable/) that run on a cluster and continuously apply a configuration. You can use Helmfile to deploy a GitOps system to clusters, or use it to manage all of the configuration of a cluster.

[Terraform](https://www.terraform.io/) configures EKS clusters that use [Auto Mode](https://docs.aws.amazon.com/eks/latest/userguide/automode.html). EKS Auto Mode configures clusters with a number of components and features that AWS recommend to integrate Kubernetes with their services and reduce manual maintenance.

The code for this project is published on GitHub:

- [GitHub: stuartellis/eks-auto-example](https://github.com/stuartellis/eks-auto-example)

## Components of EKS Auto Mode

[EKS Auto Mode](https://docs.aws.amazon.com/eks/latest/userguide/automode.html) adds a number of components for maintenance and AWS integration to each cluster. Each of these components is installed and updated on EKS cluster by AWS, so that you can customize the configurations but do not need to carry out any work to enable their features.

The most important components relate to the cluster nodes. EKS Auto Mode always uses [Bottlerocket](https://bottlerocket.dev), a minimal Linux-based operating system that is specifically designed to be used for nodes. [Karpenter](https://karpenter.sh/docs/) reads your cluster configuration and automatically launches EC2 instances as needed.

To ensure that security issues are resolved, Karpenter also automatically replaces older nodes. The [node monitoring agent](https://docs.aws.amazon.com/eks/latest/userguide/node-health.html) detects unhealthy nodes, so that they can be rebooted or replaced.

EKS Auto Mode also provides components to integrate the clusters with AWS, such as the [Application Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/) and [AWS VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s). It includes [CoreDNS](https://coredns.io/) for name resolution, but you must provide a method to register your cluster applications with DNS, such as [ExternalDNS](https://kubernetes-sigs.github.io/external-dns/latest/). EKS Auto Mode uses [IAM roles](https://docs.aws.amazon.com/eks/latest/userguide/automode.html) to enable AWS access for identities in the Kubernetes cluster and supports the newer EKS Pod Identities, as well as IAM Roles for Service Accounts (IRSA).

> [This document explains the differences between IRSA and Pod Identities](https://docs.aws.amazon.com/eks/latest/userguide/service-accounts.html#service-accounts-iam).

EKS Auto Mode does not provide observability components, so that you can install the logging and monitoring that is appropriate to your needs. For example, you can install Prometheus and Grafana on the cluster itself, or deploy the Datadog operator so that the cluster is monitored as part of a Datadog enterprise account, or use [Amazon CloudWatch Observability](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html) to integrate the cluster with AWS monitoring services.

## More About This Project

The project uses a specific set of tools and patterns to set up and maintain your clusters. The main technologies are [Terraform](https://www.terraform.io/) (_TF_) and [Helmfile](https://helmfile.readthedocs.io/). The project also includes tasks for the [Task](https://taskfile.dev) runner. The tasks for TF are provided by [my tooling for TF](https://www.stuartellis.name/articles/tf-monorepo-tooling/). Like this article, these tasks are opinionated, and are designed to minimise maintenance.

> I refer to Terraform and OpenTofu as _TF_. The two tools work identically for the purposes of this article.

To make it a working example, the project deploys a Web application to each cluster. This [podinfo](https://github.com/stefanprodan/podinfo) application produces a Web interface and a REST API.

### Design Decisions

The general principles for this project are:

- Use one repository for all of the code
- Support the deployment of multiple clusters for local development, cloud development, and production
- Provide a configuration that can be quickly deployed with minimal changes. The code can be customised to add features or enhance security.
- Support but not require Continuous Integration (CI)
- For EKS, use AWS services wherever possible
- Use an Infrastructure as Code tool to manage the AWS resources that are needed to run EKS clusters
- Use automation on the EKS clusters to control AWS resources that are used by the applications, so that there is a single point of configuration.

This leads to these specific technical choices:

- Use [Task](https://taskfile.dev) to provide sets of reusable tasks
- Use [Helmfile](https://helmfile.readthedocs.io/) to manage application configuration across the clusters
- Configure EKS to integrate Kubernetes and AWS identities with the established IAM Roles for Service Accounts (IRSA) method, rather than the newer EKS Pod Identities. [This document explains the differences](https://docs.aws.amazon.com/eks/latest/userguide/service-accounts.html#service-accounts-iam).
- Use [Amazon CloudWatch Observability](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html) for the clusters. This automatically adds [Fluent Bit](https://fluentbit.io/) for log capture.

### Out of Scope

This article does not cover how to set up container registries or maintain container images. These will be specific to the applications that you run on your cluster.

This article also does not cover how to set up the requirements to run TF. You should always use [remote TF state storage](https://opentofu.org/docs/language/state/remote/) for live systems. By default, the example code uses S3 for remote state. I recommend that you store TF remote state outside of the cloud accounts that you use for working systems. When you use S3 for TF remote state, use a separate AWS account.

> The TF tooling does enable you to use [local files for state](https://opentofu.org/docs/language/settings/backends/local/) instead of remote storage. Local state means that the cloud resources can only be managed from a computer that has access to the state files.

## Requirements

### Required Tools on Your Computer

This project uses several command-line tools. You can install all of these tools on Linux or macOS with [Homebrew](https://brew.sh/).

The required command-line tools are:

- [AWS CLI](https://aws.amazon.com/cli/) - `brew install awscli`
- [Helm]([https://helm.sh/]) - `brew install helm`
- [Helmfile]([https://helmfile.readthedocs.io/) - `brew install helmfile`
- [Git](https://git-scm.com/) - `brew install git`
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) - `brew install kubernetes-cli`
- [Task](https://taskfile.dev) - `brew install go-task`
- [Terraform](https://www.terraform.io/)
- [Trivy](https://trivy.dev) - `brew install trivy`

Use Homebrew to install the required tools:

```shell
brew install awscli kubernetes-cli git go-task helmfile trivy tenv cosign
```

> We use `tenv` to install the required version of Terraform during the [set up process](#preparing-your-workstation).

### AWS Account Requirements

You will require at least one AWS account to host an EKS cluster and other resources. I recommend that you store user accounts, backups and TF remote state in separate AWS accounts to the clusters.

You will need three IAM roles to deploy an EKS cluster with TF. These are for:

- Terraform access to the remote state storage
- Terraform execution
- Human administrators (operators)

The example code defines a _dev_ and _prod_ configuration, so that you can have separate development and production clusters. These copies can be in the same or separate AWS accounts.

### AWS Requirements for Each EKS Cluster

EKS clusters have various [network requirements](https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html). To avoid issues, each EKS cluster should have:

- A VPC
- Three subnets attached to the VPC, one per availability zone
- A DNS zone in Amazon Route 53

Each subnet should be a _/24_ or larger CIDR block. By default, every instance of every pod on a Kubernetes cluster will use an IP address. This means that every node will consume up to four IP addresses for Elastic Network Interfaces, plus one IP address per pod that it hosts.

> Each subnet that will be used for load balancers must have tags to authorize the Kubernetes controller for AWS Load Balancers to use them. Subnets for public-facing Application Load Balancers must have a tag of _kubernetes.io/role/elb_ with the _Value_ of _1_.

I recommend that you define a separate Route 53 zone for each cluster. Create these as child zones for a DNS domain that you own. This enables you to configure the ExternalDNS controller on a cluster to manage DNS records for applications on that cluster without enabling it to manage records on the parent DNS zone.

## Preparing Your Workstation

First, install the [requirements](#requirements). These include Task.

Next, fork the example project to your own Git repository. Clone your fork of the repository.

Change the working directory to the clone repository. Enter `task` in a terminal window to see the available tasks:

```shell
task
```

Run the `setup` task to set up the tools:

```shell
task setup
```

This will add the required plugins for Helmfile to your Helm installation and call `tenv` to install the required version of Terraform.

## Using a Local Kubernetes Cluster

The Helmfile configuration includes a `local` profile, as well as an `aws` profile. This enables you to develop with Kubernetes clusters on your laptop or workstation and then reproduce the same configuration on your EKS clusters.

There are several ways to run Kubernetes on your desktop systems, including [Minikube](https://minikube.sigs.k8s.io/docs/) and [Docker Desktop](https://www.docker.com/products/docker-desktop/). Each desktop Kubernetes system will register as a context in your `kubectl` configuration. For example, Minikube registers a cluster as `minikube` by default.

The `local` Helmfile has only one environment, which is the `default`. To run Helmfile commands, use the provided tasks. For example, run this task to apply the `local` Helmfile configuration to a `minikube` Kubernetes context:

```shell
HF_PROFILE=local HF_K8S_CONTEXT=minikube hf:apply
```

Then use the `hf:test` task to run the post-deployment integration tests that the Helm charts provide:

```shell
HF_PROFILE=local HF_K8S_CONTEXT=minikube hf:test
```

Once you have deployed the Helmfile configuration, you can start port forwarding to enable access to the default _podinfo_ application:

```shell
kubectl -n podinfo port-forward deploy/podinfo 8080:9898
```

You can then see the Web page for the _podinfo_ application. Open a Web browser window with this address:

- [http://localhost:8080/](http://localhost:8080/)

## Setting Up an EKS Cluster

## 1: Customise the Configurations for EKS

Create a _dev_ branch on the repository.

> The IAM principal that creates an EKS cluster is automatically granted membership of the _system:masters_ group in that cluster. In our example code, this principal is the IAM role that TF uses. The TF code also enables administrator access on the cluster to the IAM role for human system administrators.

## 2: Set Your AWS Credentials

If you are running the TF deployment from your own system, ensure that you have AWS credentials in your shell session:

```shell
eval $(aws configure export-credentials --format env --profile your-aws-profile)
```

## 3: Deploy the Infrastructure with TF

Run the tasks to initialise, plan and apply the TF code for each root module. For example:

```shell
TFT_UNIT=amc-domain TFT_CONTEXT=dev task tft:init && task tft:plan && task tft:apply
```

Apply the modules in this order:

1. _amc-domain_ - Deploys a Route 53 zone for the clusters
2. _amc-k8s_ - Deploys a Kubernetes cluster on Amazon EKS

Once the `apply` for _amc-k8s_ is complete, you will have an EKS cluster.

> It takes at least 10 minutes for a new EKS cluster to be created.

To use local TF state, you need to comment out the `backend "s3" {}` block in the `main.tf` file in each of the three TF root modules. You then use the task `tft:init:local`, rather than `tft:init`.

## 4: Register Your Cluster with Kubernetes Tools

Use the AWS command-line tool to register the new cluster with your kubectl configuration.

If you are running the TF deployment from your own system, first ensure that you have AWS credentials in your shell session:

```shell
eval $(aws configure export-credentials --format env --profile your-aws-profile)
```

Run this command to add the cluster to your kubectl configuration:

```shell
aws eks update-kubeconfig --name your-eks-cluster-name
```

To set this cluster as the default context for your Kubernetes tools, run this command:

```shell
kubectl config set-context your-eks-cluster-arn
```

## 5: Test Your EKS Cluster

To test the connection to the API endpoint for the cluster, first assume the IAM role for human operators. Run this command to get the credentials:

```shell
aws sts assume-role --role-arn your-human-ops-role-arn --role-session-name human-ops-session
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

Once you can successfully connect to a cluster, you can use the Helmfile command-line tool to work with the configuration for the cluster.

## 6: Deploy the Cluster Configuration

The Helmfile configuration includes an `aws` profile, which has `dev` and `prod` environments, as well as a `default` environment. Only use the `default` environment for testing.

For example, run this command to apply the `dev` environment in the `aws` Helmfile configuration to an EKS context:

```shell
HF_PROFILE=aws HF_ENVIRONMENT=dev HF_K8S_CONTEXT=arn:aws:eks:eu-west-2:1234567891012:cluster/dev-amc-k8s-210433fc hf:apply
```

## Destroying EKS Clusters

You can destroy an EKS cluster at any time. To delete a cluster, use the `tft:destroy` task:

```shell
TFT_UNIT=amc-k8s TFT_CONTEXT=dev task tft:destroy
```

## Going Further

The code in the example project is a minimal configuration for an EKS Auto Mode cluster, along with a simple example Web application. You can use [EKS add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) or Helmfile to deploy additional applications and services on the clusters.

The initial configuration is designed to work with minimal tuning. To harden the systems:

1. Replace the generated IAM policies that are provided with custom policies.
2. Disable public access to the cluster endpoint.
3. Deploy the EKS clusters to private subnets and deploy the load balancers to public subnets.

## Extra: How the TF Code Works

The tasks for TF are provided by [my tooling template](https://github.com/stuartellis/tf-tasks).

I have made several decisions in the example TF code for this project:

- The example code uses the [EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) from the [terraform-modules](https://registry.terraform.io/namespaces/terraform-aws-modules) project. This module enables you to deploy an EKS cluster by setting a relatively small number of values.
- We use a setting in the TF provider for AWS to apply tags on all AWS resources. This ensures that resources have a consistent set of tags with minimal code.
- To ensure that resource identifiers are unique, the TF code always constructs resource names in _locals_. The code for resources then uses these locals.
- The code supports [TF test](https://opentofu.org/docs/cli/commands/test/), the built-in testing framework for TF. You may decide to use other testing frameworks.
- The constructed names of AWS resources include an _edition_id_, which is set as a tfvar. The _edition_id_ is a shortened hash which uniquely identifies each instance.

## Resources

### Amazon EKS

- [Official Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [EKS Workshop](https://eksworkshop.com/) - Official AWS training for EKS
- [Amazon EKS Auto Mode Workshop](https://catalog.workshops.aws/eks-auto-mode/en-US)
- [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- [Amazon EKS Auto Mode ENABLED - Build your super-powered cluster](https://community.aws/content/2sV2SNSoVeq23OvlyHN2eS6lJfa/amazon-eks-auto-mode-enabled-build-your-super-powered-cluster) - A walk-through EKS Auto Mode with TF

### Helmfile

- [Official Helmfile Documentation](https://helmfile.readthedocs.io/)
- [Even more powerful Helming with Helmfile](https://www.hackerstack.org/even-more-powerful-helming-with-helmfile/) - A tutorial for Helmfile by _Gmkziz_
- [Helmfile - How to manage Kubernetes Helm releases](https://www.youtube.com/watch?v=qIJt8Iq8Zb0), a video by _AI & DevOps Toolkit_, 29 minutes
