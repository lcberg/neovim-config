return {
	"catppuccin/nvim",
	name = "catppuccin",
	enabled = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			no_italic = true,
			term_colors = true,
			transparent_background = false,
			styles = {
				comments = {},
				conditionals = {},
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
			},
			color_overrides = {
				mocha = {
					base = "#000000",
					mantle = "#000000",
					crust = "#eeeeee",
					-- blue is for functions
					blue = "#333ddd",
					-- strings
					green = "#5faf00",
				},
			},
			custom_highlights = {
				NeoTreeWinSeparator = { fg = "#eeeeee" },
			},
			integrations = {
				telescope = {
					enabled = true,
					-- style = "nvchad",
				},
				dropbar = {
					enabled = true,
					color_mode = true,
				},
				neotree = true,
				mini = {
					enabled = true,
				},
				treesitter = true,
			},
		})
		require("catppuccin").load()
	end,
	init = function()
		vim.cmd.colorscheme = "catppuccin"
	end,
}
