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

format:
	stylua lua/
