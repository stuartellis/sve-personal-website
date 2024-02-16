# List available recipes
default:
    @just --list

# Show system information
info:
    @echo "CPU Architecture: {{ arch() }}"
    @echo "OS Type: {{ os_family() }}"
    @echo "OS: {{ os() }}"

# Deploy Web site
deploy:
    @hugo
    @hugo deploy
