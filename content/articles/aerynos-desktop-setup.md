+++
title = "Setting Up AerynOS"
slug = "aerynos-desktop-setup"
date = "2025-01-18T23:43:00+00:00"
description = "Setting up AerynOS"
draft = true
categories = ["devops", "programming"]
tags = ["devops", "linux", "aerynos", "golang", "javascript", "python"]

+++

A guide to setting up a desktop system with [AerynOS](https://aerynos.com/).

{{< alert >}}
Pre-release: AerynOS is currently in _alpha_, which means that it is still being developed. Some features are not complete, and each new update may include breaking changes.
{{< /alert >}}

## Installation

### Requirements

Ensure that your computer or virtual machine meets the hardware requirements.

### GNOME Boxes

Create a new virtual machine and select the ISO image for AerynOS. Ensure that the virtual machine meets the hardware requirements. Do not specify the _Operating System_.

GNOME Boxes creates virtual machines with a default configuration. We currently need to change the configuration for AerynOS to work correctly.

To do this, stop the virtual machine, open the _Preferences_ for the machine and select _Edit Configuration_. Make the changes that are shown below, and save the file. You can then restart the virtual machine.

Change _os_ from:

```xml
<os>
```

To:

```xml
<os firmware="efi">
```

Change _interface_ from:

```xml
<model type="rtl8139"/>
```

To:

```xml
<model type="virtio"/>
```

### Partitioning

You currently need to partition the storage before you start the AerynOS installation process. If you boot a computer or virtual machine with the ISO for AerynOS you can create the required partitions with the _GParted_ graphical tool.

To prepare the storage with _GParted_:

1. Choose _Device > Create Partition Table_. Select the partition table type _gpt_ and _Apply_.
2. Select the unallocated space and choose _New_ to create a partition with _File system_ as _fat32_ and a _New size_ partition with a max size of 2048Mib
3. Select the unallocated space and choose _New_ to create a partition with _File system_ as _fat32_ and a _New size_ partition with a max size of 2048Mib
4. Select the unallocated space and choose _New_ to create a partition with the _File system_ as _xfs_ and a _New size_ of at least 40,960Mib
5. Select _Edit > Apply All Operations_
6. Select the first partition and choose _Manage flags_. Select _esp_ and _Close_.
7. Select the second partition and choose _Manage flags_. Select _bls_boot_ and _Close_.

## Run the Installer

Boot the system from the ISO. Once the desktop appears open a terminal window and run this command:

```shell
sudo lichen
```

The installer asks you several questions. You can accept the default _GNOME Desktop_.

The installer currently downloads the latest packages from the _volatile_ repository.

Once the installation is complete, shut down the system. Ensure that the system will boot from the storage where AerynOS is installed. You can then start the system again to run AerynOS.

## After the Installation

### User Settings

Select _Settings \> Privacy & Security_. Check these settings:

- Always set _Thunderbolt Access_ to _Only USB and Display Port devices can attach._ unless you know that you need to connect other types of devices to your computer.
- Set _Location \> Automatic Device Location_ to off.
- Adjust the _File History & Wastebasket_ settings if you need to.

## Installing Desktop Applications with Flatpak

[Flatpak](https://flatpak.org) is now the standard for desktop software packages on Linux. Flatpak provides software that is not available from AerynOS repositories, such as Slack.

The Software utility uses the [Flathub](https://flathub.org/) service for Flatpak packages. Software shows both Flatpak and packages for apps. If a Flatpak is available, use that option.

{{< alert >}}
Install code editors and IDEs with packages, not Flatpak. Currently, security features for Flatpak may prevent application plugins from working correctly.
{{< /alert >}}

Useful software that you can install as Flatpaks include:

- [Beekeeper Studio](https://www.beekeeperstudio.io) for working with databases
- [Draw.io](https://www.drawio.com/) for drawing diagrams
- [Joplin](https://joplinapp.org/) for note-taking

## Setting Up for Development

### Zed

AerynOS includes [Zed](https://zed.dev/), a powerful desktop editor for programming, with built-in support for version control and debugging. The large range of extensions for Zed enable it to work with every popular programming language and framework.

Use the features in Zed to install the extensions that you need for your preferred tools and programming languages.

> AerynOS also includes the command-line text editor [nano](https://www.nano-editor.org/).

### Configuring Git

AerynOS includes the [Git version control system](http://www.git-scm.com/). Always set your details for Git before you create or clone repositories on a new system. This requires two commands in a terminal window:

```shell
git config --global user.name "Your Name"
git config --global user.email "you@your-domain.com"
```

The _global_ option means that the setting will apply to every repository that you work
with in the current user account.

To enable colors in the output, which can be very helpful, enter this command:

```shell
git config --global color.ui auto
```

> Enable commit signing in Git before you work on shared projects. Follow the steps in [this article on signing code commits](https://www.stuartellis.name/articles/signing-code-commits/) to enable Git to sign your commits with a GPG key.

### Setting Up A Directory Structure for Projects

To keep your projects tidy, I would recommend following these guidelines. They may seem
slightly fussy, but they pay off when you have many projects, some of which are on
different version control hosts.

First create a top-level directory with a short, generic name like _repos_. For each repository host, create a subdirectory in _repos_. Add a subdirectory that matches your username. The final directory structure looks like this:

```text
repos/
    codeberg.org/
        my-codeberg-username/
            a-project/
    gitlab.com/
        my-gitlab-username/
            a-project/
            another-project/
```

### Creating SSH Keys

You may use SSH to access Git repositories or remote UNIX systems. AerynOS includes the standard OpenSSH suite of tools.

To create an SSH key, run the _ssh-keygen_ command in a terminal window. For example:

```shell
ssh-keygen -t ed25519 -C "Me MyName (MyDevice) <me@mydomain.com>"
```

Create a separate SSH key for each set of systems that you access.

## Working with Virtual Machines

AerynOS installs [GNOME Boxes](https://apps.gnome.org/en-GB/Boxes/) by default, to enable you to create and manage virtual machines. GNOME Boxes provides a graphical interface for the standard KVM and QEMU software. You can also use these tools directly on the command-line.

## Your Next Steps

### Keeping Up to Date

The current alpha version AerynOS updates rapidly with new features and software. To ensure that you keep up to date, resynchronize your system regularly.

To resynchronize a system, run this command in a terminal window:

```shell
sudo moss sync -u
```

After the updates have been applied, restart the computer.
