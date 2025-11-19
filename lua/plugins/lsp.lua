return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"nvim-lua/plenary.nvim",
	},
	opts = function(_, opts)
		-- opts.servers = opts.servers or {}
		-- opts.servers.vue_ls = opts.servers.vue_ls or {}
		--
		-- -- Patch TS servers (vtsls / ts_ls) to avoid conflicts in Vue files
		-- for _, name in ipairs({ "tsserver", "vtsls", "ts_ls" }) do
		-- 	opts.servers[name] = opts.servers[name] or {}
		-- 	local orig = opts.servers[name].on_attach
		-- 	opts.servers[name].on_attach = function(client, bufnr)
		-- 		if orig then
		-- 			orig(client, bufnr)
		-- 		end
		-- 		if client.server_capabilities.semanticTokensProvider then
		-- 			if vim.bo[bufnr].filetype == "vue" then
		-- 				client.server_capabilities.semanticTokensProvider.full = false
		-- 			else
		-- 				client.server_capabilities.semanticTokensProvider.full = true
		-- 			end
		-- 		end
		-- 	end
		-- end
	end,
	config = function()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
			},
			automatic_enable = true,
			automatic_installation = false,
		})

		vim.lsp.config('vtsls', {
			settings = {
				vtsls = {
					tsserver = {
						globalPlugins = {
							-- somehow if following the documentation and having vue_plugin = for this table, the plugin will not be configured correctly...
							{
								name = '@vue/typescript-plugin',
								location = vim.fn.expand '$MASON/packages' ..
									'/vue-language-server' .. '/node_modules/@vue/language-server',
								languages = { 'vue' },
								configNamespace = 'typescript',
							}
						},
					},
				},
			},
			filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
			on_attach = function(client)
				if vim.bo.filetype == 'vue' then
					client.server_capabilities.semanticTokensProvider.full = false
				else
					client.server_capabilities.semanticTokensProvider.full = true
				end
			end

		})
		vim.lsp.enable({ "vtsls", "vue_ls" })

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				local builtin = require("telescope.builtin")

				-- Jump to the definition of the word under your cursor.
				--  This is where a variable was first declared, or where a function is defined, etc.
				--  To jump back, press <C-t>.
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

				-- Find references for the word under your cursor.
				map("gr", function()
					builtin.lsp_references({
						layout_config = {
							width = 0.95,
						},
						-- fname_width = 50,
						-- path_display = { "smart" },
						show_line = false,
					})
				end, "[G]oto [R]eferences")

				-- Jump to the implementation of the word under your cursor.
				--  Useful when your language has ways of declaring types without an actual implementation.
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

				-- Jump to the type of the word under your cursor.
				--  Useful when you're not sure what type a variable is and you want to see
				--  the definition of its *type*, not where it was *defined*.
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

				-- Fuzzy find all the symbols in your current document.
				--  Symbols are things like variables, functions, types, etc.
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

				-- Fuzzy find all the symbols in your current workspace.
				--  Similar to document symbols, except searches over your entire project.
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

				-- Rename the variable under your cursor.
				--  Most Language Servers support renaming across files, etc.
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				--
				-- This may be unwanted, since they displace some of your code
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end
		})
	end,
}
