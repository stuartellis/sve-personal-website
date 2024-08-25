+++
title = "Modern Good Practices for Python Development"
slug = "python-modern-practices"
date = "2024-08-25T14:03:00+01:00"
description = "Good development practices for modern Python"
categories = ["programming", "python"]
tags = ["python"]

+++

[Python](https://www.python.org/) has a long history, and it has evolved over time. This article describes some agreed modern best practices.

## Using Python

### Avoid Using the Python Installation in Your Operating System

If your operating system includes a Python installation, avoid using it for your projects. This Python installation is for operating system tools. It is likely to use an older version of Python, and may not include all of the standard features. An operating system copy of Python should be [marked](https://packaging.python.org/en/latest/specifications/externally-managed-environments/#externally-managed-environments) to prevent you from installing packages into it, but not all operating systems set the marker.

### Install Python With Tools That Support Multiple Versions

Use a tool like [mise](https://mise.jdx.dev) or [pyenv](https://github.com/pyenv/pyenv) to install copies of Python on your development systems, so that you can switch between different versions of Python for your projects. This enables you to upgrade each project to a new version of Python without interfering with other tools and projects that use Python.

Alternatively, consider using [Development Containers](https://containers.dev/), which enable you to define an isolated environment for a software project. This also allows you to use a separate version of Python for each project.

Ensure that the tool compiles Python, rather than downloading [standalone builds](https://gregoryszorc.com/docs/python-build-standalone/main/). These standalone builds are modified versions of Python that are maintained by a third-party. Both the pyenv tool and the [Visual Studio Code Dev Container feature](https://github.com/devcontainers/features/blob/main/src/python/README.md) automatically compile Python, but you must [change the mise configuration](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries) to use compilation.

Only use the Python installation features of [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) and [Hatch](https://hatch.pypa.io) for experimental projects. These tools always download the third-party standalone builds when they manage versions of Python.

### Use the Most Recent Version of Python That You Can

For new projects, choose the most recent stable version of Python 3. This ensures that you have the latest security fixes, as well as the fastest performance.

Upgrade your projects as new Python versions are released. The Python development team usually support each version for five years, but some Python libraries may only support each version of Python for a shorter period of time. If you use tools that support multiple versions of Python and automated testing, you can test your projects on new Python versions with little risk.

{{< alert >}}
_Avoid using Python 2._ It is not supported by the Python development team or by the developers of most popular Python libraries.
{{< /alert >}}

### Use a Helper to Run Python Tools

Use either [uv](https://docs.astral.sh/uv/) or [pipx](https://pipx.pypa.io) to run Python tools on development systems, rather than installing these applications with _pip_ or another method. Both _uv_ and _pipx_ automatically put each application into a separate [Python virtual environment](https://docs.python.org/3/tutorial/venv.html).

Use the [uvx](https://docs.astral.sh/uv/#tool-management) command of _uv_ or the [pipx run](https://pipx.pypa.io/stable/#walkthrough-running-an-application-in-a-temporary-virtual-environment) feature of _pipx_ for most applications. These download the application to a cache and run it. For example, these commands download and run the latest version of [bpytop](https://github.com/aristocratos/bpytop), a system monitoring tool:

```shell
uvx bpytop
```

```shell
pipx run bpytop
```

The _bpytop_ tool is cached after the first download, which means that the second use of it will run as quickly as an installed application.

Use _uv tool install_ or _pipx install_ for tools that are essential for your development process. These options install the tool on to your system. This ensures that the tool is available if you have no Internet access, and that you keep the same version of the tool until you decide to upgrade it.

For example, install [pre-commit](https://pre-commit.com/), rather than use a temporary copy. The  _pre-commit_ tool automatically runs every time that we commit a change to version control, so we want it to be consistent and always available. To install _pre-commit_, run the appropriate command for _uv_ or _pipx_:

```shell
uv tool install pre-commit
```

```shell
pipx install pre-commit
```

> Always follow the instructions on the [pipx Website](https://pipx.pypa.io) for your specific operating system. This ensures that _pipx_ works with an appropriate Python installation.

## Developing Python Projects

### Use a Project Tool

If you use a project tool, it will follow [the best practices for Python projects](#best-practices-for-python-projects). Use either [PDM](https://pdm-project.org) or [uv](https://docs.astral.sh/uv/) to help you develop Python applications. [Hatch](https://hatch.pypa.io) is another well-known project tool, but it is most useful for developing Python libraries.

Avoid using the [Poetry](https://python-poetry.org/) or [Rye](https://rye.astral.sh/) tools for new projects. Poetry uses non-standard implementations of key features. For example, it does not use the standard format in _pyproject.toml_ files, which may cause compatibility issues with other tools. Rye is for developing experimental features that may be implemented in _uv_ in future.

### Format Your Code

Use a formatting tool with a plugin to your editor, so that your code is automatically formatted to a consistent style.

[Black](https://black.readthedocs.io/en/stable/) is currently the most popular code formatting tool for Python, but consider using [Ruff](https://docs.astral.sh/ruff/). Ruff provides both code formatting and quality checks for Python code.

Use [pre-commit](https://pre-commit.com/) to run the formatting tool before each commit to source control. You should also run the formatting tool with your CI system, so that it rejects any code that does not match the format for your project.

### Use a Code Linter

Use a code linting tool with a plugin to your editor, so that your code is automatically checked for issues.

[flake8](https://flake8.pycqa.org/en/latest/) is currently the most popular linter for Python, but consider using [Ruff](https://docs.astral.sh/ruff/). Ruff includes the features of both flake8 itself and the most popular plugins for flake8.

Use [pre-commit](https://pre-commit.com/) to run the linting tool before each commit to source control. You should also run the linting tool with your CI system, so that it rejects any code that does not meet the standards for your project.

### Test with pytest

Use [pytest](http://pytest.org) for testing. Use the _unittest_ module in the standard library for situations where you cannot add _pytest_ to the project.

By default, _pytest_ runs tests in the order that they appear in the test code. To avoid issues where tests interfere with each other, always add the [pytest-randomly](https://pypi.org/project/pytest-randomly/) plugin to _pytest_. This plugin causes _pytest_ to run tests in random order. Randomizing the order of tests is a common good practice for software development.

To see how much of your code is covered by tests, add the [pytest-cov](https://pytest-cov.readthedocs.io) plugin to _pytest_. This plugin uses [coverage](https://coverage.readthedocs.io) to analyze your code.

### Package Your Projects

Always package the tools and code libraries that you would like to share with other people. Packages enable people to use your code with the tools and systems that they prefer to work with, and select the version of your code that is best for them.

Use [wheel](https://packaging.python.org/en/latest/specifications/binary-distribution-format/) packages for libraries. You can also use _wheel_ packages for development tools. If you publish your Python application as a _wheel_, other developers can run it with _uv_ or _pipx_. Remember that all _wheel_ packages require an existing installation of Python.

In most cases, you should package an application in a format that enables you to include your code, the dependencies and a copy of the required version of Python. This ensures that your code runs with the expected version of Python, and has the correct version of each dependency.

Use container images to package applications that provide a network service, such as a Web application. Use [PyInstaller](https://pyinstaller.org/) to publish desktop and command-line applications as a single executable file. Each container image and PyInstaller file includes a copy of Python, along with your code and the required dependencies.

## Language Syntax

### Use Type Hinting

Current versions of Python support type hinting. Consider using type hints in any critical application. If you develop a shared library, use type hints.

Once you add type hints, the [mypy](http://www.mypy-lang.org/) tool can check your code as you develop it. Code editors can also read type hints to display information about the code that you are working with.

If you use [Pydantic](https://docs.pydantic.dev/) in your application, it can work with type hints. Use the [mypy plugin for Pydantic](https://docs.pydantic.dev/latest/integrations/mypy/) to improve the integration between mypy and Pydantic.

> [PEP 484 - Type Hints](https://peps.python.org/pep-0484/) and [PEP 526 – Syntax for Variable Annotations](https://peps.python.org/pep-0526/) define the notation for type hinting.

### Create Data Classes for Custom Data Objects

Python code frequently has classes for data objects, items that exist to store values, but do not carry out actions. If your application could have a number of classes for data objects, consider using either [Pydantic](https://docs.pydantic.dev/) or the built-in [data classes](https://docs.python.org/3/library/dataclasses.html) feature.

Pydantic provides validation, serialization and other features for data objects. You need to define the classes for Pydantic data objects with type hints.

The built-in syntax for data classes just enables you to reduce the amount of code that you need to define data objects. It also provides some features, such as the ability to mark instances of a data class as [frozen](https://docs.python.org/3/library/dataclasses.html#frozen-instances). Each data class acts as a standard Python class, because syntax for data classes does not change the behavior of the classes that you define with it.

Data classes were introduced in version 3.7 of Python.

> [PEP 557](https://www.python.org/dev/peps/pep-0557/) describes data classes.

### Use enum or Named Tuples for Immutable Sets of Key-Value Pairs

Use the _enum_ type in Python 3.4 or above for immutable collections of key-value pairs. Enums can use class inheritance.

Python 3 also has _collections.namedtuple()_ for immutable key-value pairs. Named tuples do not use classes.

### Format Strings with f-strings

The new [f-string](https://docs.python.org/3/reference/lexical_analysis.html#f-strings) syntax is both more readable and has better performance than older methods. Use f-strings instead of _%_ formatting, _str.format()_ or _str.Template()_.

The older features for formatting strings will not be removed, to avoid breaking backward compatibility.

The f-strings feature was added in version 3.6 of Python. Alternate implementations of Python may include this specific feature, even when they do not support version 3.6 syntax.

> [PEP 498](https://www.python.org/dev/peps/pep-0498/) explains f-strings in detail.

### Use Datetime Objects with Time Zones

Always use _datetime_ objects that are [aware](https://docs.python.org/3/library/datetime.html?highlight=datetime#aware-and-naive-objects) of time zones. By default, Python creates _datetime_ objects that do not include a time zone. The documentation refers to _datetime_ objects without a time zone as **naive**.

Avoid using _date_ objects, except where the time of day is completely irrelevant. The _date_ objects are always **naive**, and do not include a time zone.

Use aware _datetime_ objects with the UTC time zone for timestamps, logs and other internal features.

To get the current time and date in UTC as an aware _datetime_ object, specify the UTC time zone with _now()_. For example:

```python
from datetime import datetime, timezone

dt = datetime.now(timezone.utc)
```

Python 3.9 and above include the **zoneinfo** module. This provides access to the standard IANA database of time zones. Previous versions of Python require a third-party library for time zones.

> [PEP 615](https://www.python.org/dev/peps/pep-0615/) describes support for the IANA time zone database with **zoneinfo**.

### Use collections.abc for Custom Collection Types

The abstract base classes in _collections.abc_ provide the components for building your own custom collection types.

Use these classes, because they are fast and well-tested. The implementations in Python 3.7 and above are written in C, to provide better performance than Python code.

### Use breakpoint() for Debugging

This function drops you into the debugger at the point where it is called. Both the [built-in debugger](https://docs.python.org/3/library/pdb.html) and external debuggers can use these breakpoints.

The [breakpoint()](https://docs.python.org/3/library/functions.html#breakpoint) feature was added in version 3.7 of Python.

> [PEP 553](https://www.python.org/dev/peps/pep-0553/) describes the _breakpoint()_ function.

## Application Design

### Use Logging for Diagnostic Messages, Rather Than print()

The built-in _print()_ statement is convenient for adding debugging information, but you should include logging in your scripts and applications. Use the [logging](https://docs.python.org/3/library/logging.html#logrecord-attributes) module in the standard library, or a third-party logging module.

### Use the TOML Format for Configuration

Use [TOML](https://toml.io/) for data files that must be written or edited by human beings. Use the JSON format for data that is transferred between computer programs. Avoid using the INI or YAML formats.

Python 3.11 and above include _tomllib_ to read the TOML format. Use [tomli](https://pypi.org/project/tomli/) to add support for reading TOML to applications that run on older versions of Python.

If your Python software needs to generate TOML, add [Tomli-W](https://pypi.org/project/tomli-w/).

> [PEP 680 - tomllib: Support for Parsing TOML in the Standard Library](https://peps.python.org/pep-0680/) explains why TOML is now included with Python.

### Only Use async Where It Makes Sense

The [asynchronous features of Python](https://docs.python.org/3/library/asyncio.html) enable a single process to avoid blocking on I/O operations. To achieve concurrency with Python, you must run multiple Python processes. Each of these processes may or may not use asynchronous I/O.

To run multiple application processes, either use a container system, with one container per process, or an application server like [Gunicorn](https://gunicorn.org/). If you need to build a custom application that manages multiple processes, use the [multiprocessing](https://docs.python.org/3/library/multiprocessing.html) package in the Python standard library.

Code that uses asynchronous I/O must not call _any_ function that uses synchronous I/O, such as _open()_, or the _logging_ module in the standard library. Instead, you need to use either the equivalent functions from _asyncio_ in the standard library or a third-party library that is designed to support asynchronous code.

The [FastAPI](https://fastapi.tiangolo.com/) Web framework supports [using both synchronous and asynchronous functions in the same application](https://fastapi.tiangolo.com/async/). You must still ensure that asynchronous functions never call any synchronous function.

If you would like to work with _asyncio_, use Python 3.7 or above. Version 3.7 of Python introduced [context variables](https://docs.python.org/3/library/contextvars.html), which enable you to have data that is local to a specific _task_, as well as the _asyncio.run()_ function.

> [PEP 0567](https://www.python.org/dev/peps/pep-0567/) describes context variables.

## Libraries

### Handle Command-line Input with argparse

The [argparse](https://docs.python.org/3/library/argparse.html) module is now the recommended way to process command-line input. Use _argparse_, rather than the older _optparse_ and _getopt_.

The _optparse_ module is officially deprecated, so update code that uses _optparse_ to use _argparse_ instead.

Refer to [the argparse tutorial](https://docs.python.org/3/howto/argparse.html) in the official documentation for more details.

### Use pathlib for File and Directory Paths

Use [pathlib](https://docs.python.org/3/library/pathlib.html) objects instead of strings whenever you need to work with file and directory pathnames.

Consider using the [the pathlib equivalents for os functions](https://docs.python.org/3/library/pathlib.html#correspondence-to-tools-in-the-os-module).

The existing methods in the standard library have been updated to support Path objects.

To list all of the the files in a directory, use either the _.iterdir()_ function of a Path object, or the _os.scandir()_ function.

This [RealPython article](https://realpython.com/working-with-files-in-python/#directory-listing-in-modern-python-versions) provides a full explanation of the different Python functions for working with files and directories.

The _pathlib_ module was added to the standard library in Python 3.4, and other standard library functions were updated to support Path objects in version 3.5 of Python.

### Use os.scandir() Instead of os.listdir()

The _os.scandir()_ function is significantly faster and more efficient than _os.listdir()_. Use _os.scandir()_ wherever you previously used the _os.listdir()_ function.

This function provides an iterator, and works with a context manager:

```python
import os

with os.scandir('some_directory/') as entries:
    for entry in entries:
        print(entry.name)
```

The context manager frees resources as soon as the function completes. Use this option if you are concerned about performance or concurrency.

The _os.walk()_ function now calls _os.scandir()_, so it automatically has the same improved performance as this function.

The _os.scandir()_ function was added in version 3.5 of Python.

> [PEP 471](https://www.python.org/dev/peps/pep-0471/) explains _os.scandir()_.

### Run External Commands with subprocess

The [subprocess](https://docs.python.org/3/library/subprocess.html) module provides a safe way to run external commands. Use _subprocess_ rather than shell backquoting or the functions in _os_, such as _spawn_, _popen2_ and _popen3_. The _subprocess.run()_ function in current versions of Python is sufficient for most cases.

> [PEP 324](https://www.python.org/dev/peps/pep-0324/) explains subprocess in detail.

### Use httpx for Web Clients

Use [httpx](https://www.python-httpx.org/) for Web client applications. It [supports HTTP/2](https://www.python-httpx.org/http2/), and [async](https://www.python-httpx.org/async/). The httpx package supersedes [requests](https://requests.readthedocs.io/en/latest/), which only supports HTTP 1.1.

Avoid using _urllib.request_ from the Python standard library. It was designed as a low-level library, and lacks the features of httpx.

## Best Practices for Python Projects

Consider [using a project tool](#use-a-project-tool) to set up and develop your Python projects. If you decide not to use a project tool, set up your projects to follow the best practices in this section.

### Use a pyproject.toml File

Create a _pyproject.toml_ file in the root directory of each Python project. Use this file as the central place to store configuration information about the project and the tools that it uses. For example, you list [the dependencies of your project](https://www.pyopensci.org/python-package-guide/package-structure-code/declare-dependencies.html) in the _pyproject.toml_ file.

Python project tools like PDM and Hatch automatically create and use a _pyproject.toml_ file.

> The [pyOpenSci project documentation on pyproject.toml](https://www.pyopensci.org/python-package-guide/package-structure-code/pyproject-toml-python-package-metadata.html) provides an introduction to the file format. The various features of _pyproject.toml_ files are defined these PEPs: [PEP 517](https://peps.python.org/pep-0517/), [PEP 518](https://peps.python.org/pep-0518/), [PEP 621](https://peps.python.org/pep-0621/) and [PEP 660](https://peps.python.org/pep-0660/).

### Create a Directory Structure That Uses the src Layout

Python itself does not require a specific directory structure for your projects. The Python packaging documentation describes two popular directory structures: [the src layout and the flat layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/).
The [pyOpenSci project documentation on directory structures](https://www.pyopensci.org/python-package-guide/package-structure-code/python-package-structure.html) explains the practical differences between the two.

For modern Python projects, use the src layout. This requires you to use [editable installs](https://setuptools.pypa.io/en/latest/userguide/development_mode.html) of the packages in your project. [PDM](https://pdm-project.org) and [Hatch](https://hatch.pypa.io) support editable installs.

### Use Virtual Environments for Development

The [virtual environments](https://docs.python.org/3/tutorial/venv.html) feature enables you to define one or more separate sets of packages for each Python project, and switch between them. This ensures that a set of packages that you use for a specific purpose do not conflict with any other Python packages on the system. Always use Python virtual environments for your projects.

Several tools automate virtual environments. The [mise](https://mise.jdx.dev) version manager includes [support for virtual environments](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation). The [pyenv](https://github.com/pyenv/pyenv) version manager supports virtual environments with the [virtualenv plugin](https://github.com/pyenv/pyenv-virtualenv). If you use a tool like [PDM](https://pdm-project.org) or [Hatch](https://hatch.pypa.io) to develop your projects, these also manage Python virtual environments for you.

You can set up and use virtual environments with _venv_, which is part of the Python standard library. This is a manual process.

### Use Requirements Files to Install Packages Into Environments

Avoid using _pip_ commands to install individual packages into virtual environments. If you use [uv](https://docs.astral.sh/uv/), [PDM](https://pdm-project.org) or [Hatch](https://hatch.pypa.io) to develop your project, they can manage the contents of virtual environments for development and testing.

For other cases, use [requirements files](https://pip.pypa.io/en/stable/reference/requirements-file-format/). A requirements file can specify the exact version and hash for each required package.

You run a tool to read the dependencies in the _pyproject.toml_ file and generate a requirements file that lists the specific packages that are needed to provide those dependencies for the Python version and operating system. PDM, [pip-tools](https://pip-tools.readthedocs.io/en/stable/) and [uv](https://docs.astral.sh/uv/) include features to create requirements files.

You can then use [pip-sync](https://pip-tools.readthedocs.io/en/stable/cli/pip-sync/) or the _sync_ feature of _uv_ to make the packages in a target virtual environment match the list in the requirements file. This process ensures that any extra packages are removed from the virtual environment.

You can also run _pip install_ with a requirements file. This only attempts to install the specified packages. For example, these commands install the packages that are specified by the file _requirements-macos-dev.txt_ into the virtual environment _.venv-dev_:

```shell
source ./.venv-dev/bin/activate
python3 -m pip install --require-virtualenv -r requirements-macos-dev.txt
```

### Ensure That Requirements Files Include Hashes

Some tools require extra configuration to include package hashes in the requirements files that they generate. For example, you must set the _generate-hashes_ option for the _pip-compile_ and _uv_ utilities to generate _requirements.txt_ files that include hashes. Add this option to the relevant section of the _pyproject.toml_ file.

For _pip-tools_, add the option to the _tool.pip-tools_ section:

```toml
[tool.pip-tools]
# Set generate-hashes for pip-compile
generate-hashes = true
```

For _uv_, add the option to the _tool.uv.pip_ section:

```toml
[tool.uv.pip]
# Set generate-hashes for uv
generate-hashes = true
```

### pip-compile: Use the Correct Virtual Environment

If you do not already have a tool that can create requirements files, you can use the [pip-compile](https://pip-tools.readthedocs.io/en/stable/cli/pip-compile/) utility that is provided by [pip-tools](https://pip-tools.readthedocs.io/en/stable/).

To ensure that it calculates the correct requirements for your application, the _pip-compile_ tool must be run in a virtual environment that includes your application package. This means that you cannot use _pipx_ to install _pip-compile_.
