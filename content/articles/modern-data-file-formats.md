+++
title = "Modern Data File Formats"
slug = "modern-data-file-formats"
date = "2025-10-12T12:20:00+01:00"
description = "Data file formats for modern systems"
categories = ["programming", "python", "javascript"]
tags = ["python", "javascript"]
+++

This article suggests data file formats for modern systems, and explains some of the well-known formats that they can replace.

All of the suggested formats are open, standardized and portable. If you need to work with other file formats, consider using a modern file format in your application and importing data or generating exports in other file formats as you need them.

## JSON

In most cases, you should use the [JSON](https://en.wikipedia.org/wiki/JSON) format to transfer data between systems, especially if they must communicate with HTTP. JSON documents can be used for any kind of data. You can validate JSON documents with [JSON Schemas](https://json-schema.org/).

Vendors publish the schemas for their products to the [public Schema Store](https://www.schemastore.org/). You can [create schemas](https://json-schema.org/learn/getting-started-step-by-step) for the documents in your own projects. [Pydantic](https://docs.pydantic.dev/) enables you to generate JSON Schemas for your own Python data objects.

Every programming language and modern SQL database supports JSON. For example, all of the versions of Python 3 includes [a module](https://docs.python.org/3/library/json.html) for JSON.

## SQLite

Use SQLite to store sets of data that must be available for a long time, such as [the data stores for applications](https://sqlite.org/appfileformat.html). It uses tables that will store standard types of data, including plain text with [full-text search](sqlite.org/fts5.html) and will also [store and query data in JSON format](https://sqlite.org/json1.html). SQLite is widely-supported, [designed to be resilient](https://sqlite.org/hirely.html) and the file format is [guaranteed to be stable and portable for decades](https://sqlite.org/lts.html).

Every modern programming language has libraries for SQLite. All of the versions of Python 3 includes [a module](https://docs.python.org/3/library/sqlite3.html) as part of the standard library. Node.js also now includes [support for SQLite](https://nodejs.org/api/sqlite.html), although this is currently marked as experimental.

> DuckDB can read and write SQLite databases if you install an [extension](https://duckdb.org/docs/stable/core_extensions/sqlite).

## Specialized File Formats

### Configuration: TOML

Use [TOML](https://toml.io/) for configuration files that must be written or edited by human beings. TOML is the default configuration file format for Rust projects. Python 3.11 and above include [tomllib](https://docs.python.org/3/library/tomllib.html) to read the TOML format. If your Python software must generate TOML, you need to add [Tomli-W](https://pypi.org/project/tomli-w/) to your project.

> [PEP 680 - tomllib: Support for Parsing TOML in the Standard Library](https://peps.python.org/pep-0680/) explains why TOML is now included with Python.

### Tabular Data: Apache Parquet

If you need to query a large set of tabular data, store a copy in [Apache Parquet](https://parquet.apache.org/) files. This format is specifically designed for large-scale data operations. It is portable, widely-supported and supports features like indexing, compression and encryption.

[DuckDB](https://duckdb.org/docs/stable/clients/python/overview.html) and [Pandas](https://pandas.pydata.org) dataframes closely integrate with Python and support the Apache Parquet format.

## Obsolete File Formats

Avoid these older file formats:

- CSV - Use SQLite or Apache Parquet instead
- INI - Use TOML instead
- YAML - Use TOML or JSON instead

Systems can implement these legacy formats in different ways, which means that there is a risk that data will not be read correctly when you use a file that has been created by another system. Files that are edited by humans are also more likely to contain errors, due to the complexities and inconsistency of these formats.

### INI

TOML completely replaces the INI file format. Avoid using INI files, even though the [module for INI support](https://docs.python.org/3/library/configparser.html) has not yet been removed from the Python standard library.

### CSV

CSV formats are frequently used to create sets of data that are intended to be portable, so that the data can be copied between different systems. In practice, systems can implement CSV formats in different ways, which means that there is a risk that data will not be read correctly when you use a CSV file that has been created by another system. CSV files that are edited by humans are also very likely to contain errors.

Use JSON, Apache Parquet or SQLite instead. All of these formats are portable between systems. Your code can use dataframes or DuckDB to analyze data that is stored in these formats.

Python includes [a module for CSV files](https://docs.python.org/3/library/csv.html), but consider using DuckDB instead. DuckDB provides [CSV support](https://duckdb.org/docs/stable/data/csv/overview.html) that is [tested for its ability to handle incorrectly formatted files](https://duckdb.org/2025/04/16/duckdb-csv-pollock-benchmark.html).

### YAML

The YAML format is commonly used for configuration files. Avoid using this format for new projects. Use TOML for configuration files instead. If your project requires large or complex sets of configuration, consider treating these configurations as sets of structured data that must be managed using modern tools and formats.

YAML documents are very vulnerable to problems. The format itself has a large number of features and many parts of the syntax are optional. Systems also sometimes extend the format with custom features. The complexity of the format means that humans are also more likely to add errors to YAML configuration files that they edit.

We should use version 1.2 of the YAML format, which removes some of the problems of older versions, such as the Norway Problem. Unfortunately, many products accept YAML that does not strictly comply with version 1.2.

If you need to work with YAML in Python, use [ruamel.yaml](https://pypi.org/project/ruamel.yaml/). Avoid using [PyYAML](https://pypi.org/project/PyYAML/), because it only supports version 1.1 of the YAML format.

Some types of YAML documents do have published schemas that use the [JSON Schema](https://json-schema.org/) standard, but others either have no defined schema or extend the format in ways that are not compatible with the standards.
