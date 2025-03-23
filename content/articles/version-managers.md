+++
title = "Version Managers"
slug = "version-managers"
date = "2025-03-23T02:54:00+00:00"
description = "Using version managers"
categories = ["automation", "devops", "programming", "python"]
tags = ["automation", "devops", "golang", "linux", "macos", "javascript", "python"]

+++

Avoid installing stand-alone packages for tools and programming languages. Instead, use version manager tools. These enable you to use the correct version of the required tools and dependencies for each of your projects. The version manager can download all of the versions of a product that your projects need, and switch the active version as you move between projects.

## mise-en-place

[mise-en-place](https://mise.jdx.dev/) (_mise_) is one of the most powerful version managers. It supports a wide range of popular programming languages and tools. This means that you can set the expected versions of all of the languages and tools for a project through a single mise configuration file.

In fact, mise is a tool for managing your projects. It can also define [environment variables](https://mise.jdx.dev/environments/) and act as a [task runner](https://mise.jdx.dev/tasks/) as well as handling tool versions for a project. In addition, current versions of mise include experimental support for [managing Git pre-commit hooks](https://mise.jdx.dev/cli/generate/git-pre-commit.html).

If you work in a team, you may decide that other version managers are more suitable for your projects. Contributors to your projects may prefer to use tools that they are already familiar with, or certain tools and processes may be required by the policies of your organization.

You may also decide not to use mise in environments where security is an important concern. It uses a range of plugins to install and update tools, including [plugins for asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html). The mise project is migrating away from asdf plugins, but you might choose to avoid the tool until this work is complete.

If you decide not to use mise, later sections explain other version managers that are available for [programming languages](#version-managers-for-programming-languages) and [OpenTofu or Terraform](#tenv-version-manager-for-terraform-and-opentofu).

## Setting Up Version Managers

Consider using [Homebrew](http://brew.sh/) to install version manager tools on your development systems for macOS and Linux. Homebrew enables you to update the version managers and other development tools on the system with minimal effort.

For example, to install the [rustup](https://rustup.rs/) version manager for Rust and the [pyenv](https://github.com/pyenv/pyenv) version manager for Python with Homebrew, run these commands in a terminal window:

```shell
brew install rustup
brew install pyenv
```

Update your version managers regularly, to ensure that they can access the latest versions of the tools that they manage. If you install version managers with Homebrew, you can update all of the version managers and other tools that you use at the same time, rather than needing to upgrade each one separately. These commands will upgrade all of the tools that Homebrew manages:

```shell
brew update
brew upgrade
```

> Avoid using Homebrew itself to install programming languages. Homebrew has limited support for working with multiple versions of the same programming language.

If you need to use Microsoft Windows, check the documentation of a version manager before you install it. Some version managers only support UNIX-based systems, or have features that cannot work on Microsoft Windows.

### Installation Options for mise-en-place

The mise project offers [many installation options](https://mise.jdx.dev/installing-mise.html), including Homebrew and packages for most popular operating systems. Consider using Homebrew for macOS and Linux development systems, and Scoop or Winget for Windows development systems.

The mise tool itself is a single executable file that is written in Rust. This means that you can use it in any environment. The project provides specific support for adding mise to [continuous integration systems](https://mise.jdx.dev/continuous-integration.html). If necessary, you can use [a shell script](https://mise.jdx.dev/installing-mise.html#https-mise-run) to install it on Linux and macOS systems.

> Some mise plugins and features require a UNIX-based system, which means that they will not work on Microsoft Windows. Where possible, mise provides cross-platform alternatives.

Regardless of how you install it, [mise requires extra tools to verify downloads](https://mise.jdx.dev/tips-and-tricks.html#software-verification). Install GPG with the same method that you use to install mise, and then use mise to install _cosign_ and _slsa-verifier_.

Consider using the [paranoid](https://mise.jdx.dev/paranoid.html) mode when you set up mise on development systems. This reduces the risk of a developer adding unsafe values to the mise configuration for a project.

> If you added mise to a development system without using Homebrew or a package manager, use the [self-update feature](https://mise.jdx.dev/cli/self-update.html#mise-self-update) to upgrade it.

### Other Requirements for Version Managers

When you use a version manager for Python or JavaScript, you also need to install compiler tools for the C programming language. Installations of Python, Node.js and other interpreted languages compile components that are written in C.

To install a compiler on macOS, use the Command-line Tools package for [Xcode](https://developer.apple.com/xcode/resources/). On Linux, we use the GCC compiler, because it is compatible with the widest range of C code. If you are developing your own C code on Linux, consider using the [Clang](https://clang.llvm.org/) compiler for your project.

Run this command to install GCC and other compiler tools on Debian-based distributions, such as Ubuntu:

```shell
sudo apt install build-essential
```

Run this command to install just GCC on Red Hat-based distributions, such as Fedora:

```shell
sudo dnf install gcc
```

## Version Managers for Programming Languages

These are popular specialized version managers for programming languages:

- The standard _go_ tool [manages versions of Go](https://go.dev/doc/manage-install#installing-multiple).
- [jEnv](https://www.jenv.be/) for Java
- [nvm](https://github.com/nvm-sh/nvm) for Node.js
- [pyenv](https://github.com/pyenv/pyenv) for Python
- [rustup](https://rustup.rs/) for Rust

I suggest using [mise](https://mise.jdx.dev/) when you work with JavaScript if possible, as it provides a consistent set of features for managing many JavaScript tools, including Node.js, Deno and Bun.

If you do not want to use mise, consider [Volta](https://volta.sh/) as an alternative to nvm for Node.js. Volta is a cross-platform tool, whilst nvm is a Bash shell script for UNIX-based systems.

The [Ruby on Rails Guides](https://guides.rubyonrails.org/) recommend mise for Rails projects.

## Version Managers and Python

### Installing Python with a Version Manager

Whichever version manager tool you use, ensure that it compiles each version of Python that it installs, rather than downloading [standalone builds](https://gregoryszorc.com/docs/python-build-standalone/main/). These standalone builds are modified versions of Python that are maintained by [Astral](https://astral.sh/), not the Python project.

Both pyenv and mise use [python-build](https://github.com/pyenv/pyenv/tree/master/plugins/python-build) to compile Python. This means that you can use either tool. The pyenv tool automatically compiles Python, but you must [change the mise configuration](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries) to use compilation.

> Only use the Python installation features of [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) and [Hatch](https://hatch.pypa.io) for experimental projects. These project tools always download third-party standalone builds of Python when a user requests a Python version that is not already installed on the system.

### Version Managers and Python Virtual Environments

You should use a project tool like [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) or [Hatch](https://hatch.pypa.io) to develop your projects. These manage Python virtual environments for you.

Both pyenv and mise also support automatic switching between Python virtual environments. Support for creating and switching between virtual environments is [built-in to mise](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation). The [pyenv](https://github.com/pyenv/pyenv) version manager supports virtual environments with the [virtualenv plugin](https://github.com/pyenv/pyenv-virtualenv).

Only use the version manager to handle Python virtual environments if you are not using a project tool. Otherwise, use your chosen Python project tool to handle virtual environments.

Current versions of mise can [integrate with uv](https://mise.jdx.dev/mise-cookbook/python.html#mise-uv), so that there are no conflicts between the tools.

## tenv: Version Manager for Terraform and OpenTofu

Use the [tenv](https://tofuutils.github.io/tenv/) version manager to install versions of [OpenTofu](https://opentofu.org/) and [Terraform](https://www.terraform.io/). It can also manage [Atmos](https://atmos.tools/) and [Terragrunt](https://terragrunt.gruntwork.io/).

To install _tenv_ with Homebrew, run this command in a terminal window:

```shell
brew install tenv cosign
```

Always install _cosign_ along with _tenv_. If _cosign_ is present, _tenv_ automatically uses it to carry out signature verification on the binaries that it downloads.
