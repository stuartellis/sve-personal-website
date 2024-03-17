# SPDX-FileCopyrightText: 2024-present Stuart Ellis <stuart@stuartellis.name>
#
# SPDX-License-Identifier: MIT
#
# Recipes for pre-commit
#
# https://pre-commit.com/

# Check the project with pre-commit
check:
    @pre-commit run --all-files

# Run a specific pre-commit check on the project
run hook-id:
    @pre-commit run "{{ hook-id }}" --all-files

# Setup pre-commit for use
setup:
    @pre-commit install
