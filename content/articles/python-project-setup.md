+++
title = "Project Setup with Python"
slug = "python-project-setup"
date = "2025-02-28T16:51:00+00:00"
description = "Project conventions for modern Python"
categories = ["programming", "python"]
tags = ["python"]

+++

If possible [use a project tool](https://www.stuartellis.name/articles/python-modern-practices#use-a-project-tool) to set up and develop your Python projects. It will implement these concepts for you. If you decide not to use a project tool, set up your projects to follow the best practices in this article.

## Use a pyproject.toml File

Create a _pyproject.toml_ file in the root directory of each Python project. Use this file as the central place to store configuration information about the project and the tools that it uses. For example, you list [the dependencies of your project](https://www.pyopensci.org/python-package-guide/package-structure-code/declare-dependencies.html) in the _pyproject.toml_ file.

Python project tools like _uv_, PDM and Hatch automatically create and use a _pyproject.toml_ file.

> The [pyOpenSci project documentation on pyproject.toml](https://www.pyopensci.org/python-package-guide/package-structure-code/pyproject-toml-python-package-metadata.html) provides an introduction to the file format. The various features of _pyproject.toml_ files are defined these PEPs: [PEP 517](https://peps.python.org/pep-0517/), [PEP 518](https://peps.python.org/pep-0518/), [PEP 621](https://peps.python.org/pep-0621/) and [PEP 660](https://peps.python.org/pep-0660/).

## Libraries: Create a Directory Structure That Uses the src Layout

Python itself does not require a specific directory structure for your projects. The Python packaging documentation describes two popular directory structures: [the src layout and the flat layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/).
The [pyOpenSci project documentation on directory structures](https://www.pyopensci.org/python-package-guide/package-structure-code/python-package-structure.html) explains the practical differences between the two.

Use the src layout for a project that creates Python _wheel_ packages. This requires you to use [editable installs](https://setuptools.pypa.io/en/latest/userguide/development_mode.html) of the packages in your project. [PDM](https://pdm-project.org), [uv](https://docs.astral.sh/uv/) and [Hatch](https://hatch.pypa.io) support editable installs.

> By default, uv will create a project with the flat layout. Use the _--lib_ flag to create a project with the src layout.

## Use Virtual Environments for Development

The [virtual environments](https://docs.python.org/3/tutorial/venv.html) feature enables you to define one or more separate sets of packages for each Python project, and switch between them. This ensures that a set of packages that you use for a specific purpose do not conflict with any other Python packages on the system. Always use Python virtual environments for your projects.

Several tools automate virtual environments. The [mise](https://mise.jdx.dev) version manager includes [support for virtual environments](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation). The [pyenv](https://github.com/pyenv/pyenv) version manager supports virtual environments with the [virtualenv plugin](https://github.com/pyenv/pyenv-virtualenv). If you use a tool like [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) or [Hatch](https://hatch.pypa.io) to develop your projects, these also manage Python virtual environments for you.

You can set up and use virtual environments with _venv_, which is part of the Python standard library. This is a manual process.

## Use Requirements Files to Install Packages Into Environments

Avoid using _pip_ commands to install individual packages into virtual environments. If you use [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) or [Hatch](https://hatch.pypa.io) to develop your project, they can manage the contents of virtual environments for development and testing.

For other cases, use [requirements files](https://pip.pypa.io/en/stable/reference/requirements-file-format/). A requirements file can specify the exact version and hash for each required package.

You run a tool to read the dependencies in the _pyproject.toml_ file and generate a requirements file that lists the specific packages that are needed to provide those dependencies for the Python version and operating system. PDM, [pip-tools](https://pip-tools.readthedocs.io/en/stable/) and [uv](https://docs.astral.sh/uv/) include features to create requirements files.

You can then use [pip-sync](https://pip-tools.readthedocs.io/en/stable/cli/pip-sync/) or the _sync_ feature of _uv_ to make the packages in a target virtual environment match the list in the requirements file. This process ensures that any extra packages are removed from the virtual environment.

You can also run _pip install_ with a requirements file. This only attempts to install the specified packages. For example, these commands install the packages that are specified by the file _requirements-macos-dev.txt_ into the virtual environment _.venv-dev_:

```shell
source ./.venv-dev/bin/activate
python3 -m pip install --require-virtualenv -r requirements-macos-dev.txt
```

## pip-compile: Use the Correct Virtual Environment

If you do not already have a tool that can create requirements files, you can use the [pip-compile](https://pip-tools.readthedocs.io/en/stable/cli/pip-compile/) utility that is provided by [pip-tools](https://pip-tools.readthedocs.io/en/stable/).

To ensure that it calculates the correct requirements for your application, the _pip-compile_ tool must be run in a virtual environment that includes your application package. This means that you cannot use _pipx_ to install _pip-compile_.
