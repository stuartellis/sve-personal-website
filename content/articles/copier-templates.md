+++
title = "Maintaining Projects with Copier Templates"
slug = "copier-templates"
draft = true
date = "2026-05-31T20:31:00+01:00"
description = "Maintaining projects with Copier templates"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

[Copier](https://copier.readthedocs.io/en/stable/) enables you to continuously update software projects from sets of templates, so that you can maintain consistent configuration across all of your projects.

## Running Copier

> Copier requires Git for all operations.

To run Copier on a development system, use a tool like [pipx](https://pipx.pypa.io/stable/) or [uv](https://docs.astral.sh/uv/). If you are using `uv`, call Copier with `uvx`:

```shell
uvx copier copy git+https://github.com/my-username/copier-mynamespace-mytemplate my-project
```

> You can specify which version of Copier it runs.

You can safely use multiple Copier templates on the same project.

## Creating a Copier Template

1. First, create a Git repository to hold the template. By convention, the name of this template repository should start with `copier-`. Add a namespace and a name for the specific template to the full name of the repository. For example: `copier-mynamespace-mytemplate`.
2. Create a `copier.yaml` configuration file in the root of the template repository. To avoid conflicts with other Copier templates that are in use, the `_answers_file` must specify a unique name. See below for an example.
3. Create a directory called `template/` in the repository to hold the files and directories that make up the template.
4. Create a template answers file called `{{_copier_conf.answers_file}}.jinja` in the `template/` directory. See below for an example.
5. _Optional:_ Set up a project release tool for the template repository, such as [Python Semantic Release](https://python-semantic-release.readthedocs.io/en/stable/).
6. _Optional:_ Add metadata to the project for the template repository. For example, if it is hosted on GitHub, add the GitHub Topic _copier-template_.

### Example Configuration File for the Template

This is an example of a `copier.yaml` file:

```yaml
---
# Configuration for Copier Template
#
# See:
#
# https://copier.readthedocs.io/en/stable/

# This template uses the configuration format introduced in Copier version 9.
_min_copier_version: "9"

# Use this subdirectory of the template repository as the root directory of the template.
_subdirectory: template

# Name of the answers file.
# This must be unique to avoid conflicts with other Copier templates.
_answers_file: .copier-answers-mynamespace-mytemplate.yaml
```

### Example Template Answers File

Always create a template answers file called `{{_copier_conf.answers_file}}.jinja` in the `template/` directory. It must render the answers that are provided to YAML:

```yaml
---
# Maintained by Copier: NEVER EDIT THIS FILE
#
# See:
#
# https://copier.readthedocs.io/en/stable/updating/#never-change-the-answers-file-manually

{ { _copier_answers|to_nice_yaml - } }
```

## Versioning Your Copier Templates

Copier treats each Git tag on a template repository as a version. By default, it will copy from the last release found in template Git tags, sorted as [a Python version specifier](https://packaging.python.org/en/latest/specifications/version-specifiers/). regardless of whether the template is from a URL or a local clone of a Git repository.

> [Version tags may have a prefix of v](https://packaging.python.org/en/latest/specifications/version-specifiers/#preceding-v-character). Tools like [Python Semantic Release](https://python-semantic-release.readthedocs.io/en/stable/) create Git tags that have a _v_ prefix, e.g. _v1.2.3_.

This means that we should use Semantic Versioning for template repositories.

## Resources

### Copier

- [Copier documentation](https://copier.readthedocs.io/en/stable/)

### Example Templates

- [Example Copier template for Python projects](https://github.com/pawamoy/copier-uv), by Timothée Mazzucotelli
- [Example Copier baseline template](https://github.com/stuartellis/sve-copier-baseline), an example of a general-purpose template
