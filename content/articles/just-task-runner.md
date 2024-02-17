+++
title = "Using the just Task Runner"
slug = "just-task-runner"
date = "2024-02-17T11:20:00+00:00"
description = "Using the just task runner"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

The [just](https://just.systems) tool is a task runner. It provides a consistent means of organizing sets of tasks, which may be written in any scripting language and may run on multiple platforms.

## More on just

Each copy of _just_ is a single executable file, with versions for Linux, macOS and Windows. This executable is relatively small, being about 6Mb for the 64-bit Linux version. It works with set of tasks that are written in plain-text files, which are called _justfiles_.

The tasks are referred to as _recipes_. The code for a recipe may be written in any programming language that runs with an interpreter. You may write recipes for any combination of languages in the same _justfile_. This enables you to use whichever scripting languages are available in the environment, such as UNIX shell, PowerShell, Python, JavaScript or Nu.

_just_ enables you to provide [alternative implementations of a task](https://just.systems/man/en/chapter_32.html#enabling-and-disabling-recipes180) in the same set of recipes to support different platforms, and also customise the behavior of recipes for different environments. Built-in [functions](https://just.systems/man/en/chapter_31.html) provide consistent inputs across platforms. These functions include identifying the host environment, reading environment variables, generating UUIDs, calculating file checksums and formatting string inputs.

The behaviour of _just_ is covered by a [backwards compatibility guarantee](https://just.systems/man/en/chapter_9.html). To verify that new versions of _just_ do not break compatibility, the _just_ project maintain automation to test against _justfiles_ that are published as Open Source.

## Installing just

_just_ is available from the popular operating system package managers, apart from Debian and Ubuntu. For example:

```shell
winget install --id Casey.Just --exact  # winget on Windows
brew install just                       # Homebrew on macOS
sudo dnf install just                   # Fedora
```

These operating system packages may not provide the latest version of _just_. See [the package list page](https://just.systems/man/en/chapter_4.html) for what is available from operating system package managers.

To install the latest version of _just_, download the executable from GitHub, rather than use an operating system package manager. The _just_ project provides [a script for downloading just from GitHub](https://just.systems/man/en/chapter_5.html).

You may either fetch the installation script each time, as the documentation describes, or save it. To ensure that container image builds are consistent, use a saved copy of the script when you build Docker container images.

To save the installation script:

```shell
curl -L https://just.systems/install.sh > scripts/install-just.sh
```

To use the installation script, call it with _--tag_ to specify the version of _just_ and _--to_ to specify which directory to install it to:

```shell
./scripts/install-just.sh --tag 1.24.0 --to $HOME/.local/bin
```

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

> _macOS and Homebrew:_ If you install _just_ on macOS with Homebrew, follow [these instructions](https://just.systems/man/en/chapter_65.html) to  autocompletion for zsh.

## Using just in a Project

### Creating justfiles in a Project

Use **just --init** to create a _justfile_ in the root directory of your project. Use this _justfile_ for tasks that apply to the entire project. You may create other _justfiles_ in subdirectories for tasks that are more specific. For example, you might create a _justfile_ in a _tests/_ subdirectory of your project for tasks that are specifically for testing.

### Adding a Private Copy of just to a Project

The instructions that are provided in the previous section install a copy of _just_ that is shared. To install a copy of _just_ that is private to a project, you have several options. Rust and Node.js projects may use packages for _just_. You may also install _just_ in Docker container images for any project, using either operating system packages or a setup script, as described in the previous section.

To add _just_ to a Node.js project, use the [just-install](https://www.npmjs.com/package/just-install) npm package. To include _just_ in a Rust project, add [just](https://crates.io/crates/just) as a package in Cargo.

## Creating a User justfile for Global Tasks

To define tasks that are available at any time, create a file with the name _.user.justfile_ in your home directory.

```just
# List available recipes
default:
    @just --list -f "$HOME/.user.justfile"

# Display System information
sys-info:
    @echo "CPU Architecture: {{ arch() }}"
    @echo "OS Type: {{ os_family() }}"
    @echo "OS: {{ os() }}"
```

This _justfile_ requires extra options to run. For convenience, add an alias to your shell configuration. For example, add these lines in _.config/fish/config.fish_ to enable an alias in the Fish shell:

```fish
# Add abbr to call recipes in user Justfile by typing ".j RECIPE-NAME"
if test -x "$HOME/.local/bin/just"
    abbr --add .j just --justfile $HOME/.user.justfile --working-directory .
end
```

This means that you may run a task by entering _.j_ followed by the name of the recipe:

```shell
.j sys-info
```

To list the recipes in your user _justfile_, type _.j_ and press the _Enter_ key.

```shell
.j
```

## Developing just

### Writing justfiles

- For your user recipes file, use the standard name _.user.justfile_.
- Use 4 spaces for indentation. The built-in formatting command sets identation as 4 spaces.
- Always put a comment in the line above each recipe. These comments appear next to the recipe in _just --list_.
- Each _justfile_ should have the first recipe named _default_. When _just_ is invoked without a recipe name, it runs the first recipe in the _justfile_.
- To create namespaces for recipes, decide a standard prefix for each group of recipes, and set the name of each recipe to start with that recipe.
- Use [dotenv files](https://just.systems/man/en/chapter_26.html#dotenv-settings) to get configuration from files.
- Use **--fmt** to format your _justfiles_. To use this option, run this command in the same directory as the _justfile_ that you want to format:

```shell
just --unstable --fmt
```

> _**fmt** is Currently Unstable:_ The **fmt** subcommand is _unstable_, which means that it is expected to work correctly, but it is not subject to the standard compatibility guarantees of _just_.

### Writing justfiles in Projects

- Name the _just_ file in the root directory of the project _justfile_.
- Create an extra _justfile_ in each subdirectory that should be a separate scope of operations. For example, if you have a monorepo, create a child _justfile_ in the main directory for each component.
- Set _fallback_ to _true_ in each _justfile_ that is NOT in the root directory of the project. This enables _just_ to find recipes from the root _justfile_ as well as the _justfile_ in the current working directory.
- If you have many recipes for a single _justfile_, consider putting the recipes into several _.just_ files and using [imports](https://just.systems/man/en/chapter_53.html) to combine them.
- To ensure that you do not accidentally run a recipe from a user _justfile_, do NOT set _fallback_ to _true_ in a _justfile_ in the root directory of a project.
- To ensure that a project uses the version of _just_ that you expect, use containers or a copy of _just_ that is for that project, rather than relying on a system installation of _just_.

### Writing Recipes

- When it is possible, use the [built-in functions](https://just.systems/man/en/chapter_31.html) instead of shell commands, because these will behave consistently across different environments.
- Use [shebang recipes](https://just.systems/man/en/chapter_41.html) for multi-line shell recipes, as well as recipes in other languages.
- Use _sh_ syntax for single-line UNIX shell recipes. If you need the features of a specific shell, use a shebang recipe and [set error handling for recipes that use bash](https://just.systems/man/en/chapter_42.html).
- Use [quotes around arguments](https://just.systems/man/en/chapter_59.html#quoting) to ensure that _just_ can identify mistakes.
- Use the [no-cd annotation](https://just.systems/man/en/chapter_32.html#disabling-changing-directory190) to define recipes that may be executed in one of several different possible directories. By default _just_ sets the working directory to be the location of the _justfile_.

### Example justfiles

A minimal _justfile_:

```just
# List available recipes
default:
    @just --list
```

A larger project _justfile_:

```just
# Load variables from a .env file
set dotenv-load := true

# List available recipes
default:
    @just --list

# Show system information
sys-info:
    @echo "CPU Architecture: {{ arch() }}"
    @echo "OS Type: {{ os_family() }}"
    @echo "OS: {{ os() }}"
```

> The GitHub project for _just_ includes [example justfiles](https://github.com/casey/just/tree/master/examples).

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

> _**fmt** is Currently Unstable:_ The **fmt** subcommand is _unstable_, which means that it is expected to work correctly, but it is not subject to the standard compatibility guarantees of _just_.

You may also use these two options to check the behavior of _just_:

- **-n, --dry-run** - Prints what _just_ would do without doing it
- **--evaluate** - Evaluates and prints all of the variables. If a variable name is given as an argument, it only prints the value of that variable.

## Resources

- [Using a task runner to help with context switching in software projects](https://www.caro.fyi/articles/just/)
- [Just use just](https://toniogela.dev/just/) - An introductory article to Just
- [Cheatsheet for justfile](https://cheatography.com/linux-china/cheat-sheets/justfile/)
