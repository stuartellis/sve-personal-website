+++
title = "Modern Good Practices for Python Development"
slug = "python-modern-practices"
date = "2025-10-17T23:01:00+01:00"
description = "Good development practices for modern Python"
categories = ["programming", "python"]
tags = ["python"]
+++

[Python](https://www.python.org/) has a long history, and it has evolved over time. This article describes some agreed modern best practices.

## Use a Helper to Run Python Tools

Use either [pipx](https://pipx.pypa.io) or [uv](https://docs.astral.sh/uv/) to run Python tools on development systems, rather than installing these applications with _pip_ or another method. Both _pipx_ and _uv_ automatically put each application into a separate [Python virtual environment](https://docs.python.org/3/tutorial/venv.html).

> Always follow the instructions on the [Website](https://pipx.pypa.io) to install _pipx_ on your operating system. This will ensure that _pipx_ works correctly with an appropriate Python installation.

Use the [pipx run](https://pipx.pypa.io/stable/#walkthrough-running-an-application-in-a-temporary-virtual-environment) feature of _pipx_ for most Python applications, or [uvx](https://docs.astral.sh/uv/#tool-management), which is the equivalent command for _uv_. These download the application to a cache and run it. For example, these commands download and run the latest version of [bpytop](https://github.com/aristocratos/bpytop), a system monitoring tool:

```shell
pipx run bpytop
```

```shell
uvx bpytop
```

The _bpytop_ tool is cached after the first download, which means that the second use of it will run as quickly as an installed application.

Use _pipx install_ or _uv tool install_ for tools that are essential for your development process. These options install the tool on to your system. This ensures that the tool is available if you have no Internet access, and that you keep the same version of the tool until you decide to upgrade it.

For example, if you use [pre-commit](https://pre-commit.com/) you should install it, rather than use a temporary copy. The _pre-commit_ tool automatically runs every time that we commit a change to version control, so we want it to be consistent and always available. To install _pre-commit_, run the appropriate command for _pipx_ or _uv_:

```shell
pipx install pre-commit
```

```shell
uv tool install pre-commit
```

## Using Python for Development

### Use a Project Tool

Always use a project tool, unless you have special requirements. There are several of these tools, each of which provides the same essential features. For example, all of these tools can generate a directory structure that follows best practices and they can all automate Python virtual environments, so that you do not need to manually create and activate environments as you work.

These tools can also install copies of Python, so that you do not need to set up Python yourself and have the correct version of Python for each project. The [section below](#install-python-with-tools-that-support-multiple-versions) explains in more detail.

[Poetry](https://python-poetry.org/) is currently the most popular tool for Python projects. It is mature and well-supported. Some projects use [Hatch](https://hatch.pypa.io), which provides a well-integrated set of features for building and testing Python packages. Consider using [PDM](https://pdm-project.org) or [uv](https://docs.astral.sh/uv/) for new projects. PDM and _uv_ closely align to the latest Python standards.

> _Avoid using [Rye](https://rye.astral.sh/)_. Rye has been superseded by _uv_.

You may need to create projects that include Python but cannot use Python project tools. In these cases, think carefully about the tools and directory structure that you will need, and ensure that you are familiar with the current [best practices for Python projects](https://www.stuartellis.name/articles/python-project-setup).

### Install Python With Tools That Support Multiple Versions

Instead of manually installing Python on to your development systems with packages from [the Python Website](https://www.python.org), use tools that provide copies of Python on demand. This means that you can choose a Python version for each of your projects, and upgrade them to new versions of Python later without interfering with other tools and projects that use Python.

If you enable the feature, project tools like Poetry and _uv_ will install copies of Python as needed. Avoid using this feature for production systems. The project tools use [standalone builds](https://github.com/astral-sh/python-build-standalone), which are modified versions of Python that are maintained by [Astral](https://astral.sh/), not the Python project. These standalone builds may have issues that are not present with other copies of Python.

Version manager tools like [mise](https://mise.jdx.dev) or [pyenv](https://github.com/pyenv/pyenv) also allow you to switch between different versions of Python at will, as well as providing the correct versions for projects.

> I provide a separate [article on using version managers](https://www.stuartellis.name/articles/version-managers/).

[Development Containers](https://containers.dev/) enable you to define a complete environment for a software project, which means that the project will always have a separate installation of Python. Development containers are a feature of Visual Studio Code and Jetbrains IDEs.

Both the pyenv tool and the [Visual Studio Code Dev Container feature](https://github.com/devcontainers/features/blob/main/src/python/README.md) automatically compile Python rather than using the standalone builds, but you must [change the mise configuration](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries) to use compilation.

### Use the Most Recent Version of Python That You Can

For new projects, choose the most recent stable version of Python 3. This ensures that you have the latest security fixes, as well as the fastest performance.

Upgrade your projects as new Python versions are released. The Python development team usually support each version for five years, but some Python libraries may only support each version of Python for a shorter period of time. If you use tools that support multiple versions of Python and automated testing, you can test your projects on new Python versions with little risk.

> _Avoid using Python 2._ Older operating systems include Python 2, but it is not supported by the Python development team or by the developers of most popular Python libraries.

### Avoid Using the Python Installation in Your Operating System

If your operating system includes a Python installation, avoid using it for your projects. This Python installation is for system tools. It is likely to use an older version of Python, and may not include all of the standard features. An operating system copy of Python should be [marked](https://packaging.python.org/en/latest/specifications/externally-managed-environments/#externally-managed-environments) to prevent you from installing packages into it, but not all operating systems set this marker.

## Developing Python Projects

### Format Your Code

Use a formatting tool with a plugin to your editor, so that your code is automatically formatted to a consistent style.

Consider using [Ruff](https://docs.astral.sh/ruff/), which provides both code formatting and quality checks for Python code. [Black](https://black.readthedocs.io/en/stable/) was the most popular code formatting tool for Python before the release of Ruff.

Use pre-commit hooks to run the formatting tool before each commit to source control. You should also run the formatting tool with your CI system, so that it rejects any code that does not match the format for your project.

### Use a Code Linter

Use a code linting tool with a plugin to your editor, so that your code is automatically checked for issues.

Consider using [Ruff](https://docs.astral.sh/ruff/) for linting Python code. The previous standard linter was [flake8](https://flake8.pycqa.org/en/latest/). Ruff includes the features of both flake8 and the most popular plugins for flake8, along with many other capabilities.

Use pre-commit hooks to run the linting tool before each commit to source control. You should also run the linting tool with your CI system, so that it rejects any code that does not meet the standards for your project.

### Use Type Hinting

Current versions of Python support type hinting. Consider using type hints in any critical application. If you develop a shared library, use type hints.

Once you add type hints, type checkers like [mypy](http://www.mypy-lang.org/) and [pyright](https://microsoft.github.io/pyright/) can check your code as you develop it. Code editors will read type hints to display information about the code that you are working with. You can also add a type checker to your pre-commit hooks and CI to validate that the code in your project is consistent.

If you use [Pydantic](https://docs.pydantic.dev/) in your application, it can work with type hints. If you use mypy, add the [plugin for Pydantic](https://docs.pydantic.dev/latest/integrations/mypy/) to improve the integration between mypy and Pydantic.

> [PEP 484 - Type Hints](https://peps.python.org/pep-0484/) and [PEP 526 – Syntax for Variable Annotations](https://peps.python.org/pep-0526/) define the notation for type hinting.

### Test with pytest

Use [pytest](http://pytest.org) for testing. Use the _unittest_ module in the standard library for situations where you cannot add _pytest_ to the project.

By default, _pytest_ runs tests in the order that they appear in the test code. To avoid issues where tests interfere with each other, always add the [pytest-randomly](https://pypi.org/project/pytest-randomly/) plugin to _pytest_. This plugin causes _pytest_ to run tests in random order. Randomizing the order of tests is a common good practice for software development.

To see how much of your code is covered by tests, add the [pytest-cov](https://pytest-cov.readthedocs.io) plugin to _pytest_. This plugin uses [coverage](https://coverage.readthedocs.io) to analyze your code.

### Package Your Projects

Always package the applications and code libraries that you would like to share with other people. Packages enable people to use your code with the operating systems and tools that they prefer to work with, and also allow them to manage which version of your code they use.

Use [wheel](https://packaging.python.org/en/latest/specifications/binary-distribution-format/) packages to distribute the Python libraries that you create. Read the [Python Packaging User Guide](https://packaging.python.org/en/latest/flow/) for an explanation of how to build and distribute wheel packages.

You can also use _wheel_ packages to share development tools. If you publish your Python application as a _wheel_, other developers can run it with _uv_ or _pipx_. All _wheel_ packages require an existing installation of Python.

For all other cases, package your applications in a format that includes a copy of the required version of Python as well as your code and the dependencies. This ensures that your code runs with the expected version of Python, and that it has the correct version of each dependency. You can package applications either in container images or as executable files.

Use container images to package Python applications that are intended to be run by a service, such as Docker or a workflow engine, especially if the application provides a network service itself, such as a Web application. You can build OCI container images with Docker, [buildah](https://buildah.io/) and other tools. OCI container images can run on any system that uses Docker, Podman or Kubernetes, as well as on cloud infrastructure. Consider using the [official Python container image](https://hub.docker.com/_/python) as the base image for your application container images.

Use [PyInstaller](https://pyinstaller.org/) or [Nuitka](https://nuitka.net) to publish desktop and command-line applications as a single executable file. Each executable file includes a copy of Python, along with your code and the required dependencies. Each executable will only run on the type of operating system and CPU that it was compiled to use. For example, an executable for Windows on Intel-compatible machines will not run on macOS.

> _Requirements files:_ If you use requirements files to build or deploy projects then configure your tools to [use hashes](#ensure-that-requirements-files-include-hashes).

### Ensure That Requirements Files Include Hashes

Python tools support [hash checking](https://pip.pypa.io/en/stable/topics/secure-installs/#hash-checking-mode) to ensure that packages are valid. Some tools require extra configuration to include package hashes in the requirements files that they generate. For example, you must set the _generate-hashes_ option for the _pip-compile_ and _uv_ utilities to generate _requirements.txt_ files that include hashes. Add this option to the relevant section of the _pyproject.toml_ file.

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

## Language Syntax

### Create Data Classes for Custom Data Objects

Python code frequently has classes for _data objects_: items that exist to store values, but do not carry out actions. If you are creating classes for data objects in your Python code, consider using either [Pydantic](https://docs.pydantic.dev/) or the built-in [data classes](https://docs.python.org/3/library/dataclasses.html) feature.

Pydantic provides validation, serialization and other features for data objects. You need to define the classes for Pydantic data objects with type hints.

The built-in Python syntax for data classes offers fewer capabilities than Pydantic. The data class syntax does enable you to reduce the amount of code that you need to define data objects. Each data class acts as a standard Python class. Data classes also provide a limited set of extra features, such as the ability to mark instances of a data class as [frozen](https://docs.python.org/3/library/dataclasses.html#frozen-instances).

> [PEP 557](https://www.python.org/dev/peps/pep-0557/) describes data classes.

### Use enum or Named Tuples for Immutable Sets of Key-Value Pairs

Use the _enum_ type for immutable collections of key-value pairs. Enums can use class inheritance.

Python also has _collections.namedtuple()_ for immutable key-value pairs. This feature was created before _enum_ types. Named tuples do not use classes.

### Format Strings with f-strings

The new [f-string](https://docs.python.org/3/reference/lexical_analysis.html#f-strings) syntax is both more readable and has better performance than older methods. Use f-strings instead of _%_ formatting, _str.format()_ or _str.Template()_.

The older features for formatting strings will not be removed, to avoid breaking backward compatibility.

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

### Configuration: Use Environment Variables or TOML

Use environment variables for options that must be passed to an application each time that it starts. If your application is a command-line tool, you should also provide options that can override the environment variables.

Use [TOML](https://toml.io/) for configuration files that must be written or edited by human beings. This format is an open standard that is used across Python projects and is also supported by other programming languages. For example, TOML is the default configuration file format for Rust projects.

Python 3.11 and above include [tomllib](https://docs.python.org/3/library/tomllib.html) to read the TOML format. If your Python software must generate TOML, you need to add [Tomli-W](https://pypi.org/project/tomli-w/) to your project.

TOML replaces the INI file format. Avoid using INI files, even though the [module for INI support](https://docs.python.org/3/library/configparser.html) has not yet been removed from the Python standard library.

### Data Storage: Use Modern File Formats

There are now data file formats that are open, standardized and portable. If possible, use these formats:

- [JSON](https://en.wikipedia.org/wiki/JSON) - Plain-text format for data objects
- [SQLite](https://sqlite.org) - Binary format for self-contained and robust database files
- [Apache Parquet](https://parquet.apache.org/) - Binary format for efficient storage of tabular data

All of the versions of Python 3 include modules for [JSON](https://docs.python.org/3/library/json.html) and [SQLite](https://docs.python.org/3/library/sqlite3.html). Python dataframe libraries like [Pandas](https://pandas.pydata.org) support Parquet, JSON and SQLite. [DuckDB](https://duckdb.org/docs/stable/clients/python/overview) also supports all three formats.

If you need to work with other data formats, consider using a modern file format in your application and adding features to import data or generate exports in other formats when necessary.

> DuckDB and Pandas include features to import and export data to other file formats, including Excel.

In most cases, you should use the JSON format to transfer data between systems, especially if the systems must communicate with HTTP. JSON documents can be used for any kind of data. Every programming language and modern SQL database supports JSON. You can validate JSON documents with [JSON Schemas](https://json-schema.org/). [Pydantic](https://docs.pydantic.dev/) enables you to export your Python data objects to JSON and generate JSON Schemas from the data models.

Each SQLite database is a single file. Use SQLite files for [data and configuration for applications](https://sqlite.org/appfileformat.html) as well as for queryable databases. They are arguably more portable and resilient than sets of plain-text files. SQLite is widely-supported, [robust](https://sqlite.org/hirely.html) and the file format is [guaranteed to be stable and portable for decades](https://sqlite.org/lts.html). Each SQLite database file can safely be several gigabytes in size.

> You can use SQLite databases for any kind of data. They can be used to [store and query data in JSON format](https://sqlite.org/json1.html), they hold plain text with [optional full-text search](sqlite.org/fts5.html), and they can store binary data.

If you need to query a large set of tabular data, put a copy in [Apache Parquet](https://parquet.apache.org/) files and use that copy for your analysis. The Parquet format is specifically designed for large-scale data operations, and scales to tables with millions of rows.

> I provide a separate article with more details about [modern data formats](https://www.stuartellis.name/articles/modern-data-file-formats/).

### Avoid Problematic File Formats

Avoid these older file formats:

- INI - Use TOML instead
- CSV - Use SQLite or Apache Parquet instead
- YAML - Use TOML or JSON instead

Systems can implement legacy formats in different ways, which means that there is a risk that data will not be read correctly when you use a file that has been created by another system. Files that are edited by humans are also more likely to contain errors, due to the complexities and inconsistency of these formats.

### Working with YAML Files

If you need to work with YAML in Python, use [ruamel.yaml](https://pypi.org/project/ruamel.yaml/). This supports YAML version 1.2. Avoid using [PyYAML](https://pypi.org/project/PyYAML/), because it only supports version 1.1 of the YAML format.

### Working with CSV Files

Avoid creating CSV files. If you use DuckDB or Pandas then you can import and export data to Parquet and Excel file formats. Unlike CSV, Parquet and Excel file formats store explicit data types for items.

Python does include [a module for CSV files](https://docs.python.org/3/library/csv.html), but consider using DuckDB instead. DuckDB provides [CSV support](https://duckdb.org/docs/stable/data/csv/overview.html) that is [tested for its ability to handle incorrectly formatted files](https://duckdb.org/2025/04/16/duckdb-csv-pollock-benchmark.html).

### Use Logging for Diagnostic Messages, Rather Than print()

The built-in _print()_ statement is convenient for adding debugging information, but you should use logging in applications. If you use an application framework, it should include features for logging.

If you are implementing logging yourself, consider using [loguru](https://loguru.readthedocs.io/en/stable/) or [structlog](https://www.structlog.org/). Use a [structured format](https://www.structlog.org/en/stable/why.html) such as JSON, so that your logs can be parsed and analyzed later. Always include timestamps with timezones, and use the UTC timezone on servers and shared systems.

Avoid using the [logging module](https://docs.python.org/3/library/logging.html) in the Python standard library. It is slow, more difficult to configure than modern logging libraries, and the default configuration does not provide logs with timestamps.

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

Methods in the standard library support Path objects. For example, to list all of the the files in a directory, you can use either the _.iterdir()_ function of a Path object, or the _os.scandir()_ function.

This [RealPython article](https://realpython.com/working-with-files-in-python/#directory-listing-in-modern-python-versions) provides a full explanation of the different Python functions for working with files and directories.

### Use os.scandir() Instead of os.listdir()

The _os.scandir()_ function is significantly faster and more efficient than _os.listdir()_. If you previously used the _os.listdir()_ function, update your code to use _os.scandir()_.

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

Use [httpx](https://www.python-httpx.org/) for Web client applications. Many Python applications include [requests](https://requests.readthedocs.io/en/latest/), but you should use httpx for new projects.

The httpx package completely supersedes _requests_. It supports [HTTP/2](https://www.python-httpx.org/http2/) and [async](https://www.python-httpx.org/async/), which are not available with requests.

Avoid using [urllib.request](https://docs.python.org/3/library/urllib.request.html) from the Python standard library. It was designed as a low-level library, and lacks the features of requests and _httpx_.
