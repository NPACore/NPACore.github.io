.PHONY: all deploy
all: deploy
VENV := . .venv/bin/activate &&

# org mode to markdown
ALLORG := $(shell find docs/ -iname '*.org')
MD_ORG := $(patsubst %.org,%.md,$(ALLORG))
%.md: %.org
	pandoc -s -t gfm -i $< -o $@
	grep "$@" .gitignore || echo "$@" >> .gitignore

.venv/: requirements.txt
	! test -r .venv && python -m venv .venv || touch .venv
	$(VENV) python3 -m pip install -r requirements.txt

deploy: $(MD_ORG) | .venv/
	$(VENV) mkdocs gh-deploy
serve: .venv/
	$(VENV) mkdocs serve
