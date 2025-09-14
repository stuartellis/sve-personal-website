+++
title = "Maintainable YAML - Tools and Practices for YAML"
slug = "maintainable-yaml"
date = "2025-09-14T16:51:00+01:00"
description = "Working effectively with YAML"
draft = true
categories = ["automation", "devops", "kubernetes", "programming"]
tags = ["automation", "devops", "kubernetes"]
+++

[YAML](https://en.wikipedia.org/wiki/YAML) is an essential and unavoidable part of operating modern IT systems. It has been the established format for configurations for years, and is unlikely to be replaced for a long time to come. The list of technologies that rely on YAML include Kubernetes, Ansible, AWS CloudFormation, GitHub Actions and GitLab Pipelines. So, let's take it seriously.

This article covers some tools and practices for working effectively with YAML.

## Tools for Working with YAML

Many software projects today use products that are configured by YAML. We can write YAML files ourselves or generate them. In either case, we can apply several tools to help us maintain these files, and set up pre-commit hooks to automatically run these tools for us when we commit YAML files to version control.

These tools will work on files that use the standard YAML format and file extensions. They have default configurations, so you only need to add configuration files to customize their behavior.

- [Prettier](https://prettier.io/) - Formats many types of file, including YAML
- [check-jsonschema](https://check-jsonschema.readthedocs.io/en/latest/) - Checks JSON and YAML files against their [schema](#using-schemas)
- [yamllint](https://yamllint.readthedocs.io) - Lints YAML files

If we consistently apply a formatter like Prettier, we avoid unnecessary changes to files.

The `yamllint` tool ensures that files in standard YAML format are valid.

The [check-jsonschema](https://check-jsonschema.readthedocs.io/en/latest/) tool checks YAML files against the relevant schema. It includes copies of [schemas](#using-schemas) for popular tools, and provides [hooks](https://check-jsonschema.readthedocs.io/en/latest/precommit_usage.html#supported-hooks) for their files that work offline. You can configure it to download other schemas, including your own custom schemas.

## A Quick Example: pre-commit

One way to manage Git pre-commit hooks is to use the [pre-commit](https://pre-commit.com/) tool. It requires Python to run, but it will download any other tools that the hooks need. To install `pre-commit`, use either [pipx](https://pipx.pypa.io) or [uv](https://docs.astral.sh/uv/):

```shell
pipx install pre-commit
```

```shell
uv tool install pre-commit
```

The `pre-commit` configuration must be in a file called _.pre-commit-config.yaml_ file. Save this file in the root directory of your project:

```yaml
---
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: 'v6.0.0'
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer

      # Check YAML files for syntax
      - id: check-yaml

      - id: check-added-large-files

  # Use Prettier to format text files, including YAML
  - repo: https://github.com/rbubley/mirrors-prettier
    rev: 'v3.5.2'
    hooks:
      - id: prettier

  # Lint all files that use standard file extensions for YAML
  - repo: https://github.com/adrienverge/yamllint.git
    rev: 'v1.37.1'
    hooks:
      - id: yamllint
        args: ['--strict']

  # Validate the listed file types against their published schema
  - repo: https://github.com/python-jsonschema/check-jsonschema
    rev: '0.33.3'
    hooks:
      # Check files for GitHub Actions: https://docs.github.com/en/actions
      - id: check-github-workflows

      # Check files for Task: https://taskfile.dev
      - id: check-taskfile
```

This configuration enables Prettier, _yamllint_ and _check-jsonschema_, along with [check-yaml](https://github.com/pre-commit/pre-commit-hooks#check-yaml), a hook that uses [ruamel.yaml](https://pypi.org/project/ruamel.yaml/) to check YAML files for syntax errors.

To activate the configuration, run `pre-commit install`. This installs pre-commit hooks in the Git configuration for your copy of the project.

```shell
cd my-project
pre-commit install
```

> Since the `pre-commit` configuration file uses YAML, it will automatically be formatted and checked by the same tools that it runs.

## Using Schemas

Both JSON and YAML files can be validated against published schemas. These schemas are JSON files that follow the [JSON Schema](https://json-schema.org/) specification.

Vendors publish JSON schemas for their products to the [Schema Store](https://www.schemastore.org/). Various tools can download JSON Schemas to validate and support working with files. For example, code editors will automatically download JSON Schemas to provide error-checking and autocompletion.

The [check-jsonschema](https://check-jsonschema.readthedocs.io/en/latest/) utility is a command-line tool that validates files against JSON schemas. This tool includes [copies of schemas for popular tools](https://check-jsonschema.readthedocs.io/en/latest/usage.html#builtin-schema-choices), and it can download other schemas as needed. It also provides [hooks for pre-commit](https://check-jsonschema.readthedocs.io/en/latest/precommit_usage.html#supported-hooks).

You can [write your own schemas](https://json-schema.org/learn/getting-started-step-by-step), so that the same tools can validate your custom JSON and YAML files.

## Recommendations for Organizing YAML Files

### Use the Correct File Extension

The recommended file extension for YAML is _.yaml_, as [noted in the documentation](https://yaml.org/faq.html). Old versions of Microsoft Windows only supported file extensions with three characters, which is why some YAML files have the extension _.yml_. All supported versions of Windows and other standard operating systems now support file extensions with four characters, so you can use the preferred file extension of _.yaml_.

> _Ansible uses .yml as the file extension:_ The convention is that Ansible files use the extension _.yml_, so you should still use this file extension with Ansible.

### Use the Correct File Name

Some tools specify an exact name for the YAML file that they use. If you are using a product that specifies a file name, always use the correct filename for the type of YAML. This enables editors and other tools to identify the type of file and use the correct schema.

For example, always create Kubernetes [kustomization](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/) files with the name _kustomization.yaml_ and GitLab Pipelines files with the name _gitlab-ci.yaml_.

Since you can only have one file in each directory with a specific name, you will need to create a separate directory for each file.

### One Document, One YAML File

You can define multiple separate documents in one YAML file by separating each document with a line that has three dashes. Avoid doing this unless you have a good reason. It is much easier for humans when each YAML document is a separate file in a directory structure.

Avoid this:

```yaml
---
name: First YAML document
description: A tiny YAML document
---
name: Second YAML document
description: Another tiny YAML document
```

Do this instead:

```yaml
---
name: First YAML document
description: A tiny YAML document
```

```yaml
---
name: Second YAML document
description: Another tiny YAML document
```

## Writing YAML

### Write for Readability

If a YAML is converted to JSON, all of the comments in a YAML file will be discarded. JSON does not support comments at all, so they are lost in the conversion from the YAML original to JSON. This allows you to write whatever comments are useful for humans.

Similarly, the whitespace and line breaks in a YAML file will disappear once the file is converted to another data format.

### Only Use The Notation That You Need

YAML is notorious for [having 63 ways to split a string](https://askthedev.com/question/63-methods-for-dividing-a-string-in-yaml-format/). You don't have to use all of the features. In fact, you should probably only use a small number of them.

If you are working on YAML for a specific system, such as a CI pipeline, follow the standard conventions for the product that will read the YAML. Check the product documentation for help, rather than trusting example code from elsewhere.

For example, the Kubernetes project have decided to set explicit rules for the YAML that their tools generate. They have documented this subset of YAML as [KYAML](https://github.com/kubernetes/enhancements/tree/master/keps/sig-cli/5295-kyaml). In future, all of the components of Kubernetes will generate YAML that follows the KYAML specification.

If you are writing YAML for a custom system, define your own rules or guidelines. You can then enforce these through linters and apply them in your own code. Consider starting with the [StrictYAML decisions](https://hitchdev.com/strictyaml/why-not/ordinary-yaml/).

> KYAML and StrictYAML use quoted strings to avoid the [Norway Problem](https://hitchdev.com/strictyaml/why/implicit-typing-removed/).

### Double Quotes or Single Quotes?

Double quotes can enclose strings that contain single quotes. For this reason, it is simpler to use double quotes everywhere. Prettier will format your YAML files to use double quotes.

By default, [yamllint](https://yamllint.readthedocs.io) accepts either single or double quotes.
