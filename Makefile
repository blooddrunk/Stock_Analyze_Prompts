.PHONY: docs-build docs-serve docs-deploy

MKDOCS ?= $(if $(wildcard ./.venv-docs/bin/mkdocs),./.venv-docs/bin/mkdocs,mkdocs)
NO_MKDOCS_2_WARNING ?= 1

docs-build:
	NO_MKDOCS_2_WARNING=$(NO_MKDOCS_2_WARNING) $(MKDOCS) build

docs-serve:
	NO_MKDOCS_2_WARNING=$(NO_MKDOCS_2_WARNING) $(MKDOCS) serve

docs-deploy:
	NO_MKDOCS_2_WARNING=$(NO_MKDOCS_2_WARNING) $(MKDOCS) gh-deploy --force
