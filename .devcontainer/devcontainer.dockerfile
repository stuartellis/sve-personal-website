# SPDX-FileCopyrightText: 2024-present Stuart Ellis <stuart@stuartellis.name>
#
# SPDX-License-Identifier: MIT
#
# Container build file for Dev Container
#

ARG VARIANT="bookworm"
FROM mcr.microsoft.com/devcontainers/go:1-1.21-${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get upgrade -qy
