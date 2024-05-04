+++
title = "Using the Task Tool"
slug = "task-runner"
date = "2024-05-04T12:31:00+01:00"
description = "Using the Task Tool"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

The [Task](https://taskfile.dev) tool is a task runner and build tool. It provides a consistent framework for working with sets of tasks, enabling you to run the same tasks on multiple platforms and environments.

## How Task Works

Each copy of Task is a single executable file, with versions for Linux, macOS and Windows. This executable is relatively small, being about 8Mb for the 64-bit Linux version. It uses sets of tasks that are defined in YAML files, and includes a shell interpreter, so that you can use the same syntax for tasks on any platform.

This means that you can use Task in any environment. It only requires a copy of the Task executable, and has no configuration files apart from the YAML files that contain the tasks.

It also provides features for you to customise the behavior of your tasks for the different environments that you might use. The built-in [template functions](https://taskfile.dev/usage/#gos-template-engine) enable you to get consistent inputs for your tasks across different platforms. When needed, you can define [operating system specific files](https://taskfile.dev/usage/#os-specific-taskfileions), so that Task uses the specific implementation for the current platform.

Task includes two other important features: [conditional execution of tasks](https://taskfile.dev/usage/#prevent-unnecessary-work) and [running tasks on file changes](https://taskfile.dev/usage/#watch-tasks). These features are designed to be usable with any type of software development.

Here is an example of a _Taskfile.yml_, with a _build_ task that only runs when the _sources_ change:

```yaml
# Tasks for a Hugo static website project
#
# Hugo: https://gohugo.io

version: "3"

silent: true

tasks:
  default:
    cmds:
      - task: build

  build:
    desc: Build Website
    cmds:
      - hugo
    sources:
      - content/**/*.md
    generates:
      - public/**

  clean:
    desc: Delete generated files
    cmds:
      - for: [".hugo_build.lock", "public"]
        cmd: rm -fr {{.ITEM}}

  deploy:
    desc: Deploy Website
    deps: [build]
    cmds:
      - hugo deploy

  serve:
    desc: Run Website in development server
    cmds:
      - hugo server
```

## Installing Task

Consider using a tool version manager like [mise](https://mise.jdx.dev/) or [asdf](https://asdf-vm.com) to install Task. For example, this command installs the latest version of Task with _mise_:

```shell
mise use -gy task
```

If you have a Dev Container configuration for a project, use the [go-task feature](https://github.com/devcontainers-contrib/features/blob/main/src/go-task/README.md), as shown in the section below.

To add Task to container images or systems without a tool version manager, see the section below for how to install Task with a script.

All of these tools enable you to have multiple versions of Task and use the version of Task that is required for each project that you work on. If possible, avoid using operating system packages. A package installs a single shared copy of Task, and is likely to provide an older version.

### Installing Task with a Script

The Task project provide a [script for downloading task from GitHub](https://taskfile.dev/installation#install-script). You may either fetch this installation script each time, as the documentation describes, or save it.

If you build Docker container images that contain a copy of Task, use a saved copy of the script. This ensures that container image builds are consistent.

To save the installation script:

```shell
curl -L https://taskfile.dev/install.sh > install-task.sh
```

To use the installation script, call it with the Git tag and the _-b_ option. The Git tag specifies the version of Task. The _-b_ option specifies which directory to install it to:

```shell
./install-task.sh -b $HOME/.local/bin v3.36.0
```

{{< alert >}}
_Exclude the path for the Task executable file from version control._ If you use the script to download a copy of Task into a development project, make sure that the _.gitignore_ (or equivalent) excludes it from version control.
{{< /alert >}}

### Installing Task with Operating System Packages

If you do need to install Task with an operating system package manager, it is available for several popular systems. For example, these commands install Task:

```shell
winget install Task.Task  # winget on Microsoft Windows
brew install go-task      # Homebrew on macOS
sudo dnf install go-task  # dnf on Fedora Linux
```

### Enabling Visual Studio Code Integration

To use Task with Visual Studio Code, install the [redhat.vscode-yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) and [task.vscode-task](https://marketplace.visualstudio.com/items?itemName=task.vscode-task) extensions.

The _vscode-yaml_ extension enables YAML formatting and validation, and _vscode-task_ adds a graphical integration for running tasks.

> _You must install Task to use the vscode-task extension._

### Enabling Autocompletion

To enable autocompletion for Task in a shell, [download the appropriate script and install it into the correct location](https://taskfile.dev/installation#setup-completions). For example, this command enables autocompletion in the fish shell:

```shell
curl -L https://raw.githubusercontent.com/go-task/task/main/completion/fish/task.fish > $HOME/.config/fish/completions/task.fish
```

The Task project currently provides autocompletions for Bash, zsh, fish and PowerShell.

### Adding Task to a Dev Container

If you are using a Dev Container, you can add the feature [go-task](https://github.com/devcontainers-contrib/features/blob/main/src/go-task/README.md) to your _devcontainer.json_ file to download Task from GitHub:

```json
    "features": {
        "ghcr.io/devcontainers-contrib/features/go-task:1": {
            "version": "3.36.0"
        }
    }
```

Ensure that you also include the [redhat.vscode-yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) and [task.vscode-task](https://marketplace.visualstudio.com/items?itemName=task.vscode-task) extensions in the _devcontainer.json_ file:

```json
    "customizations": {
        "vscode": {
            "extensions": [
                "redhat.vscode-yaml",
                "task.vscode-task"
            ]
        }
    }
```

The _vscode-yaml_ extension enables YAML formatting and validation, and _vscode-task_ adds a graphical integration for running tasks.

## Creating a User Taskfile.yml for Global Tasks

To define tasks that are available at any time, create a file with the name _Taskfile.yml_ in your home directory.

Create a task in the _Taskfile.yml_ with the name _default_. When Task is invoked without the name of a task, it runs the _default_ task in the _Taskfile.yml_.

This example user _Taskfile.yml_ includes a _default_ task that lists the available tasks:

```yaml
version: "3"

silent: true

tasks:
  default:
    cmds:
      - task: list

  list:
    desc: List available tasks
    cmds:
      - task --list

  system-info:
    desc: Display system information
    cmds:
      - "echo CPU architecture: {{ARCH}}"
      - "echo Operating system: {{OS}}"
```

The user _Taskfile.yml_ requires the option _-g_ to run:

```shell
task -g system-info
```

For convenience, add an alias to your shell configuration. For example, add these lines in _.config/fish/config.fish_ to enable an alias in the Fish shell:

```fish
# Add abbr to call tasks in user Taskfile.yml by typing ".t TASK-NAME"
if command -s task > /dev/null
    abbr --add .t task -g
end
```

This means that you run a task in the user _Taskfile.yml_ by entering _.t_ followed by the name of the task:

```shell
.t system-info
```

To list the tasks in your user _Taskfile.yml_, you can type _.t_ and press the _Enter_ key:

```shell
.t
```

This runs the _default_ task. The example _Taskfile.yml_ configures this to display a list of tasks.

## Using Task in a Project

First, add the _.task_ directory to the exclusions for source control. This directory is used to hold [files for tracking changes](https://taskfile.dev/usage/#by-fingerprinting-locally-generated-files-and-their-sources).

Use _task --init_ to create a _Taskfile.yml_ in the root directory of your project.

> _Always use the name Taskfile.yml for Task files._ This enables tools that support [JSON Schemas](https://json-schema.org/) to identify the format of the files, so that they can provide autocompletion and validation.

If a project only requires one small set of tasks, then use a single _Taskfile.yml_. If you need to manage several sets of tasks, use these features:

1. [Taskfiles in subdirectories](https://taskfile.dev/usage/#running-a-taskfile-from-a-subdirectory)
2. [Includes](https://taskfile.dev/usage/#including-other-taskfiles)

Adding _Taskfile.yml_ files in subdirectories enables you to override the set of tasks for a project when you change your working directory in the project. This lets you define sets of tasks that are appropriate to the context.

Task includes enable you to define groups of tasks that can be added to any _Taskfile.yml_. These groups automatically become namespaces, which ensures that tasks with the same name do not override each other. For example, if you create an include for _python_ and an include for _web_, they may both have a task called _test_, which you can call as _python:task_ and _web:test_.

### Using Includes

If you decide to use Task includes in your project, consider following these guidelines:

- Create the first task in the root _Taskfile.yml_ with the name _default_. When Task is invoked without a namespace or task name, it runs the _default_ task in the _Taskfile.yml_.
- Create subdirectory called _tasks/_. For each namespace, create a directory with the same name as the namespace, with a _Taskfile.yml_ file in the directory. Write the tasks for the namespace in the relevant _Taskfile.yml_ file. Use _includes_ in the root _Taskfile.yml_ file to enable these namespaces.
- Use the root _Taskfile.yml_ to define standard tasks for the project. Each of these should call the relevant tasks in one or more namespaces. Avoid writing tasks in the root _Taskfile.yml_ that do anything other than running tasks that are defined in namespaces.
- Remember to include a _default_ task for each namespace. This means that the _default_ task runs when a user types the name of the namespace without specifying the name of the task.
- Specify any relevant [aliases](https://taskfile.dev/usage/#namespace-aliases) for a namespace with the _includes_ attribute.

This diagram shows the suggested directory structure for a project with task includes:

```shell
.
|
| - tasks/
|    |
|    |- pre-commit
|    |    |
|    |    |- Taskfile.yml
|    |
|    |- package
|         |
|         |- Taskfile_darwin.yml
|         |- Taskfile_linux.yml
|         |- Taskfile_windows.yml
|
|- Taskfile.yml
```

### Example Taskfile.yml for a Project

```yaml
# Tasks for the Task runner:
#
# https://taskfile.dev

version: "3"

silent: true

# Namespaces
includes:
  package: tasks/package/Taskfile_{{OS}}.yml
  pre-commit: tasks/pre-commit

# Top-level tasks
tasks:
  default:
    cmds:
      - task: list

  bootstrap:
    desc: Set up environment for development
    cmds:
      - task: pre-commit:setup

  build:
    desc: Build packages
    cmds:
      - task: package:build

  clean:
    desc: Delete generated files
    cmds:
      - task: package:clean

  fmt:
    desc: Format code
    aliases: [format]
    cmds:
      - task: pre-commit:run
        vars: { HOOK_ID: "ruff-format" }

  lint:
    desc: Run all checks
    aliases: [check]
    cmds:
      - task: pre-commit:check

  list:
    desc: List available tasks
    cmds:
      - task --list
```

The _default_ task runs the _list_ task, so this command displays a list of all of the available tasks, including the tasks in the namespaces:

```shell
task
```

### Example Namespace of Tasks for a Project

```yaml
# Tasks for pre-commit
#
# https://pre-commit.com/

version: "3"

silent: true

tasks:
  default:
    cmds:
      - task: check

  check:
    desc: Check the project with pre-commit
    cmds:
      - pre-commit run --all-files

  run:
    desc: Run a specific pre-commit check on the project
    cmds:
      - pre-commit run "{{.HOOK_ID}}" --all-files
    requires:
      vars: [HOOK_ID]

  setup:
    desc: Setup pre-commit for use
    cmds:
      - pre-commit install
```

The _default_ task in this file runs _check_, so this command runs the _check_ task:

```shell
task pre-commit
```

The result is the same as this command:

```shell
task pre-commit:check
```

## Writing Taskfile.yml files

Follow [the style guidelines](https://taskfile.dev/styleguide/) when writing tasks. Here are some extra suggestions:

- Use a YAML formatter to format your Task files. The [redhat.vscode-yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) extension adds support for formatting YAML files to Visual Studio Code. The [Prettier](https://prettier.io/) tool formats YAML files, and can be used in any environment.
- Always put a _desc_ attribute for each task. The description appears next to the task in the output of _task --list_.
- Consider adding a [summary](https://taskfile.dev/usage/#display-summary-of-task) attribute for each task. The summary appears in the output of _task --summary TASK-NAME_.
- Use [argument forwarding](https://taskfile.dev/usage/#forwarding-cli-arguments-to-commands) or [wildcard task names](https://taskfile.dev/usage/#wildcard-arguments) to get inputs for a task from the command-line.
- Specify the [requires](https://taskfile.dev/usage/#ensuring-required-variables-are-set) attribute for each task that uses a variable. This ensures that the task has the necessary variables.
- Use [dotenv files](https://taskfile.dev/usage/#env-files) to get configuration from files.
- Use Bash shell syntax for tasks. Task uses [mvdan/sh](https://github.com/mvdan/sh) to provide the equivalent of the _bash_ shell.
- To ensure that your tasks are portable, check the options for UNIX commands that you call in tasks, such as _rm_. Operating systems provide different implementations of these commands, which means that the options may not be consistent across different environments.
- When it is possible, use the [template functions](https://taskfile.dev/usage/#gos-template-engine) instead of shell commands, because these will behave consistently across different environments.
- Provide [operating system specific Taskfiles](https://taskfile.dev/usage/#os-specific-taskfiles) when necessary.

{{< alert >}}
_Dependencies run in parallel._ This means that dependencies of a task should not depend one another. If you want to ensure that tasks run in sequence, see the documentation on [Calling Another Task](https://taskfile.dev/usage/#calling-another-task).
{{< /alert >}}

## Running Tasks

To run a task in a _Taskfile.yml_, enter _task_ followed by the name of the task:

```shell
task example-task
```

If a task accepts [forwarding of arguments](https://taskfile.dev/usage/#forwarding-cli-arguments-to-commands), add the arguments to the command:

```shell
task example-task -- my-argument-value
```

You may [set variables](https://taskfile.dev/usage/#variables) by specifying environment values with the Task command:

```shell
MY_VARIABLE_NAME=my-variable-value task example-task
```

## Checking Taskfile.yml files

The Task project publish the schema for Task files as a [JSON Schema](https://json-schema.org/). This means that any software that supports JSON Schemas for YAML documents can automatically check your Task files. For example, Visual Studio Code will automatically do this when the [redhat.vscode-yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) extension is installed.

To validate the Task files on the command-line, use a YAML linter that supports JSON Schemas, such as [check-jsonschema](https://check-jsonschema.readthedocs.io/en/stable/index.html). The _check-jsonschema_ tool automatically includes the schema for Task files.

The _check-jsonschema_ project also provides a _pre-commit_ hook to check Task files before changes are committed to source control.

### Validating Task files with pre-commit

To validate Task files before you commit them to source control, add the [pre-commit hook for check-jsonschema](https://check-jsonschema.readthedocs.io/en/stable/precommit_usage.html) to the [pre-commit](https://pre-commit.com/) configuration for your project:

```yaml
- repo: https://github.com/python-jsonschema/check-jsonschema
  rev: 0.28.2
  hooks:
    - id: check-taskfile
```

Once this is added to your project you may run the same check at any time with the _pre-commit_ command-line tool:

```shell
pre-commit run check-taskfile --all-files
```

### Testing a Task

To test a task, run it with the [--dry](https://taskfile.dev/usage/#dry-run-mode) option:

```shell
task --dry TASK-NAME
```

This compiles and prints tasks in the order that they would be run.

To debug a task, ensure that _silent_ is not enabled in the appropriate _Taskfile.yml_, so that the outputs of the commands are visible:

```yaml
silent: false
```

## Resources

- [Documentation for Task](https://taskfile.dev/)
- [Using a task runner to help with context switching in software projects](https://www.caro.fyi/articles/just/)
