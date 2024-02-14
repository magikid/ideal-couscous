images := digitalocean foo

.PHONY: all
all: $(images)

% : %.nix
	@echo "Generating $@..."
	nix-build --out-link "${PWD}/$@" $^
