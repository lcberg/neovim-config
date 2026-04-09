vim.api.nvim_buf_set_keymap(
	0,
	"n",
	"<leader>rt",
	":w<CR>:!NODE_ENV=development node --nolazy -r ts-node/register/transpile-only ./%<CR>",
	{}
)

vim.api.nvim_buf_set_keymap(0, "n", "<leader>rx", ":w<CR>:!NODE_ENV=development tsx ./%<CR>", {})

vim.api.nvim_buf_set_keymap(0, "n", "<leader>tc", ":w<CR>:!npm run typecheck<CR>", {})
