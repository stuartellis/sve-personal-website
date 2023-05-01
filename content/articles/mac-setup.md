+++
title = "How to Set up an Apple Mac for Software Development"
slug = "mac-setup"
date = "2023-05-01T16:20:00+01:00"
description = "Setting up an Apple Mac for development and systems administration"
categories = ["devops", "programming"]
tags = ["devops", "macos", "golang", "java", "javascript", "python", "ruby"]

+++

A guide to setting up an Apple Mac for DevOps and software development. This is current for macOS 12 (Monteray). 

## Do This First!

Log in once, run Software Update, and ensure that the operating system is at the latest
point release. After all of the updates have been applied, restart the computer.

## Configuring a User Account

Log in again and create an Admin user account for your use. If other people will be
using the machine, create Standard accounts for them. Log out of the initial account,
and log in to the Admin account that you have just created.

Always log in with this new Admin account. The benefit of leaving the initial account
untouched is that it ensures that you always have a working account to login with.

{{< alert >}}
_Admin accounts have sudo privileges:_ All Admin accounts on a Mac may use sudo to run command-line utilities with administrative (root) privileges.
{{< /alert >}}

### Securing the Safari Browser

Whether or not you regularly use Safari, you should open it once, and adjust the
settings in case that you use it later.

First, choose _Safari \> Preferences \> General_ and deselect the option _Open “safe” files after downloading_.

Second, go to _Safari \> Preferences \> Search_. Decide which search engine that you want to use. Ensure that _Safari Suggestions_  and _Preload Top Hit in the background_ are not enabled.

## Configuring Security

Apple provide quite secure operating systems, but unfortunately convenience has won out
over security in a few places. These can easily be corrected by changing a few settings.
If you are using a laptop then you should probably make all of these changes as soon as
possible.

### Security & Privacy

Select _System Preferences \> Security & Privacy_, and set the following:

- Under _General_, set _require a password after sleep or screen saver begins_ to
  _immediately_
- Under _General_, click _Advanced..._ and select _Require an administrator password to access system-wide preferences_
- Under _Firewall_, click _Turn Firewall On_.
- Under _Privacy_, select _Analytics & Improvements_ and ensure that the options are not enabled.

### Spotlight

By default, Spotlight sends queries to Apple. Unless you want this feature, turn it off.

Select _System Preferences \> Spotlight \> Search Results_, and ensure that _Siri Suggestions_ is not enabled.

### Enable File Vault NOW

File Vault 2, a full-disk encryption system. You should enable File Vault
_NOW_, because it is the only protection against anyone with physical access to your
computer. All other security measures will be completely bypassed if someone with
physical access simply restarts the computer with a bootable pen drive.

{{< alert >}}
File Vault really is secure, which means that you can permanently lose access to your data if you lose the passwords and the recovery key.
{{< /alert >}}

### Set a Firmware Password

