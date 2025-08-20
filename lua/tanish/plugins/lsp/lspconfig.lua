return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    -- diagnostics UI
    vim.diagnostic.config({
      virtual_text = true,
      float = {
        border = "rounded",
        focusable = true,
        max_width = 80,
        source = "always",
        header = "",
        prefix = "",
        wrap = true,
      },
    })
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- deps
    local lspconfig = require("lspconfig")
    local mlsp = require("mason-lspconfig")
    local cmp = require("cmp_nvim_lsp")
    local navic = require("nvim-navic")

    -- shared on_attach
    local on_attach = function(client, bufnr)
      local keymap = vim.keymap
      local opts = { buffer = bufnr, silent = true }

      opts.desc = "Show LSP references"
      keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
      opts.desc = "Go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      opts.desc = "Show LSP definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
      opts.desc = "Show LSP implementations"
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
      opts.desc = "See code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
      opts.desc = "Rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      opts.desc = "Buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
      opts.desc = "Line diagnostics"
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
      keymap.set("n", "K", vim.lsp.buf.hover, opts)
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

      if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
      end
    end

    local capabilities = cmp.default_capabilities()

    -- per-server overrides
    local overrides = {
      svelte = function()
        lspconfig.svelte.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                client.notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.file) })
              end,
            })
          end,
        })
      end,

      graphql = function()
        lspconfig.graphql.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
        })
      end,

      emmet_ls = function()
        lspconfig.emmet_ls.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
        })
      end,

      lua_ls = function()
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              completion = { callSnippet = "Replace" },
            },
          },
        })
      end,

      rust_analyzer = function()
        lspconfig.rust_analyzer.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
            },
          },
        })
      end,

      gopls = function()
        lspconfig.gopls.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          cmd = { "/home/tanish/go/bin/gopls" }, -- change if needed
          root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
          settings = {
            gopls = {
              analyses = { unusedparams = true },
              staticcheck = true,
            },
          },
        })
      end,

      clangd = function()
        lspconfig.clangd.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "c", "cpp", "objc", "objcpp" },
          cmd = { "clangd", "--background-index", "--clang-tidy" },
          init_options = { clangdFileStatus = true },
        })
      end,

    }

    -- robust handler: use setup_handlers if present, otherwise do it manually
    if type(mlsp.setup_handlers) == "function" then
      mlsp.setup_handlers(vim.tbl_extend("force", {
        -- default for any server not overridden above
        function(server)
          if overrides[server] then
            overrides[server]()
          else
            lspconfig[server].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end
        end,
      }, overrides))
    else
      -- fallback path for older/newer APIs
      for _, server in ipairs(mlsp.get_installed_servers()) do
        if overrides[server] then
          overrides[server]()
        else
          lspconfig[server].setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        end
      end
    end
  end,
}

