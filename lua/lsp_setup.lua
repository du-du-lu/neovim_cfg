--[[legacy functions
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
M.buf_key_bind = function(client, bufnr)
	print("buf number is " .. bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap=true, silent=true, buffer=bufnr }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end
]] --
-- key binding when lsp attaching to buffer
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local navic = require("nvim-navic")
		navic.attach(client, bufnr)
		local bufmap = function(mode, lhs, rhs)
			local opts = { buffer = true }
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- Displays hover information about the symbol under the cursor
		bufmap('n', 'K', vim.lsp.buf.hover)
		-- Jump to the definition
		bufmap('n', 'gd', vim.lsp.buf.definition)

		-- Jump to declaration
		bufmap('n', 'gD', vim.lsp.buf.declaration)

		-- Lists all the implementations for the symbol under the cursor
		bufmap('n', 'gi', vim.lsp.buf.implementation)

		-- Jumps to the definition of the type symbol
		bufmap('n', 'go', vim.lsp.buf.type_definition)

		-- Lists all the references
		bufmap('n', 'gr', vim.lsp.buf.references)

		-- Displays a function's signature information
		bufmap('n', '<C-k>', vim.lsp.buf.signature_help)

		-- Renames all references to the symbol under the cursor
		bufmap('n', '<F2>', vim.lsp.buf.rename)

		-- Selects a code action available at the current cursor position
		bufmap('n', '<F4>', vim.lsp.buf.code_action)
		bufmap('x', '<F4>', vim.lsp.buf.range_code_action)

		-- format buffer
		bufmap('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end
		)

		bufmap('v', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end
		)

		bufmap('i', '<C-f>',
			function()
				vim.lsp.buf.format { async = true,
					range = vim.treesitter.get_node_range(vim.treesitter.get_captures_at_cursor())
				}
			end
		)

		-- Show diagnostics in a floating window
		bufmap('n', 'gl', vim.diagnostic.open_float)

		-- Move to the previous diagnostic
		bufmap('n', '[d', vim.diagnostic.goto_prev)

		-- Move to the next diagnostic
		bufmap('n', ']d', vim.diagnostic.goto_next)

	end
})

local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config

-- for nvim-cmp complete
lsp_defaults.capabilities = vim.tbl_deep_extend(
	'force',
	lsp_defaults.capabilities,
	require('cmp_nvim_lsp').default_capabilities()
)

-- set rust lsp
lspconfig.rust_analyzer.setup({
})

-- set lua lsp
lspconfig.sumneko_lua.setup {
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { 'vim' },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
}

-- set toml lsp
lspconfig.taplo.setup({
})

-- set python lsp
lspconfig.pyright.setup({})

--set c/c++ lsp
lspconfig.clangd.setup({})