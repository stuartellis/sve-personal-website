+++
title = "Setting Up Fedora Workstation for Software Development"
slug = "fedora-workstation-setup"
date = "2024-01-28T19:33:00+00:00"
description = "Setting up a Fedora Workstation for development and systems administration"
categories = ["devops", "programming"]
tags = ["devops", "linux", "fedora", "golang", "javascript", "python"]

+++

A guide to setting up Fedora Workstation for DevOps and software development. This is current for Fedora 39.

## Installation

### Enable Disk Encryption

Enable disk encryption when prompted during the setup process.

Disk encryption is the only protection against anyone with physical access to your
computer. All other security measures will be completely bypassed if someone with
physical access either restarts your computer with a bootable pen drive, or removes the
internal hard drive and attaches it to another computer.

### Set a Password for UEFI or BIOS

Once you have installed Fedora, restart your computer, and press the function key to
enter the setup menu for the UEFI firmware, or BIOS. Change the boot options so that the
computer only boots from the hard drive, and set both a user password for startup, and
an administrator password to protect the firmware menus.

## Do This First

Log in once, run the GNOME Software utility, and ensure that the operating system has
the latest updates. After all of the updates have been applied, restart the computer.

## User Settings

Select _Settings \> Privacy_, and review the settings. Depending upon your needs, you
may decide to turn off _Location Services_ or _Usage & History_.

## Installing Desktop Applications with Flatpak