Set a password to stop access to the
[Recovery](https://support.apple.com/en-us/HT201314) mode. Otherwise, any malicious
individual can change the firmware settings to boot from a disc or device of their
choosing. If you did not enable File Vault, then the attacker will have complete access
to all of the files on the system.

[Apple Knowledge Base article HT204455](https://support.apple.com/en-gb/HT204455)
provides full details.

### Setting Up Time Machine Backups

Time Machine is simple to set up. Just take a suitably large external hard drive, plug it
in to your Mac, and agree when prompted. The drive setup process will reformat the hard
drive. The only settings that may need to change are the exclusions.

Choose _System Preferences \> Time Machine_, and click _Options_. Add to the exclusions
list any folders that contain ISO disk images, virtual machines, or database files (such
as Entourage). If the external hard drive is short of space, exclude the _System_
folder.

## Setting Up for Development

The first step is to install the _Command Line Tools for Xcode_. Once you have installed Command Line Tools, you can use
[Homebrew](http://brew.sh/) to install everything else that you need.

### Getting Xcode

Apple now provide the Xcode suite as a free download from the App Store. To install the Command Line Tools, install Xcode from the App Store, then open a Terminal window and enter the following command:

    xcode-select --install

If you want to install just the Command Line Tools, you can download a package from [the Apple Developer Downloads site](https://developer.apple.com/download/all/).

### Setting Up Homebrew

[Homebrew](http://brew.sh/) provides a package management system for macOS, enabling you
to quickly install and update the tools and libraries that you need. Follow the
instructions on the site.

You should also amend your PATH, so that the versions of tools that are installed with
Homebrew take precedence over others. To do this, edit the file _.zshrc_ in
your home directory to include this line:

    export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"

You need to close all terminal windows for this change to take effect.

To check that Homebrew is installed correctly, run this command in a terminal window:

    brew doctor

To update the index of available packages, run this command in a terminal window:

    brew update

### Enabling Auto Completion of Commands

Many command-line tools provide automatic completion of commands. These include Git, curl and the AWS command-line tool. Homebrew installs the files for each command-line tool that provides completion, but it does not enable automatic completion in your shell.

To enable auto completion, edit the file _.zshrc_ in your home directory to include this line:

```bash
autoload bashcompinit && bashcompinit
```

Close all of the Terminal windows. Every new Terminal window will support autocompletion.

To use auto completion, type the name of the command, and press the Tab key on your keyboard. You will see a list of possible completions. Press the Tab key to cycle through the completions, and press the Enter key to accept a completion.

### Installing the Git Version Control System

The Xcode Command Line Tools include a copy of [Git](http://www.git-scm.com/), but this will be out of date.

To install a newer version of Git than Apple provide, use Homebrew. Enter this command in a terminal window:

    brew install git

If you do not use Homebrew, go to the [Web site](http://www.git-scm.com/) and follow the
link for _Other Download Options_ to obtain a macOS disk image. Open your downloaded
copy of the disk image and run the enclosed installer in the usual way, then dismount
the disk image.

Always set your details before you create or clone repositories on a new system. This
requires two commands in a terminal window:

    git config --global user.name "Your Name"
    git config --global user.email "you@your-domain.com"

The _global_ option means that the setting will apply to every repository that you work
with in the current user account.

To enable colors in the output, which can be very helpful, enter this command:

    git config --global color.ui auto

### Text Editors

Installations of macOS include a command-line version of [vim](http://www.vim.org/) and TextEdit, a desktop text editor. TextEdit is designed for light-weight word processing, and it has no support for programming. Add the code editors or IDEs that you would prefer to use.

If you do not have a preferred editor, consider using a version of [Visual Studio Code](https://code.visualstudio.com). Read the next section for more details.

To use a modern code editor that works like Vim, install [Neovim](https://neovim.io). The default configuration for Neovim follows best practices for Vim, but you can customise it as you wish.

#### Visual Studio Code

[Visual Studio Code](https://code.visualstudio.com) is a powerful desktop editor for programming, with built-in support for version control and debugging. The large range of extensions for Visual Studio Code enable it to work with every popular programming language and framework. It is available free of charge.

The Microsoft releases of Visual Studio Code are proprietary software with telemetry enabled by default, and download extensions from a proprietary Microsoft app store. if you have issues or concerns about the Microsoft releases, use the packages that are provided by the [vscodium](https://vscodium.com) project.

#### Setting The EDITOR Environment Variable

Whichever text editor you choose, remember to set the EDITOR environment variable in
your _~/.zshrc_ file, so that this editor is automatically invoked by command-line
tools like your version control system. For example, put this line in your profile to
make Neovim (_nvim_) the favored text editor:

    export EDITOR="nvim"

### Setting Up A Directory Structure for Projects

To keep your projects tidy, I would recommend following these guidelines. They may seem
slightly fussy, but they pay off when you have many projects, some of which are on
different version control hosts.

First create a top-level directory with a short, generic name like _repos_. For each repository host, create a subdirectory in _repos_. Add a subdirectory that matches your username. The final directory structure looks like this:

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

You will frequently use SSH to access Git repositories or remote UNIX systems. macOS
includes the standard OpenSSH suite of tools.

OpenSSH stores your SSH keys in a _.ssh_ directory. To create this directory, run these commands in a terminal window:

    mkdir $HOME/.ssh
    chmod 0700 $HOME/.ssh

To create an SSH key, run the _ssh-keygen_ command in a terminal window. For example:

    ssh-keygen -t rsa -b 4096 -C "Me MyName (MyDevice) <me@mydomain.com>"

## Programming Languages

### JavaScript Development: Node.js

Homebrew provides separate packages for each version of [Node.js](https://nodejs.org).
To ensure that you are using the version of Node.js that you expect, specify the version
when you install it. For example, enter this command in a Terminal window to install the
Node.js 18, the current LTS release:

    brew install node@18

Add the _bin/_ directory for this Node.js installation to your PATH:

    /usr/local/opt/node@18/bin

### Go Development

Use Homebrew to install [Go](https://go.dev/):

    brew install golang

This provides the standard command-line tools for Go.

The current version of Go includes support for dependency management with [modules](https://blog.golang.org/using-go-modules). Use modules for new projects. Some existing projects still use [dep](https://golang.github.io/dep/), or an older tool.

#### Setting a GOPATH

Current versions of Go do not require a GOPATH environment variable, but you should set it to ensure that third-party tools and Terminal auto-completion work correctly.

Set a GOPATH environment variable in your _~/.zshrc_ file:

    export GOPATH="$HOME/go"

Then, add this to your PATH:

    $GOPATH/bin

Close the Terminal and open it again for the changes to take effect.

### Java Development: Adoptium

#### Which Version of Java?

Many vendors provide a JDK. To avoid licensing and support issues, use Eclipse Temurin. This is an Open Source JDK that is maintained by the [Adoptium](https://adoptium.net/) project. The versions of Java on the OpenJDK Website are for testers, and the Oracle JDK is a proprietary product.

Use the _LTS_ version of Temurin, unless you need features that are in the latest releases.

Once you have installed a JDK, get the [Apache Maven](https://maven.apache.org) build tool. This is provided by the Maven project itself, and is not part of Temurin or the OpenJDK.

Use [jEnv](https://www.jenv.be/) if you need to run multiple JDKs, such as different versions of the same JDK.

#### Manual Set up of Eclipse Temurin

To manually install a copy of the JDK:

1. Download the version of the JDK that you need from Adoptium
2. Unzip the download
3. Copy the JDK directory to _/usr/local/lib_
4. Edit your _~/.zshrc_ file to set environment variables. For example, to use jdk-11.0.3+7 as the Java version:

```bash
JAVA_HOME=/usr/local/lib/jdk-11.0.3+7/Contents/Home
PATH=$PATH:/usr/local/lib/jdk-11.0.3+7/Contents/Home/bin
```

To manually install a copy of [Apache Maven](https://maven.apache.org):

1. Download the latest version of Maven
2. Unzip the download
3. Copy the Maven directory to _/usr/local/lib/_
4. Add _/usr/local/lib/MAVEN-DIRECTORY_ to your PATH environment variable

Replace _MAVEN-DIRECTORY_ with the name of the directory that Maven uses, such as _apache-maven-3.6.0_.

Maven is written in Java, which means that the project provides one package, which works on any operating system that has a supported version of Java.

#### Setting up jEnv

Run this command in a terminal window to install [jEnv](https://www.jenv.be/):

    brew install jenv

Next, add this to your PATH:

    $HOME/.jenv/bin

Add this to your _~/.zshrc_ file:

    eval "$(jenv init -)"

Open a new terminal window, and run this command:

    jenv enable-plugin export

This enables jEnv to manage the JAVA_HOME environment variable.

To avoid inconsistent behaviour, close all the terminal windows that you currently have open. The jEnv utility will work correctly in new terminal windows.

Lastly, run this command to register your current JDK with jEnv:

    jenv add $(/usr/libexec/java_home)

To see a list of the available commands, type _jenv_ in a terminal window:

    jenv

### Python Development: pyenv and pipx

Current versions of macOS include a copy of Python 3, but this will not be the latest version of Python. Use Homebrew to install [pyenv](https://github.com/pyenv/pyenv). This tool enables you to use multiple versions of Python.

To install pyenv with Homebrew, run this command in a terminal window:

    brew install pyenv
    
Use [pipx](https://pypa.github.io/pipx/) to install Python applications, rather than _pip_ or Homebrew. To set up _pipx_, run these commands in a terminal window:

    brew install pipx
    pipx ensurepath

### Rust Development: rustup

The official _rustup_ utility enables you to install the tools for building software
with the Rust programming language. Click on the Install button on the front page of the
[Rust Website](https://www.rust-lang.org), and follow the instructions.

By default, the installer adds the correct directory to your path. If this does not
work, add this to your PATH manually:

    $HOME/.cargo/bin

This process installs all of the tools into your home directory, and does not add any
files into system directories.

### Ruby Development: RVM

All macOS systems include a copy of Ruby, but it is outdated. To maintain current and
clean Ruby environments, use the [RVM](https://rvm.io/) system.

RVM relies on Git, so you must have a working installation of Git before you can set up RVM.

By default, RVM downloads copies of Ruby that have been compiled for your operating
system. If there is no compiled version, RVM then falls back to downloading the source
code and then compiling it on your computer. Enter this command to ensure that the
requirements for compiling Ruby are on your system, using Homebrew:

    brew install autoconf automake gdbm gmp libksba libtool libyaml openssl pkg-config readline

Finally, you can speed up installation of gem packages by disabling the generation of
local documentation. To do this, create a file in your home directory with the name
_.gemrc_ and put this line in it:

    gem: --no-ri --no-rdoc

## Kubernetes: Minikube

[Minikube](https://kubernetes.io/docs/setup/minikube/) sets up and manages Kubernetes on a single system, so that you can develop and test without needing a set of servers.

To install Minikube with Homebrew, run these commands in a terminal window:

    brew install kubernetes-cli
    brew install minikube

By default, Minikube uses a virtual machine manager. If you choose to install VirtualBox, MiniKube will use it. If you do not need VirtualBox, install [hyperkit](https://github.com/moby/hyperkit), which provides a minimal virtual machine manager.

    brew install hyperkit

To install [Helm](https://helm.sh/) with Homebrew, run this command in a terminal window:

    brew install kubernetes-helm

To install [Skaffold](https://skaffold.dev/) with Homebrew, run this command in a terminal window:

    brew install skaffold

## Databases

Consider using containers to run the databases that you need. If you prefer to install services
directly on to your workstation, Homebrew provides packages for PostgreSQL, MariaDB, MySQL and the [Community Edition of MongoDB](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/).

### Installing PostgreSQL

To install PostgreSQL using Homebrew, enter this command in a terminal window:

    brew install postgresql

This command installs the server, the command-line tools, and the client libraries that
are needed to compile adapters for programming languages.

Homebrew also provides some commands for managing your PostgreSQL installation. For
example, to start the server, follow the instructions that are displayed after the
installation process is completed. If you upgrade your copy of PostgreSQL, you should
use the _postgresql-upgrade-database_ command that Homebrew gives you.

### Installing MariaDB or MySQL

To install MariaDB using Homebrew, enter this command in a terminal window:

    brew install mariadb

To install MySQL using Homebrew, enter this command in a terminal window:

    brew install mysql

These commands install the server, the command-line tools, and the client libraries that
are needed to compile adapters for programming languages. To start the server, follow
the instructions that are displayed after the installation process is completed.

{{< alert >}}
For compatibility, MariaDB uses the same names for command-line tools as MySQL.
{{< /alert >}}

Remember to set a password for the root accounts. First, login with the _mysql_
command-line utility:

    mysql -u root -q

{{< alert >}}
_The -q Option Disables Command History:_ By default, the command-line client stores the full text of every command in a history file. If you know that you are going to run statements that include passwords or other sensitive data, use the -q option.
{{< /alert >}}

Run these statements to change the password for root access:

```sql
UPDATE mysql.user SET password = PASSWORD('yourpassword') WHERE user
LIKE ‘root’;
FLUSH PRIVILEGES;
EXIT;
```

You now need a password to login to the installation as root. To login with root again,
use this command:

    mysql -u root -p

Enter the password when prompted.

You should also remove the anonymous accounts and test database that MySQL automatically
includes:

```sql
DROP DATABASE test;
DELETE FROM mysql.user WHERE user = ’’;
FLUSH PRIVILEGES;
```

If you intend to duplicate a production environment for testing, create a configuration
file on your Mac. Production installations of MySQL should be configured with
appropriate _SQL modes_ to enable data integrity safeguards. By default, MySQL permits
various types of invalid data to be entered.

### Database Management Tools

To work with SQL databases, use [Beekeeper Studio](https://www.beekeeperstudio.io). This graphical tool supports the popular Open Source databases, as well as Microsoft SQL Server and Amazon Redshift. This enables you to use the same tool for all of your databases.

Install Beekeeper with Homebrew:

    brew install --cask beekeeper-studio

Each vendor recommends a specific graphical tool for their particular database product. These are the tools that the vendors suggest:

- [Azure Data Studio](https://docs.microsoft.com/en-gb/sql/azure-data-studio/what-is?view=sql-server-2017) - Microsoft tool for SQL Server and Azure databases
- [Compass](https://www.mongodb.com/products/compass) - The official tool for MongoDB
- [MySQL Workbench](http://wb.mysql.com/) - The official tool for MySQL
- [Oracle SQL Developer](https://www.oracle.com/database/technologies/appdev/sql-developer.html) - The official tool for Oracle
- [pgAdmin](https://www.pgadmin.org/) - The recommended tool for PostgreSQL

## Other Useful Desktop Applications for Developers

- [Joplin](https://joplinapp.org/) note-taking: _brew install \--cask joplin_
- [LibreOffice](http://www.libreoffice.org/) suite: _brew install \--cask libreoffice_
- [VirtualBox](http://www.virtualbox.org/) virtual machine management: _brew install \--cask virtualbox_

{{< alert >}}
If you install VirtualBox, use [Vagrant](https://www.vagrantup.com/) to manage virtual machines for development.
{{< /alert >}}

## Online Resources

The [macOS Privacy and Security Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide) by Dr Duh provides extensive information about those topics.
