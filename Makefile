.PHONY: test lint init

PROJECT_ROOT := $(shell git rev-parse --show-toplevel)
NVIM := nvim -u "${PROJECT_ROOT}/scripts/init.lua"

# Define color variables
COLOR_RESET := \033[0m
COLOR_GREEN := \033[1;32m
COLOR_BLUE_ := \033[1;34m
COLOR_YELLO := \033[1;33m
COLOR_WHITE := \033[1;37m

# install development and testing dependencies
init:
	luarocks init --no-gitignore
	luarocks install busted 2.2.0-1

	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo "$(COLOR_GREEN)Welcome to yazi.nvim development! 🚀$(COLOR_RESET)"
	@echo "$(COLOR_BLUE_)Next, run one of these commands to get started:$(COLOR_RESET)"
	@echo "$(COLOR_YELLO)  make test$(COLOR_RESET)"
	@echo "$(COLOR_WHITE)    Run all tests$(COLOR_RESET)"

	@echo "$(COLOR_YELLO)  make test-focus$(COLOR_RESET)"
	@echo "$(COLOR_WHITE)    Run only the tests marked with #focus in the test name$(COLOR_RESET)"

	@echo "$(COLOR_YELLO)  make lint$(COLOR_RESET)"
	@echo "$(COLOR_WHITE)    Check the code for lint errors$(COLOR_RESET)"

	@echo "$(COLOR_YELLO)  make format$(COLOR_RESET)"
	@echo "$(COLOR_WHITE)    Reformat all code$(COLOR_RESET)"

lint:
	selene ./lua/ ./spec/ ./integration-tests/test-environment/config-modifications
	@if grep -r -e "#focus" --include \*.lua ./spec/; then \
			echo "\n"; \
			echo "Error: ${COLOR_GREEN}#focus${COLOR_RESET} tags found in the codebase.\n"; \
			echo "Please remove them to prevent issues with not accidentally running all tests."; \
			exit 1; \
	fi


test:
	luarocks test --local

test-focus:
	luarocks test --local -- --filter=focus

format:
	stylua lua/ spec/ integration-tests/ ./repro.lua
