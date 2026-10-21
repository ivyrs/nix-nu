# nix-nu todo

## Deferred

- [ ] iCloud PIM — wait until Apple ID migration

## Reusable Home Manager

- [x] Export reusable Home Manager modules
- [x] Export shell
- [x] Export Git
- [x] Export tmux
- [x] Export Noctalia
- [x] Export Neovim core/full
- [x] Add `homeModules.default`
- [x] Add `homeModules.desktop`
- [x] Test modules from another flake
- [x] Update work flake to consume `github:ivyrs/nix-nu`
- [x] Remove duplicated Home Manager configuration from work flake
- [ ] Revisit `homeModules.default` after real-world use

**Note for consumers**: Neovim module requires passing `inputs` via `home-manager.extraSpecialArgs = { inputs = ivy-nix.inputs; }`

## Nix cleanup

- [ ] Revisit Cachix token naming once more hosts exist
- [ ] Decide whether Cachix push/watch-store should remain enabled
- [ ] Reconsider `trusted-users = [ "root" "@wheel" ]`
- [ ] Revisit deployment privilege/passwordless-sudo model

## Pi

- [ ] Add `nixosConfigurations.pi`
- [ ] Add Raspberry Pi hardware support
- [ ] Create `secrets/pi.yaml`
- [ ] Migrate Home Assistant
- [ ] Migrate remaining Pi configuration

## Aspen

Do this when actually booted into macOS.

- [x] Add nix-darwin
- [x] Add `darwinConfigurations.aspen`
- [x] Add nix-homebrew if still useful
- [ ] Recreate Darwin-specific Nix/Lix configuration
- [x] Reuse shared Home Manager modules
- [ ] Migrate rbw / SSH agent
- [ ] Migrate Git SSH signing away from 1Password
- [ ] Test shell
- [ ] Test Git
- [ ] Test Neovim
- [ ] Test Ghostty
- [ ] Ensure Tailscale Funnel remains available

## Later abstractions

Only do these when actual duplication makes them worthwhile.

- [x] Consider `roles/server.nix`
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

## Review Follow-ups

- [ ] Revoke/rotate the removed Wallhaven API credential; review historical exposure
- [ ] Reconcile Alder's actual SOPS recipients with `.sops.yaml` using an administrator key
- [ ] Audit copied unused secret entries and rotate credentials where recipient scope was too broad
- [ ] Provision Darwin credential commands for Aspen's email, calendar, and contact accounts
- [ ] Complete rbw account/key provisioning and test SSH signing on both desktop hosts
- [ ] Define consistent database/file backups, host-key recovery, and a tested restore procedure
- [ ] Decide whether Homebrew upgrades and destructive `zap` cleanup should run during activation
- [ ] Review HaRP's privileged Docker access and shared-key process-argument exposure
- [ ] Verify OIDC account-linking and username-claim trust against existing accounts
- [ ] Document tailnet enrollment, service approvals, grants, and console recovery per host
- [ ] Test first-start MPD, Noctalia generation, clipboard delivery, and Prosody certificate renewal
- [ ] Revisit Asahi kernel reuse only when source/version overrides preserve the selected kernel
- [ ] Verify Navidrome clients use the music Tailscale Service rather than Elm's raw port 4533
- [ ] Review old Cachix uploads for firmware; disabling the watcher does not delete uploaded paths
