+++
title = "Modern Good Practices for Python Development"
slug = "python-modern-practices"
date = "2025-12-28T23:21:00+00:00"
description = "Good development practices for modern Python"
categories = ["programming", "python"]
tags = ["python"]
+++

[Python](https://www.python.org/) has a long history, and it has evolved over time. This article describes some modern good practices.

## Use a Helper to Run Python Tools

Use either [pipx](https://pipx.pypa.io) or [uv](https://docs.astral.sh/uv/) to run Python tools on development systems, rather than installing these applications with _pip_ or another method. Both _pipx_ and _uv_ automatically put each application into a separate [Python virtual environment](https://docs.python.org/3/tutorial/venv.html).

Follow the instructions on the [Website](https://pipx.pypa.io) to install _pipx_ on your operating system. This will ensure that _pipx_ works correctly with an appropriate Python installation. The _uv_ tool is a single executable file that is written in Rust, which means that you do not need to install any version of Python yourself before you use it.

Use the [pipx run](https://pipx.pypa.io/stable/#walkthrough-running-an-application-in-a-temporary-virtual-environment) feature of _pipx_ for most Python applications, or [uvx](https://docs.astral.sh/uv/#tool-management), which is the equivalent command for _uv_. These download the application to a cache and run it. For example, these commands download and run the latest version of [bpytop](https://github.com/aristocratos/bpytop), a system monitoring tool:

```shell
pipx run bpytop
```

```shell
uvx bpytop
```

The _bpytop_ tool is cached after the first download, which means that the second use of it will run as quickly as an installed application.

Use _pipx install_ or _uv tool install_ for tools that are essential for your development process. These options install the tool on to your system. This ensures that the tool is available if you have no Internet access, and that you keep the same version of the tool until you decide to upgrade it.

For example, if you use a manager like [prek](https://prek.j178.dev/) or [pre-commit](https://pre-commit.com/) for Git hooks you should install it, rather than use a temporary copy. Git hooks automatically run every time that we commit a change to version control, so we need the hook manager to be consistent and always available. To install _pre-commit_, run the appropriate command for _pipx_ or _uv_:

```shell
pipx install pre-commit
```

```shell
uv tool install pre-commit
```

## Using Python for Development

### Use a Project Tool

Use a project tool when you work with Python. There are several of these tools, which all provide the key features for managing Python projects. All of them can generate a directory structure that follows best practices, manage package dependencies and automate Python virtual environments, so that you do not need to manually create and activate environments as you work.

Project tools can also manage the versions of Python, so that you will automatically have the correct version of Python for each project. Your project tool can install copies of Python as needed. The [section below](#install-python-with-tools-that-support-multiple-versions) explains in more detail.

[Poetry](https://python-poetry.org/) is currently the most popular tool for managing Python projects, and it is a good choice for most cases. It is well-supported and has been steadily developed. The feature to provide versions of Python is currently [experimental](https://python-poetry.org/docs/cli/#python), so you should use a version manager alongside Poetry for significant projects.

There are currently several other well-known project tools for Python. The [PDM](https://pdm-project.org) project and [uv](https://docs.astral.sh/uv/) from [Astral](https://astral.sh/) are less conservative than Poetry, adopting new features and standards more rapidly. Some teams use [Hatch](https://hatch.pypa.io), which provides a well-integrated set of features for building and testing Python software products.

> _Avoid using [Rye](https://rye.astral.sh/)_. Rye has been superseded by _uv_.

You may need to create projects that include Python but cannot use Python project tools. In these cases, think carefully about the tools and directory structure that you will need, and ensure that you are familiar with the current [best practices for Python projects](https://www.stuartellis.name/articles/python-project-setup).

### Install Python With Tools That Support Multiple Versions

Instead of manually installing Python on to your development systems with packages from [the Python Website](https://www.python.org), use tools that provide copies of Python on demand. This means that you can choose a Python version for each of your projects, and upgrade projects to new versions of Python later without interfering with other tools and projects that use Python.

The project tools can install copies of Python as needed. They use [standalone builds](https://github.com/astral-sh/python-build-standalone), which are modified versions of Python that are maintained by [Astral](https://astral.sh/), not the Python project. The standalone builds have [some limitations](https://gregoryszorc.com/docs/python-build-standalone/main/quirks.html) that are not present with other copies of Python.

Version manager tools like [mise](https://mise.jdx.dev) or [pyenv](https://github.com/pyenv/pyenv) also allow you to switch between different versions of Python at will, as well as providing the defined version for each of your projects. I provide a separate [article on using version managers](https://www.stuartellis.name/articles/version-managers/).

[Development Containers](https://containers.dev/) enable you to define a complete environment for a software project, which means that the project will always have a separate installation of Python. Development containers are a feature of Visual Studio Code and Jetbrains IDEs.

Both the pyenv tool and the [Visual Studio Code Dev Container feature](https://github.com/devcontainers/features/blob/main/src/python/README.md) automatically compile Python from source code, rather than using the third-party standalone builds. For mise, you will need to [change the configuration](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries) if you prefer to compile Python from the official sources rather than downloading standalone builds.

### Use the Most Recent Version of Python That You Can

For new projects, choose the most recent stable version of Python 3. This ensures that you have the latest security fixes, as well as the fastest performance.

Upgrade your projects as new Python versions are released. The Python development team usually support each version for five years, but some Python libraries may only support each version of Python for a shorter period of time. If you use tools that support multiple versions of Python and automated testing, you can test your projects on new Python versions with little risk.

> _Avoid using Python 2._ Older operating systems include Python 2, but it is not supported by the Python development team or by the developers of most popular Python libraries.

### Avoid Using the Python Installation in Your Operating System

If your operating system includes a Python installation, avoid using it for your projects. This Python installation is for system tools. It is likely to use an older version of Python, and may not include all of the standard features. An operating system copy of Python should be [marked](https://packaging.python.org/en/latest/specifications/externally-managed-environments/#externally-managed-environments) to prevent you from installing packages into it, but not all operating systems set this marker.

## Application Design

### Use a Modern Framework for CLI Applications

Consider using the [Cyclopts](https://cyclopts.readthedocs.io/en/latest/) framework or the [Typer](https://typer.tiangolo.com/) library for building new CLI applications. Both of these use type hints and are built for modern Python. Many projects still use the older [Click](https://click.palletsprojects.com/) framework.

If you must limit your project to only use the Python standard library, use the [argparse](https://docs.python.org/3/library/argparse.html) module. The _optparse_ module is officially deprecated, so update code that uses _optparse_ or _getopt_ to use _argparse_ instead. Refer to [the argparse tutorial](https://docs.python.org/3/howto/argparse.html) in the official documentation for more details.

### Use Products That Enable Concurrency and async

When you need to run concurrent operations, look for existing products that suit your needs. For example, you can use a workflow engine such as [Apache Airflow](https://airflow.apache.org/) or [Prefect](https://www.prefect.io/) to run tasks, or build a Web application by combining a framework like [FastAPI](https://fastapi.tiangolo.com/) with an application server, such as [Granian](https://github.com/emmett-framework/granian) or [Gunicorn](https://gunicorn.org/). These products enable you to run your Python code concurrently on multiple CPUs or multiple computers, and can use asynchronous code when it makes sense to do so.

By default, each Python process uses a single thread on a single CPU, so that it can can only perform one operation at a time. You can have multiple threads within a process, but this only enables switching between threads. To achieve full concurrency with Python, you must run multiple Python processes so that each process can run its threads on a separate CPU.

The [asynchronous features of Python](https://docs.python.org/3/library/asyncio.html) enable threads to avoid blocking on I/O operations. To use asynchronous I/O in your code, you must use a Python library or framework that supports it. For example, the FastAPI Web framework [supports both types of function](https://fastapi.tiangolo.com/async/) in the same application. Code that uses asynchronous I/O must not call _any_ other function that uses synchronous I/O, such as _open()_, or the _logging_ module in the standard library. Instead, you need to use either the equivalent functions from _asyncio_ in the standard library or ensure that the products and libraries that you use are designed to support asynchronous code.

> If you use a framework that supports asynchronous I/O it may provide safe functions for services like logging, but you must still ensure that asynchronous functions never call any synchronous functions.

If you need to build a custom application with concurrency, consider using the [concurrent.futures](https://docs.python.org/3/library/concurrent.futures.html) package in the Python standard library. This includes executors for distributing work across a pool of multiple threads or separate CPUs.

### Plan for Distributing Your Work

Always plan for how you will distribute the work that you produce in a project. The simplest method is through version control, but packages enable people to use your code with the operating systems and tools that they prefer to work with, rather than requiring that each system has developer tools installed.

Project tools like Poetry include support for building [wheel](https://packaging.python.org/en/latest/specifications/binary-distribution-format/) packages. The _wheel_ format is for sharing between Python installations. You can use _wheel_ packages to publish tools for other developers, as well as libraries for use in other Python projects. If you publish your Python application as a _wheel_, other people can run it with the _pipx_ and _uv_ tools, as explained in the section on [helpers](#use-a-helper-to-run-python-tools).

> Read the [Python Packaging User Guide](https://packaging.python.org/en/latest/flow/) for more about wheel packages.

For other cases, you should use extra tools to package your work into a format that includes a copy of the required version of Python as well as your code and the dependencies. This ensures that your code runs with the expected version of Python, and that it has the correct version of each dependency.

Use OCI container images to package Python applications that are intended to be run by a service, such as Docker or a workflow engine, especially if the application provides a network service itself, such as a Web application. You can build OCI container images with Docker, [buildah](https://buildah.io/) and other tools to include a copy of Python, along with your code and the required dependencies. OCI container images can run on any system that uses Docker, Podman or Kubernetes, as well as on cloud infrastructure. Consider using the [official Python container image](https://hub.docker.com/_/python) as the base image for your application container images.

Use [PyInstaller](https://pyinstaller.org/) or [Nuitka](https://nuitka.net) to compile desktop and command-line applications as a single executable file. Each executable file includes a copy of Python, along with your code and the required dependencies. Optionally, you can then put the executable in an operating system package, such as an RPM or DEB package for Linux. Each executable will only run on the type of operating system and CPU that it was compiled to use. For example, an executable for Microsoft Windows on Intel-compatible machines will work on all editions of Windows, but it will not run on macOS.

> _Requirements files:_ If you use requirements files to build or deploy projects then configure your tools to [use hashes](#ensure-that-requirements-files-include-hashes).

### Configuration: Use Environment Variables or TOML

Use environment variables for options that must be passed to an application each time that it starts. If your application is a command-line tool, you should also provide options that can override the environment variables.

Use [TOML](https://toml.io/) for configuration files that must be written or edited by human beings. This format is an open standard that is used across Python projects and is also supported by other programming languages. For example, TOML is the default configuration file format for Rust projects.

Python 3.11 and above include [tomllib](https://docs.python.org/3/library/tomllib.html) to read the TOML format. If your Python software must generate TOML, you need to add [Tomli-W](https://pypi.org/project/tomli-w/) to your project.

TOML replaces the INI format. Avoid using INI for projects, even though the [module for INI support](https://docs.python.org/3/library/configparser.html) has not yet been removed from the Python standard library.

### Set Up Logging for Diagnostic Messages, Rather Than print()

The built-in _print()_ statement is convenient for adding debugging information, but you should use logging in applications.

Use a [structured format for your logs](https://www.structlog.org/en/stable/why.html) so that they can be parsed and analyzed later. The format should always include timestamps with timezones. We include the timezones so that the data can be accurately searched and analyzed by other systems. We should expect servers and shared systems to use the UTC timezone, but log analyzers can never make this assumption.

Many frameworks use the [logging module](https://docs.python.org/3/library/logging.html) in the Python standard library, but this module was not designed to modern standards and requires some configuration to produce well-formatted logs. When you implement logging, consider using [loguru](https://loguru.readthedocs.io/en/stable/) or [structlog](https://www.structlog.org/).

### Decide On A HTTP Client Library

Avoid using [urllib.request](https://docs.python.org/3/library/urllib.request.html) from the Python standard library. It was designed as a low-level library for HTTP, and lacks the features of modern Web client libraries. Many Python applications include [requests](https://requests.readthedocs.io/en/latest/), but this only supports HTTP/1.1, and cannot be used with async code. Consider alternative Web client libraries like [aiohttp](https://pypi.org/project/aiohttp/) when you want to use async I/O.

> Python SDKs for cloud services will have a dependency on a Web client library. Check which client library an SDK uses before you include it in your project.

## Data Formats and Storage

There are now data file formats that are open, standardized and portable. If possible, use these formats, and avoid older formats. Modern formats are standardized, can be reliably read by many different systems and can be processed efficiently, even with large quantities of data. Some older formats are not standardized, which means that different systems can write different variations, which then cause errors when you move data between systems.

### Modern Data Formats

If possible, use these formats for structured data:

- [JSON](https://en.wikipedia.org/wiki/JSON) - Plain-text format for data objects
- [SQLite](https://sqlite.org) - Binary format for self-contained and robust database files
- [Apache Parquet](https://parquet.apache.org/) - Binary format for efficient storage of tabular data

All of the versions of Python 3 include modules for [JSON](https://docs.python.org/3/library/json.html) and [SQLite](https://docs.python.org/3/library/sqlite3.html). The [Pandas](https://pandas.pydata.org) dataframe library supports Parquet, JSON and SQLite. [DuckDB](https://duckdb.org/docs/stable/clients/python/overview) also supports all three formats.

If you need to work with other data formats, consider using a modern file format in your application and adding features to import data or generate exports in other formats when necessary. For example, DuckDB and Pandas include features to import and export data to files in the Excel format.

In most cases, you should use the JSON format to transfer data between systems, especially if the systems must communicate with HTTP. JSON documents can be used for any kind of data. Since JSON is plain-text, data in this format can be stored in either files or in a database. Every programming language and modern SQL database supports JSON.

> You can validate JSON documents with [JSON Schemas](https://json-schema.org/). [Pydantic](https://docs.pydantic.dev/) enables you to export your Python data objects to JSON and generate JSON Schemas from the data models.

Each SQLite database is a single file. Use SQLite files for [data and configuration for applications](https://sqlite.org/appfileformat.html) as well as for queryable databases. They are arguably more portable and resilient than sets of plain-text files. SQLite is widely-supported, [robust](https://sqlite.org/hirely.html) and the file format is [guaranteed to be stable and portable for decades](https://sqlite.org/lts.html). Each SQLite database file can safely be gigabytes in size.

> You can use SQLite databases for any kind of data. They can be used to [store and query data in JSON format](https://sqlite.org/json1.html), they hold plain text with [optional full-text search](sqlite.org/fts5.html), and they can store binary data.

If you need to query a large set of tabular data, put a copy in [Apache Parquet](https://parquet.apache.org/) files and use that copy for your work. The Parquet format is specifically designed for large-scale data operations, and scales to tables with millions of rows. Parquet can store data that is in JSON format, as well as standard data types.

> I provide a separate article with more details about [modern data formats](https://www.stuartellis.name/articles/modern-data-file-formats/).

### Avoid Problematic File Formats

Avoid these older file formats:

- INI - Use TOML instead
- CSV - Use SQLite or Apache Parquet instead
- YAML - Use TOML or JSON instead

Systems can implement legacy formats in different ways, which means that there is a risk that data will not be read correctly when you use a file that has been created by another system. Files that are edited by humans are also more likely to contain errors, due to the complexities and inconsistency of these formats.

### Working with CSV Files

Python does include [a module for CSV files](https://docs.python.org/3/library/csv.html), but consider using DuckDB instead. DuckDB provides [CSV support](https://duckdb.org/docs/stable/data/csv/overview.html) that is [tested for its ability to handle incorrectly formatted files](https://duckdb.org/2025/04/16/duckdb-csv-pollock-benchmark.html).

Avoid creating CSV files, because modern data formats are all more capable. If you use DuckDB or Pandas then you can import and export data to Parquet, SQLite and Excel file formats. Unlike CSV, these file formats store explicit data types for items.

### Working with YAML Files

If you need to work with YAML in Python, use [ruamel.yaml](https://pypi.org/project/ruamel.yaml/). This supports YAML version 1.2. Avoid using [PyYAML](https://pypi.org/project/PyYAML/), because it only supports version 1.1 of the YAML format.

Avoid creating YAML files, because modern formats offer better options. Consider using [TOML](#configuration-use-environment-variables-or-toml) for application configuration, and JSON or table-based storage like SQLite for larger sets of data.

## Developing Python Projects

### Format Your Code

Use a formatting tool with a plugin to your editor, so that your code is automatically formatted to a consistent style.

Consider using [Ruff](https://docs.astral.sh/ruff/), which provides both code formatting and quality checks for Python code. [Black](https://black.readthedocs.io/en/stable/) was the most popular code formatting tool for Python before the release of Ruff.

Use Git hooks to run the formatting tool before each commit to source control. You should also run the formatting tool with your CI system, so that it rejects any code that does not match the format for your project.

### Use a Code Linter

Use a code linting tool with a plugin to your editor, so that your code is automatically checked for issues.

Consider using [Ruff](https://docs.astral.sh/ruff/) for linting Python code. The previous standard linter was [flake8](https://flake8.pycqa.org/en/latest/). Ruff includes the features of both flake8 and the most popular plugins for flake8, along with many other capabilities.

Use Git hooks to run the linting tool before each commit to source control. You should also run the linting tool with your CI system, so that it rejects any code that does not meet the standards for your project.

### Use Type Hinting

Current versions of Python support type hinting. Consider using type hints in any critical application. If you develop a shared library, use type hints.

Once you add type hints, type checkers like [mypy](http://www.mypy-lang.org/) and [pyright](https://microsoft.github.io/pyright/) can check your code as you develop it. Code editors will read type hints to display information about the code that you are working with. You can also add a type checker to your Git hooks and CI to validate that the code in your project is consistent.

If you use [Pydantic](https://docs.pydantic.dev/) in your application, it can work with type hints. If you use mypy, add the [plugin for Pydantic](https://docs.pydantic.dev/latest/integrations/mypy/) to improve the integration between mypy and Pydantic.

> [PEP 484 - Type Hints](https://peps.python.org/pep-0484/) and [PEP 526 – Syntax for Variable Annotations](https://peps.python.org/pep-0526/) define the notation for type hinting.

### Test with pytest

Use [pytest](http://pytest.org) for testing. Use the _unittest_ module in the standard library for situations where you cannot add _pytest_ to the project.

By default, _pytest_ runs tests in the order that they appear in the test code. To avoid issues where tests interfere with each other, always add the [pytest-randomly](https://pypi.org/project/pytest-randomly/) plugin to _pytest_. This plugin causes _pytest_ to run tests in random order. Randomizing the order of tests is a common good practice for software development.

To see how much of your code is covered by tests, add the [pytest-cov](https://pytest-cov.readthedocs.io) plugin to _pytest_. This plugin uses [coverage](https://coverage.readthedocs.io) to analyze your code.

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

### Format Strings with f-strings or t-strings

The [f-string](https://docs.python.org/3/reference/lexical_analysis.html#f-strings) syntax is both more readable and has better performance than older methods for formatting strings. Python 3.14 also includes the [t-string syntax](https://t-strings.help/), which supports more advanced cases. Use f-strings or t-strings instead of _%_ formatting, _str.format()_ or _str.Template()_.

The older features for formatting strings will not be removed, to avoid breaking backward compatibility.

> [PEP 498](https://www.python.org/dev/peps/pep-0498/) explains f-strings in detail. [PEP 750](https://peps.python.org/pep-0750/) explains t-strings.

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

### Use pathlib for File and Directory Paths

Use [pathlib](https://docs.python.org/3/library/pathlib.html) objects instead of strings whenever you need to work with file and directory pathnames. Consider using the [the pathlib equivalents for os functions](https://docs.python.org/3/library/pathlib.html#correspondence-to-tools-in-the-os-module) as well.

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

### Use collections.abc for Custom Collection Types

The abstract base classes in _collections.abc_ provide the components for building your own custom collection types.

Use these classes, because they are fast and well-tested. The implementations in Python 3.7 and above are written in C, to provide better performance than Python code.

### Use breakpoint() for Debugging

This function drops you into the debugger at the point where it is called. Both the [built-in debugger](https://docs.python.org/3/library/pdb.html) and external debuggers can use these breakpoints.

The [breakpoint()](https://docs.python.org/3/library/functions.html#breakpoint) feature was added in version 3.7 of Python.

> [PEP 553](https://www.python.org/dev/peps/pep-0553/) describes the _breakpoint()_ function.
