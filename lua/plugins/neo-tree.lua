return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			config = function()
				require("nvim-web-devicons").setup({
					override_by_filename = {
						[".env.development"] = {
							icon = "",
							highlight = "NeoTreeDotfile",
						},
						[".env.example"] = {
							icon = "",
							highlight = "NeoTreeDotfile",
						},
						[".env.production"] = {
							icon = "",
							highlight = "NeoTreeDotfile",
						},
						[".env"] = {
							icon = "",
							highlight = "NeoTreeDotfile",
						},
						[".test"] = {
							icon = "",
							highlight = "NeoTreeDotfile",
						},
					},
				})
			end,
		},
		-- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
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
			-- default_component_configs = {
			-- 	icon = {
			-- 		provider = function(icon, node)
			-- 			local name = node.name
			--
			-- 			local dotfiles = {
			-- 				".env",
			-- 				".env.example",
			-- 				".env.development",
			-- 				".env.production",
			-- 				".env.test",
			-- 			}
			--
			-- 			if contains(dotfiles, name) then
			-- 				icon.text = ""
			-- 				icon.highlight = "NeoTreeDotfile"
			-- 			end
			-- 		end,
			-- 	},
			-- },
		})
	end,
}
