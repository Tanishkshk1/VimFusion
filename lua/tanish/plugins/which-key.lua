return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		--     vim.o.timelen = 500
	end,
	opts = {},
}
