-- Setup basic line number(assuming normal mode it's enabled at startup)
vim.opt.relativenumber = true
vim.opt.number = true

-- Allows copying from neovim to system clipboard
vim.api.nvim_set_option("clipboard", "unnamed")

-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true

-- Setup autocommands to toggle between absolute line numbers(insert mode) and relative numbers
vim.api.nvim_create_autocmd({"ModeChanged"}, {
    pattern = {"*:n", "n:*"},
    callback = function()
        local in_insert_mode = vim.fn.mode() == "i"
        vim.opt.relativenumber = not in_insert_mode
        -- vim.opt.number = true  -- Keep number always enabled
    end
})

-- Colorscheme / Theme
-- vim.cmd('colorscheme rose-pine-main')
vim.cmd('colorscheme kanso-zen')
