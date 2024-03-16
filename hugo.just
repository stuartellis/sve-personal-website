# SPDX-FileCopyrightText: 2024-present Stuart Ellis <stuart@stuartellis.name>
#
# SPDX-License-Identifier: MIT
#
# Recipes for pre-commit
#
# https://pre-commit.com/

# Build Website
build:
    @hugo

# Remove generated files
clean:
    @hugo clean

# Deploy site
deploy: build
    @hugo deploy

# Run Website in development server
serve:
    @hugo serve
