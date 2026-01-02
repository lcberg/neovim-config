return {
	"navarasu/onedark.nvim",
	--- currently the 1.0.0 release is broken for components
	-- version = "0.1.0",
	version = "1.0.3",
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

		vim.api.nvim_set_hl(0, "@lsp.type.modifier.java", { link = "@keyword" })
	end,
	init = function()
		vim.cmd.colorscheme = "onedark"
	end,
}
