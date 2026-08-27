{ inputs, ... }:

{
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;

    settings = {
      vim.viAlias = true;
      vim.vimAlias = true;

      vim.lsp.enable = true;
      vim.treesitter.enable = true;
      vim.languages.enableTreesitter = true;
      vim.telescope.enable = true;
      vim.statusline.lualine.enable = true;

      vim.autocomplete.blink-cmp.enable = true;
      vim.autopairs.nvim-autopairs.enable = true;
      vim.comments.comment-nvim.enable = true;

      vim.git.gitsigns.enable = true;

      vim.binds.whichKey.enable = true;
      vim.visuals.indent-blankline.enable = true;
      vim.visuals.fidget-nvim.enable = true;

      vim.theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = true;
      };

      vim.utility.oil-nvim.enable = true;
      vim.dashboard.alpha.enable = true;
      vim.notes.todo-comments.enable = true;

      vim.keymaps = [
        {
          key = "-";
          mode = "n";
          action = "<CMD>Oil<CR>";
          desc = "Open parent directory (oil.nvim)";
        }
      ];

      vim.luaConfigRC.alpha-custom = ''
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
  };
}
