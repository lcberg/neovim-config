return {
	"navarasu/onedark.nvim",
	--- currently the 1.0.0 release is broken for components
	version = "0.1.0",
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
