+++
title = "Low-Maintenance Tooling for Terraform & OpenTofu in Monorepos"
slug = "tf-monorepo-tooling"
date = "2025-05-11T12:21:00+01:00"
description = "Tooling for Terraform and OpenTofu in monorepos"
categories = ["automation", "aws", "devops", "opentofu", "terraform"]
tags = ["automation", "aws", "devops", "opentofu", "terraform"]
+++

This article describes an opinionated approach to low-maintenance [tooling for using Terraform and OpenTofu in a monorepo](https://github.com/stuartellis/tf-tasks). The main tooling is a single [Task](https://taskfile.dev) file that generates and runs commands that you add to your own projects. This specifically does not include code in a programming language like Python or Go, and is not tied to particular versions of [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/). These features mean that it runs on any UNIX-based system, including CI/CD environments, has few dependencies and does not require regular updates. It uses [Copier](https://copier.readthedocs.io/en/stable/) to synchronize projects with newer [versions](https://github.com/stuartellis/tf-tasks/releases) as needed.

> This article uses the identifier _TF_ or _tf_ for Terraform and OpenTofu. Both tools accept the same commands and have the same behavior. The tooling itself is just called `tft` in the documentation and code.

## A Quick Example

To start a new project:

```shell
copier copy git+https://github.com/stuartellis/tf-tasks my-project
cd my-project
TFT_CONTEXT=dev task tft:context:new
TFT_STACK=my-app task tft:new
```

Add the settings for remote state storage to the [context](#contexts). You can then start working with your stacks:

```shell
TFT_CONTEXT=dev TFT_STACK=my-app task tft:init
TFT_CONTEXT=dev TFT_STACK=my-app task tft:plan
TFT_CONTEXT=dev TFT_STACK=my-app task tft:apply
```

## More About This Tooling

The tooling is a [Copier](https://copier.readthedocs.io/en/stable/) template that provides a directory structure and a [Task](https://taskfile.dev) file. The file defines tasks that generate and run commands. Copier to enable you to create new projects that include the tooling, add the files and directories to any existing project and also synchronize them with newer [versions](https://github.com/stuartellis/tf-tasks/releases) as needed. [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/) accept the same commands and have the same behavior, so the same tooling can support both of them with minimal effort.

The combination of Task and Copier means that we do not need to use a programming language like Python or Go. It also avoids dependencies on particular versions of Terraform or OpenTofu. The tooling:

- Runs on any UNIX-based system, including CI/CD environments
- Works with any version of Terraform or OpenTofu that you provide
- Has few dependencies: it requires Git, Task and a UNIX shell to run. Python and Copier are only required to update projects
- Avoids conflicts with other technologies. You can use it on a new project, or to add it to an existing project.
- Does not require regular updates
- Has a well-defined update process, because it is just a [Copier](https://copier.readthedocs.io/en/stable/) template

The tasks provide an opinionated configuration for Terraform and OpenTofu, which is described in this article. This configuration enables projects to use built-in features of these tools to support:

- Multiple TF components ([root modules](https://opentofu.org/docs/language/modules/)) in the same code repository, as self-contained [stacks](#stacks)
- Multiple instances of the same TF component with different configurations
- Temporary instances of a TF component for testing or development with [workspaces](https://opentofu.org/docs/language/state/workspaces/).

> This tooling was built for my personal use. I will consider suggestions and Pull Requests, but I may decline anything that makes it less useful for my needs. You are welcome to fork [the project](https://github.com/stuartellis/tf-tasks).

For more details about how to work with Task, see [my article](https://www.stuartellis.name/articles/task-runner/).

## How It Works

First, you use [Copier](https://copier.readthedocs.io/en/stable/) to either generate a new project, or to add this tooling to an existing project.

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
|    |- definitions/
|    |    |
|    |    |- template/
|    |    |
|    |    |- <generated stack definitions>
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
- Copy the contents of the `template/` directories to new stacks and contexts. These provide consistent structures for each component.

### Stacks

You define each set of infrastructure code as a separate component. Each of the infrastructure components in the project is a separate TF root [module](https://opentofu.org/docs/language/modules/). This tooling refers to these TF root modules as _stacks_. Each TF stack is a subdirectory in the directory `tf/definitions/`.

The tooling creates each new stack as a copy of the files in `tf/stacks/template/`. This means that a new stack works immediately.

> This tooling does not explicitly conflict with the [stacks feature of Terraform](https://developer.hashicorp.com/terraform/language/stacks). However, I do not currently use HCP Terraform to test with the stacks feature that it provides. It is unclear when this feature will be finalised, if it will be able to be used without a HCP Terraform account, or if an equivalent will be implemented by OpenTofu.

### Contexts

This tooling uses _contexts_ to provide profiles for TF. Contexts enable you to deploy multiple instances of the same stack with different configurations. Each context is a subdirectory in the directory `tf/contexts/` that contains a `context.json` file and one `.tfvars` file per stack. The `context.json` file is the configuration file for the context. It specifies metadata and settings for TF [remote state](https://opentofu.org/docs/language/state/remote/).

Each `context.json` file specifies two items of metadata: `description` and `environment`. The `description` is deliberately not used by the tooling, so that you may use it however you wish. The `environment` is a string that is automatically provided as a tfvar. You may use the `environment` tfvar in whatever way is appropriate for the project. For example, you could define multiple contexts with the same environment.

To enable you to share common tfvars across all of the contexts for a stack, the directory `tf/contexts/all/` contains one `.tfvars` file for each stack. The `.tfvars` file for a stack in the `all` directory is always used, along with `.tfvars` for the current context.

The tooling creates each new context as a copy of files in `tf/contexts/template/`. It uses `standard.tfvars` to create the tfvars files that are created for new stacks.

### Variants

The variants feature creates extra copies of stacks for development and testing. A variant is a separate instance of a stack. Each variant of a stack uses the same configuration as other instances with the specified context, but has a unique identifier. Every variant is a TF [workspace](https://opentofu.org/docs/language/state/workspaces), so has separate state.

> If you do not set a variant, TF uses the default workspace for the stack.

### Resource Names

Use the `environment`, `stack_name` and `variant` tfvars in your TF code to define resource names that are unique for each instance of the resource. This avoids conflicts.

> The test in the stack template includes code to set the value of `variant` to a random string with the prefix `tt`.

The code in the stack template includes the local `standard_prefix` to help you set unique names for resources.

### Shared Modules

The project structure also includes a `tf/modules/` directory to hold TF modules that are shared between stacks in the same project. To share modules between projects, [publish them to a registry](https://opentofu.org/docs/language/modules/#published-modules).

### Dependencies Between Stacks

By design, this tooling does not specify or enforce any dependencies between infrastructure components. If you need to execute changes in a particular order, specify that order in whichever system you use to carry out deployments.

## Setting Up a Project

You need [Git](https://git-scm.com/) and [Copier](https://copier.readthedocs.io/en/stable/) to add this template to a project. Use [uv](https://docs.astral.sh/uv/) or [pipx](https://pipx.pypa.io/) to run Copier. These tools enable you to use Copier without installing it.

You can either create a new project with this template or add the template to an existing project. Use the same _copy_ sub-command of Copier for both cases. Run Copier with the _uvx_ or _pipx run_ commands, which download and cache software packages as needed. For example:

```shell
uvx copier copy git+https://github.com/stuartellis/tf-tasks my-project
```

I recommend that you use a tool version manager to install copies of Terraform and OpenTofu. Consider using either [tenv](https://tofuutils.github.io/tenv/), which is specifically designed for TF tools, or the general-purpose [mise](https://mise.jdx.dev/) framework. The generated projects include a `.terraform-version` file so that your tool version manager can install the Terraform version that you specify.

## Usage

To use the tasks in a generated project you need:

- [Git](https://git-scm.com/)
- A UNIX shell, such as Bash or Fish
- [Task](https://taskfile.dev)
- [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/)

The TF tasks in the template do not use Python or Copier. This means that they can be run in a restricted environment, such as a continuous integration job.

To see a list of the available tasks in a project, enter _task_ in a terminal window:

```shell
task
```

> The tasks use the namespace `tft`. This means that they do not conflict with any other tasks in the project.

Before you manage resources with TF, first create at least one context:

```shell
TFT_CONTEXT=dev task tft:context:new
```

This creates a new context. Edit the `context.json` file in the directory `tf/contexts/<CONTEXT>/` to specify the settings for the remote state storage that you want to use and set the `environment` name.

> By default, this tooling uses [remote state](https://opentofu.org/docs/language/state/remote/) for TF. The current version always uses S3 for remote state.

Next, create a stack:

```shell
TFT_STACK=my-app task tft:new
```

Use `TFT_CONTEXT` and `TFT_STACK` to create a deployment of the stack with the configuration from the specified context:

```shell
TFT_CONTEXT=dev TFT_STACK=my-app task tft:init
TFT_CONTEXT=dev TFT_STACK=my-app task tft:plan
TFT_CONTEXT=dev TFT_STACK=my-app task tft:apply
```

> You will see a warning when you run `init` with a current version of Terraform. This is because Hashicorp are [deprecating the use of DynamoDB with S3 remote state](https://developer.hashicorp.com/terraform/language/backend/s3#state-locking). To support older versions of Terraform, this tooling will continue to use DynamoDB for a period of time.

### Updating TF Tasks

To update projects with the latest version of this template, use the [update feature of Copier](https://copier.readthedocs.io/en/stable/updating/):

```shell
cd my-project
uvx copier update -A -a .copier-answers-tf-task.yaml .
```

This synchronizes the files in your project that the template manages with the latest release of the template.

> Copier only changes the files and directories that are managed by the template.

### Optional: Using Variants

Use the variants feature to deploy extra copies of stacks for development and testing. Each variant of a stack uses the same configuration as other instances with the specified context.

Specify `TFT_VARIANT` to create a variant:

```shell
TFT_CONTEXT=dev TFT_STACK=my-app TFT_VARIANT=feature1 task tft:plan
TFT_CONTEXT=dev TFT_STACK=my-app TFT_VARIANT=feature1 task tft:apply
```

The tooling automatically sets the value of the tfvar `variant` to match `TFT_VARIANT`. This ensures that every variant has a unique identifier that can be used in TF code.

Only set `TFT_VARIANT` when you want to create an alternate version of a stack. If you do not specify a variant name, TF uses the default workspace for state, and the value of the tfvar `variant` is `default`.

The [test](https://opentofu.org/docs/cli/commands/test/) feature of TF creates and then immediately destroys resources without storing the state. To ensure that temporary test copies of stacks do not conflict with other copies, the test in the stack template includes code to set the value of `variant` to a random string with the prefix `tt`.

### Optional: Using Local TF State

This tooling currently uses [remote state](https://opentofu.org/docs/language/state/remote/) by default. Set `TFT_REMOTE_BACKEND` to `false` to use [local TF state](https://opentofu.org/docs/language/settings/backends/local/):

```shell
TFT_REMOTE_BACKEND=false
```

> I highly recommend that you only use TF local state for prototyping. Local state means that the resources can only be managed from a computer that has access to the state files.

### Optional: Using OpenTofu

By default, this tooling uses Terraform. To use OpenTofu, set `TFT_CLI_EXE` as an environment variable, with the value `tofu`:

```shell
TFT_CLI_EXE=tofu
```

### The `tft` Tasks

| Name          | Description                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------- |
| tft:apply     | _terraform apply_ for a stack\*                                                                   |
| tft:check-fmt | Checks whether _terraform fmt_ would change the code for a stack                                  |
| tft:clean     | Remove the generated files for a stack                                                            |
| tft:console   | _terraform console_ for a stack\*                                                                 |
| tft:destroy   | _terraform apply -destroy_ for a stack\*                                                          |
| tft:fmt       | _terraform fmt_ for a stack                                                                       |
| tft:forget    | _terraform workspace delete_ for a variant\*                                                      |
| tft:init      | _terraform init_ for a stack                                                                      |
| tft:new       | Add the source code for a new stack. Copies content from the _tf/definitions/template/_ directory |
| tft:plan      | _terraform plan_ for a stack\*                                                                    |
| tft:rm        | Delete the source code for a stack                                                                |
| tft:test      | _terraform test_ for a stack\*                                                                    |
| tft:validate  | _terraform validate_ for a stack\*                                                                |

\*: These tasks require that you first run `tft:init` to [initialise](https://opentofu.org/docs/cli/commands/init/) the stack.

### The `tft:context` Tasks

| Name             | Description                                                                  |
| ---------------- | ---------------------------------------------------------------------------- |
| tft:context:list | List the contexts                                                            |
| tft:context:new  | Add a new context. Copies content from the _tf/contexts/template/_ directory |
| tft:context:rm   | Delete the directory for a context                                           |

### Settings for Features

Set these variables to override the defaults:

- `TFT_PRODUCT_NAME` - The name of the project
- `TFT_CLI_EXE` - The Terraform or OpenTofu executable to use
- `TFT_VARIANT` - See the section on [variants](#variants)
- `TFT_REMOTE_BACKEND` - Enables a remote TF backend
