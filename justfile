default:
    @just --list

fmt:
    nix fmt

check:
    nix flake check

build host=`hostname -s`:
    @just _nh build "{{ host }}"

switch host=`hostname -s`:
    @just _nh switch "{{ host }}"

[private]
_nh action host:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{ os() }}" == "macos" ]]; then
        exec nh darwin "{{ action }}" . -H "{{ host }}"
    elif [[ "{{ host }}" == "alder" ]]; then
        exec nh os "{{ action }}" . -H "{{ host }}" -- --impure
    else
        exec nh os "{{ action }}" . -H "{{ host }}"
    fi

update:
    nix flake update

sync-noctalia:
    noctalia config export > ./home/desktop/noctalia/noctalia.toml
