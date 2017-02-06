.PHONY: run
run: clear compile
	iex -S mix

.PHONY: all
all: compile

.PHONY: compile
compile: deps
	mix compile

.PHONY: deps
deps:
	mix deps.get

.PHONY: clear
clear:
	rm -rf log

