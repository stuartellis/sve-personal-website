+++
title = "Tooling for Maintaining YAML Files"
slug = "yaml-maintenance"
date = "2025-09-14T16:51:00+01:00"
description = "Tooling for maintenance of YAML files"
categories = ["automation", "devops", "kubernetes", "programming"]
tags = ["automation", "devops", "kubernetes"]
+++

[YAML](https://en.wikipedia.org/wiki/YAML) is an essential and unavoidable part of operating modern software. It has been the established format for configurations for years, and is unlikely to be replaced for a long time to come. Many, many tools rely on YAML.

Ideally, we generate YAML files. If we need to maintain YAML files that are manually edited we can apply several tools to help us. These tools become most effective when they run automatically. They should run in text editors, with pre-commit hooks that call them every time that we commit YAML files to version control, and in Continuous Integration pipelines.

## Formatting, Linting and Validating YAML

These tools will work on files that use the standard YAML format and file extensions:

- [Prettier](https://prettier.io/) - Formats many types of file, including YAML
- [yamllint](https://yamllint.readthedocs.io) - Lints YAML files
- [check-jsonschema](https://check-jsonschema.readthedocs.io/en/stable/) - Checks JSON and YAML files against their schema

Modern text editors support all of them through plugins. You can run them with both pre-commit hooks and on-demand by [using the pre-commit tool](#running-tools-with-pre-commit).

All of these tools have useful default configurations, so you only need to add configuration files if you need to customize their behavior.

### Formatting with Prettier

[Prettier](https://prettier.io/) formats files for a [wide range of programming languages and data types](https://prettier.io/docs/), including YAML. It is deliberately opinionated, so that every installation of Prettier formats files in exactly the same way, unless users decide to override it.

Automated code formatting has very powerful effects in software projects. When we apply the same formatter on every change, the format of the code becomes consistent and predictable, which enables us to rapidly refactor. Automatic code formatting also removes the need for commits that only format files.

### Linting with yamllint

The [yamllint](https://yamllint.readthedocs.io) tool ensures that files are valid YAML. It applies [rules](https://yamllint.readthedocs.io/en/stable/rules.html) that are designed for standard YAML.

If you have YAML files that are templates, you will need to provide a custom configuration for `yamllint`, or use a specialized tool for the files that are in that format, such as [cfn-lint](https://pypi.org/project/cfn-lint/) for CloudFormation. For Ansible, we do both: the [ansible-lint](https://ansible.readthedocs.io/projects/lint/) tool is intended to be used alongside `yamllint`.

> By design, `yamllint` ignores files with a double file extension, such as `.yaml.jinja2`. These files are likely to be templates.

### Validation with check-jsonschema

The [check-jsonschema](https://check-jsonschema.readthedocs.io/en/stable/) tool checks YAML files against the relevant schema. It includes copies of schemas for popular tools, and provides [hooks](https://check-jsonschema.readthedocs.io/en/stable/precommit_usage.html#supported-hooks) for their files that work offline. You can configure it to use other schemas, including your own schemas.

The schemas for YAML formats are [JSON Schemas](https://json-schema.org/). Each schema is a JSON file. Vendors publish the schemas for their products to the [Schema Store](https://www.schemastore.org/). You can [create your own schemas](https://json-schema.org/learn/getting-started-step-by-step). Modern text editors use JSON Schemas for autocompletion and error-checking, which means that both editors and tools like `check-jsonschema` apply the same validation rules.

## Running Tools with pre-commit

The [pre-commit](https://pre-commit.com/) tool both manages Git pre-commit hooks and enables you to run the same actions at any time, not just when you commit changes. The `pre-commit` tool itself requires Python to run, but it will download the other runtimes and tools that the hooks need. This means that `pre-commit` provides a cross-platform way to install and run a complete set of tools for formatting and checking code.

### Installing pre-commit

To install `pre-commit`, use either [pipx](https://pipx.pypa.io) or [uv](https://docs.astral.sh/uv/):

```shell
pipx install pre-commit
```

```shell
uv tool install pre-commit
```

### Adding pre-commit To a Project

The `pre-commit` configuration must be in a file called `.pre-commit-config.yaml` file. Save this file in the root directory of your project:

```yaml
---
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: "v6.0.0"
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/rbubley/mirrors-prettier
    rev: "v3.5.2"
    hooks:
      - id: prettier

  - repo: https://github.com/adrienverge/yamllint.git
    rev: "v1.37.1"
    hooks:
      - id: yamllint
        args: ["--strict"]

  - repo: https://github.com/python-jsonschema/check-jsonschema
    rev: "0.33.3"
    hooks:
      - id: check-github-workflows
      - id: check-taskfile
```

This configuration enables Prettier, `yamllint` and `check-jsonschema`. It also includes [check-yaml](https://github.com/pre-commit/pre-commit-hooks#check-yaml), one of the standard `pre-commit-hooks`. This hook uses [ruamel.yaml](https://pypi.org/project/ruamel.yaml/) to check YAML files for syntax errors. I leave it in place because it does not slow down small projects. It is redundant, and you might choose to remove it.

To activate the configuration, run `pre-commit install`. This adds the pre-commit hooks to the Git configuration for your copy of the project, so that the tools automatically run on the staged changes each time that you commit.

```shell
cd my-project
pre-commit install
```

> Since the `pre-commit` configuration file is YAML, it will automatically be formatted and checked by the same tools that it runs.

### Using pre-commit

The tools automatically run on the staged changes each time that you commit. To run a tool without commiting a change, use `precommit run`. If you add the option `--all-files` it will check the current files in the project, not just staged changes.

For example, to run the `check-github-workflows` hook on the project, use this command:

```shell
pre-commit run check-github-workflows --all-files
```

To run all of the hooks on the project, use this command:

```shell
pre-commit run --all-files
```

### Updating pre-commit Hooks

To update all of the hooks to their current version, run this command:

```shell
pre-commit autoupdate
```

It will automatically edit the `.pre-commit-config.yaml` file with the current versions of the hooks. You then commit this change to source control.
