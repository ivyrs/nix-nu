{ ... }:

{
  vim = {
    viAlias = true;
    vimAlias = true;

    lsp.enable = true;
    treesitter.enable = true;
    languages.enableTreesitter = true;
    telescope.enable = true;
    statusline.lualine.enable = true;

    autocomplete.blink-cmp.enable = true;
    autopairs.nvim-autopairs.enable = true;
    comments.comment-nvim.enable = true;

    git.gitsigns.enable = true;

    binds.whichKey.enable = true;
    visuals.indent-blankline.enable = true;
    visuals.fidget-nvim.enable = true;

    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = true;
    };

    utility.oil-nvim.enable = true;
    dashboard.alpha.enable = true;
    notes.todo-comments.enable = true;

    keymaps = [
      {
        key = "-";
        mode = "n";
        action = "<CMD>Oil<CR>";
        desc = "Open parent directory (oil.nvim)";
      }
    ];

    luaConfigRC.alpha-custom = ''
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      dashboard.section.header.val = {
        [[   ╭──────────╮  ]],
        [[   │  NEOVIM  │  ]],
        [[   ╰──────────╯  ]],
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      local function footer()
        local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
        local version = vim.version()
        return datetime
          .. "   v"
          .. version.major
          .. "."
          .. version.minor
          .. "."
          .. version.patch
      end

      dashboard.section.footer.val = footer()

      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      }

      dashboard.section.header.opts.hl = "Function"
      dashboard.section.buttons.opts.hl = "Keyword"
      dashboard.section.footer.opts.hl = "Comment"

      alpha.setup(dashboard.config)

      vim.cmd([[
        autocmd FileType alpha setlocal nofoldenable
      ]])
    '';
  };
}
