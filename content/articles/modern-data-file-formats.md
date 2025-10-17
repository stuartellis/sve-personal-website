+++
title = "Modern Data File Formats"
slug = "modern-data-file-formats"
date = "2025-10-15T16:54:00+01:00"
description = "Data file formats for modern systems"
categories = ["programming", "python", "javascript"]
tags = ["python", "javascript"]
+++

This article suggests data file formats for modern systems, and explains some of the well-known formats that they can replace.

All of the suggested formats are open, standardized and portable. If you need to work with other data formats, consider using a modern file format in your application and adding features to import data or generate exports in other formats when necessary.

## JSON

[JSON](https://en.wikipedia.org/wiki/JSON) is a plain-text format for defining data objects. In most cases, you should use this format to transfer data between systems, especially if they must communicate with HTTP. JSON documents can be used for any kind of data.

You can validate JSON documents with [JSON Schemas](https://json-schema.org/). Each schema is a JSON file, which means that they can be published in any Web site or stored in version control. Vendors publish the schemas for their products to the [public Schema Store](https://www.schemastore.org/). You can [write schemas yourself](https://json-schema.org/learn/getting-started-step-by-step), or generate them with tools. For example, [Pydantic](https://docs.pydantic.dev/) enables you to generate JSON Schemas for your Python data objects.

Every programming language and modern SQL database supports JSON. For example, all of the versions of Python 3 include [a module](https://docs.python.org/3/library/json.html) for JSON and [PostgreSQL includes full support for JSON](https://www.postgresql.org/docs/current/functions-json.html).

## SQLite

[SQLite](https://sqlite.org) is a binary format for self-contained SQL database files. Each SQLite database is a single file.

You can use SQLite databases for any kind of data. They can be used to [store and query data in JSON format](https://sqlite.org/json1.html), they hold plain text with [optional full-text search](sqlite.org/fts5.html), and they can store binary data. A SQLite database file can safely be several gigabytes in size.

SQLite is widely-supported, [highly robust](https://sqlite.org/hirely.html) and the file format is [guaranteed to be stable and portable for decades](https://sqlite.org/lts.html).

Since SQLite files are arguably more portable and resilient than sets of plain-text files, you can use them to store sets of data that must be available for a long time, such as [data and configuration for applications](https://sqlite.org/appfileformat.html).

Every modern programming language has libraries to support SQLite. All of the versions of Python 3 include [a module](https://docs.python.org/3/library/sqlite3.html) as part of the standard library. Node.js also now includes [support for SQLite](https://nodejs.org/api/sqlite.html), although this is currently marked as experimental.

> DuckDB can read and write SQLite databases if you install an [extension](https://duckdb.org/docs/stable/core_extensions/sqlite).

## Specialized File Formats

### Configuration: TOML

[TOML](https://toml.io/) is a plain-text format for configuration files that must be written or edited by human beings. Use it instead of YAML or INI formats.

TOML is the default configuration file format for Python and Rust projects. Python 3.11 and above include [tomllib](https://docs.python.org/3/library/tomllib.html) to read the TOML format. If your Python software must generate TOML, you need to add [Tomli-W](https://pypi.org/project/tomli-w/) to your project.

> You can use [Taplo](https://taplo.tamasfe.dev/) to validate and format TOML files. It is both a command-line tool and Rust library.

### Tabular Data: Apache Parquet

If you need to query a large set of tabular data, store a copy in [Apache Parquet](https://parquet.apache.org/) files. It is a binary file format that is specifically designed for large-scale data operations, and supports features like indexing, compression and encryption.

Parquet is portable and widely-supported. For example, [DuckDB](https://duckdb.org/) and dataframe libraries like [Pandas](https://pandas.pydata.org/) support the Parquet format. Database systems that are based on [Apache Iceberg](https://iceberg.apache.org/) can use Parquet as the file format for storage.

## Problematic File Formats

Avoid these older file formats:

- CSV - Use SQLite or Apache Parquet instead
- INI - Use TOML instead
- YAML - Use TOML or JSON instead

Systems can implement these legacy formats in different ways, which means that there is a risk that data will not be read correctly when you use a file that has been created by another system. Files that are edited by humans are also more likely to contain errors, due to the complexities and inconsistency of these formats.

### CSV

CSV formats are frequently used to create sets of data that are intended to be portable, so that the data can be copied between different systems. In practice, systems can implement CSV formats in different ways, which means that there is a risk that data will not be read correctly when you use a CSV file that has been created by another system. CSV files that are edited by humans are also very likely to contain errors.

Use Apache Parquet or SQLite instead of CSV formats. These formats are portable between systems and explicitly attach data types to columns. Your code can use dataframes or [DuckDB](https://duckdb.org/) to analyze data that is stored in these formats.

Python includes [a module for CSV files](https://docs.python.org/3/library/csv.html), but consider using DuckDB instead. DuckDB provides [CSV support](https://duckdb.org/docs/stable/data/csv/overview.html) that is [tested for its ability to handle incorrectly formatted files](https://duckdb.org/2025/04/16/duckdb-csv-pollock-benchmark.html).

### INI

Avoid using INI files for new projects. The INI format is a configuration file format that was designed for old versions of Microsoft products. The format was then implemented in other systems, such as the Python programming language. INI is not a published standard.

TOML completely replaces the INI file format. Python now includes and uses the TOML format, although [the INI support](https://docs.python.org/3/library/configparser.html) has not yet been removed from the Python standard library.

### YAML

The YAML format is commonly used for configuration files. Avoid using this format for new projects. Use TOML for configuration files instead. If your project requires large or complex sets of configuration, consider treating these configurations as sets of structured data that must be managed using modern tools and formats.

YAML documents are very vulnerable to problems. The format itself has a large number of features and many parts of the syntax are optional. Systems also sometimes extend the format with custom features. The complexity of the format means that humans are also more likely to add errors to YAML configuration files that they edit.

If you need to create YAML, try to use version 1.2 of the YAML format, which removes some of the problems of older versions, such as [the Norway Problem](https://hitchdev.com/strictyaml/why/implicit-typing-removed/). Unfortunately, many products may accept or create YAML that does not strictly comply with version 1.2.

> For Python, [ruamel.yaml](https://pypi.org/project/ruamel.yaml/), implements YAML 1.2. Avoid using [PyYAML](https://pypi.org/project/PyYAML/), because it only supports version 1.1 of the YAML format.

Some types of YAML documents do have published schemas that use the [JSON Schema](https://json-schema.org/) standard, but others either have no defined schema or extend the format in ways that are not compatible with the standards.
