local navic = require("nvim-navic")
require("lualine").setup(
	{
		sections = {
			lualine_c = {
				{
					function()
						return navic.get_location()
					end,
					cond = function ()
						return navic.is_available()
					end
				}
			},
			lualine_x = {
				{
					'lsp_progress',
					spinner_symbols = { '🌑 ', '🌒 ', '🌓 ', '🌔 ', '🌕 ', '🌖 ', '🌗 ',
						'🌘 ' },
				}
			}
		},
		options = {
			theme = 'gruvbox'
		}
	}
)
