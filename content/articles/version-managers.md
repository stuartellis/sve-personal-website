+++
title = "Version Managers"
slug = "version-managers"
date = "2025-03-22T09:55:00+00:00"
description = "Using version managers"
categories = ["devops", "programming"]
tags = ["devops", "linux", "macos", "javascript", "python"]

+++

Avoid installing stand-alone packages for tools and programming languages. Instead, use version manager tools. These enable you to install the correct version of the required tools and dependencies for each of your projects.

## mise-en-place

[mise-en-place](https://mise.jdx.dev/) (_mise_) is the most powerful version manager. It supports all of the popular programming languages and tools. It also provides a range of other features to help you manage your programming projects. Due to the fast pace of development, new versions are released frequently.

If you work in a team, you may find other version managers are more suitable for your projects. They require little configuration, update less frequently and other contributors to your projects may prefer to use other tools that they are more familiar with.

If you decide not to use mise, later sections explain the other version managers that are available.

## Installing Version Managers

Use [Homebrew](http://brew.sh/) to install version manager tools on your development systems for macOS and Linux. This enables you to update the version managers with minimal effort.

The mise tool is a single executable file, written in Rust. This means that you can also install and update it in any environment without Homebrew. For example, you can easily use it in [continuous integration systems](https://mise.jdx.dev/continuous-integration.html). If you do not install mise on development systems with Homebrew, use the [self-update feature](https://mise.jdx.dev/cli/self-update.html#mise-self-update).

If possible, avoid using Homebrew itself to install programming languages. Homebrew has limited support for working with multiple versions of the same programming language.

> Update your version managers regularly, to ensure that they can access the latest versions of the tools that they manage.

## Other Requirements

When you use a version manager for Python or JavaScript, you also need to install compiler tools for the C programming language. Installations of Python, Node.js and other interpreted languages compile components that are written in C.

To install a compiler on macOS, use the Command-line Tools package for [Xcode](https://developer.apple.com/xcode/resources/). On Linux, we use the GCC compiler, because it is compatible with the widest range of C code. If you are developing your own C code on Linux, consider using the [Clang](https://clang.llvm.org/) compiler for your project.

Run this command to install GCC on Debian-based distributions, such as Ubuntu:

```shell
sudo apt install build-essential
```

Run this command to install GCC on Red Hat-based distributions, such as Fedora:

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

I recommend using [mise](https://mise.jdx.dev/) when you work with JavaScript if possible, as it provides a consistent set of features for managing many JavaScript tools, including Node.js, Deno and Bun.

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
