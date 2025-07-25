+++
title = "mise-en-place: A Project Management Framework"
slug = "mise-en-place"
date = "2025-07-25T21:57:00+01:00"
description = "Using mise-en-place"
categories = ["automation", "devops", "programming", "python"]
tags = ["automation", "devops", "golang", "linux", "macos", "javascript", "python"]
+++

The [mise-en-place](https://mise.jdx.dev/) (_mise_) tool provides a framework for managing your projects. It can define [environment variables](https://mise.jdx.dev/environments/) and act as a [task runner](https://mise.jdx.dev/tasks/) as well as handling tool versions.

_mise_ supports wide range of [programming languages](https://mise.jdx.dev/core-tools.html) and [tools](https://mise.jdx.dev/registry.html#tools). This means that you can set the expected versions of all of the languages and tools for a project through a single mise configuration file. You can also include a [lockfile](https://mise.jdx.dev/dev-tools/mise-lock.html) with your projects to pin the exact versions of the tools that it installs.

> Avoid using mise in restricted environments. By design, mise can download and install a very wide range of software, and it will connect to multiple services on the public Internet, including GitHub.

## How mise Works

The mise tool is a single executable file that is written in Rust. This enables you to use mise in any environment, including [continuous integration systems](https://mise.jdx.dev/continuous-integration.html) like GitHub Actions.

> The mise tool is designed to replace [asdf](https://asdf-vm.com/), an older version manager. It addresses [security and usability issues with the design of asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html).

Where possible, mise uses [secure installation methods](https://mise.jdx.dev/registry.html#backends) for tools, and verifies the content of downloads. Unfortunately, some software can only be supported with legacy _asdf_ plugins. These plugins only run on UNIX-based systems, and may not support verifying downloads. Refer to the [mise registry](https://mise.jdx.dev/registry.html#tools) for a list of available tools and the installation methods that are used.

> [mise supports Microsoft Windows](https://mise.jdx.dev/faq.html#windows-support). It cannot install some tools on Windows, because they require _asdf_ plugins. Refer to the [mise registry](https://mise.jdx.dev/registry.html#tools) for a list of tools and installation methods.

## Setting Up mise on Developer Systems

The mise project offers [many installation options](https://mise.jdx.dev/installing-mise.html), including [Homebrew](http://brew.sh/), [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/) and [Scoop](https://scoop.sh/) and packages for most popular Linux distributions. If necessary, you can use [a shell script](https://mise.jdx.dev/installing-mise.html#https-mise-run) to install it on Linux and macOS systems.

Consider using Homebrew to install _mise_ on your development systems for macOS and Linux. Homebrew enables you to update the development tools on the system with minimal effort.

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

## Updating mise

If you installed mise with Homebrew or a package manager, use the same method to upgrade it. If you added mise to a system without using Homebrew or a package manager, upgrade it with the [self-update feature](https://mise.jdx.dev/cli/self-update.html#mise-self-update).

## mise and Python Virtual Environments

You should use a project tool like [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) or [Hatch](https://hatch.pypa.io) to develop your projects. These manage Python virtual environments for you.

If you are not using a project tool, you can use your version manager to handle Python virtual environments. Support for creating and switching between virtual environments is [built-in to mise](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation).

Current versions of mise can [integrate with uv](https://mise.jdx.dev/mise-cookbook/python.html#mise-uv), so that there are no conflicts between the tools.
