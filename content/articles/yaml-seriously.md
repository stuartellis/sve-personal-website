+++
title = "YAML, Seriously"
slug = "yaml-seriously"
date = "2025-09-13T09:01:00+01:00"
description = "Working effectively with YAML"
draft = true
categories = ["automation", "devops", "kubernetes", "programming"]
tags = ["automation", "devops", "kubernetes"]
+++

YAML is an essential and unavoidable part of operating modern IT systems. It has been the established format for configurations for years, and is unlikely to be replaced for a long time to come. The list of technologies that rely on YAML include Kubernetes, Ansible, AWS CloudFormation, GitHub Actions and GitLab Pipelines. So, let's take it seriously.

This article covers tools and practices for working effectively with YAML.

## What is YAML, Actually?

We can think of YAML as a set of rules for _data serialization_. It describes objects. Each YAML document can contain the description for one or more objects.

So, YAML provides a format for humans to read and edit documents that describe data objects. In some cases, the set of documents must describe a large number of objects that have the configuration information for many different components of a system. For example, a CloudFormation stack or a Helm chart for Kubernetes might describe the complete configuration of an entire service.

We often use YAML for objects that describe a configuration, but it is not specifically for this purpose. Some modern systems now use [TOML](https://toml.io), which is specifically designed for configuration that is maintained by humans. The fact that YAML is for describing data does mean that it has been able to scale up to very large sets of configuration. The way that YAML can scale from the very small and simple to the very large may be one of its best features.

YAML has always cleanly translated to and from JSON. Many systems that use YAML actually process JSON, and automatically convert YAML to and from JSON. This allow us to have the files and interfaces that humans see in YAML, whilst the internals of the systems use JSON. The JSON language is much simpler, and every popular programming language has well-tested, high-performance libraries for JSON.

You may find it helpful to keep in mind:

1. YAML helps humans to read and write definitions of data objects.
2. The YAML that you see might be converted to JSON before a system processes it.
3. There are now many variations of YAML that are specialized for working with particular systems. That is OK.

The fact that YAML supports comments and JSON does not support comments at all means that any of the comments in a YAML file will be discarded if the YAML is converted to JSON. This is obviously helpful for the separation between the YAML that you read and the optimized JSON version that a system might actually process. You can write comments in YAML for humans, and they will not appear in the JSON version.

> The current version of the YAML specification is [YAML 1.2.2](https://yaml.org/spec/1.2.2/), which was published in 2021.

## How to Work With YAML

YAML enables humans to read and edit documents that describe data objects. In some cases, the set of documents must describe a large number of objects. You do not need to write large amounts of YAML yourself, or struggle to manually check YAML. You can always use tools to help.

## 1. YAML Has Schemas

TODO

## 2. YAML Has Linters

TODO

## 3. YAML Has Formatters

TODO

## 4. Consider Letting Computers Write the YAML

TODO

### 5. Only Use The Language That You Need

YAML is notorious for [having 63 ways to split a string](https://askthedev.com/question/63-methods-for-dividing-a-string-in-yaml-format/). You don't have to use all of the features. Instead, try to use the same format and features consistently in all of the YAML for a project. This makes it easier to read and update the YAML across the project.

If you are working in a project that relies on YAML, consider defining some rules or guidelines. You can then enforce these through linters and apply them in your own code. For example, the Kubernetes project has now documented a subset of YAML that they call [KYAML](https://blog.yangjerry.tw/kyaml-introduction-en/), and future releases of Kubernetes will generate YAML that follow the KYAML specification.

## 6. You Can Always Query YAML

TODO

## Recommendations for Organizing YAML Files

### Use the Correct File Name

Always use the correct filename for the type of YAML, so that editors and other tools can identify the type of file.

Since you can only have one file in each directory with a specific name, this does that you should create a separate directory for each file.

For example, always create Kubernetes [kustomization](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/) files with the name _kustomization.yaml_ and GitLab Pipelines files with the name _gitlab-ci.yaml_.

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
