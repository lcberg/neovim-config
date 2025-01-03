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
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*lazygit",
			callback = function()
				vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:q<CR>", { buffer = true, silent = true })
			end,
		})
	end,
}
