require("telescope").setup({})
vim.keymap.set('n', '<leader>t', "<cmd>Telescope builtin<cr>")
vim.keymap.set('n', '<leader>o', "<cmd>Telescope lsp_document_symbols<cr>")
