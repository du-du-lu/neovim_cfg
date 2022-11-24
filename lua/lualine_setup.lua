local navic = require("nvim-navic")
require("lualine").setup(
	{
		sections = {
			lualine_c = {
				{ navic.get_location, cond = navic.is_available }
			},
			lualine_x = {
				{
					'lsp_progress',
					spinner_symbols = { '🌑 ', '🌒 ', '🌓 ', '🌔 ', '🌕 ', '🌖 ', '🌗 ', '🌘 ' },
				}
			}
		},
		options = {
			theme = 'gruvbox'
		}
	}
)