[Flatpak](https://flatpak.org) is the new standard for desktop software packages. The Fedora project still provides RPM packages for many desktop applications, but Flatpak already offers newer versions of products, as well as software that is not available from Fedora RPM repositories, such as Slack.

## Setting Up for Development

### Text Editors

Fedora includes the command-line editor [nano](https://www.nano-editor.org/) and a small version of [vim](http://www.vim.org/) with a limited set of features, as well as a
desktop text editor with basic support for programming. Add the code editors or IDEs that you would prefer to use.

If you do not have a preferred editor, consider using a version of [Visual Studio Code](https://code.visualstudio.com). To work with a modern Vim editor, install [Neovim](https://neovim.io).

{{< alert >}}
Install code editors and IDEs with RPM packages, not Flatpak. Currently, Flatpak packages may prevent application plugins from working correctly.
{{< /alert >}}

#### Visual Studio Code

[Visual Studio Code](https://code.visualstudio.com) is a powerful desktop editor for programming, with built-in support for version control and debugging. The large range of extensions for Visual Studio Code enable it to work with every popular programming language and framework. It is available free of charge.

The Microsoft releases of Visual Studio Code are proprietary software with telemetry enabled by default, and download extensions from a proprietary Microsoft app store. if you have issues or concerns about the Microsoft releases, use the RPM packages that are provided by the [vscodium](https://vscodium.com) project.

{{< alert >}}
Extensions may fail if you use the [Visual Studio Code OSS](https://flathub.org/apps/details/com.visualstudio.code.oss) Flatpak.
{{< /alert >}}

#### Neovim

If you would like a modern Vim editor with a good default configuration, set up Neovim. To install Neovim, enter this command in a terminal window:

    sudo dnf install neovim

#### Setting The EDITOR Environment Variable

Whichever text editor you choose, remember to set the EDITOR environment variable in
your _~/.bashrc_ file, so that this editor is automatically invoked by command-line
tools like your version control system. For example, put this line in your profile to
make Neovim (_nvim_) the favored text editor:

    export EDITOR="nvim"

### Configuring Git

Fedora Workstation includes the [Git version control system](http://www.git-scm.com/). Always set your details for Git before you create or clone repositories on a new system. This requires two commands in a terminal window:

    git config --global user.name "Your Name"
    git config --global user.email "you@your-domain.com"

The _global_ option means that the setting will apply to every repository that you work
with in the current user account.

To enable colors in the output, which can be very helpful, enter this command:

    git config --global color.ui auto

### Setting Up A Directory Structure for Projects

To keep your projects tidy, I would recommend following these guidelines. They may seem
slightly fussy, but they pay off when you have many projects, some of which are on
different version control hosts.

First, create a top-level directory with a short, generic name like _repos_. For each repository host, create a subdirectory that matches your username. Check out projects in the directory.

The final directory structure looks like this:

```
    repos/
      gitlab.com/
        my-gitlab-username/
            a-project/
            another-project/
      sr.ht/
        my-sourcehut-username/
            a-project/
```

### Creating SSH Keys

You will frequently use SSH to access Git repositories or remote UNIX systems. Fedora
includes the standard OpenSSH suite of tools.

To create an SSH key, run the _ssh-keygen_ command in a terminal window. For example:

    ssh-keygen -t ed25519 -C "Me MyName (MyDevice) <me@mydomain.com>"

## Working with Programming Languages

Avoid using Fedora packages for programming languages on development systems.  Use containers or tools for managing installations of programming languages, so that you can install the correct versions and dependencies for each of your projects.

Fedora Workstation automatically includes support for containers, with [Podman](https://podman.io/) as the equivalent of Docker, along with [toolbx](https://containertoolbx.org/) to help you manage container environments for developing your projects.

### Using Version Managers

You may use any version manager on Fedora Workstation, such as [pyenv](https://github.com/pyenv/pyenv) for Python, [nvm](https://github.com/creationix/nvm) for Node.js and [rustup](https://rustup.rs/) for Rust.

Fedora Workstation includes the GCC compiler and other tools for compiling C code. Installations of Python, Node.js and other languages use GCC to compile components that are written in C.

To install a version manager, use the process that the documentation for the product recommends.

### The System Python Installation

Fedora includes an installation of Python 3, which is used by system tools. Avoid using this system installation yourself. Instead, manage your own installations of Python with containers or version managers, as explained in the previous section.

## Working with Containers

Fedora Workstation automatically includes support for containers. [Podman](https://podman.io/) provides the features of Docker, and [toolbx](https://containertoolbx.org/) helps you manage container environments for developing your projects.

To use a graphical interface for working with containers, add [Podman Desktop](https://podman-desktop.io) to your system. To install Podman Desktop, go to _Software_, search for _Podman Desktop_, select the entry from the list, and choose _Install_.

### Podman

Podman replaces [Docker](https://www.docker.com/), and also has additional features to integrate better with both the Linux operating system and Kubernetes. For example, [you can run Podman containers as standard system services](https://www.redhat.com/sysadmin/quadlet-podman).

Podman accepts the same syntax as the _docker_ command-line tool, and will read Dockerfiles. Both Docker and Podman use the OCI image format, so that images created either product will work with the other. By default, Podman will check the Docker public registry for container images, as well as [Quay](https://quay.io/) registries.

For convenience, define a shell alias in your _.bashrc_ file:

    alias docker="podman"

This will redirect any call to Docker, so that it uses Podman instead.

The [Usage Transfer](https://github.com/containers/libpod/blob/master/transfer.md) page lists Docker commands, and the equivalents for Podman. [This article](https://developers.redhat.com/blog/2019/02/21/podman-and-buildah-for-docker-users/) explains the relationship between Podman, Buildah and Docker in more detail.

{{< alert >}}
Use [pods](https://developers.redhat.com/blog/2019/01/15/podman-managing-containers-pods/) to run groups of containers. This feature of Podman replaces _docker\-compose_.
{{< /alert >}}

If you need to run existing Docker Compose configurations, install _podman-compose_:

    sudo dnf install podman-compose

The _podman compose_ subcommand uses _podman-compose_ to substitute for Docker Compose.

This enables you to convert Docker Compose configurations into Podman pod definitions at a later time. Use pods to benefit from the features of Podman, such as systemd integration and the facility to generate Kubernetes configurations from pod definitions.

## Working with Virtual Machines

Fedora Workstation installs [GNOME Boxes](https://wiki.gnome.org/Apps/Boxes) by default, to enable you to create and manage virtual machines. GNOME Boxes provides a graphical interface for the standard KVM and QEMU software. You can also use these directly on the command-line.

## SQL Databases

Consider using containers to provide the database services for your Web applications.
This will enable you to use different versions of the database servers for different
projects, and ensure that you are running the same versions as the database instances on
your production systems.

If you prefer to install services directly on to your workstation, Fedora provides
packages for PostgreSQL and [MariaDB](https://mariadb.org/). If you need a database
server that is compatible with MySQL, install MariaDB. Otherwise, PostgreSQL is often a
better choice for new applications.

### Installing PostgreSQL

To install PostgreSQL using _dnf_, enter these commands in a terminal window:

    sudo dnf install postgresql-server
    sudo postgresql-setup --initdb
    sudo systemctl enable postgresql
    sudo systemctl start postgresql

These commands install the server, the command-line tools, and the client libraries that
are needed to compile adapters for programming languages.

To create a user account for yourself in PostgreSQL with administrative rights, enter
this command in a terminal window:

    sudo su - postgres
    createuser -s YOU
    exit

Replace _YOU_ with the username of your account on Fedora.

The _-s_ option means that your new PostgreSQL account is a _superuser_, with unlimited
rights over the databases. Once you have a superuser account, you may use tools like
_createuser_ or log in to databases without using sudo or the _-U_ option.

For example, to create an extra user account that is not a superuser:

    createuser EXTRA-ACCOUNT

Replace _EXTRA-ACCOUNT_ with the username of the new account.

Refer to the [Fedora Wiki article](https://fedoraproject.org/wiki/PostgreSQL) for more
information on working with PostgreSQL.
