return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim"
	},
	config = function ()
		require("telescope").setup({})

		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>sf', builtin.find_files, {})
		vim.keymap.set('n', '<C-p>', builtin.git_files, {})
		vim.keymap.set('n', '<leader>sg', builtin.live_grep, {})
		vim.keymap.set('n', '<leader>sb', builtin.buffers, {})
		vim.keymap.set('n', '<leader>sh', builtin.help_tags, {})
	end
}
