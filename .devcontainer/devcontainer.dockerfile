# SPDX-FileCopyrightText: 2024-present Stuart Ellis <stuart@stuartellis.name>
#
# SPDX-License-Identifier: MIT
#
# Container build file for Dev Container
#

ARG VARIANT="bookworm"
FROM mcr.microsoft.com/devcontainers/go:1-1.23-${VARIANT}

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -qy --no-install-recommends apt-transport-https gnupg lsb-release \
    && curl -L https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor > /usr/share/keyrings/trivy.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" > /etc/apt/sources.list.d/trivy.list \
    && apt-get update \
    && apt-get upgrade -qy \
    && apt-get install -qy trivy
