-- https://github.com/kevinfengcs88/nvim/tree/master
return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local opts = { noremap = true, silent = true }

		local status_ok, alpha = pcall(require, "alpha")
		if not status_ok then
			return
		end

		local function git(args)
			local result = vim.system(vim.list_extend({ "git" }, args), { text = true, cwd = vim.fn.getcwd() }):wait(1000)
			if result.code ~= 0 or not result.stdout then
				return nil
			end
			return vim.trim(result.stdout)
		end

		local function git_info()
			local toplevel = git({ "rev-parse", "--show-toplevel" })
			if not toplevel then
				return {}, {}
			end

			local branch = git({ "branch", "--show-current" })
			if not branch or branch == "" then
				branch = "detached @ " .. (git({ "rev-parse", "--short", "HEAD" }) or "?")
			end

			local behind, ahead
			local counts = git({ "rev-list", "--left-right", "--count", "@{upstream}...HEAD" })
			if counts then
				behind, ahead = counts:match("(%d+)%s+(%d+)")
			end

			local status = git({ "status", "--porcelain" }) or ""
			local staged, modified, untracked = 0, 0, 0
			for line in status:gmatch("[^\n]+") do
				local x, y = line:sub(1, 1), line:sub(2, 2)
				if x == "?" then
					untracked = untracked + 1
				else
					if x ~= " " then
						staged = staged + 1
					end
					if y ~= " " then
						modified = modified + 1
					end
				end
			end

			local hash, subject, age = (git({ "log", "-1", "--format=%h%x00%s%x00%cr" }) or ""):match("^(.-)%z(.-)%z(.*)$")
			if subject and vim.fn.strdisplaywidth(subject) > 45 then
				subject = vim.fn.strcharpart(subject, 0, 44) .. "…"
			end

			-- worktrees: the first entry of `git worktree list` is always the main one
			local worktrees = {}
			for path in (git({ "worktree", "list", "--porcelain" }) or ""):gmatch("worktree ([^\n]+)") do
				table.insert(worktrees, path)
			end
			local function short(path)
				path = path:gsub("^" .. vim.pesc(vim.env.HOME), "~")
				if vim.fn.strdisplaywidth(path) > 45 then
					path = "…" .. vim.fn.strcharpart(path, vim.fn.strchars(path) - 44)
				end
				return path
			end

			-- each row: icon, label, then a list of { text, highlight } segments
			local rows = {}
			local sep = { "  ·  ", "NonText" }

			rows[#rows + 1] = {
				"\u{e702}",
				"Repo",
				{ { vim.fn.fnamemodify(worktrees[1] or toplevel, ":t"), "Title" }, sep, { short(toplevel), "Directory" } },
			}

			local branch_row = { { branch, "Function" } }
			if ahead and ahead ~= "0" then
				table.insert(branch_row, { "  ↑" .. ahead, "DiagnosticOk" })
			end
			if behind and behind ~= "0" then
				table.insert(branch_row, { "  ↓" .. behind, "DiagnosticWarn" })
			end
			rows[#rows + 1] = { "\u{e725}", "Branch", branch_row }

			local status_row = {}
			for _, item in ipairs({
				{ staged, "● %d staged", "DiagnosticOk" },
				{ modified, "✚ %d modified", "DiagnosticWarn" },
				{ untracked, "? %d untracked", "DiagnosticInfo" },
			}) do
				if item[1] > 0 then
					if #status_row > 0 then
						table.insert(status_row, { "   ", "Normal" })
					end
					table.insert(status_row, { item[2]:format(item[1]), item[3] })
				end
			end
			if #status_row == 0 then
				status_row = { { "✓ clean", "DiagnosticOk" } }
			end
			rows[#rows + 1] = { "\u{f040}", "Status", status_row }

			if hash then
				rows[#rows + 1] = { "\u{e729}", "Commit", { { hash, "Number" }, { "  " .. subject, "Normal" }, sep, { age, "Comment" } } }
			end

			local worktree_row
			if #worktrees <= 1 then
				worktree_row = { { "main", "String" }, sep, { "no linked worktrees", "Comment" } }
			elseif worktrees[1] == toplevel then
				worktree_row = { { "main", "String" }, sep, { (#worktrees - 1) .. " linked", "Special" } }
			else
				worktree_row = {
					{ "linked: " .. vim.fn.fnamemodify(toplevel, ":t"), "Special" },
					sep,
					{ "main at " .. short(worktrees[1]), "Comment" },
				}
			end
			rows[#rows + 1] = { "\u{f0e8}", "Worktree", worktree_row }

			-- render rows into lines plus byte-offset highlights for alpha
			local lines, hls = {}, {}
			for _, row in ipairs(rows) do
				local icon, label, segments = row[1], row[2], row[3]
				local line = icon .. "  "
				local line_hl = { { "Keyword", 0, #icon } }
				local label_text = label .. string.rep(" ", 10 - #label)
				table.insert(line_hl, { "Comment", #line, #line + #label_text })
				line = line .. label_text
				for _, seg in ipairs(segments) do
					table.insert(line_hl, { seg[2], #line, #line + #seg[1] })
					line = line .. seg[1]
				end
				lines[#lines + 1] = line
				hls[#hls + 1] = line_hl
			end

			-- pad to equal width so the block stays left-aligned when centered
			local width = 0
			for _, line in ipairs(lines) do
				width = math.max(width, vim.fn.strdisplaywidth(line))
			end
			for i, line in ipairs(lines) do
				lines[i] = line .. string.rep(" ", width - vim.fn.strdisplaywidth(line))
			end
			return lines, hls
		end

		-- cached so redraws (e.g. on resize) don't re-run git
		local git_lines, git_hls = {}, {}
		local function refresh_git()
			git_lines, git_hls = git_info()
		end
		refresh_git()

		vim.api.nvim_create_autocmd("DirChanged", { callback = refresh_git })

		vim.keymap.set("n", "<leader>a", function()
			refresh_git()
			vim.cmd("Alpha")
		end, opts)

		local header = {
			"                                                     ",
			"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
			"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
			"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
			"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
			"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
			"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
			"                                                     ",
		}

		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = header

		dashboard.section.buttons.val = {
			dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
			dashboard.button("e", "  New file", ":ene <CR>"),
			dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
			dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
			dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
		}

		local v = vim.version()
		local version = " v" .. v.major .. "." .. v.minor .. "." .. v.patch
		local datetime = os.date(" %m-%d-%Y 󱑏 %H:%M:%S")

		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyVimStarted",
			callback = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				dashboard.section.footer.val = {
					"",
					"",
					version,
					"",
					datetime,
					"",
					"⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms",
				}
				pcall(vim.cmd.AlphaRedraw)
			end,
		})

		dashboard.section.footer.val = {}

		dashboard.section.footer.opts.hl = "Type"
		dashboard.section.header.opts.hl = "Include"
		dashboard.section.buttons.opts.hl = "Keyword"

		local git_section
		git_section = {
			type = "text",
			val = function()
				-- alpha reads opts.hl after resolving val, so keep it in sync with the cache
				git_section.opts.hl = git_hls
				return git_lines
			end,
			opts = { position = "center" },
		}

		dashboard.opts.layout = {
			{ type = "padding", val = 2 },
			dashboard.section.header,
			{
				type = "padding",
				val = function()
					return #git_lines > 0 and 1 or 0
				end,
			},
			git_section,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			dashboard.section.footer,
		}

		dashboard.opts.opts.noautocmd = true
		alpha.setup(dashboard.opts)
	end,
}
