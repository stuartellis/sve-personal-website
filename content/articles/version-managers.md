+++
title = "Version Managers"
slug = "version-managers"
date = "2025-03-22T22:11:00+00:00"
description = "Using version managers"
categories = ["devops", "programming"]
tags = ["devops", "linux", "macos", "javascript", "python"]

+++

Avoid installing stand-alone packages for tools and programming languages. Instead, use version manager tools. These enable you to use the correct version of the required tools and dependencies for each of your projects. The version manager can download all of the versions of a product that your projects need, and switch the active version as your move between projects.

## mise-en-place

[mise-en-place](https://mise.jdx.dev/) (_mise_) is one of the most powerful version managers. It supports a wide range of popular programming languages and tools, along with options to integrate it with your environments.

In fact, mise is a tool for managing your projects, working with [environment variables](https://mise.jdx.dev/environments/) and optionally acting as a [task runner](https://mise.jdx.dev/tasks/) as well as handling tool versions. Current versions also include experimental support for [managing pre-commit hooks](https://mise.jdx.dev/cli/generate/git-pre-commit.html).

If you work in a team, you may find other version managers are more suitable for your projects. Contributors to your projects may prefer to use tools that they are already familiar with, or that have fewer features.

You may also decide not to use mise in environments where security is an important concern. It uses a range of plugins to install and update tools, including [asdf plugins](https://mise.jdx.dev/dev-tools/backends/asdf.html). The mise project is migrating away from asdf plugins, but you might choose to avoid the tool until this work is complete.

If you decide not to use mise, later sections explain the other version managers that are available.

## Setting Up Version Managers

Consider using [Homebrew](http://brew.sh/) to install version manager tools on your development systems for macOS and Linux. Homebrew enables you to update all of the version managers and other development tools on the system with minimal effort.

> Update your version managers regularly, to ensure that they can access the latest versions of the tools that they manage.

Avoid using Homebrew itself to install programming languages. Homebrew has limited support for working with multiple versions of the same programming language.

### Installation Options for mise-en-place

The mise project offers [many installation options](https://mise.jdx.dev/installing-mise.html), including Homebrew and packages for most popular operating systems. Consider using Homebrew for macOS and Linux development systems, and Scoop or Winget for Windows development systems.

The mise tool itself is a single executable file, written in Rust. This means that you can also install and update it in any environment. The project provides specific support for adding mise to [continuous integration systems](https://mise.jdx.dev/continuous-integration.html). If necessary, you can use [a script](https://mise.jdx.dev/installing-mise.html#https-mise-run) to install it on development environments.

> Regardless of how you install it, [mise requires extra tools to verify downloads](https://mise.jdx.dev/tips-and-tricks.html#software-verification).

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

These are the most popular specialized version managers for programming languages:

- The standard _go_ tool [manages versions of Go](https://go.dev/doc/manage-install#installing-multiple).
- [jEnv](https://www.jenv.be/) for Java
- [nvm](https://github.com/nvm-sh/nvm) for Node.js
- [pyenv](https://github.com/pyenv/pyenv) for Python
- [rustup](https://rustup.rs/) for Rust

I suggest using [mise](https://mise.jdx.dev/) when you work with JavaScript if possible, as it provides a consistent set of features for managing many JavaScript tools, including Node.js, Deno and Bun.

The [Ruby on Rails Guides](https://guides.rubyonrails.org/) recommend mise for Rails projects.

### Version Managers and Python

Whichever version manager tool you use, ensure that it compiles Python, rather than downloading [standalone builds](https://gregoryszorc.com/docs/python-build-standalone/main/). These standalone builds are modified versions of Python that are maintained by [Astral](https://astral.sh/), not the Python project.

Both pyenv and mise use [python-build](https://github.com/pyenv/pyenv/tree/master/plugins/python-build) to compile Python. This means that you can use either tool. The pyenv tool automatically compiles Python, but you must [change the mise configuration](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries) to use compilation.

> Only use the Python installation features of [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) and [Hatch](https://hatch.pypa.io) for experimental projects. These project tools always download third-party standalone builds of Python when a user requests a Python version that is not already installed on the system.

## tenv: Version Manager for Terraform and OpenTofu

Use the [tenv](https://tofuutils.github.io/tenv/) version manager to install versions of Terraform and OpenTofu. To install _tenv_ with Homebrew, run this command in a terminal window:

```shell
brew install tenv cosign
```

Always install _cosign_ along with _tenv_. If _cosign_ is present, _tenv_ automatically uses it to carry out signature verification on the binaries that it downloads.
