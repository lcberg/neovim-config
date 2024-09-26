return {
	"folke/which-key.nvim",
	event = "VimEnter",
	config = function() -- This is the function that runs, AFTER loading
		require("which-key").setup()

		-- Document existing key chains
		-- require("which-key").register({})
	end,
}
