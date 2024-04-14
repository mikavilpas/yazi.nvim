.PHONY: test lint init

PROJECT_ROOT := $(shell git rev-parse --show-toplevel)
NVIM := nvim -u "${PROJECT_ROOT}/scripts/init.lua"

# install development and testing dependencies
init:
	${NVIM} -c "lua require('lazy').update()"

lint:
	selene ./lua/ ./tests/

# run tests, headless
test:
	${NVIM} --headless -c "PlenaryBustedDirectory tests { init = 'scripts/init.lua' }"

test-in-ci:
	(for i in $$(seq 1 3); do \
			${NVIM} --headless -c "PlenaryBustedDirectory tests { init = 'scripts/init.lua' }" && break || \
			if [ $$i -eq 3 ]; then \
					echo "Tests failed after 3 attempts."; \
					exit 1; \
			fi; \
			echo "Retrying tests... attempt $$i"; \
	done)

format:
	stylua lua/
