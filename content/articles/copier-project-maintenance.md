+++
categories = ["automation", "devops", "programming"]
date = "2026-07-31T11:08:00+01:00"
description = "Maintaining projects with Copier templates"
slug = "copier-project-maintenance"
tags = ["automation", "devops", "python"]
title = "Maintaining Projects with Copier Templates"
+++

[Copier](https://copier.readthedocs.io/en/stable/) enables you to continuously update software projects from templates,
so that you can maintain consistent configurations across many projects. A project can receive files from multiple
Copier templates. This means that you can maintain sets of templates that each manage configuration for a particular
capability and then mix templates into projects as they are needed.

## How It Works

A Copier template is a Git repository that contains a configuration file and template files. Copier uses
[Jinja](https://jinja.palletsprojects.com/en/stable/) for templating files and directories, with
[extensions](https://copier.readthedocs.io/en/stable/configuring/#jinja_extensions). The configuration file includes
definitions for the questions that Copier will ask a user when they apply a template to a project. The responses to
these questions become variables that the templates can use.

> Each Git repository contains one Copier template, because Copier uses
> [Git tags for version information](#versioning-your-copier-templates).

The first time that you run Copier to add a template to a project, you specify the address of the Git repository that
contains the template, like this:

```shell
copier copy git+ssh://github.com/my-username/copier-mynamespace-mytemplate.git my-project
```

Copier then prompts you for answers to the questions that are defined in the template. Once you have responded to all of
the questions it will create the files and directories from the template in the `my-project/` directory. It also creates
an `answers` file in the project directory to store the address of the template, the version of the template that you
used, and your responses to the questions.

> You can also provide responses on the command-line or in a data file.

You can update a project at any time. Specify the answers file that was created by the first run of Copier. Copier then
uses Git to fetch either the latest version of the template, or the version of the template that you
[specify](https://copier.readthedocs.io/en/stable/configuring/#vcs_ref):

```shell
# Update the current project with the latest version of the template
copier update -a .copier-answers-my-template.yaml

# Update the current project with version v1.2.3 of the template
copier update -a .copier-answers-my-template.yaml -r v1.2.3 
```

Copier then prompts you to answer the questions again. It uses the previous responses as the defaults. Once it has
responses to all of the questions that are defined in the template it performs an
[update](https://copier.readthedocs.io/en/stable/updating/). The update can also include running
[migrations](https://copier.readthedocs.io/en/stable/configuring/#migrations) or
[defined tasks](https://copier.readthedocs.io/en/stable/configuring/#tasks).

Add the `-A` option to update the project without prompting you at all, using the responses from the answers file:

```shell
copier update -A -a .copier-answers-my-template.yaml
```

You can safely use
[multiple Copier templates](https://copier.readthedocs.io/en/stable/configuring/#applying-multiple-templates-to-the-same-subproject)
on the same project. Templates can use the responses that users have provided to other templates, as explained in a
[later section](#referencing-other-copier-templates).

These features mean that you can maintain large numbers of projects that are composed from sets of Copier templates. The
developers that work on these projects can update them as needed, or you can use automation to run template updates and
commit the changes.

> If you use [Renovate](https://docs.renovatebot.com/) it updates projects with the latest versions of Copier templates,
> in the same way that it updates dependencies.

### Versioning Your Copier Templates

Copier reads the Git tags on a template repository to determine the available versions. It expects version tags to
follow the format of
[a Python version specifier](https://packaging.python.org/en/latest/specifications/version-specifiers/).

This means that you should use [Semantic Versioning](https://semver.org/) for template repositories. To identify the
tags that are for versions, give each
[version tag a prefix of v](https://packaging.python.org/en/latest/specifications/version-specifiers/#preceding-v-character).
Set up [an automated release tool](#automating-version-tags) to handle versioning for you, with Git tags that have a `v`
prefix, e.g. `v1.2.3`.

> By default, Copier will use the current release found in the Git version tags for the template,
> [excluding pre-releases](https://copier.readthedocs.io/en/stable/configuring/#use_prereleases).

## Running Copier

Copier requires Git and Python. To run Copier on a development system, use a Python tool like
[pipx](https://pipx.pypa.io/stable/) or [uv](https://docs.astral.sh/uv/). If you are using `uv`, call Copier with `uvx`.
Alternatively, you can create your own container image that includes Copier, Git, Python and any other required
dependencies.

This command uses `pipx` to run `copier copy`:

```shell
pipx run copier==9.17.0 copy git+ssh://github.com/my-username/copier-mynamespace-mytemplate.git my-project
```

This command uses `uv` to run `copier copy`:

```shell
uvx copier==9.17.0 copy git+ssh://github.com/my-username/copier-mynamespace-mytemplate.git my-project
```

> Both `pipx run` and `uvx` download Copier to a cache, so that you do not need to manage a Python virtual environment.

If you use extra Jinja filters in a Copier template, you will need include these packages into the virtual environment
that `pipx` or `uvx` maintains for Copier.

By default, Copier disables features that allow arbitrary code execution, including
[migrations](https://copier.readthedocs.io/en/stable/configuring/#migrations) and
[tasks](https://copier.readthedocs.io/en/stable/configuring/#tasks). You must use the _—trust_ flag to enable these to
run.

> Copier supports both HTTPS and SSH. Access Copier templates in private Git repositories by using SSH authentication.
> If you do not use an SSH agent, you can pass
> [credentials](https://copier.readthedocs.io/en/stable/faq/#how-to-pass-credentials-to-git).

### Updating Specific Files

Use _--exclude_ to update a single file in a project from a template:

```shell
copier copy --exclude '*' --exclude '!file-i-want' ./template ./destination
```

For example:

```shell
copier copy -a .copier/.copier-answers-my-template.yaml --exclude '*' --exclude '!.pre-commit-config.yaml' git+https://github.com/my-account/copier-my-template .
```

## Creating a Copier Template

> This process does not require the Copier tool.

A Copier template is a Git repository with a structure like this:

```shell
|- template/
|   |
|   |- .copier/
|   |    |- .copier-answers-mynamespace-mytemplate.yaml
|   |
|   |- <templated files and directories...>
|
|- .gitignore
|- LICENSE.md
|- README.md
|- copier.yaml
```

To create a Copier template:

1. First, create a Git repository to hold the template. By convention, the name of this template repository should start
   with `copier-`. Add a namespace and a name for the specific template to the full name of the repository. For example:
   `copier-mynamespace-mytemplate`.
2. Create a `copier.yaml` configuration file in the root of the template repository. To avoid conflicts with other
   Copier templates that are in use, the `_answers_file` must specify a unique name.
   [See below](#example-configuration-file-for-the-template) for an example.
3. Create a directory called `template/` in the repository to hold the files and directories that make up the template.
4. Create a directory called `template/.copier/` in the repository to hold the template answers file.
5. Create a template answers file called `[[_copier_conf.answers_file]].jinja` in the directory `template/.copier/`. See
   below for an [example answers file]](#example-template-answers-file).
6. Set the template delimiters. By default, Copier uses curly braces to denote templated values, but these may cause
   issues with some types of files, such as Jinja templates in projects. Specify square brackets as delimiters in the
   configuration file as shown in [the example configuration file](#example-configuration-file-for-the-template).
7. _Optional:_ Set up [automated releases](#automating-version-tags) for the template repository to ensure that there
   are [Git tags for versions](#versioning-your-copier-templates).
8. _Optional:_ Add metadata to the project for the template repository. For example, if it is hosted on GitHub, add the
   GitHub Topic _copier-template_.

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
# This file name must be unique to avoid conflicts with other Copier templates.
# Start the name of the file with .copier-answers so that Renovate can detect it.
# By default, Copier uses the root directory of the project for answers files,
# but this example uses a .copier/ directory.
_answers_file: .copier/.copier-answers-mynamespace-mytemplate.yaml

# Use alternate template delimiters
# This avoids conflicts with templating that is defined in the managed files.
_envops:
  block_end_string: "%]"
  block_start_string: "[%"
  comment_end_string: "#]"
  comment_start_string: "[#"
  variable_end_string: "]]"
  variable_start_string: "[["

# Create these files from the template, if they are not already present.
# If one of these files exists, it will not be updated from the template.
_skip_if_exists:
  - README.md
```

Set defaults for answers as much as possible. They minimise user effort and increase consistency. You can also use
[the well-known variables](https://copier.readthedocs.io/en/stable/settings/#well-known-variables) to get information.

### Example Template Answers File

Always create a template answers file. It must render the answers that are provided to YAML:

```yaml
---
# Maintained by Copier: NEVER EDIT THIS FILE
#
# See:
#
# https://copier.readthedocs.io/en/stable/updating/#never-change-the-answers-file-manually

[[ _copier_answers|to_nice_yaml -]]
```

Copier must template the name of the answers file from `_copier_conf.answers_file`. This means that if you use square
brackets as delimiters, it will be called `[[_copier_conf.answers_file]].jinja`.

### Referencing Other Copier Templates

A Copier template can reference other templates that have already been applied to the project:

```yaml
# Template loads answers from the previous template into the _external_data object
_external_data:
  # A dynamic path. Make sure you answer that question
  # before the first access to the data (with `_external_data.parent_tpl`)
  parent_tpl: "[[ parent_tpl_answers_file ]]"

# Ask the user where the answers file for the previous template is located
parent_tpl_answers_file:
  help: Where did you store answers for the parent template?
  default: .copier/.copier-answers-example-parent.yaml

# Answers can then reference answers in the other template through _external_data
project_name:
  type: str
  help: Your project name
  default: "[[ _external_data.parent_tpl.project_name ]]"
```

### Automating Version Tags

Always automate the release process for your templates. This ensures that every version of a Copier template has a Git
tag in the valid format. Popular tools for release automation include:

- [GoReleaser](https://goreleaser.com/)
- [Python Semantic Release](https://python-semantic-release.readthedocs.io/en/stable/)
- [semantic-release](https://semantic-release.org/)

> I provide an article on using
> [Python Semantic Release with GitLab](https://www.stuartellis.name/articles/python-semantic-release-gitlab/).

## Resources

Here are some useful articles and tutorials about Copier.

### Copier

- [Copier documentation](https://copier.readthedocs.io/en/stable/)
- [Bootstrapping Python projects with copier](https://blog.dusktreader.dev/2025/04/06/bootstrapping-python-projects-with-copier/)
- [Effective Repository Templates with Copier](https://browniantech.com/blog/post/Effective-Repository-Templates-with-Copier)
- [Renovate Support for Copier](https://docs.renovatebot.com/modules/manager/copier/)

### Example Templates

- [Example Copier template for Python projects](https://github.com/pawamoy/copier-uv), by Timothée Mazzucotelli
- [Example Copier baseline template](https://github.com/stuartellis/sve-copier-baseline), an example of a
  general-purpose template
