+++
title = "Tooling for Terraform & OpenTofu in Monorepos"
slug = "tf-monorepo-tooling"
date = "2025-09-07T17:30:00+01:00"
description = "Tooling for Terraform and OpenTofu in monorepos"
categories = ["automation", "aws", "devops", "opentofu", "terraform"]
tags = ["automation", "aws", "devops", "opentofu", "terraform"]
+++

This article describes an example of tooling for [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/) using a [general-purpose task runner utility](https://www.stuartellis.name/articles/task-runner/). The tooling supports these features without any other third-party software:

- [Monorepo](https://en.wikipedia.org/wiki/Monorepo) projects that contain the code for infrastructure and applications.
- Multiple infrastructure components in the same code repository. Each of these _units_ is a complete [root module](https://opentofu.org/docs/language/modules/).
- Multiple instances of the same infrastructure component with different configurations. The TF configurations are called [contexts](#creating-a-context).
- [Deploying extra instances of a component](#using-extra-instances) with the same set of configuration. Use this to deploy instances from version control branches for development, or to create temporary instances.
- [Integration testing](#testing) for every component.
- [Migrating from Terraform to OpenTofu](#migrating-to-opentofu). You use the same commands for both.

> If we separate out our infrastructure code into components then we avoid create a [terralith](https://masterpoint.io/blog/terralith-monolithic-terraform-architecture/), where all of the TF code for all of the resources is in a single root module. Monolithic root modules complicate development and testing, and they grow slower and more brittle over time as resources are added to them.

The code for this example tooling is available on GitHub:

- [https://github.com/stuartellis/tf-tasks](https://github.com/stuartellis/tf-tasks)

For more details about how this tooling works and the design decisions, read my [article on designing a wrapper for TF](https://www.stuartellis.name/articles/tf-wrapper-design/).

> This article uses the identifier _TF_ or _tf_ for Terraform and OpenTofu. Both tools accept the same commands and have the same behavior. The tooling itself is just called `tft` (_TF Tasks_).

## Quick Examples

First, install the tools on Linux or macOS with [Homebrew](https://brew.sh/):

```shell
brew install git pipx go-task cosign tenv
```

Start a new project:

```shell
# Use pipx to fetch Copier and run it to create a new project
# Enter your details when prompted
pipx run copier copy git+https://github.com/stuartellis/tf-tasks my-project

# Go to the working directory for the project
cd my-project

# Ask tenv to detect and install the correct version of Terraform for the project
tenv terraform install

# Create a configuration and a root module for the project
TFT_CONTEXT=dev task tft:context:new
TFT_UNIT=my-app task tft:new
```

The `tft:new` task creates a _unit_, a complete Terraform root module. Each new root module includes example code for AWS, so that it can work immediately. The context is a configuration profile. You only need to set:

1. Either the [remote state storage](#setting-the-remote-state-for-a-context), OR use [local state](#using-local-tf-state)
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

Code included in each TF module provides unique identifiers for instances, so that you can have multiple copies of the resources at the same time. The only requirement is that you include the `edition_id` for the instance as part of each resource name:

```hcl
resource "aws_dynamodb_table" "example_table" {
  name = "${local.meta_product_name}-${local.meta_component_name}-example-${local.edition_id}"
```

To create an extra copy of the resources for a module, set the variable `TFT_EDITION` with a unique name for the copy. This example will deploy an extra instance called `copy2` alongside the main set of resources:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app

# Create a disposable copy of my-app called "copy2"
TFT_EDITION=copy2 task tft:plan
TFT_EDITION=copy2 task tft:apply

# Destroy the extra copy of my-app
TFT_EDITION=copy2 task tft:destroy

# Clean-up: Delete the remote TF state for the extra copy of my-app
TFT_EDITION=copy2 task tft:forget
```

These extra instances automatically have their own unique `edition_id`, which is a shortened SHA256 hash. They also each have their own TF state, using [workspaces](https://opentofu.org/docs/language/state/workspaces/). Use this feature to create disposable instances for the branches of your code as you need them, or to deploy temporary instances for any other purpose.

The ability to have multiple copies of resources for the same module without conflicts also enables us to run [integration tests](#testing) at any time. This example runs tests for the module:

```shell
TFT_CONTEXT=dev TFT_UNIT=my-app task tft:test
```

The integration tests can create and then destroy unique copies of the resources for every test run.

To pass extra options to Terraform or OpenTofu, add `--` to the end of the command, followed by the options:

```shell
task tft:init -- -upgrade
```

All of the commands are available through [Task](https://www.stuartellis.name/articles/task-runner/). To see a list of the available tasks in a project, enter _task_ in a terminal window:

```shell
task
```

If you set up [shell completions](https://taskfile.dev/installation/#setup-completions) for Task, you will see you suggestions as you type.

## How It Works

This tooling is built as a [Copier](https://copier.readthedocs.io/en/stable/) template. Copier enables us to create new projects from the template, add the tooling to any existing project, and synchronize the copies of the tooling in our projects with newer versions as needed.

The core is a single [Task](https://www.stuartellis.name/articles/task-runner/) file that Copier adds to projects. Task is a command-line tool that generates and runs _tasks_, shell commands that are defined in a Taskfile. Each Taskfile is a YAML document that defines templates for the commands. Task uses a versioned and published schema so that we can [validate Taskfiles](https://www.stuartellis.name/articles/task-runner/#checking-taskfiles). By design, we can replace Task with any other script or tool that generates the same commands.

The tooling does not use or rely on the [stacks feature of HCP Terraform](https://developer.hashicorp.com/terraform/language/stacks). Since the _units_ are standard modules, they can be used with stacks or [any other orchestration](#what-about-dependencies-between-components) that you wish.

## Setting Up a Project

To create a new project, run Copier. I recommend that you use either [pipx](https://pipx.pypa.io/) or [uv](https://docs.astral.sh/uv/) to run Copier, because they will automatically fetch and use Copier without needing to install it. These commands both create a new project:

```shell
pipx run copier copy git+https://github.com/stuartellis/tf-tasks my-project
```

```shell
uvx copier copy git+https://github.com/stuartellis/tf-tasks my-project
```

Enter your details when prompted. These values are written into the generated files for the project.

To add the tooling to an existing project, change the working directory to your project and then run `copier copy`:

```shell
cd my-project
uvx copier copy git+https://github.com/stuartellis/tf-tasks .
```

Copier only creates or updates the files and directories that are managed by the template. The template is configured to avoid updating these files if they already exist: `.gitignore`, `README.md` and `Taskfile.yaml`.

## Using the Tasks

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

### Creating a Context

Contexts provide configurations for TF. Before you manage resources with TF, first create at least one context:

```shell
TFT_CONTEXT=dev task tft:context:new
```

Edit the `context.json` file in the directory `tf/contexts/<CONTEXT>/` to set the `environment` name and specify the settings for the [remote state](https://opentofu.org/docs/language/state/remote/) storage that you want to use.

> This tooling currently only supports Amazon S3 for remote state storage.

### Setting the Remote State for a Context

The `context.json` file is the configuration file for the context. It specifies metadata and settings for TF [remote state](https://opentofu.org/docs/language/state/remote/). Here is an example of a `context.json` file:

```json
{
  "metadata": {
    "description": "Cloud development environment",
    "environment": "dev"
  },
  "backends": {
    "s3": {
      "tfstate_bucket": "789000123456-tf-state-dev-eu-west-2",
      "tfstate_dir": "dev",
      "region": "eu-west-2",
      "role_arn": "arn:aws:iam::789000123456:role/my-tf-state-role"
    },
    "s3ddb": {
      "tfstate_bucket": "",
      "tfstate_ddb_table": "",
      "tfstate_dir": "",
      "region": "",
      "role_arn": ""
    }
  }
}
```

The `backends.s3` section specifies the settings for a TF backend that uses S3 for storage. This uses the [S3 native locking feature](https://opentofu.org/docs/language/settings/backends/s3/) in current versions of Terraform and OpenTofu. It does not use DynamoDB. The tooling will use this backend by default.

The `backends.s3ddb` section specifies the settings for a legacy TF backend that uses S3 for storage and DynamoDB for locking. Only use this type of backend if you need to use an older version of Terraform or OpenTofu.

> The tooling automatically enables encryption for both types of S3 backend.

### Setting the tfvars for a Context

Each context has one `.tfvars` file for each unit. This `.tfvars` file is automatically loaded when you run a task with that context for the unit.

To enable you to have variables for a unit that apply for every context, the directory `tf/contexts/all/` also contains one `.tfvars` file for each unit. The `.tfvars` file for a unit in the `tf/contexts/all/` directory is always used, along with the `.tfvars` for the current context.

### Creating a Root Module (Unit)

To create a unit from the template, use `new`:

```shell
TFT_UNIT=my-new-app task tft:new
```

To create a unit as a copy of an existing unit, use `copy`. Specify the existing unit with `TFT_SOURCE_UNIT` and the name of the new unit with `TFT_UNIT`, like this:

```shell
TFT_SOURCE_UNIT=my-first-app TFT_UNIT=my-new-app task tft:copy
```

Use `TFT_CONTEXT` and `TFT_UNIT` to create a deployment of the unit with the configuration from the specified context:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-new-app
task tft:init
task tft:plan
task tft:apply
```

### Customising the Module Code

This tooling creates each new unit as a copy of the files in `tf/units/template/`. If the provided code is not appropriate, you can customise the contents of a module in any way that you need. The provided code is for AWS, but you can replace this code and use this tooling for any cloud service.

The tooling only requires that a module is a valid TF root module in the directory `tf/units/` and accepts these input variables:

- `tft_product_name` (string) - The name of the product or project
- `tft_environment_name` (string) - The name of the environment
- `tft_unit_name` (string) - The name of the component
- `tft_edition_name` (string) - An identifier for the specific instance of the resources

These variables are only used to set locals in the file `meta_locals.tf`. Use the `edition_id` and the other locals in `meta_locals.tf` to define resource names, and create your own locals in another file for any other identifiers that the resources need.

You can change or completely replace the provided test code. For example, you might change the format of the random edition name identifier that the test setup generates.

> If you do not use the instance `edition_id` or an equivalent hash in the name of a resource, you must decide how to ensure that each copy of the resource will have a unique name.

### Using Extra Instances

Specify `TFT_EDITION` to deploy an extra instance of a unit:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app TFT_EDITION=feature1
task tft:plan
task tft:apply
```

This creates a complete and separate copy of the resources that are defined by the unit and the context. The tooling automatically sets the value of the tfvar `tft_edition_name` to match `TFT_EDITION`. The unique edition name means that the locals `meta_edition_name` and `edition_id` are also unique.

Once you no longer need the extra instance, run `tft:destroy` to delete the resources, and then run `tft:forget` to delete the TF remote state for the extra instance:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app TFT_EDITION=feature1
task tft:destroy
task tft:forget
```

> Only set `TFT_EDITION` when you want to create an extra copy of a unit. If you do not specify an edition identifier, the tooling uses the _default_ [workspace](https://opentofu.org/docs/language/state/workspaces/) to store the state, and the value of the tfvar `tft_edition_name` will be `default`.

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

Each test specifies either `plan` or `apply`. Every run of an `apply` test will create and then destroy resources without storing the state. To ensure that these temporary copies do not conflict with other copies of the resources, the test setup in the units sets the value of `tft_edition_name` to a random string with the prefix `tt`. This means that the `edition_id` becomes a new value for each test run.

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

## Updating TF Tasks

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

## How Input Variables Are Set

The tooling sets the values of the required variables when it runs TF commands on a unit:

- `tft_product_name` - Defaults to the name of the project. Set the environment variable `TFT_PRODUCT_NAME` to override this.
- `tft_environment_name` - The `environment` of the current context
- `tft_unit_name` - Automatically set as name of the unit itself
- `tft_edition_name` - Automatically set as the value `default`, except when using an [extra instance](#using-extra-instances) or running [tests](#testing)

These variables are only used to set locals in the file `meta_locals.tf`. Always use these locals in your TF code, rather than the `tft` variables. This ensures that deployed resources are not directly tied to the tooling.

## Shared Modules

The project structure includes a `tf/shared/` directory to hold TF modules that are shared between the root modules in the same project.

This directory only exists to provide a simple way to share code between root modules. By design, the tooling does not manage any of the shared modules in this directory, and does not impose any requirements on them.

To share modules between projects, [publish them to a registry](https://opentofu.org/docs/language/modules/#published-modules).

## What About Dependencies Between Components?

This tooling does not specify or enforce any dependencies between infrastructure components. You are free to run operations on separate components in parallel whenever you believe that this is safe. If you need to execute changes in a particular order, specify that order in whichever system you use to carry out deployments.

Similarly, there are no restrictions on how you run tasks on multiple units. You can use any method that can call Task several times with the required variables. For example, you can create your own Taskfiles that call the supplied tasks, write a script, or define jobs for your CI system.

> This tooling does not explicitly support or conflict with the [stacks feature of Terraform](https://developer.hashicorp.com/terraform/language/stacks). I do not currently test with the stacks feature. This feature is specific to HCP, and not available in OpenTofu.

## Suggestions About Names

Cloud systems use tags or labels to enable you to categorise and manage resources. However, we do have to give names to the groups of resources, as well as setting identifiers for individual resources.

Every type of cloud resource may have a different set of rules about acceptable names. To avoid compatibility issues between systems, we should use names that only include lowercase letters, numbers and hyphen characters, with the first character being a lowercase letter.

The length of names can also become an issue when a resource name includes several names for groups or other things. Here are some suggestions about the lengths of names:

- _Product or project names:_ - 12 characters or less
- _Component names:_ - 12 characters or less
- _Environment names:_ - 8 characters or less
- _Instance (edition) names:_ - 8 characters or less

This tooling provides an `edition_id` hash that is based on these groups, so that every instance of a set of resources has a unique identifier. You can place the `edition_id` anywhere in a resource name.

## Migrating to OpenTofu

By default, this tooling currently uses Terraform. Set `TFT_CLI_EXE` as an environment variable to specify the path to the tool that you wish to use. To use [OpenTofu](https://opentofu.org/), set `TFT_CLI_EXE` with the value `tofu`:

```shell
export TFT_CLI_EXE=tofu

TFT_CONTEXT=dev TFT_UNIT=my-app tft:init
```

To specify which version of OpenTofu to use, create a `.opentofu-version` file. This file should contain the version of OpenTofu and nothing else, like this:

```shell
1.10.3
```

The `tenv` tool reads this file when installing or running OpenTofu.

> Remember that if you switch between Terraform and OpenTofu, you will need to initialise your unit again, and when you run `apply` it will migrate the TF state. The OpenTofu Website provides [migration guides](https://opentofu.org/docs/intro/migration/), which includes information about code changes that you may need to make.

## Going Further

This tooling was built for my personal use. I am happy to consider feedback and suggestions, but I may decline to implement anything that makes it less useful for my needs. You are welcome to use this work as a basis for your own wrappers.

> For more details about how to develop your own tasks, see [my article on Task](https://www.stuartellis.name/articles/task-runner/).

The ideas in this wrapper can be implemented in any task runner or programming language. For more details about these ideas and the design decisions that I made for this implementation, read my [article on designing a wrapper for TF](https://www.stuartellis.name/articles/tf-wrapper-design/).
