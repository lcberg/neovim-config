log = require("log")
log:write("Starting")
-- disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
require("config.lazy")

local notify_original = vim.notify
vim.notify = function(msg, ...)
	if
		msg
		and (
			msg:match 'position_encoding param is required'
			or msg:match 'Defaulting to position encoding of the first client'
			or msg:match 'multiple different client offset_encodings'
			or msg:match 'vim.lsp.util.jump_to_location is deprecated. Run ":checkhealth vim.deprecated" for more information'
		)
	then
		return
	end
	return notify_original(msg, ...)
end
