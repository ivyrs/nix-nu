{ ... }:

{
  vim.languages = {
    nix.enable = true;
    markdown.enable = true;

    rust.enable = true;
    # go.enable = true;
    # python.enable = true;
    typescript = {
      enable = true;
      format.enable = false;
    };
    astro.enable = true;
    # clang.enable = true;
    html.enable = true;
    css.enable = true;
  };

  vim.lsp.servers.nil.settings.nil.formatting.command = [ "nixfmt" "-" ];

  vim.formatter.conform-nvim = {
    enable = true;
    setupOpts = {
      formatters.oxfmt = {
        command = "oxfmt";
        args = [ "--stdin-filepath" "$FILENAME" ];
      };
      formatters_by_ft = {
        typescript = [ "oxfmt" ];
        javascript = [ "oxfmt" ];
      };
    };
  };
}
