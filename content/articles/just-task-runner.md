+++
title = "Shared Tooling for Diverse Systems with just"
slug = "just-task-runner"
date = "2025-09-06T15:41:00+01:00"
description = "Using the just task runner"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

The [just](https://just.systems) tool provides a consistent framework for working with sets of tasks, which may be written in any scripting language and can run on all of the popular operating systems.

Add _just_ to your projects when you need to provide task definitions that must run on many environments, especially when you do not manage the systems that the tasks are run on. The [wide range of installation methods](#installing-just), support for multiple languages and the [backwards compatibility guarantee](#the-backwards-compatibility-guarantee) allow you to support large numbers of very different systems.

If you are maintaining project tooling for teams within an organization, you might also consider [Task](https://www.stuartellis.name/articles/task-runner/). Task runs tasks with a built-in shell interpreter and uses a published YAML schema for the task definitions. These features enable you to maintain and validate tasks with standard tools, and also ensure that the tasks have consistent behavior on each system. However, they also mean that you need to manage the versions of Task that are in use.

## How just Works

Each copy of _just_ is a single executable file, with versions for Linux, macOS, Windows and FreeBSD. This executable is relatively small, about 5Mb for the 64-bit Linux version. It uses sets of tasks that are defined in plain-text files. You may write each task in any programming language that runs with an interpreter, such as UNIX shells, PowerShell, Python, JavaScript or Nu shell.

This means that you can add _just_ to any environment and use whichever scripting languages are available. If you define [multiple implementations of a task](https://just.systems/man/en/attributes.html?highlight=disabl#enabling-and-disabling-recipes180), _just_ runs the correct implementation for the current platform. It also provides other features for you to customise the behavior of tasks for different environments.

For example, you may use built-in [functions for just](https://just.systems/man/en/functions.html) in your tasks. These functions include identifying the host environment, reading environment variables, generating UUIDs, calculating file checksums and formatting string inputs. These enable you to get consistent inputs for your tasks across different platforms, even if the scripting language that you use does not have these features.

> **Terms:** In _just_, tasks are referred to as **recipes**. The text files that contain recipes are known as **justfiles**.

You do not need to set up or configure _just_. It only requires a copy of the executable, and has no configuration files apart from the files that contain the recipes. Here is an example of a _justfile_:

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

> You can run recipes [in parallel](https://just.systems/man/en/parallelism.html) when it makes sense to do so.

### The Backwards Compatibility Guarantee

The behaviour of _just_ is covered by a [backwards compatibility guarantee](https://just.systems/man/en/backwards-compatibility.html). This means that new versions of _just_ will not introduce backwards incompatible changes that break existing _justfiles_. New features are only available when you use the _unstable_ flag, until it can be guaranteed that they will not change. To verify that new versions of _just_ do not break compatibility, the _just_ project maintain automation to test against _justfiles_ that are published as Open Source.

These decisions enable _just_ to be an evergreen tool. Project maintainers simply decide the minimum version of _just_ that they will require. Users can install and update their copies of _just_ with whatever method they prefer, as long as it provides versions that is more recent than the minimum version that is required by the project.

## Installing just

If possible, use a tool that enables you to specify which versions of _just_ to install. This means that you can install the most recent version of _just_ that is available. You can use [Python tools](#installing-just-with-python-tools), [Rust and Node.js packages](#adding-a-copy-of-just-to-a-project), a tool version manager like [mise](#installing-just-with-mise), or [the feature for Dev Containers](#adding-just-to-a-dev-container).

If you do not wish to use a tool, see the section on [how to install _just_ with a script](#installing-just-with-a-script).

These methods also enable you to either add a copy of _just_ to a specific project, or install _just_ into a user account so that it is available for all of your work. If you install a copy of _just_ into a user account you can [integrate it with your shell](#integrating-just-with-your-shell).

> Consider using the [Python](#installing-just-with-python-tools) or Rust tools to install _just_. The Python and Rust packages contain a copy of the _just_ executable, and can be distributed from private package repositories. Other tools may download files from GitHub.

You can also install _just_ with [operating system packages](#installing-just-with-operating-system-packages). These packages may provide older versions of _just_.

### Installing just with Python Tools

If you use Python, you can install _just_ into your user account with your existing tools. It is available on the Python Package Index as [rust-just](https://pypi.org/project/rust-just/).

To install _just_ with [uv](https://docs.astral.sh/uv/), run this command:

```shell
uv tool install rust-just==1.46.0
```

To install _just_ with [pipx](https://pipx.pypa.io), run this command:

```shell
pipx install rust-just==1.46.0
```

### Installing just with mise

This command installs version 1.46.0 of _just_ with [mise](https://mise.jdx.dev/) and makes it available to your user account:

```shell
mise use -gy just@1.46.0
```

You can also use _mise_ to specify alternate versions of _just_ for specific projects, in the same ways that it manages other tools.

### Adding just to a Dev Container

If you are using a Visual Studio Code Dev Container, you can add the feature [guiyomh/features/just](https://github.com/guiyomh/features/tree/main/src/just) to your _devcontainer.json_ file to download _just_ from GitHub:

```json
    "features": {
        "ghcr.io/guiyomh/features/just:0": {
            "version": "1.46.0"
        }
    }
```

### Adding a Copy of just to a Project

Python, Rust and Node.js projects may use packages for _just_:

- Node.js: Use the [just-install](https://www.npmjs.com/package/just-install) npm package
- Python: Use the [rust-just](https://pypi.org/project/rust-just/) package
- Rust: To include _just_ in a Rust project, add [just](https://crates.io/crates/just) as a package in Cargo.

If necessary, you can use the [installation script](#installing-just-with-a-script) to download a copy of _just_ into a directory within the project. If you do this, remember to exclude the path of the _just_ executable file from version control.

### Installing just with a Script

The _just_ project provide a [script for downloading just from GitHub](https://just.systems/man/en/pre-built-binaries.html). You may either fetch this installation script each time, as the documentation describes, or save it. To ensure that container image builds are consistent, use a saved copy of the script when you build Docker container images.

To save the installation script:

```shell
curl -L https://just.systems/install.sh > scripts/install-just.sh
```

To use the installation script, call it with _--tag_ and _--to_ The _--tag_ specifies the version of _just_. The _--to_ specifies which directory to install it to:

```shell
./scripts/install-just.sh --tag 1.46.0 --to $HOME/.local/bin
```

### Installing just with Homebrew

You can install _just_ with Homebrew on macOS and Linux. This command installs _just_ with [Homebrew](https://brew.sh/) and makes it available to your user account:

```shell
brew install just
```

This will install the most recent version of _just_ that is known to Homebrew.

### Installing just with Operating System Packages

You can install _just_ with an operating system package manager, if necessary. For example, these commands install _just_:

```shell
winget install --id Casey.Just --exact  # winget on Microsoft Windows
sudo dnf install just                   # dnf on Fedora Linux
sudo apt install just                   # apt on Debian and Ubuntu
```

To install Task on Alpine Linux, you need to use the _community_ package repository:

```shell
doas apk add go-task --repository=http://dl-cdn.alpinelinux.org/alpine/latest-stable/community/
```

> See [the package list page](https://just.systems/man/en/packages.html) for a list of the available operating system packages.

## Integrating just with Your Shell

If you install a copy of _just_ into a user account you can integrate with your shell to enable autocompletion and a global set of of tasks.

### Enabling Shell Autocompletion

To enable autocompletion in a shell, use _--completions_ to generate a completion script that you install into the correct location. For example, to install autocompletion for the fish shell, use this command:

```fish
just --completions fish > ~/.config/fish/completions/just.fish
```

To enable autocompletion for the Bash shell, run this command:

```bash
mkdir -p $HOME/.local/share/bash-completion && just --completions bash > $HOME/.local/share/bash-completion/just.bash
```

Current versions of _just_ provide autocompletion for Bash, zsh, fish, PowerShell, elvish and Nu.

{{< alert >}}
**macOS and Homebrew:** If you install _just_ on macOS with Homebrew, follow [these instructions](https://just.systems/man/en/shell-completion-scripts.html?highlight=homebrew#shell-completion-scripts) for autocompletion with zsh.
{{< /alert >}}

### Creating a User justfile for Global Tasks

If you install _just_ into a user account, you can define a set of recipes that are available at any time. Create a file with the name _.user.justfile_ in your home directory to store these recipes.

Add the first recipe in the root _justfile_ with the name _help_. Write _@just --list_ in the body of the recipe.

Here is an example of a user justfile:

```just
# List available recipes
help:
    @just --list -f "{{ justfile() }}"

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

> When _just_ is invoked without the name of a recipe, it runs the [default recipe](https://just.systems/man/en/the-default-recipe.html) or the first recipe in the _justfile_.

## Integrating just with Other Tools

### Enabling Visual Studio Code Integration

The [nefrob.vscode-just-syntax](https://marketplace.visualstudio.com/items?itemName=nefrob.vscode-just-syntax) extension provides support for _justfiles_ in Visual Studio Code. This extension currently only provides syntax highlighting.

### Enabling Integration with JetBrains IDEs

To enable support for _just_ in JetBrains IDEs such as PyCharm, install the [Just](https://plugins.jetbrains.com/plugin/18658-just) plugin.

## Using just in a Project

Use **just --init** to create a _justfile_ in the root directory of your project. You should always name the _just_ file in the root directory of the project _justfile_.

If a project only requires one small set of recipes, then use a single _justfile_.

If you need to manage several sets of recipes, use multiple files.

### Registering justfiles for EditorConfig

To ensure that [EditorConfig](https://editorconfig.org/) correctly manages the format of files for _just_, add this to the _.editorconfig_ file in your project:

```toml
[{justfile, *.just}]
indent_style = space
indent_size = 4
```

### Multiple justfiles in a Project

When you need to have multiple _justfiles_ in a project, you have two ways to organize them:

1. [Modules](#using-modules)
2. [Directory structure](#multiple-justfiles-in-a-directory-structure)

You can combine these approaches, but few projects will be complex enough to need to do this.

If you are starting a new project, consider using _just_ modules. Real-world projects often have multiple components with many tasks, and _just_ modules enable you to define clear namespaces for recipes. Modules also provide more flexibility for organizing the files that contain your recipes. A [later section](#using-modules) in this article explains how to use modules.

> _Use just 1.31.0 or later with modules:_ The modules feature became available by default with _just_ 1.31.0.

The project directory structure approach means that you create a _justfile_ in the root directory of the project, and then create an extra _justfile_ in each sub-directory that relates to a separate area of work. You then enable _fallback_ in the _justfiles_ in subdirectories. Users change working directories to get different recipes from the nearest _justfile_, and if they specify a recipe that is not defined in the nearest _justfile_, then _just_ will try _justfiles_ in parent directories. The [section on directory structures](#multiple-justfiles-in-a-directory-structure) explains how to use multiple _justfiles_ in a directory structure.

## Writing justfiles

### Formatting justfiles

Follow these guidelines when writing _justfiles_ and _mod.just_ modules:

- Use 4 spaces for indentation. The built-in formatting command sets indentation as 4 spaces.
- Always put a comment in the line above each recipe. These comments appear next to the recipe in the output of _--list_.
- Use **--fmt** to format your _justfiles_. To use this option, run this command in the same directory as the _justfile_ that you want to format:

```shell
just --unstable --fmt
```

> **--fmt is Currently Unstable:** The **--fmt** subcommand is _unstable_, which means that it is expected to work correctly, but it is not subject to the standard compatibility guarantees of _just_.

### Writing Recipes

Follow these guidelines when writing recipes:

- Set a [default recipe](https://just.systems/man/en/the-default-recipe.html). When _just_ is invoked without the name of a recipe, it runs the default recipe. If there no default recipe, it will run the first recipe in the _justfile_.
- Use [parameters](https://just.systems/man/en/recipe-parameters.html) to get inputs for a recipe from the command-line.
- Use [dotenv files](https://just.systems/man/en/settings.html#dotenv-settings) to get configuration from files.
- Remember to use POSIX shell (_sh_) syntax for single-line recipes. By default, _just_ uses the _sh_ shell on the system.
- When it is possible, use the [built-in functions](https://just.systems/man/en/functions.html) instead of shell commands, because these will behave consistently across different environments.
- Use [shebang recipes](https://just.systems/man/en/shebang-recipes.html) for multi-line shell recipes, as well as recipes in other languages.
- If you need the features of a specific UNIX shell, use a shebang recipe. Set [error handling for recipes that use bash](https://just.systems/man/en/safer-bash-shebang-recipes.html).
- Use [quotes around arguments](https://just.systems/man/en/avoiding-argument-splitting.html?highlight=quoting#quoting) to ensure that _just_ can identify mistakes.

### More Examples of justfiles

The GitHub project for _just_ includes [example justfiles](https://github.com/casey/just/tree/master/examples).

## Running just Recipes

To run a recipe in a _justfile_, enter _just_ followed by the name of the recipe:

```shell
just example-recipe
```

If a recipe accepts [parameters](https://just.systems/man/en/recipe-parameters.html), add the value for the parameter to the command:

```shell
just example-recipe my-parameter-value
```

You may always [override a variable](https://just.systems/man/en/setting-variables-from-the-command-line.html) by specifying a value with the _just_ command:

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

## Using Modules

If you decide to use _just_ modules in your project, consider following these guidelines:

- Create the first recipe in the root _justfile_ with the name _help_. Write _@just --list_ in the body of the recipe. When _just_ is invoked without a module or recipe name, it runs the first recipe in the _justfile_.
- Create an extra _mod.just_ file in each subdirectory that relates to a specific component or type of work. You may not need a separate module for every main subdirectory in the project.
- Create an extra _.just_ file in the root directory for each tool that applies to the entire project, such as pre-commit.
- Use the root _justfile_ to define standard tasks for the project. Each of these should call the relevant recipes in one or more modules. Avoid writing recipes in the _justfile_ that do anything other than running recipes that are defined in modules.
- Remember that the first recipe in each _mod.just_ file is the default for the module. This means that the first recipe runs when a user types the module without specifying the name of the task.
- Specify the [no-cd attribute](https://just.systems/man/en/working-directory.html) on each recipe in a module, so that the working directory of the recipe is the root directory of the project.

### Example justfile for a Project with Modules

```just
mod precommit  # Defined by pre-commit.just file in root directory
mod python  # Defined by mod.just file in python/ directory

# List available recipes
help:
    @just --list

# Install tools and dependencies, then set up environment for development
bootstrap:
    @just install
    @just setup

# Build artifacts
build:
    @just python::build

# Install project tools and dependencies
install:
    @just python::install

# Run all checks
lint:
    @just pre-commit::check

# Set up environment for development
setup:
    @just python::setup
    @just pre-commit::setup
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

## Multiple justfiles in a Directory Structure

If you use multiple _justfiles_ in a project, consider following these guidelines:

- Create the first recipe in the root _justfile_ with the name _help_. Write _@just --list_ in the body of the recipe. When _just_ is invoked without the name of a recipe, it runs the first recipe in the _justfile_.
- Create an extra _justfile_ in each subdirectory that should be a separate scope of operations. For example, if you have a monorepo, create a child _justfile_ in the main directory for each component.
- Set _fallback_ to _true_ in each _justfile_ that is NOT in the root directory of the project. This enables _just_ to find recipes from the root _justfile_ as well as the _justfile_ in the current working directory.
- If you have many recipes for a single _justfile_, consider putting the recipes into several _.just_ files and using [imports](https://just.systems/man/en/imports.html) to combine them.
- To ensure that you do not accidentally run a recipe from a user _justfile_, do NOT set _fallback_ to _true_ in a _justfile_ in the root directory of a project.
- To create namespaces for recipes, decide a standard prefix for each group of recipes, and set the name of each recipe to start with that prefix, e.g. _sys-_.
- Use the [no-cd attribute](https://just.systems/man/en/working-directory.html) to define recipes that may be executed in one of several different possible directories. By default _just_ sets the working directory to be the location of the _justfile_ that contains the recipe.

## Resources

- [Using a task runner to help with context switching in software projects](https://www.caro.fyi/articles/just/)
- [Just use just](https://toniogela.dev/just/) - An introductory article to Just
- [Cheatsheet for justfile](https://cheatography.com/linux-china/cheat-sheets/justfile/)
