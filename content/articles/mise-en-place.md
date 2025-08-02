+++
title = "mise-en-place: A Project Management Framework"
slug = "mise-en-place"
date = "2025-08-02T20:22:00+01:00"
description = "Using mise-en-place"
categories = ["automation", "devops", "programming", "python"]
tags = ["automation", "devops", "golang", "linux", "macos", "javascript", "python"]
+++

The [mise-en-place](https://mise.jdx.dev/) (mise) tool provides a framework for managing your projects, so that you have a consistent set of configuration, tools and reusable tasks for every copy of the project. It can run in Continuous Integration (CI) environments as well as on developer systems.

You can also set a default mise configuration for your user account, so that it can provide a standard set of configuration, tools and tasks that are always available.

To enable mise to manage tools, you define the expected versions of the [programming languages](https://mise.jdx.dev/core-tools.html) and other [tools](https://mise.jdx.dev/registry.html#tools). It then downloads copies of the required software to a cache as needed, and can switch the active version of each language and tool when you change projects or request a different version.

Similarly, you can define [environment variables](https://mise.jdx.dev/environments/), so that mise adds and removes them as needed. It supports multiple profiles for a project, so that you can switch between sets of environment variables as you work.

Current versions of mise allow you to define [tasks](https://mise.jdx.dev/tasks/) as part of mise configurations. This means that you may not need to use a separate task runner such as [just](https://www.stuartellis.name/articles/just-task-runner/) to maintain a shared set of tasks for projects that use mise.

> Avoid using mise in restricted environments. By design, mise can download and install a very wide range of software, and it will connect to multiple services on the public Internet, including GitHub.

## How mise Works

The mise tool is a single executable file that is written in Rust. This enables you to use mise in any environment, including [continuous integration systems](https://mise.jdx.dev/continuous-integration.html) like GitHub Actions.

It is an evergreen tool, which means that [mise is regularly updated and you can always use the latest version](https://mise.jdx.dev/roadmap.html#versioning). New versions of mise should not cause errors with existing configurations, and new features are opt-in. Updating mise never changes the versions of software that your projects use.

The configuration for mise is defined by text files in the TOML format. These store information about tool versions, task definitions and variables. You can place configuration files in the root directory of a project to set project-level options, in your home directory for global defaults, or in [other locations](https://mise.jdx.dev/configuration.html) to handle particular requirements.

You can also add [lockfiles](https://mise.jdx.dev/dev-tools/mise-lock.html) to pin the exact versions of the software that mise installs and uses. This feature is currently marked as _experimental_, which means that the format of the lockfiles may change with future versions of mise.

Where possible, mise uses [secure installation methods](https://mise.jdx.dev/registry.html#backends) for software, and verifies the content of downloads. Unfortunately, some software can only be supported with legacy _asdf_ plugins. These plugins only run on UNIX-based systems, and may not support verifying downloads. Refer to the [mise registry](https://mise.jdx.dev/registry.html#tools) for a list of available tools and the installation methods that are used.

> The mise tool is designed to be able to replace [asdf](https://asdf-vm.com/), an older version manager, so it supports asdf plugins. It addresses [security and usability issues with the design of asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html).

## Setting Up mise on Developer Systems

> [mise itself supports Microsoft Windows](https://mise.jdx.dev/faq.html#windows-support). It cannot install tools that require _asdf_ plugins on Windows.

The mise project offers [many installation options](https://mise.jdx.dev/installing-mise.html). Consider using these options for developer systems, since they enable you to update mise with the same process that you use to update other development tools:

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

### Updating mise

If you installed mise with Homebrew or a package manager, use the same method to upgrade it. If you added mise to a system without using Homebrew or a package manager, upgrade it with the [self-update feature](https://mise.jdx.dev/cli/self-update.html#mise-self-update).

These commands will upgrade mise on Homebrew:

```shell
brew update
brew upgrade mise
```

> Updating mise never changes the versions of software that your projects use.

## Using mise with Continuous Integration (CI)

You can use mise with [any continuous integration system](https://mise.jdx.dev/continuous-integration.html). The mise project provide an [action](https://mise.jdx.dev/continuous-integration.html#github-actions) for GitHub Actions. If you define a custom environment for CI, you will need to ensure that GnuPG is installed for mise to use it to verify downloads.

I recommend that your mise configuration has one or more [environments](https://mise.jdx.dev/configuration/environments.html#config-environments) specifically for CI, so that you can override the default settings for the project when you need different behavior in a CI job. To specify the active mise environment for a CI job, set `MISE_ENV` as an environment variable.

I would also recommend that you configure your CI system to set an environment variable to enable [paranoid](https://mise.jdx.dev/paranoid.html) mode:

```shell
MISE_PARANOID: 1
```

Once you define these environment variables you can use `mise trust` in your CI, so that mise only works with the configuration files that you expect:

```shell
# Trust the main project configuration file
mise trust --quiet .mise.toml

# Trust the configuration file for the current mise environment.
mise trust --quiet .mise.$MISE_ENV.toml
```

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
