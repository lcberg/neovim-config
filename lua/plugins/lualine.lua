return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			icons_enabled = false,
			-- theme = "onedark",
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { { "filename", path = 0 } },
				lualine_x = {},
				lualine_y = { "diagnostics" },
			},
		})
	end,
}
