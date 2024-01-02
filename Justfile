#!/usr/bin/env just

set shell := ["zsh", "-cu"]

set dotenv-load := true

build-template:
    pushd proxmox_template && \
    nix run github:nix-community/nixos-generators -- --format proxmox-lxc -c ./configuration.nix && \
    popd

deploy host='load-balancer-2':
    pushd {{host}} && \
    nixos-rebuild switch --fast --flake .#default --target-host {{host}} --build-host {{host}} --option eval-cache false && \
    popd
