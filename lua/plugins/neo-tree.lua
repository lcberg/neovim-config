local function contains(t, value)
	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			window = {
				position = "left",
				width = 35,
			},
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
				},
				follow_current_file = {
					enabled = true,
				},
			},
			default_component_configs = {
				icon = {
					provider = function(icon, node)
						local name = node.name

						local dotfiles = {
							".env",
							".env.example",
							".env.development",
							".env.production",
							".env.test",
						}

						if contains(dotfiles, name) then
							icon.text = ""
							icon.highlight = "NeoTreeDotfile"
						end
					end,
				},
			},
		})
	end,
}
