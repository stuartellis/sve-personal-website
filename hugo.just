# SPDX-FileCopyrightText: 2024-present Stuart Ellis <stuart@stuartellis.name>
#
# SPDX-License-Identifier: MIT
#
# Recipes for Hugo
#
# https://gohugo.io/

# Build Website
build:
    @hugo

# Remove generated files
clean:
    #!/usr/bin/env sh
    set -eu
    HUGO_TEMP_PATHS=".hugo_build.lock public"
    echo "Removing temporary files for Hugo..."
    for HUGO_TEMP_PATH in $HUGO_TEMP_PATHS
    do
      rm -fr $HUGO_TEMP_PATH
      echo "Removed $HUGO_TEMP_PATH"
    done

# Deploy Website
deploy: build
    @hugo deploy

# Run Website in development server
serve:
    @hugo server
