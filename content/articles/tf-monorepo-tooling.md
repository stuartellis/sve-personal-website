+++
title = "Low-Maintenance Tooling for Terraform & OpenTofu in Monorepos"
slug = "tf-monorepo-tooling"
date = "2025-06-25T06:29:00+01:00"
description = "Tooling for Terraform and OpenTofu in monorepos"
categories = ["automation", "aws", "devops", "opentofu", "terraform"]
tags = ["automation", "aws", "devops", "opentofu", "terraform"]
+++

This article describes an example of an approach to low-maintenance tooling for using [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/) in a [monorepo](https://en.wikipedia.org/wiki/Monorepo). This enables infrastructure definitions to be maintained in the same project, alongside other code. The design also enables projects to support:

- Multiple infrastructure components in the same code repository. Each [unit](#units) is a complete [root module](https://opentofu.org/docs/language/modules/).
- Multiple instances of the same component with [different configurations](#contexts)
- [Extra instances](#extra-instances) of a component for development and testing. Use this to create disposable instances for the branches of your code as you need them.
- [Integration testing](#testing) for every component.
- [Migrating from Terraform to OpenTofu](#using-opentofu). You use the same tasks for both.

The basic approach is simply to create a wrapper for Terraform and OpenTofu. This means that a tool that generates commands and sends them to the Terraform or OpenTofu executable for you. This is a common idea, and wrappers have been written with a variety of technologies and programming languages. Since Terraform and OpenTofu are extremely flexible, each wrapper implements specific design choices.

In this example, the tooling is designed for monorepos. This means that each project repository can contain the code for both the infrastructure and the applications. The infrastructure is defined as one or more named components. Each infrastructure component can be deployed to multiple environments. To ensure that we can continue to maintain these copies of the infrastructure over time, the tooling is designed to ensure that we can use it alongside other tools, and that we can stop using it at any time.

To achieve these goals, the tooling follows three specific rules:

1. Each [component](#units) is a root module
2. The tooling only requires that each root module implements a small number of [specific tfvars](#units).
3. The tooling does not impose any limitations on the code within the modules

The wrapper itself is a single [Task](https://taskfile.dev) file that you add to your own projects. It does not include code in a programming language like Python or Go. These decisions mean that the wrapper will run on any UNIX-based system, including CI/CD environments. It is also not tied to particular versions of [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/).

This tooling is built to be distributed as a [Copier](https://copier.readthedocs.io/en/stable/) template. Copier enables us to create new projects that include the tooling, add the tooling to any existing project, and synchronize the copies of the tooling in our projects with newer versions as needed. Copier uses Git and tracks releases by tags, so a Copier template can be made available through any code hosting service.

The code for this example tooling is available on GitHub:

- [https://github.com/stuartellis/tf-tasks](https://github.com/stuartellis/tf-tasks)

> This article uses the identifier _TF_ or _tf_ for Terraform and OpenTofu. Both tools accept the same commands and have the same behavior. The tooling itself is just called `tft` (_TF Tasks_).

## Requirements

The tooling uses several command-line tools. We can install all of these tools on Linux or macOS with [Homebrew](https://brew.sh/):

- [Git](https://git-scm.com/) - `brew install git`
- [Task](https://taskfile.dev) - `brew install go-task`
- [pipx](https://pipx.pypa.io/) OR [uv](https://docs.astral.sh/uv/) - `brew install pipx` OR `brew install uv`

> Set up [shell completions](https://taskfile.dev/installation/#setup-completions) for Task after you install it. Task supports bash, zsh, fish and PowerShell.

Use a Python helper to run [Copier](https://copier.readthedocs.io/en/stable/) without installing it. We can use either [pipx](https://pipx.pypa.io/) or [uv](https://docs.astral.sh/uv/) to do this:

```shell
pipx run copier copy git+https://github.com/stuartellis/tf-tasks my-project
```

```shell
uvx copier copy git+https://github.com/stuartellis/tf-tasks my-project
```

You can install Terraform or OpenTofu with any method. If you do not have a preference, I recommend that you use [tenv](https://tofuutils.github.io/tenv/). The `tenv` tool automatically installs and uses the required version of Terraform or OpenTofu for the project. If _cosign_ is present, _tenv_ uses it to carry out signature verification on OpenTofu binaries.

```shell
# Install tenv with cosign
brew install tenv cosign
```

Python and Copier are only needed on systems that create and update projects. The tasks only need a UNIX shell, Git, Task and Terraform or OpenTofu. They do not use Python or Copier. This means that tasks can be run in a restricted environment, such as a continuous integration runner or an Alpine Linux container. Again, we can [add tenv to any environment](https://tofuutils.github.io/tenv/#installation) and then use it to install the versions of Terraform or OpenTofu that we need.

## Quick Examples

To start a new project:

```shell
# Run Copier with uv to create a new project
uvx copier copy git+https://github.com/stuartellis/tf-tasks my-project

# Go to the working directory for the project
cd my-project

# Create a context and a root module for the project
TFT_CONTEXT=dev task tft:context:new
TFT_UNIT=my-app task tft:new
```

The `tft:new` task creates a [unit](#units), a complete Terraform root module. Each new root module includes example code for AWS, so that it can work immediately. You only need to set:

- A name for the `environment` in the [context](#contexts)
- Either remote state storage settings in the [context](#contexts), OR use [local state](#using-local-tf-state)
- The AWS IAM role for TF in the module, with the tfvar `tf_exec_role_arn`

You can then start working with your TF module:

```shell
# Set a default context and unit
export TFT_CONTEXT=dev TFT_UNIT=my-app

# Run tasks on the unit with the configuration from the context
task tft:init
task tft:plan
task tft:apply
```

You can specifically set the unit and context for one task. This example runs the [integration tests](#testing) for the module:

```shell
TFT_CONTEXT=dev TFT_UNIT=my-app task tft:test
```

To create [an extra copy](#extra-instances) of the resources for a module, set the variable `TFT_EDITION` with a unique name for the copy. This example will deploy an extra instance called `copy2` alongside the main set of resources:

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

To see a list of all of the available tasks in a project, enter _task_ in a terminal window:

```shell
task
```

If you have set up autocompletion for Task, you will see you suggestions as you type.

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
|- Taskfile.yaml
```

The Copier template:

- Adds a `.gitignore` file and a `Taskfile.yaml` file to the root directory of the project, if these do not already exist.
- Provides a `.terraform-version` file.
- Provides the file `tasks/tft/Taskfile.yaml` to the project. This file contains the task definitions.
- Provides a `tf/` directory structure for TF files and configuration.

The tasks:

- Generate a `tmp/tf/` directory for artifacts.
- Only change the contents of the `tf/` and `tmp/tf/` directories.
- Copy the contents of the `template/` directories to new units and contexts. These provide consistent structures for each component.

### Units

You define each set of infrastructure code as a component. Every infrastructure component is a separate TF root [module](https://opentofu.org/docs/language/modules/). This means that each component can be created, tested, updated or destroyed independently of the others. This tooling refers to these components as _units_.

To create a new unit, use the `tft:new` task:

```shell
TFT_UNIT=my-app task tft:new
```

Each unit is created as a subdirectory in the directory `tf/units/`.

For convenience, the tooling creates each new unit as a copy of the files in `tf/units/template/`. The template directory provides a working TF module for AWS resources with the required tfvars. This means that each new unit has a complete set of code and is immediately ready to use. You can completely remove the AWS resources from a new unit if you are not using AWS.

> When a unit does not use AWS, ensure that you change the supplied tests to use resources that are relevant for the cloud provider.

You can actually create the units any way that you wish, and there are no limitations on the TF code in them. The tooling automatically finds all of the modules in the directory `tf/units/`. It only requires that each module is a valid TF root module and accepts the four tfvars that are listed below.

> Since each unit is a separate module, you can have different versions of the same providers in separate units.

The tooling only requires that each unit is a valid TF root module that accepts these tfvars:

- `product_name` (string)
- `environment_name` (string)
- `unit_name` (string)
- `edition` (string)

There are no limitations on how your code uses these tfvars. You might only use them to [set resource names](#managing-resource-names).

The tooling sets the values of the required tfvars when it runs TF commands on a unit:

- `product_name` - Defaults to the name of the project, but you can [override this](#settings-for-features)
- `environment_name` - Provided by the current [context](#contexts)
- `unit_name` - The name of the unit itself
- `edition` - Set as the value `default`, except when using an [extra instance](#extra-instances) or running [tests](#testing)

To avoid compatibility issues, we should use names that only include lowercase letters, numbers and hyphen characters, with the first character being a lowercase letter. To avoid limits on the length of resource names, unit names should be no longer than about 12 characters. For usability, we should avoid environment and edition names that are longer than 7 characters.

### Contexts

Contexts enable you to define named configurations for TF. You can then use these to deploy multiple instances of the same unit with different configurations, instead of needing to maintain separate sets of code for different instances. For example, if you have separate AWS accounts for development and production then you can define these as separate contexts.

To create a new context, use the `tft:context:new` task:

```shell
TFT_CONTEXT=dev task tft:context:new
```

Each context is a subdirectory in the directory `tf/contexts/` that contains a `context.json` file and one `.tfvars` file per unit.

The `context.json` file is the configuration file for the context. It specifies metadata and settings for TF [remote state](https://opentofu.org/docs/language/state/remote/). Each `context.json` file specifies two items of metadata:

- `environment`
- `description`

The `environment` is a string that is automatically provided to TF as the tfvar `environment_name`. The `description` is deliberately not used by the tooling, so that you can leave it empty, or do whatever you wish with it.

Here is an example of a `context.json` file:

```json
{
  "metadata": {
    "description": "Cloud development environment",
    "environment": "dev"
  },
  "backend_s3": {
    "tfstate_bucket": "789000123456-tf-state-dev-eu-west-2",
    "tfstate_ddb_table": "789000123456-tf-lock-dev-eu-west-2",
    "tfstate_dir": "dev",
    "region": "eu-west-2",
    "role_arn": "arn:aws:iam::789000123456:role/my-tf-state-role"
  }
}
```

To enable you to have tfvars for a unit that apply for every context, the directory `tf/contexts/all/` contains one `.tfvars` file for each unit. The `.tfvars` file for a unit in the `tf/contexts/all/` directory is always used, along with `.tfvars` for the current context.

The tooling creates each new context as a copy of files in `tf/contexts/template/`. It copies the `standard.tfvars` file to create the tfvars files for new units. You can actually create and edit the contexts with any method. The tooling will automatically find all of the contexts in the directory `tf/contexts/`.

To avoid compatibility issues between systems, we should use context and environment names that only include lowercase letters, numbers and hyphen characters, with the first character being a lowercase letter. For usability, we should avoid environment and edition names that are longer than 7 characters.

> Contexts exist to provide configurations for TF. To avoid coupling live resources directly to contexts, the tooling does not pass the name of the active context to the TF code, only the `environment` name that the context specifies.

### Extra Instances

TF has two different ways to create extra copies of the same infrastructure from a root module: the [test](https://opentofu.org/docs/cli/commands/test/) feature and [workspaces](https://opentofu.org/docs/language/state/workspaces/).

The _test_ feature creates new resources and destroys them at the end of each test run. The state information about these temporary resources is only held in the memory of the system, and is not stored elsewhere. No existing state data is updated by a test.

If you specify a _workspace_ then TF makes an extra set of state for the root module. You can use this workspace to create and update another copy of the resources for as long as you need it, alongside the main copy. We can have many workspaces for the same root module at the same time. This enables us to deploy separate copies of infrastructure for development and testing, with different copies from different branches of a project.

> The workspace for the main set of state for a root module is always called `default`.

Since TF could attempt to create multiple copies of resources with the same name, this tooling allows every copy of a set of infrastructure to have a unique identifier, regardless of how the copy was created. This identifier is called the _edition_. Every unit has a tfvar called `edition` to use this identifier. The `edition` is set to the value _default_, unless you [run a test](#testing) or decide to [create extra instances](#using-extra-instances).

To avoid conflicts between copies, include this `edition` identifier in the names that you define for resources. The template TF code provides locals that you can use to create unique resource names, but you will also need to define your own locals that meet the needs of your project. The [next section](#managing-resource-names) has more details about resource names.

If you do not specify a workspace, changes affect the main copy of the resources, because TF uses the `default` workspace. Whenever you want to use another workspace, set the variable `TFT_EDITION`. The tooling then sets the active workspace to match the variable `TFT_EDITION` and sets the tfvar `edition` to the same value. If a workspace with that name does not already exist, it will automatically be created. To remove a workspace, first run the `destroy` task to terminate the copy of the resources that it manages, and then run the `forget` task to delete the stored state.

You can set the variable `TFT_EDITION` to any string. For example, you can configure your CI system to set the variable `TFT_EDITION` with values that are based on branch names.

Tests never use workspaces, because every test run uses its own state. For tests, we need to use a pattern for `edition` that lets us identify all of the test copies of infrastructure, but has a unique value for every test run. The example test in the unit template includes code to set the value of `edition` to a random string with the prefix `tt`. You may decide to use a different format in the `edition` identifier for your tests.

### Managing Resource Names

Use the `product_name`, `environment_name`, `unit_name` and `edition` tfvars in your TF code to define resource names that are both meaningful to humans and unique for each instance of the resource. This avoids conflicts between copies of infrastructure.

Every type of cloud resource may have a different set of rules about acceptable names. For the best compatibility across systems, use values that only include lowercase letters, numbers and hyphen characters, with the first character being a lowercase letter. To avoid limits on the total length of resource names, try to limit the size of the identifiers that you use:

- `product_name` - 12 characters or less
- `unit_name` - 12 characters or less
- `environment_name` - 7 characters or less
- `edition` - 7 characters or less

For convenience, the code in the unit template includes locals and outputs to help with this:

- `tft_handle` - Normalizes the `unit_name` to the first 12 characters, in lowercase
- `tft_standard_prefix` - Combines `environment`, `edition` and `tft_handle`, separated by hyphens

> The test in the unit template includes code to set the value of the tfvar `edition` to a random string with the prefix `tt`. If you use the `edition` in resource names, this ensures that test copies of resources do not conflict with existing resources that were deployed with the same TF module.

### Shared Modules

The project structure includes a `tf/shared/` directory to hold TF modules that are shared between the root modules in the same project. By design, the tooling does not manage any of these shared modules, and does not impose any requirements on them.

To share modules between projects, [publish them to a registry](https://opentofu.org/docs/language/modules/#published-modules).

### Dependencies Between Units

By design, this tooling does not specify or enforce any dependencies between infrastructure components. You are free to run operations on separate components in parallel whenever you believe that this is safe. If you need to execute changes in a particular order, specify that order in whichever system you use to carry out deployments.

Similarly, you can run tasks on multiple units by using any method that can call Task several times with the required variables. For example, you can create your own Taskfiles that call the supplied tasks, write a script, or define jobs for your CI system.

> This tooling does not explicitly support or conflict with the [stacks feature of Terraform](https://developer.hashicorp.com/terraform/language/stacks). I do not currently test with the stacks feature. It is unclear when this feature will be finalised, or if an equivalent will be implemented by OpenTofu.

### Working with TF Versions

By default, this tooling uses the copy of Terraform or OpenTofu that is provided by the system. It does not install or manage copies of Terraform and OpenTofu. It is also not dependent on specific versions of these tools.

You will need to use different versions of Terraform and OpenTofu for different projects. To handle this, use a tool version manager. The version manager will install the versions that you need and automatically switch between them as needed. Consider using [tenv](https://tofuutils.github.io/tenv/), which is a version manager that is specifically designed for TF tools. Alternatively, you could decide to manage your project with [mise](https://mise.jdx.dev/), which handles all of the tools that the project needs.

The generated projects include a `.terraform-version` file so that your tool version manager installs and use the Terraform version that you specify. To use OpenTofu, add an `.opentofu-version` file to enable your tool version manager to install and use the OpenTofu version that you specify.

> This tooling can [switch between Terraform and OpenTofu](#using-opentofu). This is specifically to help you migrate projects from one of these tools to the other.

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

### Settings for Features

Set these variables to override the defaults:

- `TFT_PRODUCT_NAME` - The name of the project
- `TFT_CLI_EXE` - The Terraform or OpenTofu executable to use
- `TFT_REMOTE_BACKEND` - Set to _false_ to force the use of local TF state
- `TFT_EDITION` - See the section on [extra instances](#extra-instances)

### The `tft` Tasks

| Name          | Description                                                                                |
| ------------- | ------------------------------------------------------------------------------------------ |
| tft:apply     | _terraform apply_ for a unit\*                                                             |
| tft:check-fmt | Checks whether _terraform fmt_ would change the code for a unit                            |
| tft:clean     | Remove the generated files for a unit                                                      |
| tft:console   | _terraform console_ for a unit\*                                                           |
| tft:context   | An alias for `tft:context:list`.                                                           |
| tft:destroy   | _terraform apply -destroy_ for a unit\*                                                    |
| tft:fmt       | _terraform fmt_ for a unit                                                                 |
| tft:forget    | _terraform workspace delete_\*                                                             |
| tft:init      | _terraform init_ for a unit. An alias for `tft:init:s3`.                                   |
| tft:new       | Add the source code for a new unit. Copies content from the _tf/units/template/_ directory |
| tft:plan      | _terraform plan_ for a unit\*                                                              |
| tft:rm        | Delete the source code for a unit                                                          |
| tft:test      | _terraform test_ for a unit\*                                                              |
| tft:units     | List the units.                                                                            |
| tft:validate  | _terraform validate_ for a unit\*                                                          |

\*: These tasks require that you first [initialise](https://opentofu.org/docs/cli/commands/init/) the unit.

### The `tft:context` Tasks

| Name             | Description                                                                  |
| ---------------- | ---------------------------------------------------------------------------- |
| tft:context      | An alias for `tft:context:list`.                                             |
| tft:context:list | List the contexts                                                            |
| tft:context:new  | Add a new context. Copies content from the _tf/contexts/template/_ directory |
| tft:context:rm   | Delete the directory for a context                                           |

### The `tft:init` Tasks

| Name           | Description                                               |
| -------------- | --------------------------------------------------------- |
| tft:init       | _terraform init_ for a unit. An alias for `tft:init:s3`.  |
| tft:init:local | _terraform init_ for a unit, with local state.            |
| tft:init:s3    | _terraform init_ for a unit, with Amazon S3 remote state. |

### Using Extra Instances

Specify `TFT_EDITION` to create an [extra instance](#extra-instances) of a unit:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app TFT_EDITION=feature1
task tft:plan
task tft:apply
```

Each instance of a unit has an identical configuration as other instances that use the specified context, apart from the tfvar `edition`. The tooling automatically sets the value of the tfvar `edition` to match `TFT_EDITION`. This ensures that every edition has a unique identifier that can be used in TF code.

Only set `TFT_EDITION` when you want to create an extra copy of a unit. If you do not specify a edition identifier, TF uses the default workspace for state, and the value of the tfvar `edition` is `default`.

Once you no longer need the extra instance, run `tft:destroy` to delete the resources, and then run `tft:forget` to delete the TF remote state for the extra instance:

```shell
export TFT_CONTEXT=dev TFT_UNIT=my-app TFT_EDITION=copy2
task tft:destroy
task tft:forget
```

### Testing

This tooling supports the [validate](https://opentofu.org/docs/cli/commands/validate/) and [test](https://opentofu.org/docs/cli/commands/test/) features of TF. Each unit includes a test configuration, so that you can run immediately run tests on the module as soon as it is created.

A test creates and then immediately destroys resources without storing the state. To ensure that temporary test copies of units do not conflict with other copies of the resources, the test in the unit template includes code to set the value of `edition` to a random string with the prefix `tt`.

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

### Using OpenTofu

By default, this tooling uses the copy of Terraform that is found on your `PATH`. Set `TFT_CLI_EXE` as an environment variable to specify the path to the tool that you wish to use. For example, to use [OpenTofu](https://opentofu.org/), set `TFT_CLI_EXE` with the value `tofu`:

```shell
TFT_CLI_EXE=tofu
```

To specify which version of OpenTofu to use, create a `.opentofu-version` file. This file should contain the version of OpenTofu and nothing else, like this:

```shell
1.9.1
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

## Going Further

This tooling was built for my personal use. I am happy to consider feedback and suggestions, but I may decline to implement anything that makes it less useful for my needs. You are welcome to use this work as a basis for your own wrappers.

For more details about how to work with Task and develop your own tasks, see [my article](https://www.stuartellis.name/articles/task-runner/).
