-- Diagnostic configuration (for "Error Lens" effect)
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        source = 'if_many',
        spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

vim.opt.completeopt = "menu,menuone,noselect,popup"
vim.o.autocomplete = true

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
    callback = function(args)
        local client_id = args.data and args.data.client_id or nil
        if not client_id then
            return
        end

        local client = vim.lsp.get_client_by_id(client_id)
        if not client then
            return
        end

        local bufnr = args.buf
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = true })
        end

        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<leader>=', function()
            vim.lsp.buf.format({ async = true })
        end, bufopts)

        local ft = vim.bo[bufnr].filetype
        if ft == 'javascript' or ft == 'javascriptreact' or ft == 'typescript' or ft == 'typescriptreact' then
            vim.keymap.set('n', '<leader>to', '<cmd>TSToolsOrganizeImports<CR>', bufopts)
            vim.keymap.set('n', '<leader>ta', '<cmd>TSToolsAddMissingImports<CR>', bufopts)
            vim.keymap.set('n', '<leader>tr', '<cmd>TSToolsRemoveUnusedImports<CR>', bufopts)
        end
    end,
})

-- Setup TypeScript Tools
require("typescript-tools").setup({
})
