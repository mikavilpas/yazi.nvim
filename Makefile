.PHONY: lint init

lint:
	selene .

format:
	stylua lua/
