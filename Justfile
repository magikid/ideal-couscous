#!/usr/bin/env just

set shell := ["zsh", "-cu"]

set dotenv-load := true

deploy host='load-balancer-2' verbose="":
    nixos-rebuild switch --fast --flake .#{{host}} --target-host {{host}} --build-host {{host}} --option eval-cache false --use-remote-sudo {{verbose}}

deploy-upgrade host='load-balancer-2':
    nixos-rebuild switch --upgrade --fast --flake .#{{host}} --target-host {{host}} --build-host {{host}} --option eval-cache false --use-remote-sudo

build-images:
    cd images && make
