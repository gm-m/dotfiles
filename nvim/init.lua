require("config.lazy")
local has_ui2, ui2 = pcall(require, "vim._core.ui2")
if has_ui2 then
    ui2.enable({})
end
require("config.lsp")

require("core.options")
require("core.keymaps")
