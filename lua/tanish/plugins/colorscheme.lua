-- return {
--   "folke/tokyonight.nvim",
--   priority = 1000,
--   config = function()
--     require("tokyonight").setup({
--       style = "night",
--       transparent = "true",
--       comments = { italic = true },
--       keywords = { italic = true },
--     })
--     vim.cmd("colorscheme tokyonight")
--   end
--
-- }
-- lua/plugins/rose-pine.lua
-- return {
-- 	"rose-pine/neovim",
-- 	name = "rose-pine",
-- 	config = function()
-- 		vim.cmd("colorscheme rose-pine")
-- 	end
-- }
return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    -- Set up rose-pine with transparency
    require("rose-pine").setup({
      variant = "auto", -- auto, main, moon, or dawn
      dark_variant = "main", -- main, moon, or dawn
      dim_inactive_windows = false,
      extend_background_behind_borders = true,

      enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true, -- Handle deprecated options automatically
      },

      styles = {
        bold = true,
        italic = true,
        transparency = true, -- Enable transparency
      },
    })
    vim.cmd("colorscheme rose-pine")
  end
}
