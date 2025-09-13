+++
title = "YAML, Seriously - Tools and Practices for YAML"
slug = "yaml-seriously"
date = "2025-09-13T09:25:00+01:00"
description = "Working effectively with YAML"
draft = true
categories = ["automation", "devops", "kubernetes", "programming"]
tags = ["automation", "devops", "kubernetes"]
+++

YAML is an essential and unavoidable part of operating modern IT systems. It has been the established format for configurations for years, and is unlikely to be replaced for a long time to come. The list of technologies that rely on YAML include Kubernetes, Ansible, AWS CloudFormation, GitHub Actions and GitLab Pipelines. So, let's take it seriously.

This article covers some tools and practices for working effectively with YAML.

## A Quick Example

Many software projects today use products that are configured by YAML. We can write YAML files ourselves or generate them. In either case, we can apply several tools to help us maintain these files, and set up pre-commit hooks to automatically run the tools for us when we commit YAML files to version control.

Here is an example of a configuration file for [pre-commit](https://pre-commit.com/):

```yaml
repos:
  # Use Prettier to format text files, including YAML
  - repo: https://github.com/rbubley/mirrors-prettier
    rev: 'v3.6.2'
    hooks:
      - id: prettier

  # Lint all files that use standard file extensions for YAML
  - repo: https://github.com/adrienverge/yamllint.git
    rev: 'v1.37.1'
    hooks:
      - id: yamllint
        args: [--strict]

  # Validate the listed file types against their published schema
  - repo: https://github.com/python-jsonschema/check-jsonschema
    rev: '0.33.3'
    hooks:
      # Check files for GitHub Actions: https://docs.github.com/en/actions
      - id: check-github-workflows

      # Check files for Task: https://taskfile.dev
      - id: check-taskfile
```

You add these lines to a _.pre-commit-config.yaml_ file in the root directory of your project.

> Since the `pre-commit` configuration file uses YAML, it will automatically be formatted and checked by the same tools that it runs.

These tools will work on files that use the standard YAML format and file extensions. They have default configurations, so you only need to add configuration files to customize their behavior.

- [Prettier](https://prettier.io/) - Formats many types of file, including YAML
- [check-jsonschema](https://check-jsonschema.readthedocs.io/en/latest/) - Checks JSON and YAML files against their [schema](#using-schemas)
- [yamllint](https://yamllint.readthedocs.io) - Lints YAML files

If we consistently apply a formatter like Prettier, we avoid unnecessary changes in version control. The `yamllint` tool ensures that files in standard YAML format are valid, and `check-jsonschema` checks the YAML documents in the files against the relevant schema.

The [check-jsonschema](https://check-jsonschema.readthedocs.io/en/latest/) tool includes copies of [schemas](#using-schemas) for popular tools, so that it provide hooks for their files that work offline. You can configure it to download other schemas, including your own custom schemas.

## What is YAML, Actually?

Today, we can think of YAML as a notation format for humans to read and edit documents that describe data objects. We often use YAML for data objects that describe a configuration, but it was not specifically intended for this purpose.

The YAML format was actually designed for _serialization_. This means that each YAML document contains the description for one or more objects. These could be objects in an object-oriented programming language. By a happy accident, the original design of YAML was completely compatible with JSON.

Many systems that use YAML actually process JSON, and automatically convert between YAML and JSON. This allow humans to see and edit YAML, whilst the internals of the systems use JSON. The JSON format is much better suited for processing by software than YAML. It is simpler than YAML, and every popular programming language has well-tested, high-performance libraries for JSON. It is also much more verbose, and lacks many of the features of YAML that help us work with larger documents.

The way that YAML can scale from the very small and simple to the very large may be one of its best features. In some cases, a set of YAML documents are a configuration that describes a large number of objects, which might all be the components of a single system.

For example, you might have a set of YAML files that describes all of the CI/CD pipelines for a project. A CloudFormation stack or a Helm chart for Kubernetes might describe the complete configuration of an entire service. The human operators can see and manage the entire configuration of the system through the YAML file, rather than working with raw JSON or other data formats that are designed to be read by machines.

The current version of the YAML specification is [YAML 1.2.2](https://yaml.org/spec/1.2.2/), which was published in 2021. YAML was originally proposed in 2001 and version 1.0 was published in 2004. It is a stable format.

Many software projects will use multiple products that are configured by YAML. A number of popular products have their own conventions or specify their own additions to YAML, in order to make the format more suitable for their specific needs.

In summary:

1. YAML helps humans to read and write definitions of data objects.
2. The YAML that you see might be converted to a machine-friendly format like JSON.
3. There are now many variations of YAML that are specialized for working with particular systems.

## Using Schemas

Both JSON and YAML files can be validated against published schemas. These schemas are JSON files that follow the [JSON Schema](https://json-schema.org/) specification. The JSON Schema specification was released in 2019.

Vendors publish JSON schemas for their products to the [Schema Store](https://www.schemastore.org/). Various tools can download JSON Schemas to validate and support working with files. For example, code editors will automatically download JSON Schemas to provide error-checking and autocompletion. The [check-jsonschema](https://check-jsonschema.readthedocs.io/en/latest/) tool includes copies of schemas for popular tools, and can download other schemas as needed.

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

Double quotes can enclose strings that contain single quotes. For this reason, it is simpler to use double quotes everywhere.

By default, [yamllint](https://yamllint.readthedocs.io) accepts either single or double quotes.
