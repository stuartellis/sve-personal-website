+++
title = "Creating Container Images with Buildah and GitLab"
slug = "buildah-gitlab"
date = "2026-05-27T16:13:00+01:00"
description = "Creating container images with Buildah and GitLab"
categories = ["automation", "devops", "programming"]
tags = ["automation", "devops"]
+++

[Buildah](https://buildah.io/) is an Open Source command-line tool that builds OCI container images. Consider using Buildah to create your container images, instead of Docker or BuildKit. Buildah is safer than other options, because it does not use root privileges and never runs as a network service. It is also more flexible. You can provide configuration files in the `Dockerfile` format, or drive builds from the command-line.

> Buildah is part of the [CNCF Podman container tools project](https://www.cncf.io/projects/podman-container-tools/).

By design, Buildah can be run inside a container. This means that you can run Buildah on any development system as well as with any CI service, including GitHub Actions, GitLab Pipelines, Forgejo Actions and Tekton.

GitLab provides a range of services for containers, so that you can build, store and use container images without needing any other systems. By default, the [GitLab Pipelines](https://docs.gitlab.com/ci/pipelines/) CI service itself uses containers, which means that it can run Buildah from a container image, and use the images that you build as environments for other CI jobs. A Pipelines component for [container scanning](https://docs.gitlab.com/ee/user/application_security/container_scanning/) can check your container images for security issues on each build. GitLab instances can also provide a [container registry](https://docs.gitlab.com/ee/user/packages/container_registry/) for each project that they host.

## Set Up

> By default, projects on [GitLab.com](https://gitlab.com) have the container registry feature enabled. If you use a private instance of GitLab, this feature will need to be configured.

To use Buildah with GitLab, you will need a `.gitlab-ci.yml` file in the root directory of the project. This provides the configuration for GitLab Pipelines. See below for an example.

Buildah can build container images from command-line instructions, but we usually provide a configuration file in the `Dockerfile` format. By convention this file should be called `Containerfile`. See below for an example.

Once an image has been publisheded to the container registry for the project, it is visible in the Web interface for GitLab. To view a project container registry in the GitLab Web interface, go to the project and select _Deploy > Container registry_.

### Example .gitlab-ci.yml for GitLab

This `.gitlab-ci.yml` file runs Buildah to create an image from the `Containerfile`, and then publishes the image that it builds to the container registry for the GitLab project. The CI job in this example only builds an image for the `linux/amd64` platform, which is Linux on 64-bit Intel-compatible CPUs.

```yaml
---
stages:
  - build

build-image-amd64:
  stage: build
  tags:
    - saas-linux-small-amd64
  image: quay.io/buildah/stable
  variables:
    BUILDAH_FORMAT: docker
    FQ_IMAGE_NAME: "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA"
    STORAGE_DRIVER: vfs
  before_script:
    - echo "$CI_REGISTRY_PASSWORD" | buildah login -u "$CI_REGISTRY_USER" --password-stdin $CI_REGISTRY
  script:
    - buildah build --platform=linux/amd64 -t $FQ_IMAGE_NAME .
    - buildah push $FQ_IMAGE_NAME
```

### Example Containerfile

> A Containerfile uses the Dockerfile format. The name indicates that this file is intended by used by standards-compliant tools, and does not include any features that are specific to Docker.

This example file creates an Alpine Linux container that includes [OpenTofu](https://opentofu.org/) and [Terramate](https://terramate.io/docs/):

```dockerfile
FROM ghcr.io/opentofu/opentofu:1.12.0-minimal AS tofu
FROM ghcr.io/terramate-io/terramate:0.17.1 AS terramate

FROM alpine:3.23

RUN apk update && apk upgrade --no-cache && apk add --no-cache git

COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu
COPY --from=terramate /usr/local/bin/terramate /usr/local/bin/terramate
```

## More on Container Image Formats

By default, Buildah creates images in the [OCI Image Specification format](https://github.com/opencontainers/image-spec). This is an open standard that is based on the Docker Version 2 format for images. Modern container tools support both the OCI format and the Docker Version 2 format. You can only use features that are specific to Docker if you use the Docker format. For example, only container images that are in the Docker format can use the `ONBUILD` instruction.

To configure Buildah to create images in the Docker format, specify the Docker format with the `--format=docker` command-line option, or by setting the `BUILDAH_FORMAT` environment variable to `docker`.

> You can see which format an image uses by looking at the `media type` manifest property.

## Resources

### Buildah

- [A Complete Overview of Buildah](https://mkdev.me/posts/buildah-a-complete-overview)
- [Red Hat Linux documentation on using Buildah](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/building_running_and_managing_containers/working-with-containers#building-a-container)

### GitLab

- [GitLab Pipelines documentation](https://docs.gitlab.com/ci/pipelines/)
- [How to Use Container Registry in GitLab CI](https://oneuptime.com/blog/post/2026-01-28-container-registry-gitlab-ci/view) - Article by Nawaz Dhandala

### Buildah on GitLab

- [GitLab documentation on using Buildah](https://docs.gitlab.com/ci/docker/buildah_rootless_multi_arch/)
- [Using Buildah over DinD for building container images](https://arcsoft.uvic.ca/log/2025-08-07-buildah-over-dind/) - Article by Paurav Hosur Param on replacing Docker-in-Docker (DinD) for container builds
- [Build containers in GitLab CI with buildah](https://major.io/p/build-containers-in-gitlab-ci-with-buildah/) - Example by Major Hayden
