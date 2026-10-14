return {
	"nvim-lualine/lualine.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("lualine").setup({
			icons_enabled = false,
			-- theme = "onedark",
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = {
					{
						"filename",
						path = 1,
						fmt = function(str)
							local parts = vim.split(str, "/", { plain = true })
							if #parts <= 3 then
								return str
							end
							return table.concat({ unpack(parts, #parts - 2) }, "/")
						end,
					},
				},
				lualine_x = {},
				lualine_y = { "diagnostics" },
			},
		})
	end,
}
