default:
    @just --list

fmt:
    nix fmt

check:
    nix flake check

build:
    nh os build .

switch:
    nh os switch .

update:
    nix flake update

sync-noctalia:
    noctalia config export > ./home/desktop/noctalia/noctalia.toml
