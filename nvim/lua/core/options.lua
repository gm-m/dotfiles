-- Setup basic line number(assuming normal mode it's enabled at startup)
vim.opt.relativenumber = true
vim.opt.number = true

-- Allows copying from neovim to system clipboard
vim.opt.clipboard = "unnamedplus"

-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Setup autocommands to toggle between absolute line numbers(insert mode) and relative numbers
vim.api.nvim_create_autocmd({"ModeChanged"}, {
    pattern = {"*:n", "n:*"},
    callback = function()
        local in_insert_mode = vim.fn.mode() == "i"
        vim.opt.relativenumber = not in_insert_mode
        -- vim.opt.number = true  -- Keep number always enabled
    end
})

-- enable timeout for key sequences
vim.opt.timeout = true        
-- wait 200 ms (default is 1000 ms). Useful for keymaps with multiple mappings that start with the same key (e.g. <leader>f and <leader>ff ) 
vim.opt.timeoutlen = 200      

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- Colorscheme / Theme
vim.cmd('colorscheme habamax')
-- vim.cmd('colorscheme rose-pine-main')
-- vim.cmd('colorscheme kanso-zen')
