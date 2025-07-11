+++
title = "An Example of Tooling for Terraform & OpenTofu in Monorepos"
slug = "tf-monorepo-tooling"
date = "2025-07-11T06:43:00+01:00"
description = "Tooling for Terraform and OpenTofu in monorepos"
categories = ["automation", "aws", "devops", "opentofu", "terraform"]
tags = ["automation", "aws", "devops", "opentofu", "terraform"]
+++

This article describes an example of tooling for [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/) in a [monorepo](https://en.wikipedia.org/wiki/Monorepo). The infrastructure configurations can be maintained in the same project, alongside other code. The design also enables projects to support:

- Multiple infrastructure components in the same code repository. Each of these _units_ is a complete [root module](https://opentofu.org/docs/language/modules/).
- Multiple instances of the same component with different configurations. The TF configurations are called _contexts_.
- [Extra instances of a component](#using-extra-instances). Use this to deploy instances from version control branches for development, or to create temporary instances.
- [Integration testing](#testing) for every component.
- [Migrating from Terraform to OpenTofu](#using-opentofu). You use the same tasks for both.

The tooling is built as a [Copier](https://copier.readthedocs.io/en/stable/) template. Copier enables us to create new projects from the template, add the tooling to any existing project, and synchronize the copies of the tooling in our projects with newer versions as needed.

The wrapper itself is a single [Task](https://www.stuartellis.name/articles/task-runner/) file. Task is a command-line tool that generates and runs _tasks_, shell commands that are defined in a Taskfile. Each Taskfile is a YAML document that defines templates for the commands. Task uses a versioned and published schema so that we can [validate Taskfiles](https://www.stuartellis.name/articles/task-runner/#checking-taskfiles). By design, we can replace this Task wrapper with any other script or tool that generates the same commands.

This tooling does not use or rely on the [stacks feature of HCP Terraform](https://developer.hashicorp.com/terraform/language/stacks). Since the _units_ are standard valid modules, they can be used with stacks or [any orchestration](#what-about-dependencies-between-components).

The code for this example tooling is available on GitHub:

- [https://github.com/stuartellis/tf-tasks](https://github.com/stuartellis/tf-tasks)

For more details about how this tooling works and the design decisions, read my [article on designing a wrapper for TF](https://www.stuartellis.name/articles/tf-wrapper-design/).

> This article uses the identifier _TF_ or _tf_ for Terraform and OpenTofu. Both tools accept the same commands and have the same behavior. The tooling itself is just called `tft` (_TF Tasks_).

## Quick Examples

First, install the tools on Linux or macOS with [Homebrew](https://brew.sh/):

```shell
brew install git go-task uv cosign tenv
```

Start a new project:

```shell
# Run Copier with uv to create a new project, and enter your details when prompted
uvx copier copy git+https://github.com/stuartellis/tf-tasks my-project

# Go to the working directory for the project
cd my-project

# Ask tenv to detect and install the correct version of Terraform for the project
tenv terraform install

# Create a configuration and a root module for the project
TFT_CONTEXT=dev task tft:context:new
TFT_UNIT=my-app task tft:new
```

The `tft:new` task creates a _unit_, a complete Terraform root module. Each new root module includes example code for AWS, so that it can work immediately. The context is a configuration profile. You only need to set:

1. Either remote state storage settings in the context, OR use [local state](#using-local-tf-state)
2. The AWS IAM role for TF itself. This is the variable `tf_exec_role_arn` in the tfvars files for the context.

You can then start working with your TF module:

```shell
# Set a default configuration and module
export TFT_CONTEXT=dev TFT_UNIT=my-app

# Run tasks on the module with the configuration from the context
task tft:init
task tft:plan
task tft:apply
```

You can always specifically set the unit and context for a task. This example runs `validate` on the module:

```shell
TFT_CONTEXT=dev TFT_UNIT=my-app task tft:validate
```

Code included in each TF module provides unique identifiers for instances, so that you can have multiple copies of the resources at the same time. The only requirement is that you include `handle` as part of each resource name:

```hcl
resource "aws_dynamodb_table" "example_table" {
  name = "${local.meta_product_name}-${local.meta_component_name}-example-${local.handle}"
```

To create an extra copy of the resources for a module, set the variable `TFT_EDITION` with a unique name for the copy. This example will deploy an extra instance called `copy2` alongside the main set of resources:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app

# Create a disposable copy of my-app
TFT_EDITION=copy2 task tft:plan
TFT_EDITION=copy2 task tft:apply

# Destroy the extra copy of my-app
TFT_EDITION=copy2 task tft:destroy

# Clean-up: Delete the remote TF state for the extra copy of my-app
TFT_EDITION=copy2 task tft:forget
```

Use this feature to create disposable instances for the branches of your code as you need them.

The ability to have multiple copies of resources for the same module also enables us to run [integration tests](#testing) at any time. This example runs tests for the module:

```shell
TFT_CONTEXT=dev TFT_UNIT=my-app task tft:test
```

All of the commands are available through [Task](https://www.stuartellis.name/articles/task-runner/). To see a list of the available tasks in a project, enter _task_ in a terminal window:

```shell
task
```

If you set up [shell completions](https://taskfile.dev/installation/#setup-completions) for Task, you will see you suggestions as you type.

## Usage

To use the tasks in a generated project you will need:

- A UNIX shell
- [Git](https://git-scm.com/)
- [Task](https://taskfile.dev)
- [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/)

The TF tasks in the template do not use Python or Copier. This means that they can be run in a restricted environment, such as a continuous integration system.

To see a list of the available tasks in a project, enter _task_ in a terminal window:

```shell
task
```

> The tasks use the namespace `tft`. This means that they do not conflict with any other tasks in the project.

Before you manage resources with TF, first create at least one context:

```shell
TFT_CONTEXT=dev task tft:context:new
```

This creates a new context. Edit the `context.json` file in the directory `tf/contexts/<CONTEXT>/` to set the `environment` name and specify the settings for the [remote state](https://opentofu.org/docs/language/state/remote/) storage that you want to use.

> This tooling currently only supports Amazon S3 for remote state storage.

Next, create a unit:

```shell
TFT_UNIT=my-app task tft:new
```

Use `TFT_CONTEXT` and `TFT_UNIT` to create a deployment of the unit with the configuration from the specified context:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app
task tft:init
task tft:plan
task tft:apply
```

> You will see a warning when you run `init` with a current version of Terraform. This is because Hashicorp are [deprecating the use of DynamoDB with S3 remote state](https://developer.hashicorp.com/terraform/language/backend/s3#state-locking). To support older versions of Terraform, this tooling will continue to use DynamoDB for a period of time.

### Setting the Remote State for a Context

The `context.json` file is the configuration file for the context. It specifies metadata and settings for TF [remote state](https://opentofu.org/docs/language/state/remote/). Here is an example of a `context.json` file:

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

The `backend_s3ddb` section specifies the settings for a TF backend that uses S3 for storage with DynamoDB for locking. The tooling automatically enables encryption for this backend.

### Setting the tfvars for a Context

Each context has one `.tfvars` file for each unit. This `.tfvars` file is automatically loaded when you run a task that unit the with the context. To enable you to have variables for a unit that apply for every context, the directory `tf/contexts/all/` also contains one `.tfvars` file for each unit. The `.tfvars` file for a unit in the `tf/contexts/all/` directory is always used, along with the `.tfvars` for the current context.

### Using Extra Instances

Specify `TFT_EDITION` to deploy an extra instance of a unit:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app TFT_EDITION=feature1
task tft:plan
task tft:apply
```

This create a complete and separate copy of the resources that are defined by the unit. Each instance of a unit has an identical configuration as other instances that use the specified context, apart from the variable `tft_edition`. The tooling automatically sets the value of the tfvar `tft_edition` to match `TFT_EDITION`. This ensures that every instance has a unique identifier that can be used in TF code, and a unique `handle` for resource names.

Only set `TFT_EDITION` when you want to create an extra copy of a unit. If you do not specify a edition identifier, TF uses the _default_ workspace for state, and the value of the tfvar `tft_edition` is `default`.

Once you no longer need the extra instance, run `tft:destroy` to delete the resources, and then run `tft:forget` to delete the TF remote state for the extra instance:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app TFT_EDITION=copy2
task tft:destroy
task tft:forget
```

> This tooling uses [workspaces](https://opentofu.org/docs/language/state/workspaces/) to handle the TF state for extra instances. If you do not specify an edition name, it uses the _default_ workspace.

### Formatting

To check whether _terraform fmt_ needs to be run on the module, use the `tft:check-fmt` task:

```shell
TFT_UNIT=my-app task tft:check-fmt
```

If this check fails, run the `tft:fmt` task to format the module:

```shell
TFT_UNIT=my-app task tft:fmt
```

### Testing

This tooling supports the [validate](https://opentofu.org/docs/cli/commands/validate/) and [test](https://opentofu.org/docs/cli/commands/test/) features of TF. Each unit includes a test configuration, so that you can run immediately run tests on the module as soon as it is created.

Each test run creates and then immediately destroys resources without storing the state. To ensure that temporary test copies of units do not conflict with other copies of the resources, the test setup in the units sets the value of `tft_edition` to a random string with the prefix `tt`. This means that the `handle` becomes a new value for each test run.

To validate a unit before any resources are deployed, use the `tft:validate` task:

```shell
TFT_UNIT=my-app task tft:validate
```

To run tests on a unit, use the `tft:test` task:

```shell
TFT_CONTEXT=dev TFT_UNIT=my-app task tft:test
```

> Unless you set a test to only _plan_, it will create and destroy copies of resources. Check the expected behaviour of the types of resources that you are managing before you run tests, because cloud services may not immediately remove some resources.

### Using Local TF State

By default, this tooling uses Amazon S3 for [remote state storage](https://opentofu.org/docs/language/state/remote/). To initialize a unit with local state storage, use the task `tft:init:local` rather than `tft:init`:

```shell
task tft:init:local
```

To use local state, you will also need to comment out the `backend "s3" {}` block in the `main.tf` file.

> I highly recommend that you only use TF local state for prototyping. Local state means that the resources can only be managed from a computer that has access to the state files.

### Shared Modules

The project structure includes a `tf/shared/` directory to hold TF modules that are shared between the root modules in the same project. By design, the tooling does not manage any of these shared modules, and does not impose any requirements on them.

To share modules between projects, [publish them to a registry](https://opentofu.org/docs/language/modules/#published-modules).

### Using OpenTofu

By default, this tooling uses the copy of Terraform that is found on your `PATH`. Set `TFT_CLI_EXE` as an environment variable to specify the path to the tool that you wish to use. For example, to use [OpenTofu](https://opentofu.org/), set `TFT_CLI_EXE` with the value `tofu`:

```shell
TFT_CLI_EXE=tofu
```

To specify which version of OpenTofu to use, create a `.opentofu-version` file. This file should contain the version of OpenTofu and nothing else, like this:

```shell
1.10.2
```

> Remember that if you switch between Terraform and OpenTofu, you will need to initialise your unit again, and when you run `apply` it will migrate the TF state. The OpenTofu Website provides [migration guides](https://opentofu.org/docs/intro/migration/), which includes information about code changes that you may need to make.

### Updating TF Tasks

To update a project with the latest version of the template, we use the [update feature of Copier](https://copier.readthedocs.io/en/stable/updating/). We can use either [pipx](https://pipx.pypa.io/) or [uv](https://docs.astral.sh/uv/) to run Copier:

```shell
cd my-project
pipx run copier update -A -a .copier-answers-tf-task.yaml .
```

```shell
cd my-project
uvx copier update -A -a .copier-answers-tf-task.yaml .
```

Copier `update` synchronizes the files in the project that the template manages with the latest release of the template.

> Copier only changes the files and directories that are managed by the template.

## What About Dependencies Between Components?

This tooling does not specify or enforce any dependencies between infrastructure components. You are free to run operations on separate components in parallel whenever you believe that this is safe. If you need to execute changes in a particular order, specify that order in whichever system you use to carry out deployments.

Similarly, there are no restrictions on how you run tasks on multiple units. You can use any method that can call Task several times with the required variables. For example, you can create your own Taskfiles that call the supplied tasks, write a script, or define jobs for your CI system.

> This tooling does not explicitly support or conflict with the [stacks feature of Terraform](https://developer.hashicorp.com/terraform/language/stacks). I do not currently test with the stacks feature. This feature is specific to HCP, and not available in OpenTofu.

## Going Further

This tooling was built for my personal use. I am happy to consider feedback and suggestions, but I may decline to implement anything that makes it less useful for my needs. You are welcome to use this work as a basis for your own wrappers.

For more details about how to work with Task and develop your own tasks, see [my article](https://www.stuartellis.name/articles/task-runner/).
