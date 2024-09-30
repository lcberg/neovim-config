return {
	"windwp/nvim-ts-autotag",
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = function()
		require("nvim-ts-autotag").setup({
			enable = true,
			filetypes = { "html", "vue", "xml" },
		})
	end,
}
