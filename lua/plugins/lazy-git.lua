return {
	"kdheepak/lazygit.nvim",
	lazy = true,
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	-- optional for floating window border decoration
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- setting the keybinding for LazyGit with 'keys' is recommended in
	-- order to load the plugin when the command is run for the first time
	keys = {
		{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	},
	config = function()
		-- vim.api.nvim_create_autocmd("TermOpen", {
		-- 	pattern = "term://*lazygit",
		-- 	callback = function()
		-- 		vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:q<CR>", { buffer = true, silent = true })
		-- 	end,
		-- })

		-- Force update of Neotree (mostly for git signs when exiting lazygit)
		vim.api.nvim_create_autocmd("TermClose", {
			pattern = "*lazygit*",
			callback = function()
				vim.schedule(function()
					require("neo-tree.sources.manager").refresh("filesystem")
					require("neo-tree.sources.manager").refresh("git_status")
				end)
			end,
		})
	end,
}
