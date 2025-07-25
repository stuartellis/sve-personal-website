+++
title = "Using Version Managers for Your Tools"
slug = "version-managers"
date = "2025-07-25T22:18:00+01:00"
description = "Using version managers"
categories = ["automation", "devops", "programming", "python"]
tags = ["automation", "devops", "golang", "linux", "macos", "javascript", "python"]
+++

Avoid installing stand-alone packages for tools and programming languages. Instead, use version manager tools. These enable you to use the correct version of the required tools and dependencies for each of your projects. A version manager can download all of the versions of a product that your projects need and switch the active version as you move between projects, as well as letting you set a default version.

Each popular programming language has a [specialized version manager](#version-managers-for-programming-languages). Alternatively, you can use [mise-en-place](https://www.stuartellis.name/articles/mise-en-place/) (_mise_), which supports wide range of popular programming languages and tools. This means that you can set the expected versions of all of the languages and tools for a project through a single mise configuration file.

> Avoid using mise in restricted environments. By design, mise can download and install a very wide range of software, and it will connect to multiple services on the public Internet, including GitHub.

## Specialized Version Managers

### Version Managers for Programming Languages

These are popular specialized version managers for programming languages:

- The standard _go_ tool [manages versions of Go](https://go.dev/doc/manage-install#installing-multiple).
- [jEnv](https://www.jenv.be/) for Java
- [fnm](https://github.com/Schniz/fnm) and [nvm](https://github.com/nvm-sh/nvm) for Node.js
- [pyenv](https://github.com/pyenv/pyenv) for Python
- [rustup](https://rustup.rs/) for Rust

> See the [section on Python](#version-managers-and-python) for more details about using version managers with Python.

If you are a Ruby developer, you may already use mise. The [Ruby on Rails Guides](https://guides.rubyonrails.org/) now recommend mise for Rails projects.

Some packages for JavaScript, Python and Ruby use Rust or C code. To support these packages, you may need to [install a compiler](#extra-requirements-for-version-managers).

### tenv: Version Manager for Terraform and OpenTofu

If you decide not to use mise, consider using [tenv](https://tofuutils.github.io/tenv/) to install versions of [OpenTofu](https://opentofu.org/) and [Terraform](https://www.terraform.io/). The tenv version manager also supports [Atmos](https://atmos.tools/) and [Terragrunt](https://terragrunt.gruntwork.io/).

> Install _cosign_ on systems that use _tenv_. OpenTofu binaries are then verified with _cosign_ when _tenv_ downloads them.

## Setting Up Version Managers on Developer Systems

Consider using [Homebrew](http://brew.sh/) to install version manager tools on your development systems for macOS and Linux. Homebrew enables you to update the version managers and other development tools on the system with minimal effort.

[WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/) and [Scoop](https://scoop.sh/) provide equivalents of Homebrew for Microsoft Windows. If you use Microsoft Windows, check the documentation of a version manager before you install it. Some version managers only support UNIX-based systems, or have features that cannot work on Microsoft Windows.

Homebrew can install all of the popular version manager tools. For example, to install the [rustup](https://rustup.rs/) version manager for Rust and the [pyenv](https://github.com/pyenv/pyenv) version manager for Python, run these commands in a terminal window:

```shell
brew install pyenv rustup
```

You can also use Homebrew to install other tools that version managers work with. For example, we should install _cosign_ on systems that use _tenv_. If _cosign_ is present, _tenv_ automatically uses it to carry out signature verification on the binaries that it downloads. This command uses Homebrew to install both _tenv_ and _cosign_:

```shell
brew install tenv cosign
```

> Avoid using Homebrew itself to install programming languages. Homebrew has limited support for working with multiple versions of the same programming language.

### Extra Requirements for Version Managers

When you use any version manager for Python, JavaScript or Ruby, you may also need to install compiler tools for the C programming language. Packages for interpreted languages use components that are written in C or Rust. Python tools fetch compiled versions of these components when they are available. For other cases, you need to have a compiler on your own system to build working components from the source code.

To install a Rust compiler on a system, use mise or the [rustup](https://rustup.rs/) version manager. Linux distributions provide packages for Rust, but these are usually not the latest versions.

To install a C compiler on macOS, use the Command-line Tools package for [Xcode](https://developer.apple.com/xcode/resources/). On Linux, use the system package manager to install a C compiler. Use the GCC compiler, because components may not be tested with other compilers.

Run this command to install GCC and other C compiler tools on Debian-based distributions, such as Ubuntu:

```shell
sudo apt install build-essential
```

Run this command to install just GCC on Red Hat-based distributions, such as Fedora:

```shell
sudo dnf install gcc
```

## Updating Version Managers

Update your version managers regularly. This ensures that they can access the latest versions of the tools that they manage.

If you install version managers with Homebrew, you can update all of the version managers and other tools that you use at the same time, rather than needing to upgrade each one separately. These commands will upgrade all of the tools that Homebrew manages:

```shell
brew update
brew upgrade
```

## Version Managers and Python

### Installing Python with a Version Manager

Whichever version manager tool you use, ensure that it compiles each version of Python that it installs, rather than downloading [standalone builds](https://gregoryszorc.com/docs/python-build-standalone/main/). These standalone builds are modified versions of Python that are maintained by [Astral](https://astral.sh/), not the Python project.

The pyenv tool automatically compiles Python. You must [change the mise configuration](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries) to use compilation rather than standalone builds. Both pyenv and mise use [python-build](https://github.com/pyenv/pyenv/tree/master/plugins/python-build) to compile Python.

> Only use the Python installation features of [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) and [Hatch](https://hatch.pypa.io) for experimental projects. These project tools always download the third-party standalone builds of Python when a user requests a Python version that is not already installed on the system.

### Version Managers and Python Virtual Environments

You should use a project tool like [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) or [Hatch](https://hatch.pypa.io) to develop your projects. These manage Python virtual environments for you.

> Current versions of mise can [integrate with uv](https://mise.jdx.dev/mise-cookbook/python.html#mise-uv), so that there are no conflicts between the tools.

If you are not using a project tool, you can use your version manager to handle Python virtual environments. Both pyenv and mise support automatic switching between Python virtual environments. Support for creating and switching between virtual environments is [built-in to mise](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation). The [pyenv](https://github.com/pyenv/pyenv) version manager supports virtual environments with the [virtualenv plugin](https://github.com/pyenv/pyenv-virtualenv).
