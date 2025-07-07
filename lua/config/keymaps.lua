local keymap = vim.keymap

keymap.set("n", "<leader>o", ":Ex<CR>")

-- wrap helper
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
keymap.set("n", "üd", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
keymap.set("n", "+d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- primeagan remaps
-- move visual mode selected line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor in place during J (appending line below cursor to current line)
vim.keymap.set("n", "J", "mzJ`z")

-- keep cursor in middle during half page jumping (ctrl d/u)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in middle during searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- toggle neotree
keymap.set("n", "<C-b>", "<Cmd>Neotree toggle<CR>")

-- clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

-- neotest

keymap.set("n", "<leader>t", "", { desc = "+test" })
keymap.set("n", "<leader>tt", function()
	require("neotest").run.run(vim.fn.expandcmd("%"))
end, { desc = "Run File" })
keymap.set("n", "<leader>tT", function()
	require("neotest").run.run(vim.uv.cwd())
end, { desc = "Run All Test Files" })
keymap.set("n", "<leader>tr", function()
	require("neotest").run.run()
end, { desc = "Run nearest" })
keymap.set("n", "<leader>tl", function()
	require("neotest").run.run_last()
end, { desc = "Run Last" })
keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { desc = "Toggle Summary" })
keymap.set("n", "<leader>to", function()
	require("neotest").output.open({ enter = true, auto_close = true })
end, { desc = "Show output" })
keymap.set("n", "<leader>tO", function()
	require("neotest").output_panel.toggle()
end, { desc = "Toggle Output Panel" })
keymap.set("n", "<leader>tS", function()
	require("neotest").run.stop()
end, { desc = "Stop" })
keymap.set("n", "<leader>tW", function()
	require("neotest").watch.toggle(vim.fn.expand("%"))
end, { desc = "Toggle watch" })

local diffview_open = false

local function toggle_diffview()
	if diffview_open then
		vim.cmd("DiffviewClose")
	else
		vim.cmd("DiffviewFileHistory %")
	end
	diffview_open = not diffview_open
end

keymap.set("n", "<leader>gh", toggle_diffview, { noremap = true, silent = true, desc = "Git File History" })
keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { noremap = true, silent = true, desc = "Close Diffview" })

-- quickly create string arrays
vim.keymap.set("i", "<C-l>", function()
	vim.cmd("normal! bell")
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()

	local function add_on_same_line()
		local new_line = line:sub(1, col) .. ", ''" .. line:sub(col + 1)
		vim.api.nvim_set_current_line(new_line)
		vim.api.nvim_win_set_cursor(0, { row, col + 3 })
	end

	local function add_on_new_line()
		local indent = line:match("^%s*") or ""
		-- Append comma to current line if not already present
		if not line:match(",%s*$") then
			vim.api.nvim_set_current_line(line .. ",")
		end
		vim.cmd("normal! o")

		-- Insert a new line below with indentation and empty string
		local new_line = indent .. "''"
		vim.api.nvim_set_current_line(new_line)

		-- Move cursor inside the new quotes
		vim.api.nvim_win_set_cursor(0, { row + 1, #indent + 1 })
	end

	if line:match("^%s*'[^']*'%s*,?%s*$") then
		-- Line has only one string element → vertical layout
		add_on_new_line()
	else
		-- Otherwise, treat it as horizontal layout
		add_on_same_line()
	end
end, { desc = "Add string entry", expr = false })
