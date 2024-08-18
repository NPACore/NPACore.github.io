.PHONY: all deploy
all: deploy

# org mode to markdown
ALLORG := $(shell find docs/ -iname '*.org')
MD_ORG := $(patsubst %.org,%.md,$(ALLORG))
%.md: %.org
	pandoc -s -t gfm -i $< -o $@
	grep "$@" .gitignore || echo "$@" >> .gitignore

deploy: $(MD_ORG)
	mkdocs gh-deploy
