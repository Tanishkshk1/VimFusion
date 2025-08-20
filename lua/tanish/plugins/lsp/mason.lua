return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mlsp = require("mason-lspconfig")
    local mti = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mlsp.setup({
      ensure_installed = {
        -- LSP servers (nvim-lspconfig names)
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "emmet_ls",
        "pyright",
        "gopls",
        "clangd",
        "graphql",
      },
      automatic_installation = true,
    })

    mti.setup({
      ensure_installed = {
        -- formatters / linters / tools
        "prettier",
        "stylua",
        "isort",
        "black",
        "pylint",
        "eslint_d",
      },
      run_on_start = true,
    })
  end,
}

