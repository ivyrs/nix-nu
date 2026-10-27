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

iso:
    nix build .#nixosConfigurations.installer.config.system.build.isoImage
    @echo "ISO at: $(readlink -f result)/iso/"

# flash the built installer ISO to a device, e.g. `just flash /dev/sdX`
flash device:
    #!/usr/bin/env bash
    set -euo pipefail
    iso=$(find ./result/iso -name '*.iso')
    echo "About to overwrite {{ device }} with ${iso}"
    read -p "Type the device path again to confirm: " confirm
    [[ "$confirm" == "{{ device }}" ]] || { echo "mismatch, aborting"; exit 1; }
    nix run nixpkgs#caligula -- burn "${iso}" -o "{{ device }}" --interactive never -f --root always
