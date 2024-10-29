+++
title = "Using the Task Tool"
slug = "task-runner"
date = "2024-10-29T13:22:20+00:00"
description = "Using the Task Tool"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

[Task](https://taskfile.dev) is a task runner and build tool. It provides a consistent framework for sets of tasks, enabling you to run the same workflows on multiple platforms and environments.

> Task is also known as go-task.

## How Task Works

Each copy of Task is a single executable file, with versions for Linux, macOS and Windows. This executable is relatively small, being about 8Mb for the 64-bit Linux version. It uses sets of tasks that are defined in YAML files, and includes a shell interpreter, so that you can use the same syntax for tasks on any platform.

This means that you can use Task in any environment. It only requires a copy of the Task executable, and has no configuration files apart from the YAML files that contain the tasks.

It also provides features for you to customise the behavior of your tasks for the different environments that you might use. The built-in [template functions](https://taskfile.dev/reference/templating/#functions) enable you to get consistent inputs for your tasks across different platforms. When needed, you can define [operating system specific files](https://taskfile.dev/usage/#os-specific-taskfiles), so that Task uses the specific implementation for the current platform.

Task includes two other key features: [conditional execution of tasks](https://taskfile.dev/usage/#prevent-unnecessary-work) and [running tasks on file changes](https://taskfile.dev/usage/#watch-tasks). These features are designed to be usable with any type of software development.

Here is an example of a _Taskfile.yaml_, with a _build_ task that only runs when the _sources_ change:

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

You can install Task with [operating system packages](#installing-task-with-operating-system-packages). These packages only provide a single global copy of Task, which may be an older version.

If possible, use a tool that enables you to specify which versions of Task to install and activate different versions of Task for different projects. These options enable you to specify a version of Task for a project:

1. Tool version managers like [mise](#installing-task-with-mise)
2. [Dev Containers](#adding-task-to-a-dev-container)
3. [Installation script](#installing-task-with-a-script)

Tool version managers and the installation script also enable you to install Task so that it is globally available for all of your work, not just a single project.

If you install a global copy of Task then [you can integrate it with your shell](#integrating-task-with-your-shell).

### Installing Task with mise

This command installs the latest version of Task with [mise](https://mise.jdx.dev/) and makes it available to your user account:

```shell
mise use -gy task
```

### Adding Task to a Dev Container

If you are using a Dev Container with Visual Studio Code, you can add the feature [go-task](https://github.com/devcontainers-contrib/features/blob/main/src/go-task/README.md) to your _devcontainer.json_ file to download Task from GitHub:

```json
    "features": {
        "ghcr.io/devcontainers-contrib/features/go-task:1": {
            "version": "3.39.2"
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

### Installing Task with a Script

The Task project provide a [script for downloading task from GitHub](https://taskfile.dev/installation#install-script). You may either fetch this installation script each time, as the documentation describes, or save it.

If you build Docker container images that contain a copy of Task, use a saved copy of the script. This ensures that container image builds are consistent.

To save the installation script:

```shell
curl -L https://taskfile.dev/install.sh > install-task.sh
```

To use the installation script, call it with the Git tag and the _-b_ option. The Git tag specifies the version of Task. The _-b_ option specifies which directory to install it to:

```shell
./install-task.sh -b $HOME/.local/bin v3.39.2
```

{{< alert >}}
_Exclude the path for the Task executable file from version control._ If you use the script to download a copy of Task into a development project, make sure that the _.gitignore_ (or equivalent) excludes it from version control.
{{< /alert >}}

### Installing Task with Operating System Packages

If you do need to install Task with an operating system package manager, it is available for several popular systems. For example, these commands install Task:

```shell
winget install Task.Task  # winget on Microsoft Windows
brew install go-task      # Homebrew on macOS
doas apk add go-task      # apk on Alpine Linux
sudo dnf install go-task  # dnf on Fedora Linux
```

To install Task on Alpine Linux, you need to enable the _community_ package repository.

> _Alpine Linux installs Task as go-task._ This means that you need to use the name _go-task_ rather than _task_ on the command-line. For example _go-task --list_.

## Integrating Task with Your Shell

### Enabling Autocompletion

To enable autocompletion for Task in a shell, [follow the instructions for the shell that you use](https://taskfile.dev/installation/#option-1-load-the-completions-in-your-shells-startup-config-recommended). For example, to add autocompletion for the fish shell, add this line to the file _~/.config/fish/config.fish_:

```shell
task --completion fish | source
```

The Task project currently provides completion support for Bash, zsh, fish and PowerShell.

### Creating a User Taskfile for Global Tasks

To define tasks that are available at any time, create a file with the name _Taskfile.yaml_ in your home directory.

Create a task in the _Taskfile.yaml_ with the name _default_. When Task is invoked without the name of a task, it runs the _default_ task in the _Taskfile.yaml_.

This example user _Taskfile.yaml_ includes a _default_ task that lists the available tasks:

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

Use the option _-g_ to run the user _Taskfile.yaml_, rather than the nearest Taskfile:

```shell
task -g system-info
```

For convenience, add an alias to your shell configuration. For example, add these lines in _.config/fish/config.fish_ to enable an alias in the Fish shell:

```fish
# Add abbr to call tasks in global Taskfile by typing ".t TASK-NAME"
if command -s task > /dev/null
    abbr --add .t task -g
end
```

## Integrating Task with Other Tools

### Enabling Visual Studio Code Integration

To use Task with Visual Studio Code, install the [redhat.vscode-yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) and [task.vscode-task](https://marketplace.visualstudio.com/items?itemName=task.vscode-task) extensions.

The _vscode-yaml_ extension enables YAML formatting and validation, and _vscode-task_ adds a graphical integration for running tasks.

> _You must install Task to use the vscode-task extension._

### Enabling Integration with JetBrains IDEs

To enable support for Task in JetBrains IDEs such as PyCharm, install the [Taskfile](https://plugins.jetbrains.com/plugin/17058-taskfile) plugin.

## Using Task in a Project

First, add the _.task_ directory to the exclusions for source control. This directory is used to hold [files for tracking changes](https://taskfile.dev/usage/#by-fingerprinting-locally-generated-files-and-their-sources).

> _Always use the name Taskfile.yaml or Taskfile.yml for Task files._ This enables tools that support [JSON Schemas](https://json-schema.org/) to identify the format of the files, so that they can provide autocompletion and validation.

If a project only requires one small set of tasks, then use a single Taskfile. If you need to manage several sets of tasks, use these features:

1. [Taskfiles in subdirectories](https://taskfile.dev/usage/#running-a-taskfile-from-a-subdirectory)
2. [Includes](https://taskfile.dev/usage/#including-other-taskfiles)

Adding _Taskfile.yaml_ files in subdirectories enables you to override the set of tasks for a project when you change your working directory in the project. This lets you define sets of tasks that are appropriate to the context.

The _includes_ feature of Task enables you to define groups of tasks that can be added to any Taskfile. These groups automatically become namespaces, which ensures that tasks with the same name do not override each other. For example, if you create an include for _python_ and an include for _web_, they may both have a task called _test_, which you can call as _python:test_ and _web:test_.

### Using Includes

If you decide to use Task includes in your project, consider following these guidelines:

- Create the first task in the root _Taskfile.yaml_ with the name _default_. When Task is invoked without a namespace or task name, it runs the _default_ task in the _Taskfile.yaml_.
- Create subdirectory called _tasks/_. For each namespace, create a directory with the same name as the namespace, with a _Taskfile.yaml_ file in the directory. Write the tasks for the namespace in the relevant _Taskfile.yaml_ file. Use _includes_ in the root _Taskfile.yaml_ file to enable these namespaces.
- Use the root _Taskfile.yaml_ to define standard tasks for the project. Each of these should call the relevant tasks in one or more namespaces. Avoid writing tasks in the root _Taskfile.yaml_ that do anything other than running tasks that are defined in namespaces.
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
|    |    |- Taskfile.yaml
|    |
|    |- package
|         |
|         |- Taskfile_darwin.yaml
|         |- Taskfile_linux.yaml
|         |- Taskfile_windows.yaml
|
|- Taskfile.yaml
```

### Example Taskfile.yaml for a Project

```yaml
# Tasks for the Task runner:
#
# https://taskfile.dev

version: "3"

silent: true

# Namespaces
includes:
  package: tasks/package/Taskfile_{{OS}}.yaml
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

## Writing Taskfiles

Follow [the style guidelines](https://taskfile.dev/styleguide/) when writing tasks. Here are some extra suggestions:

- Use a YAML formatter to format your Task files. The [redhat.vscode-yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) extension adds support for formatting YAML files to Visual Studio Code. The [Prettier](https://prettier.io/) tool formats YAML files, and can be used in any environment.
- Always put a _desc_ attribute for each task. The description appears next to the task in the output of _task --list_.
- Consider adding a [summary](https://taskfile.dev/usage/#display-summary-of-task) attribute for each task. The summary appears in the output of _task --summary TASK-NAME_.
- Use [argument forwarding](https://taskfile.dev/usage/#forwarding-cli-arguments-to-commands) or [wildcard task names](https://taskfile.dev/usage/#wildcard-arguments) to get inputs for a task from the command-line.
- Specify the [requires](https://taskfile.dev/usage/#ensuring-required-variables-are-set) attribute for each task that uses a variable. This ensures that the task has the necessary variables.
- Use [dotenv files](https://taskfile.dev/usage/#env-files) to get configuration from files.
- Use Bash shell syntax for tasks. Task uses [mvdan/sh](https://github.com/mvdan/sh) to provide the equivalent of the _bash_ shell.
- To ensure that your tasks are portable, check the options for UNIX commands that you call in tasks, such as _rm_. Different operating systems and Linux distributions provide different implementations of these commands, which means that the options may not be consistent across environments.
- When it is possible, use the [template functions](https://taskfile.dev/reference/templating/#functions) instead of shell commands, because these will behave consistently across different environments.
- Provide [operating system specific Taskfiles](https://taskfile.dev/usage/#os-specific-taskfiles) when necessary.

{{< alert >}}
_Dependencies run in parallel._ This means that dependencies of a task should not depend on each other. If you want to ensure that tasks run in sequence, see the documentation on [Calling Another Task](https://taskfile.dev/usage/#calling-another-task).
{{< /alert >}}

## Running Tasks

To run a task in a _Taskfile.yaml_, enter _task_ followed by the name of the task:

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

## Checking Taskfiles

The Task project publish the schema for Task files as a [JSON Schema](https://json-schema.org/). This means that any software that supports JSON Schemas for YAML documents can check that your Task files are valid. To ensure that your Task files are consistently formatted, use standard tools for YAML files.

Visual Studio Code will both validate and format Task files when the [redhat.vscode-yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) extension is installed. This extension use a language server for the YAML format, with support for JSON Schemas.

To validate Task files on the command-line, use [check-jsonschema](https://check-jsonschema.readthedocs.io/en/stable/index.html). The _check-jsonschema_ tool automatically includes the schema for Task files. The [yamllint](https://yamllint.readthedocs.io) command-line tool provides format and quality checks for all types of YAML file.

The _check-jsonschema_ and _yamllint_ projects also provide hooks for [pre-commit](https://pre-commit.com), so that files are automatically checked before changes are committed to source control.

### Validating Task files with pre-commit

To validate Task files before you commit them to source control, add the [hook for check-jsonschema](https://check-jsonschema.readthedocs.io/en/stable/precommit_usage.html) and the [hook for yamllint](https://yamllint.readthedocs.io/en/stable/integration.html#integration-with-pre-commit) to the [pre-commit](https://pre-commit.com/) configuration for your project.

Add these lines to the _.pre-commit-config.yaml_ file in the root directory of your project:

```yaml
- repo: https://github.com/python-jsonschema/check-jsonschema
  rev: "0.29.4"
  hooks:
    - id: check-taskfile
- repo: https://github.com/adrienverge/yamllint.git
  rev: "v1.35.1"
  hooks:
    - id: yamllint
      args: [--strict]
```

To ensure that _yamllint_ handles Task files, add a _.yamllint.yaml_ file with this content:

```yaml
---
# Begin with yamllint default settings
extends: default

rules:
  # Rules for curly braces: {}
  braces:
    forbid: false
    min-spaces-inside: 0
    max-spaces-inside: 0
    min-spaces-inside-empty: 0
    max-spaces-inside-empty: 0

  # Rules for round brackets: ()
  brackets:
    forbid: false
    min-spaces-inside: 0
    max-spaces-inside: 0
    min-spaces-inside-empty: 0
    max-spaces-inside-empty: 0

  # Do not require three dashes at the start of a YAML document
  document-start: disable

  # Rules for line length
  line-length:
    max: 88
    level: error
```

The _pre-commit_ checks automatically run when you commit code. You may also run the checks yourself at any time, with the _pre-commit_ command-line tool. For example, this command validates all of the Task files in your project:

```shell
pre-commit run check-taskfile --all-files
```

### Testing a Task

To test a task, run it with the [--dry](https://taskfile.dev/usage/#dry-run-mode) option:

```shell
task --dry TASK-NAME
```

This compiles and prints tasks in the order that they would be run.

To debug a task, ensure that _silent_ is not enabled in the appropriate _Taskfile.yaml_, so that the outputs of the commands are visible:

```yaml
silent: false
```

## Resources

- [Documentation for Task](https://taskfile.dev/)
- [Using a task runner to help with context switching in software projects](https://www.caro.fyi/articles//)
- [Video: Say Goodbye to Makefile - Use Taskfile to Manage Tasks in CI/CD Pipelines and Locally](https://www.youtube.com/watch?v=Z7EnwBaJzCk) (YouTube, 17 minutes long)
