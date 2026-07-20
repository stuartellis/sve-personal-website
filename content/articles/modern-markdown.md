+++
categories = ["documentation", "programming"]
date = "2026-07-19T08:50:00+01:00"
description = "Markdown formatted text for modern systems"
slug = "modern-markdown"
tags = ["python", "markdown"]
title = "Modern Markdown"
+++

[Markdown](https://en.wikipedia.org/wiki/Markdown) has become the standard syntax for formatted text. Use Markdown
documents for any kind of written content. For example, input and output for LLMs defaults to Markdown.

Many products render Markdown into other formats, such as HTML. [Jupyter](https://jupyter.org/) notebooks for
interactive computation and static Website generators like [Hugo](https://gohugo.io/) and
[Zensical](https://zensical.org/) use Markdown as the source format for content.

Modern text editors for code also support Markdown. Current versions of the [LibreOffice](https://www.libreoffice.org/)
office suite now support Markdown as a document format.

> Structured data formats like JSON can include Markdown documents as strings, since Markdown uses plain-text. This
> means that any modern data storage system will store Markdown documents.

The Markdown format supports extensions and embedded elements. You can embed metadata as _frontmatter_,
[MDX components](https://mdxjs.com/) and [Mermaid](https://mermaid-js.github.io) diagrams into Markdown documents, as
well as links to assets like images.

## Dialects of Markdown

- [CommonMark](https://commonmark.org/) - The standard for Markdown
- [GFM](https://github.github.com/gfm/)
- [Python Markdown](https://python-markdown.github.io/)
- [MyST](https://mystmd.org)

> All Markdown files use the file extension `.md`. We have no automatic means of distinguishing betweeen CommonMark, GFM
> and Python Markdown documents.

## Known Issues with Markdown

- The CommonMark standard does not specify tables and other important elements. This means that many Markdown documents
  use GFM syntax.
- Tools that assume that Markdown documents use CommonMark and GFM syntax may fail on Python Markdown documents.
- Content from humans often contain formatting errors and broken links.

> Use [rumdl](https://www.stuartellis.name/articles/rumdl-markdown-maintenance/) to lint and format Markdown files. It
> supports the popular variations of Markdown, including CommonMark, GFM and Python Markdown.
