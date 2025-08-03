+++
title = "mise-en-place for Managing Development Tooling"
slug = "mise-en-place"
date = "2025-08-03T07:21:00+01:00"
description = "Using mise-en-place"
categories = ["automation", "devops", "programming", "python"]
tags = ["automation", "devops", "golang", "linux", "macos", "javascript", "python"]
+++

[mise-en-place](https://mise.jdx.dev/) (mise) provides a framework for development tooling, so that you can have a consistent set of configuration, tools and task definitions for every copy of a project. It can run in Continuous Integration (CI) environments as well as on developer systems.

You can also set a default mise configuration for your user account. This enables it to provide a standard set of configuration, tools and tasks that are always available to you.

To enable mise to manage software, you define the expected versions of the [programming languages](https://mise.jdx.dev/core-tools.html) and other [tools](https://mise.jdx.dev/registry.html#tools). It then downloads copies of the required products to a cache as needed, and can switch the active version of each language and tool when you change projects or request a different version.

Similarly, you can define [environment variables](https://mise.jdx.dev/environments/), so that mise adds and removes them as needed. It supports multiple profiles for a project, so that you can switch between sets of environment variables as you work.

Current versions of mise allow you to define [tasks](https://mise.jdx.dev/tasks/) as part of mise configurations. This means that you may not need to use a separate task runner such as [just](https://www.stuartellis.name/articles/just-task-runner/) to maintain a shared set of tasks for projects that use mise.

> Avoid using mise for projects that have strict requirements about reproducible environments or the [software supply chain](https://en.wikipedia.org/wiki/Software_supply_chain). By design, mise can download and install a very wide range of software, and it will connect to multiple services on the public Internet, including GitHub.

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

Consider using the [paranoid mode](https://mise.jdx.dev/paranoid.html) when you set up mise on development systems. This enables various security restrictions. Importantly, it means that each copy of mise will only trust configuration files that the user approves. If a configuration file changes, it must be approved again.

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

> Updating mise never changes the versions of software that your projects use. Run [mise upgrade](https://mise.jdx.dev/cli/upgrade.html#mise-upgrade) to update the versions of tools in mise configurations.

## Using mise with Continuous Integration (CI)

You can use mise with [any continuous integration system](https://mise.jdx.dev/continuous-integration.html). The next sections provide suggestions to consider when you set up mise and CI systems.

### Using mise Environments with CI

I recommend that your mise configuration has one or more [environments](https://mise.jdx.dev/configuration/environments.html#config-environments) specifically for CI, so that you can override the default settings for the project when you need different behavior in a CI job. To specify the active mise environment for a CI job, set `MISE_ENV` as an environment variable:

```shell
MISE_ENV: test
```

### Verifying Downloads

You need to ensure that the environment has GnuPG installed, so that mise can use it to verify downloads. You can then write mise CI job definitions that use mise itself to install _cosign_ and _slsa-verifier_, which mise may also use to [verify downloads](https://mise.jdx.dev/tips-and-tricks.html#software-verification):

```shell
mise use cosign slsa-verifier
```

### Disabling Software Sources

Unless you need specific software that is only available through asdf plugins, disable the use of legacy asdf plugins:

```shell
mise settings disable_backends=asdf
```

To avoid issues, you should also disable these backend types unless you expect a project to need them:

- [vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html)
- [pipx](https://mise.jdx.dev/dev-tools/backends/pipx.html)
- [npm](https://mise.jdx.dev/dev-tools/backends/npm.html)
- [go](https://mise.jdx.dev/dev-tools/backends/go.html)
- [cargo](https://mise.jdx.dev/dev-tools/backends/cargo.html)
- [dotnet](https://mise.jdx.dev/dev-tools/backends/dotnet.html)

Apart from _vfox_, all of these backends require additional tools to run.

### Limiting mise to Trusted Configurations

I would recommend that you configure your CI system to set an environment variable to enable [paranoid mode](https://mise.jdx.dev/paranoid.html):

```shell
MISE_PARANOID: 1
```

This enables various security restrictions. Importantly, it means that mise will only use configuration files that you allow. To allow a configuration file, use `mise trust`:

```shell
# Trust the main mise configuration file for the project.
mise trust --quiet .mise.toml

# Trust the configuration file for the current mise environment.
mise trust --quiet .mise.$MISE_ENV.toml
```

### Caching Downloads

Most CI systems support caching downloads. Set the [$MISE_DATA_DIR](https://mise.jdx.dev/directories.html#local-share-mise) as an environment variable, and use it to specify a location that your CI can cache.

## mise and Python

You should use a project tool to develop your Python projects, such as [uv](https://docs.astral.sh/uv/) or [Poetry](https://python-poetry.org/). These manage Python virtual environments for you, and also offer to manage the versions of Python.

Current versions of mise can [integrate with uv](https://mise.jdx.dev/mise-cookbook/python.html#mise-uv), so that there are no conflicts between the tools.

I would recommend that you use mise to manage the versions of Python. This means that the versions of Python are managed along with all of the other tools.

In addition, the project tools always download third-party [standalone builds](https://gregoryszorc.com/docs/python-build-standalone/main/) of Python when a user requests a Python version that is not already installed on the system. These standalone builds are modified versions of Python that are maintained by [Astral](https://astral.sh/), not the Python project. You can [change the mise configuration](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries) to compile copies of Python rather than using the standalone builds.

If you are not using a project tool, you can use mise to handle Python virtual environments as well as the versions of Python. Support for creating and switching between virtual environments is [built-in to mise](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation).

## Resources

### Documentation

- [mise Documentation](https://mise.jdx.dev/)
- [Renovate support for mise](https://docs.renovatebot.com/modules/manager/mise/)

### Media

- [devtools FM Episode #129: Jeff Dickey - Mise, Usage, and Pitchfork and the Future of Polyglot Tools](https://www.devtools.fm/episode/129)
