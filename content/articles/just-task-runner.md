+++
title = "Using the just Task Runner"
slug = "just-task-runner"
date = "2024-05-25T12:30:00+01:00"
description = "Using the just task runner"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

The [just](https://just.systems) tool is a task runner. It provides a consistent framework for working with sets of tasks, which may be written in any scripting language and can run on multiple platforms.

## How just Works

Each copy of _just_ is a single executable file, with versions for Linux, macOS and Windows. This executable is relatively small, about 6Mb for the 64-bit Linux version. It uses sets of tasks that are defined in plain-text files. You may write a task in any programming language that runs with an interpreter, such as UNIX shells, PowerShell, Python, JavaScript or Nu shell.

This means that you can add _just_ to any environment and use whichever scripting languages are available. If you define [multiple implementations of a task](https://just.systems/man/en/chapter_32.html#enabling-and-disabling-recipes180), _just_ runs the correct implementation for the current platform. It also provides other features for you to customise the behavior of tasks for different environments.

For example, you may use built-in [functions for just](https://just.systems/man/en/chapter_31.html) in your tasks. These functions include identifying the host environment, reading environment variables, generating UUIDs, calculating file checksums and formatting string inputs. These enable you to get consistent inputs for your tasks across different platforms, even if the scripting language that you use does not have these features.

> **Terms:** In _just_, tasks are referred to as **recipes**. The text files that contain recipes are known as **justfiles**.

You do not need to set up or configure _just_, because it only requires a copy of the executable, and has no configuration files apart from the files that contain the recipes. Here is an example of a _justfile_:

```just
# Recipes for Hugo
#
# https://gohugo.io/

# Build Website
build:
    @hugo

# Remove generated files
clean:
    #!/usr/bin/env sh
    set -eu
    HUGO_TEMP_PATHS=".hugo_build.lock public"
    echo "Removing temporary files for Hugo..."
    for HUGO_TEMP_PATH in $HUGO_TEMP_PATHS
    do
      rm -fr $HUGO_TEMP_PATH
      echo "Removed $HUGO_TEMP_PATH"
    done

# Deploy Website
deploy: build
    @hugo deploy

# Run Website in development server
serve:
    @hugo server
```

The behaviour of _just_ is covered by a [backwards compatibility guarantee](https://just.systems/man/en/chapter_9.html). To verify that new versions of _just_ do not break compatibility, the _just_ project maintain automation to test against _justfiles_ that are published as Open Source.

## Installing just

Consider using a tool version manager like [mise](https://mise.jdx.dev/), [asdf](https://asdf-vm.com) or [a Dev Container feature](https://code.visualstudio.com/docs/devcontainers/containers#_dev-container-features) to download and install _just_. These can install any version of _just_ that is required, including the latest, because they download executables from GitHub.

For example, this command installs the latest version of _just_ with _mise_:

```shell
mise use -gy just
```

If you do not wish to use a tool version manager, see the section below for how to install _just_ with a script.

If possible, avoid using operating system packages. These are likely to provide older versions of _just_.

### Adding just to a Dev Container

If you are using a Visual Studio Code Dev Container, you can add the feature [guiyomh/features/just](https://github.com/guiyomh/features/tree/main/src/just) to your _devcontainer.json_ file to download _just_ from GitHub:

```json
    "features": {
        "ghcr.io/guiyomh/features/just:0": {
            "version": "1.26.0"
        }
    }
```

### Installing just with a Script

The _just_ project provide a [script for downloading just from GitHub](https://just.systems/man/en/chapter_5.html). You may either fetch this installation script each time, as the documentation describes, or save it. To ensure that container image builds are consistent, use a saved copy of the script when you build Docker container images.

To save the installation script:

```shell
curl -L https://just.systems/install.sh > scripts/install-just.sh
```

To use the installation script, call it with _--tag_ and _--to_ The _--tag_ specifies the version of _just_. The _--to_ specifies which directory to install it to:

```shell
./scripts/install-just.sh --tag 1.26.0 --to $HOME/.local/bin
```

### Installing just with Operating System Packages

If you do need to install _just_ with an operating system package manager, it is available for many popular systems. For example, these commands install _just_:

```shell
winget install --id Casey.Just --exact  # winget on Microsoft Windows
brew install just                       # Homebrew on macOS
sudo dnf install just                   # dnf on Fedora Linux
```

Debian includes [_just_ in the _testing_ distribution](https://packages.debian.org/trixie/just). Ubuntu provides [_just_ in 24.04 LTS](https://packages.ubuntu.com/noble/just).

See [the package list page](https://just.systems/man/en/chapter_4.html) for what is available from operating system package managers.

### Adding a Private Copy of just to a Project

The instructions that are provided in the previous sections install a copy of _just_ for a user or a system. To install a copy of _just_ that is private to a project, you have several options.

Rust and Node.js projects may use packages for _just_. To add _just_ to a Node.js project, use the [just-install](https://www.npmjs.com/package/just-install) npm package. To include _just_ in a Rust project, add [just](https://crates.io/crates/just) as a package in Cargo.

Finally, you can use the installation script to install a copy of _just_ into a directory within the project. If you do this, remember to exclude the path of the _just_ executable file from version control.

### Enabling Autocompletion

To enable autocompletion in a shell, use _--completions_ to generate a completion script that you install into the correct location. For example, to enable autocompletion for the Bash shell, run this command:

```bash
sudo su -c 'just --completions bash > /etc/bash_completion.d/just.bash'
```

To install autocompletion for the fish shell, use this command:

```fish
just --completions fish > ~/.config/fish/completions
```

Current versions of _just_ provide autocompletion for Bash, zsh, fish, PowerShell, elvish and Nu.

{{< alert >}}
**macOS and Homebrew:** If you install _just_ on macOS with Homebrew, follow [these instructions](https://just.systems/man/en/chapter_65.html) to  autocompletion for zsh.
{{< /alert >}}

### Enabling Visual Studio Code Integration

To use _just_ with Visual Studio Code, install the [nefrob.vscode-just-syntax](https://marketplace.visualstudio.com/items?itemName=nefrob.vscode-just-syntax) extension. This provides support for the _justfile_ syntax in Visual Studio Code.

{{< alert >}}
**Extension only provide syntax highlighting:** The Visual Studio Code extension currently only provides syntax highlighting.
{{< /alert >}}

## Creating a User justfile for Global Tasks

To define tasks that are available at any time, create a file with the name _.user.justfile_ in your home directory.

Create the first recipe in the root _justfile_ with the name _help_. Write _@just --list_ in the body of the recipe. When _just_ is invoked without the name of a recipe, it runs the first recipe in the _justfile_.

Here is an example of a user justfile:

```just
# List available recipes
help:
    @just --list -f "{{ home_directory() }}/.user.justfile"

# Display system information
system-info:
    @echo "CPU architecture: {{ arch() }}"
    @echo "Operating system type: {{ os_family() }}"
    @echo "Operating system: {{ os() }}"
    @echo "Home directory: {{ home_directory() }}"
```

This _justfile_ requires extra options to run. For convenience, add an alias to your shell configuration. For example, add these lines in _.config/fish/config.fish_ to enable an alias in the Fish shell:

```fish
# Add abbr to call recipes in user Justfile by typing ".j RECIPE-NAME"
if command -s just > /dev/null
    abbr --add .j just --justfile $HOME/.user.justfile --working-directory .
end
```

This means that you run a task in the _justfile_ by entering _.j_ followed by the name of the recipe:

```shell
.j system-info
```

To list the recipes in your user _justfile_, type _.j_ and press the _Enter_ key.

```shell
.j
```

## Using just in a Project

Use **just --init** to create a _justfile_ in the root directory of your project. You should always name the _just_ file in the root directory of the project _justfile_.

If a project only requires one small set of recipes, then use a single _justfile_. If you need to manage several sets of recipes, use multiple files.

You have two ways to organize the other _justfiles_ in a project:

1. Modules
2. Directory hierarchy

You can combine these approaches, but few projects will be complex enough to need to do this.

If you are starting a new project, consider using _just_ modules. Real-world projects often have multiple components with many tasks, and _just_ modules enable you to define clear namespaces for recipes. Modules also provide more flexibility for organizing the files that contain your recipes.

The modules feature is available in _just_ 1.19.0 and above, but it is currently _unstable_, which means that it is expected to work correctly, but it is not subject to the standard compatibility guarantees of _just_. This also means that you either need to set the environment variable _JUST_UNSTABLE_ as _true_, or use the _--unstable_ option when you run commands with _just_.

### Using Modules

If you decide to use _just_ modules in your project, consider following these guidelines:

- Create the first recipe in the root _justfile_ with the name _help_. Write _@just --list_ in the body of the recipe. When _just_ is invoked without a module or recipe name, it runs the first recipe in the _justfile_.
- Create an extra _mod.just_ file in each subdirectory that relates to a specific component or type of work. You may not need a separate module for every main subdirectory in the project.
- Create an extra _.just_ file in the root directory for each tool that applies to the entire project, such as pre-commit.
- Use the root _justfile_ to define standard tasks for the project. Each of these should call the relevant recipes in one or more modules. Avoid writing recipes in the _justfile_ that do anything other than running recipes that are defined in modules.
- Remember that the first recipe in each _mod.just_ file is the default for the module. This means that the first recipe runs when a user types the module without specifying the name of the task.
- Specify the [no-cd attribute](https://just.systems/man/en/chapter_32.html#disabling-changing-directory190) on each recipe in a module, so that the working directory of the recipe is the root directory of the project.

### Example justfile for a Project

```just
mod precommit  # Defined by pre-commit.just file in root directory
mod python  # Defined by mod.just file in python/ directory

# List available recipes
help:
    @just --unstable --list

# Install tools and dependencies, then set up environment for development
bootstrap:
    @just --unstable install
    @just --unstable setup

# Build artifacts
build:
    @just --unstable python::build

# Install project tools and dependencies
install:
    @just --unstable python::install

# Run all checks
lint:
    @just --unstable pre-commit::check

# Set up environment for development
setup:
    @just --unstable python::setup
    @just --unstable pre-commit::setup
```

Note that the first recipe in this file is _help_, so this command runs that recipe:

```shell
just
```

### Example just Module for a Project

```just
# Check the project with pre-commit
check:
    @pre-commit run --all-files

# Run a specific pre-commit check on the project
run hook-id:
    @pre-commit run "{{ hook-id }}" --all-files

# Setup pre-commit for use
setup:
    @pre-commit install
```

Note that the first recipe in this file is _check_, so this command runs that recipe:

```shell
just pre-commit
```

### Using a Hierarchy of justfiles

If you decide not to use modules, consider following these guidelines:

- Create the first recipe in the root _justfile_ with the name _help_. Write _@just --list_ in the body of the recipe. When _just_ is invoked without the name of a recipe, it runs the first recipe in the _justfile_.
- Create an extra _justfile_ in each subdirectory that should be a separate scope of operations. For example, if you have a monorepo, create a child _justfile_ in the main directory for each component.
- Set _fallback_ to _true_ in each _justfile_ that is NOT in the root directory of the project. This enables _just_ to find recipes from the root _justfile_ as well as the _justfile_ in the current working directory.
- If you have many recipes for a single _justfile_, consider putting the recipes into several _.just_ files and using [imports](https://just.systems/man/en/chapter_53.html) to combine them.
- To ensure that you do not accidentally run a recipe from a user _justfile_, do NOT set _fallback_ to _true_ in a _justfile_ in the root directory of a project.
- To create namespaces for recipes, decide a standard prefix for each group of recipes, and set the name of each recipe to start with that prefix, e.g. _sys-_.
- Use the [no-cd attribute](https://just.systems/man/en/chapter_32.html#disabling-changing-directory190) to define recipes that may be executed in one of several different possible directories. By default _just_ sets the working directory to be the location of the _justfile_ that contains the recipe.

## Writing justfiles

### Formatting justfiles

Follow these guidelines when writing _justfiles_ and _mod.just_ modules:

- Use 4 spaces for indentation. The built-in formatting command sets indentation as 4 spaces.
- Always put a comment in the line above each recipe. These comments appear next to the recipe in _just --list_.
- Use **--fmt** to format your _justfiles_. To use this option, run this command in the same directory as the _justfile_ that you want to format:

```shell
just --unstable --fmt
```

> **--fmt is Currently Unstable:** The **--fmt** subcommand is _unstable_, which means that it is expected to work correctly, but it is not subject to the standard compatibility guarantees of _just_.

### Writing Recipes

Follow these guidelines when writing recipes:

- Use [parameters](https://just.systems/man/en/chapter_38.html) to get inputs for a recipe from the command-line.
- Use [dotenv files](https://just.systems/man/en/chapter_26.html#dotenv-settings) to get configuration from files.
- Remember to use POSIX shell (_sh_) syntax for single-line recipes. By default, _just_ uses the _sh_ shell on the system.
- When it is possible, use the [built-in functions](https://just.systems/man/en/chapter_31.html) instead of shell commands, because these will behave consistently across different environments.
- Use [shebang recipes](https://just.systems/man/en/chapter_41.html) for multi-line shell recipes, as well as recipes in other languages.
- If you need the features of a specific UNIX shell, use a shebang recipe. Set [error handling for recipes that use bash](https://just.systems/man/en/chapter_42.html).
- Use [quotes around arguments](https://just.systems/man/en/chapter_59.html#quoting) to ensure that _just_ can identify mistakes.

### More Examples of justfiles

The GitHub project for _just_ includes [example justfiles](https://github.com/casey/just/tree/master/examples).

## Running just Recipes

To run a recipe in a _justfile_, enter _just_ followed by the name of the recipe:

```shell
just example-recipe
```

If a recipe accepts [parameters](https://just.systems/man/en/chapter_38.html), add the value for the parameter to the command:

```shell
just example-recipe my-parameter-value
```

You may always [override a variable](https://just.systems/man/en/chapter_36.html) by specifying a value with the _just_ command:

```shell
just example-recipe my-var=my-var-value
```

## Checking justfiles

To validate a _justfile_, run **--fmt** with **--check**. This returns an exit code of 0 if the _justfile_ is formatted correctly. If the _justfile_ is not correctly formatted, it returns an exit code of 1 and prints a diff.

```shell
just --unstable --fmt --check
```

> **--fmt is Currently Unstable:** The **--fmt** subcommand is _unstable_, which means that it is expected to work correctly, but it is not subject to the standard compatibility guarantees of _just_.

You may also use these two options to check the behavior of _just_:

- **-n, --dry-run** - Prints what _just_ would do without doing it
- **--evaluate** - Evaluates and prints all of the variables. If a variable name is given as an argument, it only prints the value of that variable.

## Resources

- [Using a task runner to help with context switching in software projects](https://www.caro.fyi/articles/just/)
- [Just use just](https://toniogela.dev/just/) - An introductory article to Just
- [Cheatsheet for justfile](https://cheatography.com/linux-china/cheat-sheets/justfile/)
