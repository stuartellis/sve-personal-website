+++
title = "Handling Credentials and Secrets for Technical Work"
slug = "tech-credentials-and-secrets"
date = "2026-06-28T08:26:00+01:00"
description = "Handling credentials and secrets for development and systems administration"
categories = ["devops", "programming"]
tags = ["devops", "fedora", "linux", "macos"]

+++

Every technical user frequently needs to use passwords, API tokens and other sensitive credentials, keeping them secure whilst making them available to tools when required.

This means that you will need to manage these types of secrets:

- _GPG keys_ - To digitally sign files, messages and code commits
- _Passwords_ and _passkeys_ - To identify yourself to systems
- _SSH keys_ - To access remote systems, such as remote Git repositories
- _API tokens_ - To access APIs for services

If you work for an organization, they should specify the tools that you use for that work. This article provides an introduction to tools that you can use for yourself.

## Managing GPG Keys

> _GPG_: This article refers to GPG, because many existing documents use the term _GPG_ instead of _GnuPG_ or _OpenPGP_. [Sequoia PGP](https://sequoia-pgp.org/) also implements the OpenPGP standards,and may supersede GnuPG in future.

Set up your GPG key and enable commit signing in Git before you work on shared projects. We should always sign the commits that we make in source code repositories, especially for shared projects like Open Source software. This makes it possible to detect when an attacker has tampered with a repository, because every commit includes a signature that links it to a specific author.

Many Linux distributions automatically include GPG. To install GPG on macOS, use [Homebrew](http://brew.sh/). Follow the steps in [this article on signing code commits](https://www.stuartellis.name/articles/signing-code-commits/) to enable Git to sign your commits with a GPG key.

The GnuPG suite stores keys as files on your local device. For this reason, always set a strong passphrase for your GPG key. If someone has a copy of your private key and the passphrase, they can use the key to sign items with your identity.

If you need to digitally sign your emails, consider using an email client that includes support for GPG, rather than relying on plugins. The GNOME and KDE desktops for Linux include email clients with GPG support. The [Thunderbird](https://www.thunderbird.net) email and calendar client supports GPG and runs on all popular operating systems.

## Managing Passwords and Passkeys

The [KeePassXC](https://keepassxc.org/) password manager runs on Windows, macOS, and Linux systems. It stores credentials in a database file. If you use KeePassX you will need to use a third-party app such as [KeePassDX](https://www.keepassdx.com/) on mobile devices, along with an extra tool to synchronize password databases.

Consider using the [Proton Pass](https://proton.me/pass) or [Bitwarden](https://bitwarden.com/) services if you need to share passwords or synchronize them across devices. Both of these services provide apps for mobile devices as well as desktop operating systems, Open Source the code for their apps, and have successfully passed security audits.

> KeePassXC, Proton Pass and Bitwarden all provide command-line tools as well as desktop applications.

Avoid using a password manager for Multifactor Authentication (MFA), also referred to as two-step verification. MFA ensures that attackers cannot log in to the protected service as you, even if the security of your password manager fails or your password for that service leaks in another way. If you use Android devices, consider using [Aegis Authenticator](https://getaegis.app/) for MFA.

## Managing SSH Keys

SSH supports remote log in, remote command execution, file transfers and secure port forwarding. Always use SSH keys to access code repositories and other remote systems, such as servers. They provide more security than passwords.

Linux distributions and macOS include the standard [OpenSSH](https://www.openssh.org/) suite of tools for SSH. The OpenSSH suite provides the tools to use SSH, including an agent for SSH keys.

If you enable an SSH key agent, all software that requires SSH can automatically authenticate to remote systems as needed by using the relevant key. Consider using an SSH key agent that stores your keys in an encrypted store, rather than the OpenSSH key agent. KeePassXC, Bitwarden, Proton Pass and 1Password can all act as SSH key agents.

If you use the OpenSSH key agent, use the `ssh-keygen` command to create new SSH keys. For example:

```shell
ssh-keygen -t ed25519 -C "Me MyName (MyDevice) <me@mydomain.com>"
```

Always set a strong passphrase for a SSH key that you create with `ssh-keygen`. It stores the files in the `.ssh` directory within your home directory. If someone has a copy of your private key and the passphrase, they can use the key to log in to systems as you.

> Use a separate SSH key for each set of systems that you access.

## Working with API Tokens

You will need to make API tokens and other sensitive credentials available to development tools when required, without storing them in unencrypted files. If you work for an organization, they should provide a solution for you to use. Otherwise, consider using [fnox](https://fnox.jdx.dev/) or [dotenvx](https://dotenvx.com/) for this.

The `fnox` tool works with a range of local and remote [providers](https://fnox.jdx.dev/providers/overview.html) to get credentials and set them as environment variables. For example, it supports KeePassXC as a local provider. This means that you can store API tokens in the providers of your choice.

To install `fnox` with Homebrew, run this command in a terminal window:

```shell
brew install fnox
```

> Rotate your API tokens regularly. If you work for an organization, they should automatically rotate the API tokens for their services and the tools that they specify should provide the current API tokens for you.
