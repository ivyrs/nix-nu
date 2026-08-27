{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.noctalia.homeModules.default ];

  home.packages = [ pkgs.swappy ];

  programs.noctalia = {
    enable = true;
    settings = ./noctalia.toml;
    systemd.enable = true;
  };

  # noctalia writes its generated theme directly into these apps' own config
  # paths at runtime. A non-empty home-manager-owned file at that exact path
  # is a read-only symlink into the nix store, so noctalia's write fails with
  # a permission error — these have to be forced empty (or, for zathura,
  # pointed at a sibling file via `include`) to leave the path mutable. See
  # home/ghostty.nix, home/files/zathura.nix, home/git/lazygit.nix,
  # home/pim/aerc/default.nix, home/tmux/default.nix and home/shell/cli.nix
  # for the mkDefault fallbacks these override.
  programs.ghostty.settings.theme = lib.mkForce "noctalia";

  programs.zathura.options = lib.mkForce { };
  programs.zathura.extraConfig = "include noctaliarc";

  programs.lazygit.settings = lib.mkForce { };

  programs.aerc.extraConfig.ui.styleset-name = lib.mkForce "noctalia";
  programs.aerc.stylesets = lib.mkForce { };

  programs.fzf.defaultOptions = lib.mkForce [
    "--style=minimal"
    "--info=inline-right"
    "--highlight-line"
    "--no-separator"
  ];

  home.sessionVariablesExtra = ''
    [ -f "$HOME/.config/fzf/noctalia-colors.sh" ] && source "$HOME/.config/fzf/noctalia-colors.sh"
  '';

  programs.tmux.extraConfig = lib.mkForce ''
    ${builtins.readFile ../tmux/tmux.conf}

    # Source noctalia-generated theme (will override hardcoded colors above)
    source-file -q ~/.config/tmux/noctalia-theme.conf
  '';

  home.file.".config/noctalia/templates/aerc.conf".source = ./templates/aerc.conf;
  home.file.".config/noctalia/templates/fzf.sh".source = ./templates/fzf.sh;
  home.file.".config/noctalia/templates/tmux.conf".source = ./templates/tmux.conf;

  # neovim: unlike the apps above, nvf never touches ~/.config/nvim at
  # runtime (it wraps a fully self-contained nix-store binary — no
  # xdg.configFile management and no live config directory on the
  # runtimepath), so noctalia can't theme it by overwriting a config file
  # in place. Instead its generated colors are rendered to a path nvf never
  # manages (~/.config/nvim-noctalia), and base16-nvim + a dofile() of that
  # path is wired in via luaConfigRC, applied at startup and again on
  # SIGUSR1 (this template's post_hook in noctalia.toml signals running
  # nvim instances to reload after a theme change).
  programs.nvf.settings.vim = {
    extraPlugins.base16-nvim.package = pkgs.vimPlugins.base16-nvim;

    luaConfigRC.noctalia-theme = {
      after = [ "mappings" ];
      before = [ ];
      data = ''
        local noctalia_theme_file = vim.fn.expand("~/.config/nvim-noctalia/matugen.lua")

        local noctalia_transparent_groups = {
          "Normal", "NormalNC", "NormalFloat", "FloatBorder", "NonText",
          "SignColumn", "EndOfBuffer", "LineNr", "CursorLineNr",
          "VertSplit", "WinSeparator", "StatusLine", "StatusLineNC",
          "TabLine", "TabLineFill", "Pmenu", "FoldColumn", "Folded",
          -- Telescope's floating window backdrops. Left alone on purpose:
          -- TelescopeSelection (row highlight, needed to see what's
          -- selected) and the Prompt/Preview/ResultsTitle badges (their
          -- accent-colored bg is a deliberate pill, not page background).
          "TelescopeNormal", "TelescopeBorder",
          "TelescopePromptNormal", "TelescopePromptBorder",
          "TelescopePromptPrefix", "TelescopeResultsNormal",
          "TelescopeResultsBorder", "TelescopePreviewNormal",
          "TelescopePreviewBorder",
        }

        local function apply_noctalia_theme()
          if vim.fn.filereadable(noctalia_theme_file) == 1 then
            local ok, matugen = pcall(dofile, noctalia_theme_file)
            if ok and matugen and matugen.setup then
              matugen.setup()

              -- base16-nvim paints a solid Normal background; strip it back
              -- out so the terminal's own (transparent) background shows
              -- through, matching vim.theme.transparent on non-noctalia hosts.
              for _, group in ipairs(noctalia_transparent_groups) do
                vim.api.nvim_set_hl(0, group, { bg = "none" })
              end
            end
          end
        end

        apply_noctalia_theme()

        local noctalia_signal = vim.uv.new_signal()
        noctalia_signal:start("sigusr1", vim.schedule_wrap(apply_noctalia_theme))
      '';
    };
  };

  home.file.".config/nvim-noctalia/.keep".text = "";
  home.file.".config/noctalia/templates/nvim-matugen.lua".source = ./templates/nvim-matugen.lua;
}
