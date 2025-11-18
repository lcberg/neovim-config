return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"nvim-lua/plenary.nvim",
	},
	opts = function(_, opts)
		opts.servers = opts.servers or {}
		opts.servers.vue_ls = opts.servers.vue_ls or {}

		-- Patch TS servers (vtsls / ts_ls) to avoid conflicts in Vue files
		for _, name in ipairs({ "tsserver", "vtsls", "ts_ls" }) do
			opts.servers[name] = opts.servers[name] or {}
			local orig = opts.servers[name].on_attach
			opts.servers[name].on_attach = function(client, bufnr)
				if orig then
					orig(client, bufnr)
				end
				if client.server_capabilities.semanticTokensProvider then
					if vim.bo[bufnr].filetype == "vue" then
						client.server_capabilities.semanticTokensProvider.full = false
					else
						client.server_capabilities.semanticTokensProvider.full = true
					end
				end
			end
		end
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
	end,
}
