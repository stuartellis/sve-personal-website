+++
title = "Patterns for Writing YAML"
slug = "yaml-patterns"
date = "2025-09-14T16:51:00+01:00"
description = "Working effectively with YAML"
draft = true
categories = ["automation", "devops", "kubernetes", "programming"]
tags = ["automation", "devops", "kubernetes"]
+++

[YAML](https://en.wikipedia.org/wiki/YAML) is an essential and unavoidable part of operating modern IT systems. It has been the established format for configurations for years, and is unlikely to be replaced for a long time to come. The list of technologies that rely on YAML include Kubernetes, Ansible, AWS CloudFormation, GitHub Actions and GitLab Pipelines.

This article covers some practices for writing YAML files. They follow the principle that your YAML should work with standard tools. If your YAML matches the expectations of standard tools then you can [automate formatting, syntax checks and validation](https://www.stuartellis.name/articles/yaml-maintenance/).

## Recommendations for Organizing YAML Files

### Use the Correct File Extension

The recommended file extension for YAML is _.yaml_, as [noted in the documentation](https://yaml.org/faq.html). Old versions of Microsoft Windows only supported file extensions with three characters, which is why some YAML files have the extension _.yml_. All supported versions of Windows and other standard operating systems now support file extensions with four characters, so you can use the preferred file extension of _.yaml_.

> _Ansible uses .yml as the file extension:_ The convention is that Ansible files use the extension _.yml_, so you should still use this file extension with Ansible.

### Use the Correct File Name

Some tools specify an exact name for the YAML file that they use. If you are using a product that specifies a file name, always use the correct filename for the type of YAML. This enables editors and other tools to identify the type of file and use the correct [schema](https://www.schemastore.org/).

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
