+++
title = "YAML, Seriously"
slug = "yaml-seriously"
date = "2025-09-07T12:11:00+01:00"
description = "Working effectively with YAML"
draft = true
categories = ["automation", "devops", "kubernetes", "programming"]
tags = ["automation", "devops", "kubernetes"]
+++

YAML is an essential and unavoidable part of operating modern IT systems. It has been the established format for configurations for years, and is unlikely to be replaced for a long time to come. The list of technologies that rely on YAML include Kubernetes, Ansible, AWS CloudFormation, GitHub Actions and GitLab Pipelines. So, let's take it seriously.

This article covers tools and practices for working effectively with YAML.

## Recommendations for YAML Files

### Use the Correct File Name

Always use the correct filename for the type of YAML, so that editors and other tools can identify the type of file. Since you can only have one file in each directory with a specific name, this does that you should create a separate directory for each file. For example, always create Kubernetes [kustomization](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/) files with the name _kustomization.yaml_ and GitLab Pipelines files with the name _gitlab-ci.yaml_.

### Use the Correct File Extension

The recommended file extension for YAML is _.yaml_, as [noted in the documentation](https://yaml.org/faq.html). Old versions of Microsoft Windows only supported file extensions with three characters, which is why some YAML files have the extension _.yml_. All supported versions of Windows and other standard operating systems now support file extensions with four characters, so you can use the preferred file extension of _.yaml_.

> _Ansible uses .yml as the file extension:_ The convention is that Ansible files use the extension _.yml_, so you should still use this file extension with Ansible.

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

## Recommendations for Writing YAML

### Only Use What You Need

YAML is notorious for [having 63 ways to split a string](https://askthedev.com/question/63-methods-for-dividing-a-string-in-yaml-format/). You don't have to use all of the features. Instead, try to use the same format and features consistently in all of the YAML for a project. This makes it easier to read and update the YAML across the project.

If you are working in a project that relies on YAML, consider defining some rules or guidelines. You can then enforce these through linters and apply them in your own code. For example, the Kubernetes project has now documented a subset of YAML that they call [KYAML](https://blog.yangjerry.tw/kyaml-introduction-en/), and future releases of Kubernetes will generate YAML that follow the KYAML specification.
