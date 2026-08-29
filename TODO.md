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
