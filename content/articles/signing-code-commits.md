+++
title = "Signing Code Commits"
slug = "signing-code-commits"
date = "2026-06-27T13:11:00+01:00"
description = "Signing Code Commits"
categories = ["devops", "programming"]
tags = ["devops"]

+++

We should always sign the commits that we make in source code repositories, especially for shared projects like Open Source software. This ensures that every commit includes a signature that links it to a specific author. Since I use more than one repository hosting service, I have written this article on how to set up commit signing in a way that works across services.

This method uses [GnuPG](https://gnupg.org/), the current standard Open Source tool for signing code commits. [Sequoia PGP](https://sequoia-pgp.org/) may supersede GnuPG in future.

> _GPG_: Many existing documents use the term _GPG_ instead of _GnuPG_ or _OpenPGP_. To avoid confusion, this article follows the same convention.

## How Commit Signing Works

If you use a repository hosting service like [Codeberg](https://codeberg.org/), [GitHub](https://github.com/) or an instance of [GitLab](https://about.gitlab.com/), you will see that it shows commits as _Verified_. This means that it has successfully checked the signature on the commit.

> GitHub and GitLab allow you to sign commit with SSH keys. Avoid using SSH keys to sign commits, because the SSH key standard does not support verification or revocation of keys across independent and distributed systems.

Use GPG to sign your Git commits as you create them, and register the same GPG key for every service that you use.

To do this, create a keypair with GPG, configure Git to use it, and then register the public key with the hosting services that you use.

If you work on Open Source projects, publish your GPG public keys to open key servers as well. This enables other people to verify your commits without relying on the hosting service.

The rest of this article leads you through the process to enable commit signing.

## Installing GPG

Many Linux distributions automatically include GPG. To install GPG on macOS, use [Homebrew](http://brew.sh/). Run these commands to install GPG and integration with the desktop:

```shell
brew install gnupg
brew install pinentry-mac
```

## Creating a GPG Key

To create a GPG key, run the _gpg_ command in a terminal window, like this:

```shell
gpg --full-gen-key
```

GPG will prompt you for several options. Use these values:

- Select the _RSA and RSA_ algorithm
- Choose a key length of _4096_
- Accept the default option to have no expiration date for your key
- Enter the same email address that you will use for code hosting sites, such as Codeberg or GitHub

Once you have created a GPG key, configure Git to use it.

First get the ID of the key:

```shell
gpg --list-secret-keys --keyid-format=long
```

This displays an output like this:

```shell
pub   rsa4096/C36CB86CB86B3716 2022-01-18 [SC]
      BF18AC2876178908D6E71267D36CB86CB86B3716
uid                 [ultimate] Anne Example <anne@example.org>
sub   rsa4096/B7BB94F0C9BA6CAA 2022-01-18 [E]
```

In this example, the key ID is _C36CB86CB86B3716_.

## Enabling Git to Sign Commits

To configure Git to use the key that you have created:

```shell
git config --global user.signingkey C36CB86CB86B3716
git config --global commit.gpgsign true
```

## Registering Your GPG Key with Repository Hosts

Add your GPG key to your accounts on code hosting services that you use. These services each provide their own documentation on how to register your GPG key:

- [Codeberg](https://docs.codeberg.org/security/gpg-key/)
- [GitHub](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)
- [GitLab](https://docs.gitlab.com/ee/user/project/repository/signed_commits/gpg.html#add-a-gpg-key-to-your-account)

## Publishing Your GPG Key with

If you work on Open Source projects, publish your GPG public key to [the OpenPGP key server](https://keys.openpgp.org/). If you contribute to an existing project, you might also publish your GPG public key to other servers that the project recommends. This enables other people to verify your commits without relying on a hosting service.
