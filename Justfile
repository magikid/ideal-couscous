#!/usr/bin/env just

set shell := ["zsh", "-cu"]

set dotenv-load := true

deploy host='load-balancer-2':
    nixos-rebuild switch --fast --flake .#{{host}} --target-host {{host}} --build-host {{host}} --option eval-cache false --use-remote-sudo
