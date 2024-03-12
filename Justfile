#!/usr/bin/env just

set shell := ["zsh", "-cu"]

set dotenv-load := true

deploy host='external-load-balancer' verbose="":
    nixos-rebuild switch --fast --flake ".#{{host}}.exocomet-cloud.ts.net" --target-host "{{host}}.exocomet-cloud.ts.net" --build-host "{{host}}.exocomet-cloud.ts.net" --option eval-cache false --use-remote-sudo {{verbose}}

deploy-upgrade host='external-load-balancer':
    nixos-rebuild switch --upgrade --fast --flake ".#{{host}}.exocomet-cloud.ts.net" --target-host "{{host}}.exocomet-cloud.ts.net" --build-host "{{host}}.exocomet-cloud.ts.net" --option eval-cache false --use-remote-sudo

build-images:
    cd images && make
