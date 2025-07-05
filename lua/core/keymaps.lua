local opts = {
    noremap = true,
    silent = true
}

-- Move current line up and down
vim.keymap.set('n', '<A-down>', ':m .+1<CR>==', opts)
vim.keymap.set('n', '<A-up>', ':m .-2<CR>==', opts)

-- Move current visual-line selection up and down
vim.keymap.set('v', '<A-down>', ":m '>+1<CR>gv=gv", opts)
vim.keymap.set('v', '<A-up>', ":m '<-2<CR>gv=gv", opts)

-- Remap p in visual mode to paste, reselect, and yank
vim.keymap.set('x', 'p', 'p`[v`]y', {
    noremap = true,
    silent = true,
    desc = 'Paste and keep in register'
})

-- Telescope mappings
local map = vim.api.nvim_set_keymap
map('n', '<leader>f', ':Telescope find_files<CR>', opts)
map('n', '<leader>F', ':Telescope live_grep<CR>', opts)
-- map('n', '<leader>fs', ':Telescope lsp_workspace_symbols<CR>', opts)  -- search symbols
map('n', '<leader>s', ':Telescope lsp_document_symbols<CR>', opts) -- document symbols
map('n', '<leader>.', ':Telescope buffers<CR>', opts) -- list all buffers

-- File Explorer mappings
-- map('n', '<leader>e', ':Ex<CR>', opts)
map('n', '<leader>e', '<cmd>Oil<CR>', opts)

-- Other mappings
map('n', '<C-_>', ':normal gcc<CR><DOWN>', opts) -- toggle comment line (INFO: Most terminals send the same key code for <C-/> and <C-_>.)
map('v', '<C-_>', ":'<,'>normal gcc<CR>", opts) -- toggle comment selection (INFO: Most terminals send the same key code for <C-/> and <C-_>.)
map('n', '<leader>r', ':earlier 1f<CR>', opts) -- revert file
map('n', '<C-w>', ':bd<CR>', opts) -- close file
map('n', '<C-s>', '<cmd>w<CR>', opts) -- save file
map('n', '<C-right>', ':bnext<CR>', opts) -- go to the next buffer
map('n', '<C-left>', ':bprevious<CR>', opts) -- go to previous buffer
map('n', '<Esc>', '<cmd>noh<CR>', opts) -- clear highlights
map('n', '<C-h>', '<C-w>h', opts) -- switch window left
map('n', '<C-l>', '<C-w>l', opts) -- switch window right
map('n', '<C-j>', '<C-w>j', opts) -- switch window down
map('n', '<C-k>', '<C-w>k', opts) -- switch window up

-- Diagnostic navigation
vim.keymap.set('n', '<A-j>', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<A-k>', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })

-- Harpoon mappings
local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>a", function()
    harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end)

-- vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
-- vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
-- vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
-- vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list. 
-- {ui_nav_wrap = true} Allows cycling through the items in the list. 
-- When reaching the end of the list, it wraps around to the first item.
-- Conversely, if at the first item and using 'prev', it goes to the last item.
vim.keymap.set("n", "<C-S-P>", function()
    harpoon:list():prev({
        ui_nav_wrap = true
    })
end)
vim.keymap.set("n", "<leader>t", function()
    harpoon:list():next({
        ui_nav_wrap = true
    })
end)
