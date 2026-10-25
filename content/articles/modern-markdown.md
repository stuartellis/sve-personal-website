+++
categories = ["documentation", "programming"]
date = "2026-10-25T07:56:00+01:00"
description = "Markdown formatted text for modern systems"
slug = "modern-markdown"
tags = ["python", "markdown"]
title = "Notes on Modern Markdown"
+++

[Markdown](https://en.wikipedia.org/wiki/Markdown) has become the standard syntax for formatted text. Use Markdown
documents for any kind of written content. Markdown is a supported text format for:

- Content Management Systems like [Ghost](https://ghost.org/)
- Note-taking apps like [Obsidian](https://obsidian.md/)
- Modern editors for code and technical documentation
- Current versions of the [LibreOffice](https://www.libreoffice.org/) office suite
- Working with LLMs

Many products render Markdown into other formats, such as HTML. [Jupyter](https://jupyter.org/) notebooks for
interactive computation and static Website generators like [Hugo](https://gohugo.io/) and
[Zensical](https://zensical.org/) use Markdown as the source format for content.

> Structured data formats like JSON can include Markdown documents as strings, since Markdown uses plain-text. This
> means that any modern data storage system will store Markdown documents.

The Markdown format supports extensions and embedded elements. You can embed metadata as
[frontmatter](https://github.com/jlevy/frontmatter-format), [MDX components](https://mdxjs.com/) and
[Mermaid](https://mermaid-js.github.io) diagrams into Markdown documents, as well as links to assets like images.

## Popular Dialects of Markdown

- [CommonMark](https://commonmark.org/) - The standard for Markdown
- [GFM](https://github.github.com/gfm/) - GitHub Flavored Markdown
- [Obsidian](https://obsidian.md/help/obsidian-flavored-markdown) - Obsidian Flavoured Markdown
- [Python Markdown](https://python-markdown.github.io/) - The Markdown dialect used by [Zensical](https://zensical.org/)
  and [MkDocs](https://www.mkdocs.org/)
- [MyST](https://mystmd.org) - Extends Markdown for technical and scientific publications

> All Markdown files use the file extension `.md`. There is no way to distinguish between stored CommonMark, GFM and
> Python Markdown documents. Content in the CommonMark format may be served with the `variant` MIME type
> `text/markdown; variant=CommonMark`.

## Known Issues with Markdown

- The CommonMark standard does not specify tables and other important elements. This means that many Markdown documents
  use GFM syntax.
- Tools that assume that Markdown documents use CommonMark and GFM syntax may fail on Python Markdown documents.
- Content from humans often contain formatting errors.
- Internal and external links may be invalid or broken. Use
  [rumdl](https://www.stuartellis.name/articles/rumdl-markdown-maintenance/) to check internal and anchor links, and a
  tool such as [lychee](https://lychee.cli.rs/) to check the links to external sites.

> Use [rumdl](https://www.stuartellis.name/articles/rumdl-markdown-maintenance/) to lint and format Markdown files. It
> supports the popular variations of Markdown, including CommonMark, Obsidian, GFM and Python Markdown.
