+++
title = "Using Python Semantic Release with GitLab"
slug = "python-semantic-release-gitlab"
date = "2026-05-27T22:24:00+01:00"
description = "Python Semantic Release with GitLab"
categories = ["gitlab","programming", "python"]
tags = ["automation", "gitlab", "python"]
+++

[Python Semantic Release](https://python-semantic-release.readthedocs.io/en/stable/) enables you to automate the release of software projects. This can include projects do not use Python. By default, Python Semantic Release assumes that you are hosting your project on GitHub. This article explains how to set up Python Semantic Release to work with GitLab projects.

## Set Up

You will need these files in the GitLab project:

- _CI Pipeline configuration:_ A `.gitlab-ci.yml` file in the root directory of the project. See below for an example.
- _Python Semantic Release configuration:_ A `pyproject.toml` or `releaserc.toml` file in the root directory of the project. See below for an example.
- _Changelog:_ A `CHANGELOG.md` file in the root directory of the project. Create this as an empty file, because Python Semantic Release maintains the contents of this file.

> Use a `releaserc.toml` file for projects that do not have a `pyproject.toml` file.

The GitLab project must have _Allow Git push requests to the repository_ enabled in _Settings > CI/CD > Job token permissions_.

If you are using a free GitLab account, then you will also need to set up a Personal Access Token that Python Semantic Release can use. See the next section for details.

## Using Personal Access Tokens

Python Semantic Release must use a GitLab token to carry out operations on the project repositories. If you are using a free GitLab account, then you will need to set up a Personal Access Token that Python Semantic Release can use.

Use a legacy personal access token. This must be attached to user account with the _Maintainer_ role for the project, and the API token itself must have these permissions:

- api
- read_repository
- write_repository

> If you cannot automate the rotation of this token you must give it an expiration date that is long enough for you to manage manual rotations.

Register this access token as a CI variable. Set the CI variable as _Protected_, _Masked_ and _Expanded_. By default, Python Semantic Release reads the environment variable _GITLAB_TOKEN_ to get an access token.

## Example .gitlab-ci.yml for GitLab

This `.gitlab-ci.yml` file runs Python Semantic Release, using the configuration from the `releaserc.toml` file:

```yaml
---
stages:
  - release

variables:
  PIP_CACHE_DIR: $CI_PROJECT_DIR/.cache/pip
  PIP_ROOT_USER_ACTION: ignore

semantic-release:
  stage: release
  image: python:3.14-slim-trixie
  variables:
    # Git must create a full clone
    GIT_STRATEGY: clone
    GIT_DEPTH: 0
    # Set variable for python-semantic-release to use
    GIT_COMMIT_AUTHOR: "$GITLAB_USER_NAME <$GITLAB_USER_EMAIL>"
  before_script:
    - apt-get -qy update
    - apt-get install -qy git
    - pip install python-semantic-release==10.5.3
    - git checkout -B "$CI_COMMIT_REF_NAME"

  script:
    - semantic-release -c releaserc.toml version --print
    - semantic-release -c releaserc.toml version
    - semantic-release -c releaserc.toml changelog
    - semantic-release -c releaserc.toml publish

  cache:
    paths:
      - ${PIP_CACHE_DIR}

  rules:
    - if: '$CI_COMMIT_BRANCH == "main" && $CI_PIPELINE_SOURCE == "push"'
      when: on_success
```

> Remove the `-c releaserc.toml` option from calls to `semantic-release` if you use `pyproject.toml` to hold the project settings for Python Semantic Release.

## Example releaserc.toml for GitLab

This `releaserc.toml` file provides a minimum configuration for Python Semantic Release with GitLab:

```toml
[semantic_release]
# Allow 0.x.x versions
allow_zero_version = true
major_on_zero = false
# Do not trigger Git hooks
no_git_verify = true

[semantic_release.commit_author]
env = "GIT_COMMIT_AUTHOR"
default = "semantic-release <semantic-release>"

[semantic_release.publish]
# Use an empty list to avoid errors with GitLab
dist_glob_patterns = []

[semantic_release.remote]
type = "gitlab"
# Must be set as false for releases to be published to GitLab Releases
upload_to_vcs_release = false
```

> By default, Python Semantic Release uses the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format. This means that commits that are marked as a _chore_ do not produce a new version number.

## Resources

- [Python Semantic Release documentation](https://python-semantic-release.readthedocs.io/en/stable/)
- [Example Python Semantic Release configuration for GitLab](https://gitlab.com/kolumdium/python-semantic-release-gitlab-example) by Martin Plank
