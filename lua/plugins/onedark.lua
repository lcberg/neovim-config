return {
	"navarasu/onedark.nvim",
	priority = 1000,
	enabled = true,
	config = function()
		require("onedark").setup({
			style = "warmer",
			colors = {
				bg0 = "#000000",
			},
		})
		require("onedark").load()
	end,
	init = function()
		vim.cmd.colorscheme = "onedark"
	end,
}
