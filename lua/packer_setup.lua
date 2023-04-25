local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()
return require("packer").startup({
	function(use)
		use "wbthomason/packer.nvim"
		-- official lsp config
		use "neovim/nvim-lspconfig"
		-- color theme
		use "ellisonleao/gruvbox.nvim"

		-- update lsp client capability
		use "hrsh7th/cmp-nvim-lsp"
		-- source for complete
		use "hrsh7th/cmp-buffer"
		use "hrsh7th/cmp-path"
		use "hrsh7th/cmp-cmdline"
		-- for snip template and expand snip
		use "L3MON4D3/LuaSnip"
		use "rafamadriz/friendly-snippets"
		-- better icon
		use "onsails/lspkind.nvim"

		-- complete engine
		use "hrsh7th/nvim-cmp"
		use {
			"kyazdani42/nvim-tree.lua",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("nvim-tree").setup {
					git = {
						enable = false
					}

				}
				vim.api.nvim_set_keymap('n', '<A-m>', ':NvimTreeToggle<CR>',
				{ noremap = true, silent = true })
			end
		}

		use { 'akinsho/bufferline.nvim',
			tag = "v3.*",
			requires = 'nvim-tree/nvim-web-devicons',
			config = function()
				require("bufferline").setup({
					options = {
						diagnostics = "nvim_lsp",
						diagnostics_indicator = function(count, level, _, _)
							local icon = level:match("error") and " " or " "
							return " " .. icon .. count
						end,
						diagnostics_update_in_insert = true,
						offsets = { {
							filetype = "NvimTree",
							text = "File Explorer",
							highlight = "Directory",
							text_align = "left"
						} },
						custom_filter = function(buf_num)
							return vim.bo[buf_num].filetype ~= 'qf'
						end
					}
				})
				vim.api.nvim_set_keymap('n', '<A-left>', ':BufferLineCyclePrev<CR>',
				{ noremap = true, silent = true })
				vim.api.nvim_set_keymap('n', '<A-right>', ':BufferLineCycleNext<CR>',
				{ noremap = true, silent = true })
			end
		}

		-- treesitter auto install
		use { "nvim-treesitter/nvim-treesitter",

			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = { "c", "lua", "rust", "python", "toml", "json" },
				})
			end
		}

		-- auto pair () {} []
		use {
			"windwp/nvim-autopairs",
			config = function()
				require("nvim-autopairs").setup {

				}
				local npairs = require("nvim-autopairs")
				local Rule = require('nvim-autopairs.rule')

				npairs.setup({
					check_ts = true,
					ts_config = {
						lua = { 'string' }, -- it will not add a pair on that treesitter node
						javascript = { 'template_string' },
					}
				})

				local ts_conds = require('nvim-autopairs.ts-conds')
				npairs.add_rules({
					-- press % => %% only while inside a comment or string
					Rule("%", "%", "lua")
					    :with_pair(ts_conds.is_ts_node({ 'string', 'comment' })),
					Rule("$", "$", "lua")
					    :with_pair(ts_conds.is_not_ts_node({ 'function' }))
				})
			end
		}

		use {
			'nvim-lualine/lualine.nvim',
			requires = { 'kyazdani42/nvim-web-devicons', opt = true }
		}

		use {
			"SmiteshP/nvim-navic",
			requires = "neovim/nvim-lspconfig"
		}

		use {
			"nvim-telescope/telescope.nvim",
			requires = {
				{ "nvim-telescope/telescope-live-grep-args.nvim" },
			},
			config = function()
				require("telescope").load_extension("live_grep_args")
			end
		}

		use {
			'saecki/crates.nvim',
			tag = 'v0.3.0',
			requires = { 'nvim-lua/plenary.nvim' },
			config = function()
				require('crates').setup()
			end,
		}

		use {
			'WhoIsSethDaniel/lualine-lsp-progress.nvim'
		}
		use {
			'lewis6991/gitsigns.nvim',
			config = function()
				require('gitsigns').setup({
					current_line_blame = true,
					on_attach = function(bufnr)
						local gs = package.loaded.gitsigns

						local function map(mode, l, r, opts)
							opts = opts or {}
							opts.buffer = bufnr
							vim.keymap.set(mode, l, r, opts)
						end

						-- Navigation
						map('n', ']c', function()
							if vim.wo.diff then return ']c' end
							vim.schedule(function() gs.next_hunk() end)
							return '<Ignore>'
						end, { expr = true })

						map('n', '[c', function()
							if vim.wo.diff then return '[c' end
							vim.schedule(function() gs.prev_hunk() end)
							return '<Ignore>'
						end, { expr = true })

						-- Actions
						map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
						map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
						map('n', '<leader>hS', gs.stage_buffer)
						map('n', '<leader>hu', gs.undo_stage_hunk)
						map('n', '<leader>hR', gs.reset_buffer)
						map('n', '<leader>hp', gs.preview_hunk)
						map('n', '<leader>hb', function() gs.blame_line { full = true } end)
						map('n', '<leader>tb', gs.toggle_current_line_blame)
						map('n', '<leader>hd', gs.diffthis)
						map('n', '<leader>hD', function() gs.diffthis('~') end)
						map('n', '<leader>td', gs.toggle_deleted)

						-- Text object
						map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
					end
				})
			end
		}


		if packer_bootstrap then
			require("packer").sync()
		end
	end,
	config = {
		display = {
			open_fn = require("packer.util").float,
		}
	}
})
