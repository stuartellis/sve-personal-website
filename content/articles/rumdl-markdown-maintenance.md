+++
categories = ["automation", "devops", "documentation", "programming"]
date = "2026-10-25T07:56:00+01:00"
description = "Using rumdl to Maintain Markdown Documents"
slug = "rumdl-markdown-maintenance"
tags = ["automation", "devops", "documentation", "markdown"]
title = "Using rumdl to Maintain Markdown Documents"
+++

[Markdown](https://en.wikipedia.org/wiki/Markdown) has effectively become the standard for formatted text. We often
write Markdown manually, so the documents that we rely on can easily contain syntax issues and broken links as well as
inconsistent formatting. This means that we should automatically lint and format Markdown files, in the same way that we
maintain code files.

The [rumdl](https://rumdl.dev/) tool provides both linting and formatting for Markdown documents, including
[reflowing text](https://rumdl.dev/md013/?h=reflow#reflow-modes) to standardise line lengths. You can run `rumdl` with
Git hooks, on-demand by [using a hook manager](https://www.stuartellis.name/articles/prek-containers/), and as part of
continuous integration pipelines. It supports the popular variations of Markdown, such as
[CommonMark](https://commonmark.org/), [GitHub Flavored Markdown](https://github.github.com/gfm/),
[Obsidian Flavoured Markdown](https://obsidian.md/help/obsidian-flavored-markdown) and
[Python Markdown](https://python-markdown.github.io/).

> The `rumdl` checks test [relative links](https://rumdl.dev/link-validation/?h=links#relative-links-md057) and
> [anchor links](https://rumdl.dev/link-validation/?h=links#anchor-links-md051). You will need to use a tool like
> [lychee](https://lychee.cli.rs/) to check the links to external sites.

## Installing `rumdl`

To install `rumdl` on a development system, use the packages from the [npm](https://www.npmjs.com/package/rumdl) or
[Python](https://pypi.org/project/rumdl/) registries. If you use a package management tool like
[npm](https://docs.npmjs.com/cli), [pipx](https://pipx.pypa.io/stable/), or [uv](https://docs.astral.sh/uv/), you can
specify which version of `rumdl` it installs:

```shell
npm install -g rumdl@0.3.0
```

```shell
pipx install rumdl==0.3.0
```

You can also install `rumdl` with [Homebrew](https://brew.sh/). Homebrew always installs the latest version of `rumdl`:

```shell
brew install rumdl
```

## Example Configuration File for `rumdl`

This example configuration file for a project enable the complete set of features that `rumdl` provides, including
[reflow](https://rumdl.dev/md013/?h=reflow#reflow-modes) of text:

```toml
# rumdl configuration file
#
# https://rumdl.dev/

[global]

enable = ["ALL"]

exclude = [
    ".git",
    "LICENSES",
    "LICENSE.md"
]

line-length = 120

respect-gitignore = true

[MD004]
style = "dash"

[MD013]
reflow = true
reflow-mode = "normalize"
```

## Using `rumdl` in Your Editor

Set up integrations with your text editors to automatically receive feedback as you work and enable the editor to format
Markdown documents with `rumdl`.

### Enabling Visual Studio Code Integration

To use `rumdl` with Visual Studio Code or a compatible editor, install the
[rvben.rumdl](https://marketplace.visualstudio.com/items?itemName=rvben.rumdl) extension.

> The extension includes a copy of `rumdl`. This means that it will function even if you have not installed a package
> for `rumdl`.

### Enabling Integration with JetBrains IDEs

To enable support for `rumdl` in JetBrains IDEs such as PyCharm, install the
[rumdl](https://plugins.jetbrains.com/plugin/29943-rumdl) plugin.

## Automating Checks with `prek` or `pre-commit`

To automate the maintenance of Markdown files in your project, add Git hooks. The most popular tools for managing hooks
are [prek](https://prek.j178.dev/) and [pre-commit](https://pre-commit.com/). The [prek](https://prek.j178.dev/) tool
supersedes [pre-commit](https://pre-commit.com/). It can use existing `pre-commit` hooks, and also works with existing
`pre-commit` project configurations.

This example `.pre-commit-config.yaml` configuration file for a project uses the copy of `rumdl` on the system:

```yaml
---
minimum_prek_version: "0.4.0"

repos:
  - repo: builtin
    hooks:
      - id: check-added-large-files
      - id: check-case-conflict
      - id: check-illegal-windows-names
      - id: check-json
      - id: check-merge-conflict
      - id: check-symlinks
      - id: check-toml
      - id: check-vcs-permalinks
      - id: check-xml
      - id: check-yaml
      - id: destroyed-symlinks
      - id: end-of-file-fixer
      - id: fix-byte-order-marker
      - id: mixed-line-ending
      - id: trailing-whitespace

  - repo: local
    hooks:

      - id: rumdl-fmt
        name: rumdl fmt
        description: Format Markdown files in place. Always exits 0; relies on pre-commit file-change detection.
        entry: rumdl fmt
        language: system
        types: [markdown]
        require_serial: true

      - id: rumdl-check
        name: rumdl check
        description: Lint Markdown files. Exits 1 if violations are found. Run rumdl-fix to auto-fix in place.
        entry: rumdl check
        language: system
        types: [markdown]
        require_serial: true

      - id: rumdl-fix
        name: rumdl fix
        description: Fix Markdown files.
        entry: rumdl check --fix
        language: system
        types: [markdown]
        require_serial: true
        stages: [manual]
```

The hooks automatically run on the staged changes each time that you commit. The only exception is `rumdl-fix`, which is
`manual` and runs when explicitly called.

> For security, the example above uses `builtin` hooks. To make it compatible with `pre-commit`, you would need to
> replace these with [remote hooks](https://github.com/pre-commit/pre-commit-hooks).

To run a tool without committing a change, use `prek run`. If you add the option `--all-files` it will check the current
files in the project, not just staged changes. For example, to run the `rumdl-fix` hook on the project, use this
command:

```shell
prek run rumdl-fix --all-files
```

To run every hook on the project, use this command:

```shell
prek run --all-files
```
