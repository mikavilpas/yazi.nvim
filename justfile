set unstable := true

# allow `just --fmt`

COLOR_RESET := '\033[0m'
COLOR_GREEN := '\033[1;32m'
COLOR_BLUE_ := '\033[1;34m'
COLOR_YELLO := '\033[1;33m'
COLOR_WHITE := '\033[1;37m'

default: help

@help:
    just --list

# Build the project
@build:
    echo "Building project..."
    luarocks init --no-gitignore
    luarocks install busted 2.2.0-1

    just help

# Check the code for lint errors
lint:
    selene ./lua/ ./spec/ ./integration-tests/test-environment/config-modifications

    @if grep -r -e "#focus" --include \*.lua ./spec/; then \
      echo "\n"; \
      echo "Error: {{ COLOR_GREEN }}#focus{{ COLOR_RESET }} tags found in the codebase.\n"; \
      echo "Please remove them to prevent issues with not accidentally running all tests."; \
      exit 1; \
    fi

# Run all tests
test:
    luarocks test --local

# Run only the tests marked with #focus somewhere in the test name
test-focus:
    luarocks test --local -- --filter=focus

# Reformat all code
format:
    stylua lua/ spec/ integration-tests/ ./repro.lua

# Check the code for errors (lint + test + format)
check: lint test format
