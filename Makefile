.PHONY: preflight install

preflight:
	./scripts/preflight.sh

install: preflight
	./scripts/setup-openspec-skills-global.sh
