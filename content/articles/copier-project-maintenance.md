+++
categories = ["automation", "devops", "programming"]
date = "2026-07-31T22:40:00+01:00"
description = "Using shared Copier templates to maintain projects"
slug = "copier-project-maintenance"
tags = ["automation", "devops", "python"]
title = "Maintaining Projects with Shared Templates Using Copier"
+++

[Copier](https://copier.readthedocs.io/en/stable/) enables you to maintain large numbers of projects by defining
templates for common capabilites, adding the relevant templates to the projects that require those capabilities, and
then evolving the projects by updating the shared templates that they use.

## How It Works

A Copier template is a Git repository that contains a configuration file and template files. Copier uses
[Jinja](https://jinja.palletsprojects.com/en/stable/) for templating files and directories, with
[extensions](https://copier.readthedocs.io/en/stable/configuring/#jinja_extensions). The configuration file includes
definitions for the questions that Copier will ask a user when they apply a template to a project. The responses to
these questions become variables that the templates can use.

You can also use the [external data](https://copier.readthedocs.io/en/stable/configuring/#external_data) option to set
variables for the Jinja templating. This enables you to use Jinja extensions, or define your own macros to run custom
Python code.

> Each Git repository contains one Copier template, because Copier uses
> [Git tags for version information](#versioning-your-copier-templates).

Once a template is applied for the first time, Copier creates an
[answers file](https://copier.readthedocs.io/en/stable/configuring/#the-copier-answersyml-file) in the project. This
answers file enables Copier to manage updates to new versions of the template. It stores the address of the template,
the version of the template that you used, and your most recent responses to the questions in the template.

### Using a Copier Template

The first time that you run Copier to add a template to a project, you specify the address of the Git repository that
contains the template, like this:

```shell
copier copy git+ssh://github.com/my-username/copier-mycompany-myteam-aws-lambda-py.git my-project
```

Copier then prompts you for answers to the questions that are defined in the template. Once you have responded to all of
the questions it will create the files and directories from the template in the `my-project/` directory, including the
[answers file](https://copier.readthedocs.io/en/stable/configuring/#the-copier-answersyml-file).

> You can also provide responses on the command-line or in a data file.

You can update a project at any time. Run Copier, using the
[-a](https://copier.readthedocs.io/en/stable/configuring/#answers_file) option to specify an answers file in the
project. Copier will read the address of the template repository from the answers file and begin the update process. It
will fetch either the latest version of the template, or the version of the template that you provide:

```shell
# Apply the latest version of the template that is specified in the answers file
copier update -a .copier/.copier-answers-mycompany-myteam-aws-lambda-py.yaml

# Apply version v1.2.3 of the template that is specified in the answers file
copier update -a .copier/.copier-answers-mycompany-myteam-aws-lambda-py.yaml -r v1.2.3 
```

Copier then reads the questions that are defined for the new version of the template. By default, it prompts the user
for responses, but we can provide responses by other means in order to [automate updates](#automating-updates). If a
question existed in the previous version, it sets the previous response from the answers file as the default response.

Once it has responses to all of the questions that are defined in the template it performs an
[update](https://copier.readthedocs.io/en/stable/updating/). The update can also include running
[migrations](https://copier.readthedocs.io/en/stable/configuring/#migrations) or other
[defined tasks](https://copier.readthedocs.io/en/stable/configuring/#tasks).

You can safely use
[multiple Copier templates](https://copier.readthedocs.io/en/stable/configuring/#applying-multiple-templates-to-the-same-subproject)
on the same project. Templates can use the responses that users have provided to other templates, as explained in a
[later section](#referencing-other-copier-templates).

These features mean that you can maintain large numbers of projects that are composed from sets of Copier templates. The
developers that work on these projects can update them as needed, or you can use automation to run template updates and
commit the changes.

> If you use [Renovate](https://docs.renovatebot.com/) it can update projects with the latest versions of Copier
> templates, in the same way that it updates dependencies.

### Versioning Your Copier Templates

Copier reads the Git tags on a template repository to determine the available versions. By default, it will use the
current release found in the Git version tags for the template,
[excluding pre-releases](https://copier.readthedocs.io/en/stable/configuring/#use_prereleases).
[Migrations](https://copier.readthedocs.io/en/stable/configuring/#migrations) also rely on the version of the template
to determine whether to run.

> Copier expects the version tags to follow the format of
[a Python version specifier](https://packaging.python.org/en/latest/specifications/version-specifiers/).

These features mean that you should use [Semantic Versioning](https://semver.org/) for template repositories. To
identify the tags that are for versions, give each
[version tag a prefix of v](https://packaging.python.org/en/latest/specifications/version-specifiers/#preceding-v-character).
Set up [an automated release tool](#automating-version-tags) to handle versioning for you, with Git tags that have a `v`
prefix, e.g. `v1.2.3`.

If you use Semantic Versioning then it also allows you to indicate whether a new version of a template is a minor
release, or a major new version that could introduce breaking changes. Humans and automations can then decide when and
how to carry out updates. The section on [automating updates](#automating-updates) explains how Copier upgrades
projects.

> For development and testing Copier templates, you can use the
> [-r](https://copier.readthedocs.io/en/stable/configuring/#vcs_ref) option to fetch a Copier template from any Git ref,
> such as a branch name.

### Automating Updates

> Use [tasks](https://copier.readthedocs.io/en/stable/configuring/#tasks) and
> [migrations](https://copier.readthedocs.io/en/stable/configuring/#migrations) to trigger actions that should not be
> carried out by Copier itself.

Each time that Copier updates a project to a different version of a template, it reads the configuration for the new
version of the template. It then uses any
[external data](https://copier.readthedocs.io/en/stable/configuring/#external_data) to set variables and reads the
questions that are defined for that version of the template. If Copier has responses to all of the questions in the
template, it does not prompt the user.

> Consider using [Renovate](https://www.mend.io/renovate/) to manage updates for Copier templates that do not require
> any responses.

You can use any automation tools that you wish to update templates that require responses. You may decide to use
different approaches for different templates, or depending on whether the update is a minor version or a major version
change that could introduce breaking changes.

Copier accepts responses [from the command-line](https://copier.readthedocs.io/en/stable/configuring/#data) and from
[YAML data files](https://copier.readthedocs.io/en/stable/configuring/#data_file). If you think that it is safe to use
the existing responses for an update, you can also use the [skip answered](#using-existing-responses-for-updates) option
to make Copier automatically use those responses from the answers file.

## Running Copier

To run Copier on a development system, use a Python tool like [pipx](https://pipx.pypa.io/stable/) or
[uv](https://docs.astral.sh/uv/). If you are using `uv`, call Copier with `uvx`. Alternatively, you can create your own
container image that includes Copier along with Python, Git and any other required dependencies.

This command uses `pipx` to run `copier copy`:

```shell
pipx run copier==9.17.0 copy git+ssh://github.com/my-username/copier-mycompany-myteam-aws-lambda-py.git my-project
```

This command uses `uv` to run `copier copy`:

```shell
uvx copier==9.17.0 copy git+ssh://github.com/my-username/copier-mycompany-myteam-aws-lambda-py.git my-project
```

> Both `pipx run` and `uvx` download Copier to a cache, so that you do not need to manage a Python virtual environment.

If you use extra Jinja filters in a Copier template, you will need include these packages into the virtual environment
that `pipx` or `uvx` maintains for Copier.

By default, Copier disables features that allow arbitrary code execution, including
[tasks](https://copier.readthedocs.io/en/stable/configuring/#tasks) and
[migrations](https://copier.readthedocs.io/en/stable/configuring/#migrations). You must use the _--trust_ flag to enable
these to run.

> Copier supports fetching templates from remote Git repositories over HTTPS and SSH, as well as from repositories on
> the local system. Use SSH authentication to access Copier templates in private Git repositories. If you do not use an
> SSH agent, you can pass
> [credentials](https://copier.readthedocs.io/en/stable/faq/#how-to-pass-credentials-to-git).

### Using Existing Responses for Updates

If you think that it is safe to use the existing responses for an update, you can use the
[skip answered](https://copier.readthedocs.io/en/stable/configuring/#skip_answered) option to make Copier automatically
use the responses from the answers file:

```shell
copier update -A -a .copier/.copier-answers-mycompany-myteam-aws-lambda-py.yaml
```

 This option does not handle responses to new questions, because the answers file will not have a response for them.

### Updating Specific Files

Use _--exclude_ to update a single file in a project from a template:

```shell
copier copy --exclude '*' --exclude '!file-i-want' ./template ./destination
```

For example:

```shell
copier copy -a .copier/.copier-answers-mycompany-myteam-aws-lambda-py.yaml --exclude '*' --exclude '!.pre-commit-config.yaml' git+ssh://github.com/my-username/copier-mycompany-myteam-aws-lambda-py.git .
```

## Creating a Copier Template

> This process does not require the Copier tool.

A Copier template is a Git repository with a structure like this:

```shell
|- template/
|   |
|   |- .copier/
|   |    |- [[_copier_conf.answers_file]].jinja
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
   with `copier-`. To simplify management, set the name of the repository to match the
   [identifier of the answers file](#managing-copier-answers-files). For example:
   `copier-mycompany-myteam-aws-lambda-py` when the answers file will be identified as `mycompany-myteam-aws-lambda-py`.
2. Create a `copier.yaml` configuration file in the root of the template repository. See below for an
   [example configuration file](#example-configuration-file-for-the-template). To avoid conflicts with other Copier
   templates that projects may use, the `_answers_file` must specify a
   [name that is unique to each template](#managing-copier-answers-files).
3. Create a directory called `template/` in the repository to hold the files and directories that make up the template.
4. Create a directory called `template/.copier/` in the repository to hold the template answers file.
5. Create a template answers file with the name `[[_copier_conf.answers_file]].jinja` in the directory
   `template/.copier/`. Use this exact name. The file name in the template must include the delimiters, because the file
   in each project is completely managed by Copier. See below for an
   [example answers file](#example-template-answers-file).
6. _Optional:_ Set up [automated releases](#automating-version-tags) for the template repository to ensure that there
   are [Git tags for versions](#versioning-your-copier-templates).
7. _Optional:_ Add metadata to the project for the template repository. For example, if it is hosted on GitHub, add the
   GitHub Topic _copier-template_.

> Copier supports having
> [multiple template directories](https://copier.readthedocs.io/en/stable/configuring/#subdirectory) in the same
> template repository. This requires that every set of files uses the same questions. To avoid issues occurring later
> on, I would recommend only having one template directory for each template repository.

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
# Specify version 9.17 as the minimum because of security fixes in that version.
_min_copier_version: "9.17"

# Use this subdirectory of the template repository as the root directory of the template.
_subdirectory: template

# Name of the answers file.
# This file name must be unique to avoid conflicts with other Copier templates.
# Start the name of the file with .copier-answers so that Renovate can detect it.
# By default, Copier uses the root directory of the project for answers files,
# but this example uses a .copier/ directory.
_answers_file: .copier/.copier-answers-myorg-myteam-aws-lambda-py.yaml

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
  - LICENSE.md
  - README.md
```

> To avoid conflicts with other Copier templates that projects may use, the `_answers_file` must specify
[a unique name](#managing-copier-answers-files).

You also define the questions for the template in the configuration file. The Copier maintainers recommend that you use
[the well-known variable names](https://copier.readthedocs.io/en/stable/settings/#well-known-variables) for common
variables. Set default answers for questions as much as possible, because they minimise user effort and increase
consistency.

> Copier supports including
> [other YAML files](https://copier.readthedocs.io/en/stable/configuring/#include-other-yaml-files) into the
> configuration. To avoid issues, you should only do this if you have a specific requirement that makes it necessary.

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
brackets as delimiters, the file itself will be called `[[_copier_conf.answers_file]].jinja` in the template repository.

### Managing Copier Answers Files

Each Copier template must have a separate answers file in the projects that use it. templates. This means that every
Copier template must specify a unique name for the answers file that it creates. The names of the answers files become
particularly important if projects may use templates that are maintained by different groups.

Here are some guidelines for naming Copier templates answers files:

- Start the name of each answers file with `.copier-answers`, so that [Renovate](https://www.mend.io/renovate/) and
  other tools can identify it as a Copier answers file.
- Use hyphens as separators.
- Include namespaces in the template name, such as your company and your team.
- Include a unique identifier for the template.
- Use the same name for the answers file and the repository.
- Always use the file extension `.yaml`, so that the file is identified as a YAML file.

For example, you could name the answers file for a Copier template for AWS Lambda projects as
`.copier-answers-mycompany-myteam-aws-lambda-py.yaml`, so that the template has the namespaces `mycompany` and `myteam`
and the template identifier `aws-lambda-py`. The repository could then have the name
`copier-mycompany-myteam-aws-lambda-py`.

This article also suggests that you put answers files in a `.copier/` directory. This simplifies automation and reduces
clutter in the root directory of each project. By default, Copier puts answers files in the root directory of projects.

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

- [The Official Copier documentation](https://copier.readthedocs.io/en/stable/)
- [Exploring Copier Python: A Comprehensive Guide](https://coderivers.org/blog/copier-python/)
- [Bootstrapping Python projects with copier](https://blog.dusktreader.dev/2025/04/06/bootstrapping-python-projects-with-copier/)
- [Effective Repository Templates with Copier](https://browniantech.com/blog/post/Effective-Repository-Templates-with-Copier)
- [Renovate Support for Copier](https://docs.renovatebot.com/modules/manager/copier/)

### Example Templates

- [Example Copier template for Python projects](https://github.com/pawamoy/copier-uv), by Timothée Mazzucotelli
- [Example Copier baseline template](https://github.com/stuartellis/sve-copier-baseline), an example of a
  general-purpose template
