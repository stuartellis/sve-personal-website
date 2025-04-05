+++
title = "Using Version Managers for Your Tools"
slug = "version-managers"
date = "2025-04-05T22:00:00+01:00"
description = "Using version managers"
categories = ["automation", "devops", "programming", "python"]
tags = ["automation", "devops", "golang", "linux", "macos", "javascript", "python"]

+++

Avoid installing stand-alone packages for tools and programming languages. Instead, use version manager tools. These enable you to use the correct version of the required tools and dependencies for each of your projects. A version manager can download all of the versions of a product that your projects need and switch the active version as you move between projects, as well as letting you set a default version.

[mise-en-place](https://mise.jdx.dev/) (_mise_) supports wide range of popular programming languages and tools. This means that you can set the expected versions of all of the languages and tools for a project through a single mise configuration file. Alternatively, you can use a [specialized version manager for each programming language](#version-managers-for-programming-languages).

## mise-en-place

The mise tool provides a framework for managing your projects. It can define [environment variables](https://mise.jdx.dev/environments/) and act as a [task runner](https://mise.jdx.dev/tasks/) as well as handling tool versions.

Importantly, mise is a single executable file that is written in Rust. This enables you to use mise in any environment, including [continuous integration systems](https://mise.jdx.dev/continuous-integration.html) like GitHub Actions. You can also include a [lockfile](https://mise.jdx.dev/configuration/settings.html#lockfile) with your projects to pin the exact versions of the tools that it installs. These features mean that your developer systems and continuous integration jobs can all work with the same set of languages and tools, and can share a common set of reusable tasks.

The mise tool is designed to replace [asdf](https://asdf-vm.com/), an older version manager. It addresses [security and usability issues with the design of asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html). It also [supports Microsoft Windows](https://mise.jdx.dev/faq.html#windows-support), unlike asdf.

Where possible, mise uses [secure installation methods](https://mise.jdx.dev/registry.html#backends) for tools and verifies the content of downloads. Unfortunately, some software can only be supported with legacy asdf plugins. These plugins only run on UNIX-based systems, and may not support verifying downloads.

> Refer to the [mise registry](https://mise.jdx.dev/registry.html#tools) for a list of available tools and the installation methods that are used.

Even though mise uses the safest installation method that it can for each tool, you may decide to avoid adding it to restricted environments. By design, mise can download and install a very wide range of software, and it will connect to multiple services on the public Internet, including GitHub.

## Specialized Version Managers

### Version Managers for Programming Languages

These are popular specialized version managers for programming languages:

- The standard _go_ tool [manages versions of Go](https://go.dev/doc/manage-install#installing-multiple).
- [jEnv](https://www.jenv.be/) for Java
- [nvm](https://github.com/nvm-sh/nvm) for Node.js
- [pyenv](https://github.com/pyenv/pyenv) for Python
- [rustup](https://rustup.rs/) for Rust

> See the [section on Python](#version-managers-and-python) for more details about using version managers with Python.

I suggest using [mise](https://mise.jdx.dev/) when you work with JavaScript, as it provides a consistent set of features for managing many JavaScript tools, including Node.js, Deno and Bun. If you work with Node.js and decide not to use mise, consider using [Volta](https://volta.sh/) instead. Volta is a cross-platform tool, whilst nvm is a Bash shell script for UNIX-based systems.

If you are a Ruby developer, you may already use mise. The [Ruby on Rails Guides](https://guides.rubyonrails.org/) now recommend mise for Rails projects.

Some packages for JavaScript, Python and Ruby use Rust or C code. To support these packages, you may need to [install a compiler](#extra-requirements-for-version-managers).

### tenv: Version Manager for Terraform and OpenTofu

If you do not want to use mise, consider using [tenv](https://tofuutils.github.io/tenv/) to install versions of [OpenTofu](https://opentofu.org/) and [Terraform](https://www.terraform.io/). The tenv version manager also supports [Atmos](https://atmos.tools/) and [Terragrunt](https://terragrunt.gruntwork.io/).

> Always install _cosign_ on systems that use _tenv_. If _cosign_ is present, _tenv_ automatically uses it to carry out signature verification on the binaries that it downloads.

## Setting Up Version Managers on Developer Systems

Consider using [Homebrew](http://brew.sh/) to install version manager tools on your development systems for macOS and Linux. Homebrew enables you to update the version managers and other development tools on the system with minimal effort.

[Scoop](https://scoop.sh/) and [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/) provide the equivalent of Homebrew for Microsoft Windows. If you use Microsoft Windows, check the documentation of a version manager before you install it. Some version managers only support UNIX-based systems, or have features that cannot work on Microsoft Windows.

> [mise supports Microsoft Windows](https://mise.jdx.dev/faq.html#windows-support). It cannot install some tools on Windows, because they require _asdf_ plugins, which only run on UNIX-based systems. Refer to the [mise registry](https://mise.jdx.dev/registry.html#tools) for a list of tools and installation methods.

### Setting Up mise-en-place on Developer Systems

The mise project offers [many installation options](https://mise.jdx.dev/installing-mise.html), including Homebrew, Scoop, WinGet and packages for most popular Linux distributions. If necessary, you can use [a shell script](https://mise.jdx.dev/installing-mise.html#https-mise-run) to install it on Linux and macOS systems.

Regardless of how you install it, [mise requires extra tools to verify downloads](https://mise.jdx.dev/tips-and-tricks.html#software-verification). Linux systems often include the GnuPG tool. To install GnuPG on other operating systems, use the same method that you used to install mise. You can then use mise to install _cosign_ and _slsa-verifier_.

For example, if you have Homebrew on macOS, enter these commands in a terminal window to install mise:

```shell
brew install mise gnupg
mise use -g cosign slsa-verifier
```

Once you have installed mise, [enable the shell integration](https://mise.jdx.dev/installing-mise.html#shells) and [install the plugin for your text editor](https://mise.jdx.dev/ide-integration.html).

Consider using the [paranoid](https://mise.jdx.dev/paranoid.html) mode when you set up mise on development systems. This reduces the risk of a developer adding unsafe values to the mise configuration for a project.

For extra safety, disable the use of legacy asdf plugins:

```shell
mise settings disable_backends=asdf
```

### Installing Other Version Managers with Homebrew

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

### Updating Version Managers with Homebrew

If you install version managers with Homebrew, you can update all of the version managers and other tools that you use at the same time, rather than needing to upgrade each one separately. These commands will upgrade all of the tools that Homebrew manages:

```shell
brew update
brew upgrade
```

### Updating mise

If you installed mise with Homebrew or a package manager, use the same method to upgrade it. If you added mise to a system without using Homebrew or a package manager, upgrade it with the [self-update feature](https://mise.jdx.dev/cli/self-update.html#mise-self-update).

## Version Managers and Python

### Installing Python with a Version Manager

Whichever version manager tool you use, ensure that it compiles each version of Python that it installs, rather than downloading [standalone builds](https://gregoryszorc.com/docs/python-build-standalone/main/). These standalone builds are modified versions of Python that are maintained by [Astral](https://astral.sh/), not the Python project.

The pyenv tool automatically compiles Python. You must [change the mise configuration](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries) to use compilation rather than standalone builds. Both pyenv and mise use [python-build](https://github.com/pyenv/pyenv/tree/master/plugins/python-build) to compile Python.

> Only use the Python installation features of [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) and [Hatch](https://hatch.pypa.io) for experimental projects. These project tools always download the third-party standalone builds of Python when a user requests a Python version that is not already installed on the system.

### Version Managers and Python Virtual Environments

You should use a project tool like [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) or [Hatch](https://hatch.pypa.io) to develop your projects. These manage Python virtual environments for you.

If you are not using a project tool, you can use your version manager to handle Python virtual environments. Both pyenv and mise support automatic switching between Python virtual environments. Support for creating and switching between virtual environments is [built-in to mise](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation). The [pyenv](https://github.com/pyenv/pyenv) version manager supports virtual environments with the [virtualenv plugin](https://github.com/pyenv/pyenv-virtualenv).

Current versions of mise can [integrate with uv](https://mise.jdx.dev/mise-cookbook/python.html#mise-uv), so that there are no conflicts between the tools.
