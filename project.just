# SPDX-FileCopyrightText: 2024-present Stuart Ellis <stuart@stuartellis.name>
#
# SPDX-License-Identifier: MIT
#
# Recipes for project maintenance

# Display information about the project
about:
    #!/usr/bin/env python3
    import tomllib
    with open("pyproject.toml", mode="rb") as fp:
        config = tomllib.load(fp)
        for item in ["name", "version", "description",]:
            data = config["project"][item]
            print(f"{item.title()}: {data}")

# Delete generated files
clean:
    #!/usr/bin/env sh
    set -eu
    PROJECT_TEMP_DIRS="tmp"
    echo "Removing temporary directories..."
    for PROJECT_TEMP_DIR in $PROJECT_TEMP_DIRS
    do
      rm -fr $PROJECT_TEMP_DIR
      echo "Removed $PROJECT_TEMP_DIR"
    done
