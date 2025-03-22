+++
title = "Version Managers"
slug = "version-managers"
date = "2025-03-22T08:45:00+00:00"
description = "Using version managers"
categories = ["devops", "programming"]
tags = ["devops", "linux", "macos", "javascript", "python"]

+++

Avoid installing stand-alone packages for tools and programming languages. Instead, use version manager tools. These enable you to install the correct version of the required tools and dependencies for each of your projects.

## Requirements

Use Homebrew to install version manager tools on macOS and Linux. This enables you to update the version managers with minimal effort.

If you use a version manager, you will also need to install compiler tools for the C programming language. Installations of Python, Node.js and other languages use GCC to compile components that are written in C.

Use the Xcode Command-line Tools package to install a compiler on macOS. On Linux, we use the GCC compiler, because it is compatible with the widest range of C code. If you are developing your own C code on Linux, consider using the [Clang](https://clang.llvm.org/) compiler for your project.

Run this command to install GCC on Debian-based distributions, such as Ubuntu:

```shell
sudo apt install build-essential
```

Run this command to install GCC on Red Hat-based distributions, such as Fedora:

```shell
sudo dnf install gcc
```

## mise

[mise](https://mise.jdx.dev/) is the most powerful version manager. It supports all of the popular programming languages and tools. If you decide not to use mise, the next sections explain the other version managers that are available.

## Version Managers for Programming Languages

Consider using these specialized version manager for programming languages:

- [pyenv](https://github.com/pyenv/pyenv) for Python
- [rustup](https://rustup.rs/) for Rust
- The standard _go_ tool [manages versions of Go](https://go.dev/doc/manage-install#installing-multiple).
- [jEnv](https://www.jenv.be/) for Java

You can start using these version managers quickly. They require very little configuration.

I recommend using [mise](https://mise.jdx.dev/) when you work with JavaScript if possible, as it provides a consistent set of features for managing many tools, including Node.js, Deno and Bun.

> Only use the Python installation features of the [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) and [Hatch](https://hatch.pypa.io) tools for experimental projects. These project tools always download third-party standalone builds of Python when a user requests a Python version that is not already installed on the system.

## tenv: Version Manager for Terraform and OpenTofu

Use the [tenv](https://tofuutils.github.io/tenv/) version manager to install versions of Terraform and OpenTofu. To install _tenv_ with Homebrew, run this command in a terminal window:

```shell
brew install tenv cosign
```

Always install _cosign_ along with _tenv_. If _cosign_ is present, _tenv_ automatically uses it to carry out signature verification on the binaries that it downloads.
