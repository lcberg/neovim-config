return {
	"navarasu/onedark.nvim",
	priority = 1000,
	enabled = false,
	config = function()
		require("onedark").setup({
			style = "warmer",
		})
		require("onedark").load()
	end,
	init = function()
		vim.cmd.colorscheme = "onedark"
	end,
}
