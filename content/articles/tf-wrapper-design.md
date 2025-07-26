+++
title = "Designing a Wrapper for Terraform & OpenTofu"
slug = "tf-wrapper-design"
date = "2025-07-26T15:11:00+01:00"
description = "Designing a wrapper for working with Terraform & OpenTofu components"
categories = ["automation", "aws", "devops", "opentofu", "terraform"]
tags = ["automation", "aws", "devops", "opentofu", "terraform"]
+++

This article describes [an implementation of a wrapper](https://www.stuartellis.name/articles/tf-monorepo-tooling/) for [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/). This particular implementation is for [monorepos](https://en.wikipedia.org/wiki/Monorepo), where the infrastructure configurations can be maintained in the same project alongside other code. The design also enables projects to support:

- Multiple infrastructure components in the same code repository. Each [unit](#units---tf-modules-as-components) is a complete [root module](https://opentofu.org/docs/language/modules/).
- Multiple instances of the same component with [different configurations](#contexts---configuration-profiles)
- [Extra instances](#extra-instances---workspaces-and-tests) of a component for development and testing.
- Integration testing for every component.
- Migrating from Terraform to OpenTofu. You use the same tasks for both.

This means that we avoid creating a [terralith](https://masterpoint.io/blog/terralith-monolithic-terraform-architecture/), where all of TF code for all of the resources is in a single root module.

The code for this example tooling is available on GitHub:

- [https://github.com/stuartellis/tf-tasks](https://github.com/stuartellis/tf-tasks)

For practical walk-through of using the example tooling, see [this article](https://www.stuartellis.name/articles/tf-monorepo-tooling/).

Several of the same design considerations apply to wrappers for other Infrastructure as Code (IaC) tools.

> These articles uses the identifier _TF_ or _tf_ for Terraform and OpenTofu. Both tools accept the same commands and have the same behavior. The tooling itself is just called `tft` (_TF Tasks_).

## Goals

The first goal is that this tooling must enable us to use monorepos. This means that a single source code repository is able to contain the code for both the infrastructure along with code for applications and other tools.

The infrastructure code should be defined as one or more named components. We need to enable multiple instances of each of these infrastructure code components to be deployed to multiple environments.

The other key goals are:

1. We must be able to continue to maintain the deployed copies of the infrastructure over time, as TF versions change
2. We must be able to use this tooling alongside other tools
3. We must be able to stop using this tooling at any time without needing to rewrite the infrastructure code

In general, the tooling should be easy to understand, extend and debug. We should try to avoid the risk of adding a layer of software on top of TF that masks errors or complicates the process of debugging issues with infrastructure deployments.

## Design Rules

To achieve the goals, the tooling follows three specific rules:

1. Each [component](#units---tf-modules-as-components) is a complete and valid TF root module
2. The tooling only requires that each root module implements a small number of [specific input variables](#units---tf-modules-as-components).
3. The tooling does not impose any limitations on the code within the modules. The generated code for new modules can be completely replaced.

## Technology Decisions

This tooling uses a wrapper to interact with Terraform and OpenTofu. A wrapper is a tool that generates commands and sends them to the executable for you. This is a common idea, and wrappers have been written with a variety of technologies and programming languages.

The wrapper itself is a single [Task](https://www.stuartellis.name/articles/task-runner/) file. Task is a command-line tool that generates and runs _tasks_, shell commands that are defined in a Taskfile. Each Taskfile is a YAML document that defines templates for the commands. Task uses a versioned and published schema so that we can [validate Taskfiles](https://www.stuartellis.name/articles/task-runner/#checking-taskfiles). If necessary, we can replace Task with any other tool that generates the same commands.

Each task in the Taskfile uses standard UNIX commands, and they do not include any code in a programming language, such as Python or Go. Since the UNIX commands and the command-line interfaces of [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/) are stable, the tasks are not tied to particular versions of these tools, and they do not need updates as new versions are released.

The tooling is built as a [Copier](https://copier.readthedocs.io/en/stable/) template that includes the Task file. Copier enables us to create new projects from the template, add the tooling to any existing project, and synchronize the copies of the tooling in our projects with newer versions as needed. Copier uses Git and tracks releases by tags, so that templates can be distributed through any code hosting service.

I have avoided requiring any extra configuration as much as possible. The tooling uses the files and directories in the project, so that you do not need to maintain a separate set of configuration. There are [small configuration files](#contexts---configuration-profiles) alongside the TF variables files, since they are needed to support TF remote state and enable the concept of environments. These files use the JSON format, since JSON is supported by all modern tools.

These decisions mean that the tooling will run on any UNIX-based system, including restricted environments like continuous integration runners and Alpine Linux containers. The wrapper works with any UNIX shell, using Task. We can install Terraform or OpenTofu through any method that we prefer, although [I usually recommend tenv](#working-with-tf-versions). We only need Python and Copier when we create and update projects.

## How It Works

First, you run [Copier](https://copier.readthedocs.io/en/stable/) to either generate a new project, or to add this tooling to an existing project.

The tooling uses specific files and directories:

```shell
|- tasks/
|   |
|   |- tft/
|       |- Taskfile.yaml
|
|- tf/
|    |- .gitignore
|    |
|    |- contexts/
|    |   |
|    |   |- all/
|    |   |
|    |   |- template/
|    |   |
|    |   |- <generated contexts>
|    |
|    |- units/
|    |    |
|    |    |- template/
|    |    |
|    |    |- <generated unit definitions>
|    |
|    |- modules/
|
|- tmp/
|    |
|    |- tf/
|
|- .gitignore
|- .terraform-version
|- README.md
|- Taskfile.yaml
```

The Copier template:

- Adds a `.gitignore` file, a `README.md` file and a `Taskfile.yaml` file to the root directory of the project, if these do not already exist.
- Provides a `.terraform-version` file.
- Provides the file `tasks/tft/Taskfile.yaml` to the project. This file contains the task definitions.
- Provides a `tf/` directory structure for TF files and configuration.

The tasks:

- Generate a `tmp/tf/` directory for artifacts.
- Only change the contents of the `tf/` and `tmp/tf/` directories.
- Copy the contents of the `template/` directories to new units and contexts. These provide consistent structures for each component.

## Units - TF Modules as Components

To work with the tooling, a TF module must be a valid [root module](https://opentofu.org/docs/language/modules/), and the input variables must include four string variables that have specific names. This tooling refers to modules that follow these requirements as _units_.

These requirements enable us to handle every unit as a component that behaves in a standard way, regardless of the differences between them. For example, since each unit is a separate root module, we can have different versions of the same providers in different units.

The four required input variables are:

- `tft_product_name` (string) - The name of the product or project
- `tft_environment_name` (string) - The name of the environment
- `tft_unit_name` (string) - The name of the component
- `tft_edition_name` (string) - An identifier for the specific instance of the resources

To create a new unit, use the `tft:new` task:

```shell
TFT_UNIT=my-app task tft:new
```

Each unit is created as a subdirectory in the directory `tf/units/`. The provided code implements the required input variables in the file `tft_variables.tf`.

The tooling sets the values of the required variables when it runs TF commands on a unit:

- `tft_product_name` - Defaults to the name of the project, but you can override this
- `tft_environment_name` - Provided by the current [context](#contexts---configuration-profiles)
- `tft_unit_name` - The name of the unit itself
- `tft_edition_name` - Set as the value `default`, except when using an [extra instance](#extra-instances---workspaces-and-tests) or running tests

The provided code for new units also includes the file `meta_locals.tf`, which defines locals that use these variables to help you generate [names and identifiers](#managing-resource-names). These include a `edition_id`, a short version of a SHA256 hash for the instance. This means that you can deploy as many instances of the module as you wish without conflicts, as long as you use the `edition_id` as part of each resource name:

```hcl
resource "aws_dynamodb_table" "example_table" {
  name = "${local.meta_product_name}-${local.meta_component_name}-example-${local.edition_id}"
```

> Only use the required variables in locals, then use those locals to define resource names. This ensures that your deployed resources are not tied to the details of the tooling.

This tooling creates new units as a copy of files in `tf/units/template/`. If the provided code is not appropriate, you can customise the contents of a module in any way that you need. The tooling automatically finds all of the modules in the directory `tf/units/`. It only requires that a module is a valid TF root module and accepts the four defined input variables. The `edition_id` and other locals in `meta_locals.tf` give you a set of conventions to help you manage resource names, but the tooling does not rely on them.

> If you do not use the `edition_id` or an equivalent hash in the name of a resource, you must decide how to ensure that each copy of the resource will have a unique name.

## Contexts - Configuration Profiles

Contexts enable you to define named configurations for TF. You can then use these to deploy multiple instances of the same unit with different configurations, instead of needing to maintain separate sets of code for different instances. For example, if you have separate AWS accounts for development and production then you can define these as separate contexts.

To create a new context, use the `tft:context:new` task:

```shell
TFT_CONTEXT=dev task tft:context:new
```

Each context is a subdirectory in the directory `tf/contexts/` that contains a `context.json` file and one `.tfvars` file per unit.

To avoid compatibility issues between systems, we should use context and environment names that only include lowercase letters, numbers and hyphen characters, with the first character being a lowercase letter. The section on [resource names](#managing-resource-names) provides more guidance.

### The context.json File

The `context.json` file is the configuration file for the context. It specifies metadata and settings for TF [remote state](https://opentofu.org/docs/language/state/remote/).

Here is an example of a `context.json` file:

```json
{
  "metadata": {
    "description": "Cloud development environment",
    "environment": "dev"
  },
  "backend_s3ddb": {
    "tfstate_bucket": "789000123456-tf-state-dev-eu-west-2",
    "tfstate_ddb_table": "789000123456-tf-lock-dev-eu-west-2",
    "tfstate_dir": "dev",
    "region": "eu-west-2",
    "role_arn": "arn:aws:iam::789000123456:role/my-tf-state-role"
  }
}
```

Each `context.json` file specifies two items of metadata:

- `environment`
- `description`

The `environment` is a string that is automatically provided to TF as the tfvar `tft_environment_name`.

> Contexts exist to provide configurations for TF. To avoid coupling live resources directly to contexts, the tooling does not pass the name of the active context to the TF code, only the `environment` name that the context specifies.

The `description` is deliberately not used by the tooling, so that you can leave it empty, or do whatever you wish with it.

The `context.json` file stores configuration for TF remote state storage. We could have tried to define the remote state with TF _backend_ configuration files and set the generated commands to use these directly. This would have prevented us from being able to programmatically change or validate the backend configuration at all.

The configuration file uses JSON because the JSON format can be read and written by the widest range of tools and programming languages. For example, we can work with JSON in UNIX shell scripts by using [jq](https://jqlang.org/).

### Managing TF Variables for a Context

To enable us to have variables for a unit that apply for every context, the directory `tf/contexts/all/` contains one `.tfvars` file for each unit. The `.tfvars` file for a unit in the `tf/contexts/all/` directory is always used, along with `.tfvars` for the current context.

The tooling creates each new context as a copy of files in `tf/contexts/template/`. It copies the `standard.tfvars` file to create the tfvars files for new units. You can actually create and edit the contexts with any method. The tooling will automatically find all of the contexts in the directory `tf/contexts/`.

## Extra Instances - Workspaces and Tests

TF has two different ways to create extra copies of the same infrastructure from a root module: [workspaces](https://opentofu.org/docs/language/state/workspaces/) and [tests](https://opentofu.org/docs/cli/commands/test/). We use workspaces to have multiple sets of resources that are associated with the same root module. These copies might be from different branches of the code repository for the project. The test feature uses _apply_ to create new copies of resources and then automatically runs _destroy_ to remove them at the end of each test run.

The extra copies of resources for workspaces and tests create a problem. If we run the same code with the same inputs TF could attempt to create multiple copies of resources with the same name. Cloud services often refuse to allow us to have multiple resources with identical names. They may also keep deleted resources for a period of time, which prevents us from creating new resources that have the same names as other resources that we have deleted.

To solve this problem, the tooling allows each copy of a set of infrastructure to have a separate identifier, regardless of how the copy was created. This identifier is called the _edition_. The edition is always set to the value _default_, unless you run a test or decide to use an extra instance.

The provided TF code for modules combines the edition and the other standard variables to create a unique SHA256 hash for the instance. A short version of this hash is registered in the locals as `edition_id`, so that we can create unique names for resources. The full version of this hash is also registered as a local called `meta_instance_sha256_hash`, and attached to resources as an AWS tag.

A [later section](#managing-resource-names) has more about resource names and instance hashes.

### Working with Extra Instances

By default, TF works with the main copy of the resources for a module. This means that it uses the `default` workspace.

To work with another copy of the resources, we set the variable `TFT_EDITION`. The tooling then sets the active workspace to match the variable `TFT_EDITION` and sets the tfvar `tft_edition_name` to the same value. If a workspace with that name does not already exist, it will automatically be created. To remove a workspace, first run the `destroy` task to terminate the copy of the resources that it manages, and then run the `forget` task to delete the stored state.

You can use any string for the variable `TFT_EDITION`. For example, you can configure your CI system to set the variable `TFT_EDITION` with values that are based on branch names.

You do not set `TFT_EDITION` for tests. The example test in the unit template includes code to automatically set the value of `tft_edition_name` to a random string with the prefix `tt`. This is because we need to use a pattern for `tft_edition_name` that guarantees a unique value for every test run. You can change this to use a different format in the `tft_edition_name` identifier for your tests.

## Managing Resource Names

Cloud systems use tags or labels to enable us to categorise and manage resources. However, resources often need to have unique names. Every type of cloud resource may have a different set of rules about acceptable names. The tooling uses hashes to provide a `edition_id` as a local, so that every deployed instance of a module has a unique identifier that we can use in the resource names.

For consistency and the best compatibility between systems, we should always follow some simple guidelines for names. Values should only include lowercase letters, numbers and hyphen characters, with the first character being a lowercase letter. To avoid limits on the total length of resource names, try to limit the size of other types of name:

- _Product or project name:_ `tft_product_name` - 12 characters or less
- _Component name:_ `tft_unit_name` - 12 characters or less
- _Environment name:_ `tft_environment_name` - 8 characters or less
- _Instance name:_ `tft_edition_name` - 8 characters or less

To avoid coupling live resources to the tooling, do not reference these variables directly in resource names. Use these variables in locals, and then use the locals to set resource names. For convenience, the code that is provided for new modules includes locals and outputs that you can use in resource names. These are defined in the file `meta_locals.tf`:

```hcl
locals {

  # Use these in tags and labels
  meta_component_name       = lower(var.tft_unit_name)
  meta_edition_name         = lower(var.tft_edition_name)
  meta_environment_name     = lower(var.tft_environment_name)
  meta_product_name         = lower(var.tft_product_name)
  meta_instance_sha256_hash = sha256("${local.meta_product_name}-${local.meta_environment_name}-${local.meta_component_name}-${local.meta_edition_name}")

  # Use this in resource names
  edition_id = substr(local.meta_instance_sha256_hash, 0, 8)
}
```

The SHA256 hash in the locals provides a unique identifier for each instance of the root module. This enables us to have a short `edition_id` that we can use in any kind of resource name. For example, we might create large numbers of Lambdas in an AWS account with different TF root modules, and they will not conflict if the name of each Lambda includes the `edition_id`.

For convenience, the tooling includes tasks to calculate the ID and the full SHA256 hash, so that we can match deployed resources to the code that produced them:

```shell
TFT_CONTEXT=dev TFT_UNIT=my-app task tft:edition:id
TFT_CONTEXT=dev TFT_UNIT=my-app task tft:edition:sha256
```

The provided module code also deploys an AWS Parameter Store parameter that has the `edition_id`, and attaches an `EditionId` tag to every resource. This enables us to query AWS for resources by instance.

> The provided test setup in each unit includes code to set the value of the variable `tft_edition_name` to a random string with the prefix `tt`. This means that test copies of resources have unique identifiers and will not conflict with existing resources that were deployed with the same TF module.

## Supporting Shared Modules

The project structure includes a `tf/shared/` directory to hold TF modules that are shared between the root modules in the same project. By design, the tooling does not manage any of these shared modules, and does not impose any requirements on them.

To share modules between projects, [publish them to a registry](https://opentofu.org/docs/language/modules/#published-modules).

## Working with TF Versions

You will need to use different versions of Terraform and OpenTofu for different projects. The state files will change when you use new versions, so each project must specify the current version that is in use.

The best way to handle this is to use a version manager. This will install the versions that you specify in a configuration file and automatically switch between them as needed.

This tooling is designed to work with version managers and not complicate version changes. It does not install or manage copies of Terraform and OpenTofu. Unlike other wrappers, it is also not dependent on specific versions of Terraform or OpenTofu. It supports new features by new tasks, but never hard-codes references to specific versions.

For convenience, the generated projects include a `.terraform-version` file, so that your tool version manager will install and use the Terraform version that you specify. To use OpenTofu, add an `.opentofu-version` file to enable your tool version manager to install and use the OpenTofu version that you specify. Once the version file is generated, you change the version as you need.

> This tooling can switch between Terraform and OpenTofu. This is specifically to help you migrate projects from one of these tools to the other.

You are free to manage versions in any way that wish. If you do not have any specific requirements for a project, consider using [tenv](https://tofuutils.github.io/tenv/), which is a version manager that is specifically designed for TF tools. For some projects, [mise](https://mise.jdx.dev/) may be a good choice, because it control all of the tools for a project, not just Terraform and OpenTofu.

## Dependencies Between Units

This tooling does not specify or enforce any dependencies between infrastructure components. We are free to run operations on separate components in parallel whenever you believe that this is safe. If we need to execute changes in a particular order, we can specify that order in whichever system we are using to carry out deployments.

Similarly, there are no restrictions on how we run tasks on multiple units. We can use any method that can call Task several times with the required variables. For example, we can create your own Taskfiles that call the supplied tasks, write a script, or define jobs for a CI system.

> This tooling does not explicitly support or conflict with the [stacks feature of Terraform](https://developer.hashicorp.com/terraform/language/stacks). I do not currently test with the stacks feature. It is unclear if this feature will be permanently tied to Hashicorp cloud services in Terraform, or what equivalent will be implemented by OpenTofu.

## Migrating to OpenTofu

By default, this tooling currently uses Terraform. [OpenTofu](https://opentofu.org/) accepts the same commands, which means that we can switch between the two. Set `TFT_CLI_EXE` as an environment variable to specify the path to the tool that you wish to use. To use OpenTofu, set `TFT_CLI_EXE` with the value `tofu`:

```shell
export TFT_CLI_EXE=tofu

TFT_CONTEXT=dev TFT_UNIT=my-app tft:init
```

To specify which version of OpenTofu to use, create a `.opentofu-version` file. This file should contain the version of OpenTofu and nothing else, like this:

```shell
1.10.2
```

The `tenv` tool reads this file when installing or running OpenTofu.

> Remember that if you switch between Terraform and OpenTofu, you will need to initialise your unit again, and when you run `apply` it will migrate the TF state. The OpenTofu Website provides [migration guides](https://opentofu.org/docs/intro/migration/), which includes information about code changes that you may need to make.

## Going Further

This example tooling was built for my personal use. I am happy to consider feedback and suggestions, but I may decline to implement anything that makes it less useful for my needs. You are welcome to use this work as a basis for your own wrappers. The ideas in this wrapper can be implemented in any task runner or programming language that you wish.
