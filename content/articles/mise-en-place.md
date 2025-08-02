+++
title = "mise-en-place: A Project Management Framework"
slug = "mise-en-place"
date = "2025-08-02T10:32:00+01:00"
description = "Using mise-en-place"
categories = ["automation", "devops", "programming", "python"]
tags = ["automation", "devops", "golang", "linux", "macos", "javascript", "python"]
+++

The [mise-en-place](https://mise.jdx.dev/) (mise) tool provides a framework for managing your projects. It can define [environment variables](https://mise.jdx.dev/environments/) and act as a [task runner](https://mise.jdx.dev/tasks/) as well as handling tool versions.

mise supports [popular programming languages](https://mise.jdx.dev/core-tools.html) and a wide range of [tools](https://mise.jdx.dev/registry.html#tools). This means that you can set the expected versions of all of the languages and tools for a project through a single mise configuration file. You can also include a [lockfile](https://mise.jdx.dev/dev-tools/mise-lock.html) to pin the exact versions of the software that it installs.

> Avoid using mise in restricted environments. By design, mise can download and install a very wide range of software, and it will connect to multiple services on the public Internet, including GitHub.

## How mise Works

The mise tool is a single executable file that is written in Rust. This enables you to use mise in any environment, including [continuous integration systems](https://mise.jdx.dev/continuous-integration.html) like GitHub Actions.

It uses text files in the TOML format to store configuration information about tool versions, task definitions and variables. You can place configuration files in the root directory of a project to set project-level options, in your home directory for global defaults, or in [other locations](https://mise.jdx.dev/configuration.html) to handle particular requirements.

You can also add [lockfiles](https://mise.jdx.dev/dev-tools/mise-lock.html) to pin the exact versions of the software that mise installs and uses. This feature is currently _experimental_, which means that the format of the lockfiles may change with future versions of mise.

Where possible, mise uses [secure installation methods](https://mise.jdx.dev/registry.html#backends) for software, and verifies the content of downloads. Unfortunately, some software can only be supported with legacy _asdf_ plugins. These plugins only run on UNIX-based systems, and may not support verifying downloads. Refer to the [mise registry](https://mise.jdx.dev/registry.html#tools) for a list of available tools and the installation methods that are used.

> The mise tool is designed to be able to replace [asdf](https://asdf-vm.com/), an older version manager, so it supports asdf plugins. It addresses [security and usability issues with the design of asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html).

## Setting Up mise on Developer Systems

> [mise itself supports Microsoft Windows](https://mise.jdx.dev/faq.html#windows-support). It cannot install tools that require _asdf_ plugins on Windows.

The mise project offers [many installation options](https://mise.jdx.dev/installing-mise.html). Consider using these tools for developer systems, since they enable you to update mise:

- [Homebrew](http://brew.sh/) for macOS and Linux systems
- [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/) or [Scoop](https://scoop.sh/) for Microsoft Windows

If necessary, you can use [a shell script](https://mise.jdx.dev/installing-mise.html#https-mise-run) to install it on Linux and macOS systems.

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

These commands will upgrade mise on Homebrew:

```shell
brew update
brew upgrade mise
```

> Updating mise never changes the versions of software that your projects use.

## mise and Python Virtual Environments

You should use a project tool to develop your Python projects, such [uv](https://docs.astral.sh/uv/) or [Poetry](https://python-poetry.org/). These manage Python virtual environments for you.

If you are not using a project tool, you can use your version manager to handle Python virtual environments. Support for creating and switching between virtual environments is [built-in to mise](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation).

Current versions of mise can [integrate with uv](https://mise.jdx.dev/mise-cookbook/python.html#mise-uv), so that there are no conflicts between the tools.

## Resources

### Documentation

- [mise Documentation](https://mise.jdx.dev/)
- [Renovate support for mise](https://docs.renovatebot.com/modules/manager/mise/)

### Media

- [devtools FM Episode #129: Jeff Dickey - Mise, Usage, and Pitchfork and the Future of Polyglot Tools](https://www.devtools.fm/episode/129)
