vim.api.nvim_buf_set_keymap(
	0,
	"n",
	"<leader>ts",
	":w<CR>:!NODE_ENV=development node --nolazy -r ts-node/register/transpile-only ./%<CR>",
	{}
)
