current_env := env_var_or_default('ENVIRONMENT', 'unspecified')
current_aws_profile := env_var_or_default('AWS_PROFILE', 'unspecified')
is_containerized := env_var_or_default('REMOTE_CONTAINERS', 'false')

alias info := session-info

# List available recipes
help:
    @just --list

# Deploy Web site
deploy:
    @hugo
    @hugo deploy

# Show information about current working session
session-info:
    @echo "CPU architecture: {{ arch() }}"
    @echo "Operating system type: {{ os_family() }}"
    @echo "Operating system: {{ os() }}"
    @echo "Containerized session: {{ is_containerized }}"
    @echo "Environment: {{ current_env }}"
    @echo "AWS profile: {{ current_aws_profile }}"
