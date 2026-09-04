{
  vim.formatter.conform-nvim = {
    enable = true;
    setupOpts = {
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 500;
      };
    };
  };
}
