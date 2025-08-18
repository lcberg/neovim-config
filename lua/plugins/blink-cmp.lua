return {
	"saghen/blink.cmp",
	lazy = false, -- lazy loading handled internally
	-- optional: provides snippets for the snippet source
	dependencies = "rafamadriz/friendly-snippets",

	-- use a release tag to download pre-built binaries
	version = "1.*",
	-- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = function(_, opts)
		-- 'default' for mappings similar to built-in completion
		-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
		-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
		-- see the "default configuration" section below for full documentation on how to define
		-- your own keymap.
		opts.keymap = {
			preset = "default",
			-- ["<Tab>"] = { "select_and_accept", "fallback" },
			["<Tab>"] = {
				function(cmp)
					if cmp.is_menu_visible() then
						cmp.select_and_accept()
						cmp.show_signature()
						return true
					else
						return
					end
				end,
				"fallback",
			},
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
			["<C-h>"] = { "snippet_forward", "fallback" },
			["<C-l>"] = { "snippet_backward", "fallback" },
			["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
		}

		opts.appearance = {
			-- Sets the fallback highlight groups to nvim-cmp's highlight groups
			-- Useful for when your theme doesn't support blink.cmp
			-- will be removed in a future release
			use_nvim_cmp_as_default = true,
			-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
			kind_icons = {
				Snippet = "",
			},
		}
		opts.cmdline = {

			completion = {
				menu = {
					auto_show = true,
				},
				ghost_text = {
					enabled = false,
				},
				list = {
					selection = {
						preselect = false,
						auto_insert = true,
					},
				},
			},
		}

		-- default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, via `opts_extend`
		opts.sources = {
			default = { "lsp", "buffer", "snippets", "lazydev", "path" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		}
		opts.signature = {
			enabled = true,
			trigger = {
				enabled = true,
				show_on_keyword = true,
				show_on_trigger_character = true,
				show_on_insert = true,
			},
		}
		opts.fuzzy = { implementation = "prefer_rust_with_warning" }
		opts.completion = {
			menu = {
				draw = {
					columns = { { "kind_icon" }, { "label", gap = 1 }, { "source" } },
					components = {
						label = {
							text = require("colorful-menu").blink_components_text,
							highlight = require("colorful-menu").blink_components_highlight,
						},
						source = {
							text = function(ctx)
								local map = {
									["lsp"] = "[]",
									["path"] = "[󰉋]",
									["snippets"] = "[]",
								}

								return map[ctx.item.source_id]
							end,
							highlight = "BlinkCmpDoc",
						},
					},
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 100,
				update_delay_ms = 50,
				window = {
					max_width = math.min(80, vim.o.columns),
				},
			},
		}

		-- experimental signature help support
		-- signature = { enabled = true }
	end,
	-- allows extending the providers array elsewhere in your config
	-- without having to redefine it
	opts_extend = { "sources.default" },
}
