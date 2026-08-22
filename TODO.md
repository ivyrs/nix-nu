# nix-nu todo

## Alder

- [x] Base system
- [x] Apple Silicon / Asahi support
- [x] Networking
- [x] SSH
- [x] SOPS
- [x] Per-host secrets
- [x] Tailscale
- [x] Lix / Nix
- [x] Cachix
- [x] nh
- [x] Ly
- [x] Niri
- [x] XDG portals
- [x] PipeWire / WirePlumber
- [x] Noctalia
- [x] Noctalia recommended services
- [x] Fonts / theming
- [x] Home Manager

### Home

- [x] Zsh
- [x] Starship
- [x] CLI tools
- [x] Ghostty
- [x] Git
- [x] Delta
- [x] LazyGit
- [x] Git SSH signing
- [x] rbw / Bitwarden
- [x] GPG
- [x] Firefox
- [x] Neovim / NVF
- [x] Emacs
- [x] tmux
- [x] aerc
- [x] khal
- [x] khard
- [x] vdirsyncer
- [x] Syncthing
- [x] Yazi
- [x] Bat
- [x] Zathura
- [x] Music
- [x] Vesktop
- [x] AI tooling

### Deliberately dropped / deferred

- [x] Drop Nushell
- [x] Drop KeePassXC
- [x] Don't restore old GPG cache TTLs
- [x] Drop Nokkvi for now
- [ ] iCloud PIM — wait until Apple ID migration

## Neovim / NVF

- [x] Restore NVF
- [x] Split core editor from language configuration
- [x] Export reusable core module
- [x] Export full module
- [ ] Finalise language bundles
- [ ] Make heavyweight language/LSP tooling explicitly opt-in
- [ ] Ensure reusable modules don't unnecessarily install runtimes
- [ ] Add Java only where explicitly wanted

## Repo tooling

- [x] Add `nix fmt`
- [x] Use treefmt-nix
- [x] Use nixfmt
- [x] Check formatting with `nix flake check`
- [x] Add development shell
- [x] Restore Justfile
- [x] Restore this TODO

## Reusable Home Manager

- [x] Export reusable Home Manager modules
- [x] Export shell
- [x] Export Git
- [x] Export tmux
- [x] Export Noctalia
- [x] Export Neovim core/full
- [x] Add `homeModules.default`
- [x] Add `homeModules.desktop`
- [ ] Test modules from another flake
- [ ] Update work flake to consume `github:ivyrs/nix-nu`
- [ ] Remove duplicated Home Manager configuration from work flake
- [ ] Revisit `homeModules.default` after real-world use

## Nix cleanup

- [x] Move to stable NixOS 26.05
- [x] Pin nixos-apple-silicon release
- [x] Drop custom Asahi ccache kernel override
- [x] Keep proprietary Asahi firmware outside the repo
- [x] Remove Den-era architecture from the rewrite
- [x] Split SOPS secrets per host
- [ ] Revisit Cachix token naming once more hosts exist
- [ ] Decide whether Cachix push/watch-store should remain enabled
- [ ] Reconsider `trusted-users = [ "root" "@wheel" ]`
- [ ] Revisit deployment privilege/passwordless-sudo model

## Elm

- [ ] Add `nixosConfigurations.elm`
- [ ] Migrate hardware configuration
- [ ] Reuse shared system modules
- [ ] Create `secrets/elm.yaml`
- [ ] Migrate services
- [ ] Test remote rebuild/deployment

## Yew

- [ ] Add `nixosConfigurations.yew`
- [ ] Migrate hardware configuration
- [ ] Reuse shared system modules
- [ ] Create `secrets/yew.yaml`
- [ ] Migrate services
- [ ] Compare Elm and Yew before extracting shared server abstractions

## Houseplants

- [ ] Add `nixosConfigurations.houseplants`
- [ ] Migrate hardware configuration
- [ ] Create `secrets/houseplants.yaml`
- [ ] Migrate Disko
- [ ] Migrate Caddy / public-edge configuration
- [ ] Preserve public-edge vs private-service-host boundary
- [ ] Migrate remaining services

## Pi

- [ ] Add `nixosConfigurations.pi`
- [ ] Add Raspberry Pi hardware support
- [ ] Create `secrets/pi.yaml`
- [ ] Migrate Home Assistant
- [ ] Migrate remaining Pi configuration

## Deployment

- [ ] Add deploy-rs
- [x] Keep `nh` for local rebuilds
- [ ] Configure deployments over Tailscale / MagicDNS
- [ ] Configure Elm deployment
- [ ] Configure Yew deployment
- [ ] Configure Houseplants deployment
- [ ] Configure Pi deployment if useful
- [ ] Revisit deployment privilege model

## Aspen

Do this when actually booted into macOS.

- [ ] Add nix-darwin
- [ ] Add `darwinConfigurations.aspen`
- [ ] Add nix-homebrew if still useful
- [ ] Recreate Darwin-specific Nix/Lix configuration
- [ ] Reuse shared Home Manager modules
- [ ] Migrate rbw / SSH agent
- [ ] Migrate Git SSH signing away from 1Password
- [ ] Test shell
- [ ] Test Git
- [ ] Test Neovim
- [ ] Test Ghostty
- [ ] Ensure Tailscale Funnel remains available

## Later abstractions

Only do these when actual duplication makes them worthwhile.

- [ ] Consider `roles/server.nix`
- [ ] Consider `roles/desktop.nix`
- [ ] Consider shared Darwin/NixOS Nix module
- [ ] Consider custom `lib/` helpers

## Rules

- Keep hosts explicit.
- Keep reusable system capabilities in small modules.
- Keep user applications and dotfiles under `home/`.
- Keep project-specific language runtimes out of the general home environment.
- Prefer project flakes/dev shells for development toolchains.
- Don't abstract until duplication or friction demonstrates a need.
- Build and commit successful layers independently.
- Keep proprietary Apple firmware outside the public repository.

## Final cleanup

- [ ] Redirect `ivyro.se/flake` to the `nix-nu` repository
