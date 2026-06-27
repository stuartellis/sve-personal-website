+++
title = "Handling Credentials and Secrets"
slug = "tech-credentials-and-secrets"
date = "2026-06-27T13:15:00+01:00"
description = "Handling credentials and secrets for development and systems administration"
categories = ["devops", "programming"]
tags = ["devops", "fedora", "linux", "macos"]

+++

Every technical user frequently needs to use API tokens and other sensitive credentials, keeping them secure whilst making them available when required.

This means that you will need to manage these types of secrets:

- _GPG keys_ - To digitally sign files, messages and code commits
- _Passwords_ and _passkeys_ - To identify yourself to systems
- _SSH keys_ - To access Git repositories and remote systems
- _API tokens_ - To access APIs for services

## Managing GPG Keys

> _GPG_: This article refers to GPG, because GnuPG is the main implementation of the OpenPGP standards. Many existing documents use the term _GPG_ instead of _GnuPG_ or _OpenPGP_. [Sequoia PGP](https://sequoia-pgp.org/) may supersede GnuPG in future.

Set up your GPG key and enable commit signing in Git before you work on shared projects. We should always sign the commits that we make in source code repositories, especially for shared projects like Open Source software. This ensures that every commit includes a signature that links it to a specific author.

Many Linux distributions automatically include GPG. To install GPG on macOS, use [Homebrew](http://brew.sh/). Follow the steps in [this article on signing code commits](https://www.stuartellis.name/articles/signing-code-commits/) to enable Git to sign your commits with a GPG key.

The GnuPG suite stores keys as files on your local device. For this reason, always set a strong passphrase for your GPG key. If someone has a copy of your private key and the passphrase, they can use the key to sign items with your identity.

If you need to digitally sign your emails, consider using an email client that includes support for GPG, rather than relying on plugins. The GNOME and KDE desktops for Linux include email clients with GPG support. The [Thunderbird](https://www.thunderbird.net) email and calendar client supports GPG and runs on all popular operating systems.

## Managing Passwords and Passkeys

The [KeePassXC](https://keepassxc.org/) password manager runs on Windows, macOS, and Linux systems. It stores credentials in a database file. If you use KeePassX you will need to use a third-party app such as [KeePassDX](https://www.keepassdx.com/) on mobile devices, along with an extra tool to synchronize password databases.

Consider using the [Proton Pass](https://proton.me/pass) or [Bitwarden](https://bitwarden.com/) services if you need to share passwords or synchronize them across devices. Both of these services provide apps for mobile devices as well as desktop operating systems, Open Source the code for their apps and have successfully passed security audits.

> KeePassXC, Proton Pass and Bitwarden all provide command-line tools as well as desktop applications.

## Managing SSH Keys

Linux distributions and macOS include the standard [OpenSSH](https://www.openssh.org/) suite of tools for SSH.

Consider using an SSH key agent that stores your keys in an encrypted store, rather than the OpenSSH key agent. The KeePassXC, Bitwarden, Proton Pass and 1Password password managers can hold SSH keys as well as passwords, and provide SSH key agents.

If you use the OpenSSH key agent, use the `ssh-keygen` command to create new SSH keys. For example:

```shell
ssh-keygen -t ed25519 -C "Me MyName (MyDevice) <me@mydomain.com>"
```

Always set a strong passphrase for a SSH key that you create with `ssh-keygen`. It stores the files in the `.ssh` directory within your home directory. If someone has a copy of your private key and the passphrase, they can use the key to log in to systems as you.

> Use a separate SSH key for each set of systems that you access.

## Working with API Tokens

You will need make API tokens and other sensitive credentials available to development tools when required, without storing them in unencrypted files. If you work for an organization, they should provide a solution for you to use. Otherwise, consider using [fnox](https://fnox.jdx.dev/) or [dotenvx](https://dotenvx.com/) for this.

The `fnox` tool works with a range of local and remote [providers](https://fnox.jdx.dev/providers/overview.html) to get credentials and set them as environment variables. For example, it supports KeepPassXC, AWS Secrets Manager and Hashicorp Vault as providers. This means that you can store API tokens in the provider of your choice.

To install `fnox` with Homebrew, run this command in a terminal window:

```shell
brew install fnox
```

> Rotate your API tokens regularly. If you work for an organization, they should automatically rotate the API tokens for their services and the tools that they specify should fetch the current API tokens for you.
