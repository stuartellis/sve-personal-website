+++
title = "Using the Task Tool"
slug = "task-runner"
date = "2024-04-22T07:01:00+01:00"
description = "Using the Task Tool"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

The [Task](https://taskfile.dev/) tool is a task runner. It provides a consistent framework for working with sets of tasks, which can run on multiple platforms.

## How Task Works

Each copy of Task is a single executable file, with versions for Linux, macOS and Windows. This executable is relatively small, about 8Mb for the 64-bit Linux version. It uses sets of tasks that are defined in YAML files.

This means that you can add Task to any environment and use whichever scripting languages are available. If you define [operating system specific files](https://taskfile.dev/usage/#os-specific-taskfiles), Task runs the correct implementation for the current platform. It also provides other features for you to customise the behavior of tasks for different environments.

For example, you may use built-in [template functions](https://taskfile.dev/usage/#gos-template-engine) in your tasks. These functions include reading environment variables, calculating file checksums and formatting string inputs. These enable you to get consistent inputs for your tasks across different platforms, even if the scripting language that you use does not have these features.

You do not need to set up or configure Task, because it only requires a copy of the executable, and has no configuration files apart from the files that contain the tasks. Here is an example of a _Taskfile.yml_:

```yaml
# Tasks for a Hugo website project
#
# https://gohugo.io/

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

Consider using a tool version manager like [mise](https://mise.tdx.dev/), [asdf](https://asdf-vm.com) or [a Dev Container feature](https://code.visualstudio.com/docs/devcontainers/containers#_dev-container-features) to download and install Task. These can install any version of Task that is required, including the latest, because they download executables from GitHub.

For example, this command installs the latest version of Task with _mise_:

```shell
mise use -gy task
```

If you do not wish to use a tool version manager, see the section below for how to install Task with a script.

If possible, avoid using operating system packages. These are likely to provide older versions of Task.

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

These extensions enable YAML formatting and validation, and add a graphical integration for running tasks.

### Installing Task with a Script

The Task project provide a [script for downloading task from GitHub](https://taskfile.dev/installation#install-script). You may either fetch this installation script each time, as the documentation describes, or save it. To ensure that container image builds are consistent, use a saved copy of the script when you build Docker container images.

To save the installation script:

```shell
curl -L https://taskfile.dev/install.sh > scripts/install-task.sh
```

To use the installation script, call it with the Git tag and the _-b_ option. The Git tag specifies the version of Task. The _-b_ option specifies which directory to install it to:

```shell
./scripts/install-task.sh -b $HOME/.local/bin v3.36.0
```

### Installing Task with Operating System Packages

If you do need to install Task with an operating system package manager, it is available for many popular systems. For example, these commands install Task:

```shell
winget install Task.Task  # winget on Microsoft Windows
brew install go-task      # Homebrew on macOS
sudo dnf install go-task  # dnf on Fedora Linux
```

### Adding a Private Copy of Task to a Project

The instructions that are provided in the previous sections install a copy of Task for a user or a system. To install a copy of Task that is private to a project, you can use the installation script to install a copy of Task into a directory within the project. If you do this, remember to exclude the path of the Task executable file from version control.

### Enabling Autocompletion

To enable autocompletion for Task in a shell, [download the appropriate script and install it into the correct location](https://taskfile.dev/installation#setup-completions).

Current versions of Task provide autocompletion for Bash, zsh, fish and PowerShell.

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
# Add abbr to call tasks in user Taskfile.yml by typing ".t task-NAME"
if command -s task > /dev/null
    abbr --add .t task -g
end
```

This means that you run a task in the _Taskfile.yml_ by entering _.t_ followed by the name of the task:

```shell
.t system-info
```

To list the tasks in your user _Taskfile.yml_, you can type _.t_ and press the _Enter_ key:

```shell
.t
```

This runs the _default_ task. The example _Taskfile.yml_ configures this to display a list of tasks.

## Using Task in a Project

First, add the _.task_ directory to the exclusions for source control. This directory is used to hold files for tracking changes.

Use _task --init_ to create a _Taskfile.yml_ in the root directory of your project. You should always name the Task file in the root directory of the project _Taskfile.yml_.

If a project only requires one small set of tasks, then use a single _Taskfile.yml_. If you need to manage several sets of tasks, use multiple files.

You have two ways to organize the other _Taskfile.yml_ files in a project:

1. [Namespaces](https://taskfile.dev/usage/#including-other-taskfiles)
2. [Directory hierarchy](https://taskfile.dev/usage/#running-a-taskfile-from-a-subdirectory)

You can combine these approaches. Namespaces enable you to use sets of tasks from multiple _Taskfile.yml_ files. You may also place _Taskfile.yml_ files in subdirectories for tasks that should be scoped to that subdirectory.

### Using Namespaces

If you decide to use namespaces for the tasks in your project, consider following these guidelines:

- Create the first task in the root _Taskfile.yml_ with the name _default_. When Task is invoked without a namespace or task name, it runs the _default_ task in the _Taskfile.yml_.
- Create subdirectory called _.tasks/_. For each namespace, create a directory with the same name as the namespace, with a _Taskfile.yml_ file in the directory. Write the tasks for the namespace in the relevant _Taskfile.yml_ file. Use _includes_ in the root _Taskfile.yml_ file to enable these namespaces.
- Use the root _Taskfile.yml_ to define standard tasks for the project. Each of these should call the relevant tasks in one or more namespaces. Avoid writing tasks in the root _Taskfile.yml_ that do anything other than running tasks that are defined in namespaces.
- Remember to include a _default_ task for each namespace. This means that the _default_ task runs when a user types the name of the namespace without specifying the name of the task.
- Specify any relevant [namespace aliases](https://taskfile.dev/usage/#namespace-aliases) with the _includes_ attribute.

This diagram shows the suggested directory structure for a project with task namespaces:

```shell
.
|
| - .tasks/
|    |
|    |- hugo
|    |    |
|    |    |- Taskfile.yml
|    |
|    |- pre-commit
|         |
|         |- Taskfile.yml
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
  hugo: .tasks/hugo
  pre-commit: .tasks/pre-commit

# Top-level tasks
tasks:
  default:
    cmds:
      - task: list

  bootstrap:
    desc: Set up environment for development
    cmds:
      - task: pre-commit:setup

  clean:
    desc: Delete generated files
    cmds:
      - task: hugo:clean

  deploy:
    desc: Deploy Website
    cmds:
      - task: hugo:deploy

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

  site:
    desc: Display Website in a Web browser
    aliases: [run]
    cmds:
      - task: hugo:serve
```

The _default_ task runs the _list_ task, so this command displays a list of the available tasks:

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

The _default_ task in this file runs _check_, so this command also runs the _check_ task:

```shell
task pre-commit
```

## Writing Taskfile.yml files

Follow [the style guidelines](https://taskfile.dev/styleguide/) when writing tasks. Here are some extra suggestions:

- Use a YAML formatter to format your Task files. For example, [Prettier](https://prettier.io/) formats YAML files.
- Always put a _desc_ attribute for each task. The description appears next to the task in the output of _task --list_.
- Consider adding a [summary](https://taskfile.dev/usage/#display-summary-of-task) attribute for each task. The summary appears in the output of _task --summary TASK-NAME_.
- Use [argument forwarding](https://taskfile.dev/usage/#forwarding-cli-arguments-to-commands) or [wildcard task names](https://taskfile.dev/usage/#wildcard-arguments) to get inputs for a task from the command-line.
- Specify the [requires](https://taskfile.dev/usage/#ensuring-required-variables-are-set) attribute for each task that uses a variable. This ensures that the task has the necessary variables.
- Use [dotenv files](https://taskfile.dev/usage/#env-files) to get configuration from files.
- Use Bash shell syntax for tasks. Task uses [mvdan/sh](https://github.com/mvdan/sh) to provide the equivalent of the _bash_ shell.
- When it is possible, use the [template functions](https://taskfile.dev/usage/#gos-template-engine) instead of shell commands, because these will behave consistently across different environments.

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

To validate the Task files, use a YAML linter that supports JSON schema, such as [check-jsonschema](https://check-jsonschema.readthedocs.io/en/stable/index.html).

### Validating Task files with pre-commit

To validate Task files before you commit them to source control, add the [pre-commit hook for check-jsonschema](https://check-jsonschema.readthedocs.io/en/stable/precommit_usage.html) to the [pre-commit](https://pre-commit.com/) configuration for your project:

```yaml
- repo: https://github.com/python-jsonschema/check-jsonschema
  rev: 0.28.2
  hooks:
    - id: check-taskfile
```

### Testing a Task

To test a task, run it with the _--dry_ option:

```shell
task --dry TASK-NAME
```

## Resources

- [Using a task runner to help with context switching in software projects](https://www.caro.fyi/articles/just/)
