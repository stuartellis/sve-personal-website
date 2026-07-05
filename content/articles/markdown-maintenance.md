+++
title = "Tooling for Maintaining Markdown Files"
slug = "markdown-maintenance"
date = "2026-07-04T18:13:00+01:00"
description = "Tooling for maintenance of Markdown files"
draft = true
categories = ["automation", "devops", "documentation", "programming"]
tags = ["automation", "devops", "documentation", "markdown"]
+++

[Markdown](https://en.wikipedia.org/wiki/Markdown) has effectively become the standard for formatted text. Many, many products now use Markdown, from [Jupyter](https://jupyter.org/) notebooks for interactive computation to static Website generators like [Hugo](https://gohugo.io/) and [Zensical](https://zensical.org/). Current versions of the [LibreOffice](https://www.libreoffice.org/) office suite support Markdown. LLMs now use Markdown as their standard text format for input and output.

The Markdown format supports extensions and embedded elements. You can embed metadata (frontmatter), [MDX components](https://mdxjs.com/) and [Mermaid](https://mermaid-js.github.io) diagrams into Markdown documents, as well as links to assets like images.

Markdown files often contain formatting errors and broken links. This means that we should always check the Markdown documents that we rely on.

Tools become most effective when they work automatically. This article describes tools that run in both text editors and with Git hooks that call them when we commit changes to version control. We should also run them in continuous integration pipelines, to ensure that changes never introduce errors.

## Formatting, Linting and Validating Markdown

You can run these tools with both Git hooks and on-demand by [using a hook manager](https://www.stuartellis.name/articles/prek-containers/). Since they are command-line tools, you can also run them as part of continuous integration pipelines.

> The tools have useful default configurations, so you only need to add configuration files if you need to customize their behavior.

### Formatting

Automated formatting improves projects for no cost. When we apply the same formatter on every change, the format becomes consistent and predictable, which enables us to rapidly refactor projects. Automatic formatting also removes the need for commits that only format files.

### Linting

Linting ensures that files contain valid Markdown, and that the Markdown content follows good practice.
