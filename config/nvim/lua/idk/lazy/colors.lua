return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night"	
			})

			vim.cmd.colorscheme("tokyonight")
		end,
	}
	-- {
	-- 	"catppucin/nvim",
	-- 	name = "catppucin",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("catppucin").setup({
	-- 			flavour = "mocha"
	-- 		})
	--
	-- 		vim.cmd.colorscheme("tokyonight")
	-- 	end,
	-- }
}
