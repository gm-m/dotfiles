return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        dependencies = {'nvim-lua/plenary.nvim'}
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    {
	    "jake-stewart/multicursor.nvim",
	    branch = "1.0",
	    config = function()
		    local mc = require("multicursor-nvim")
		    mc.setup()

		    local set = vim.keymap.set

		    -- Add or skip cursor above/below the main cursor.
		    set({"n", "x"}, "<up>", function() mc.lineAddCursor(-1) end)
		    set({"n", "x"}, "<down>", function() mc.lineAddCursor(1) end)
		    set({"n", "x"}, "<leader><up>", function() mc.lineSkipCursor(-1) end)
		    set({"n", "x"}, "<leader><down>", function() mc.lineSkipCursor(1) end)

		    -- Add or skip adding a new cursor by matching word/selection
		    set({"n", "x"}, "<leader>n", function() mc.matchAddCursor(1) end)
		    set({"n", "x"}, "<leader>s", function() mc.matchSkipCursor(1) end)
		    set({"n", "x"}, "<leader>N", function() mc.matchAddCursor(-1) end)
		    set({"n", "x"}, "<leader>S", function() mc.matchSkipCursor(-1) end)

		    -- Add and remove cursors with control + left click.
		    set("n", "<c-leftmouse>", mc.handleMouse)
		    set("n", "<c-leftdrag>", mc.handleMouseDrag)
		    set("n", "<c-leftrelease>", mc.handleMouseRelease)

		    -- Disable and enable cursors.
		    set({"n", "x"}, "<c-q>", mc.toggleCursor)

		    -- Pressing `gaip` will add a cursor on each line of a paragraph.
		    set("n", "ga", mc.addCursorOperator)

		    -- Split visual selections by regex.
		    set("x", "S", mc.splitCursors)

		    -- Mappings defined in a keymap layer only apply when there are
		    -- multiple cursors. This lets you have overlapping mappings.
		    mc.addKeymapLayer(function(layerSet)

			    -- Select a different cursor as the main one.
			    layerSet({"n", "x"}, "<left>", mc.prevCursor)
			    layerSet({"n", "x"}, "<right>", mc.nextCursor)

			    -- Delete the main cursor.
			    layerSet({"n", "x"}, "<leader>x", mc.deleteCursor)

			    -- Enable and clear cursors using escape.
			    layerSet("n", "<esc>", function()
				    if not mc.cursorsEnabled() then
					    mc.enableCursors()
				    else
					    mc.clearCursors()
				    end
			    end)
		    end)

		    -- Customize how cursors look.
		    local hl = vim.api.nvim_set_hl
		    hl(0, "MultiCursorCursor", { reverse = true })
		    hl(0, "MultiCursorVisual", { link = "Visual" })
		    hl(0, "MultiCursorSign", { link = "SignColumn"})
		    hl(0, "MultiCursorMatchPreview", { link = "Search" })
		    hl(0, "MultiCursorDisabledCursor", { reverse = true })
		    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
		    hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
	    end
    },
    -- File Explorer
    {
	    'stevearc/oil.nvim',
	    ---@module 'oil'
	    ---@type oil.SetupOpts
	    opts = {},
	    -- Optional dependencies
	    dependencies = { { "echasnovski/mini.icons", opts = {} } },
	    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	    lazy = false,
    },
    -- Autoclose brackets
    {
        "echasnovski/mini.pairs",
	version = '*',
	config = function() require("mini.pairs").setup() end
    },
    -- Add extra text objects like daa / caa etc...
    {
        "echasnovski/mini.ai",
	version = '*',
	config = function() require("mini.ai").setup() end
    },
    -- Colorscheme
    {
	    "webhooked/kanso.nvim",
	    lazy = false,
	    priority = 1000,
    },
    {
        "rose-pine/neovim"
    },
    -- LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        }
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        }
    },
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    },
}
