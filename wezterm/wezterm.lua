local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()
-- Define the modifier keys based on OS - changed to just CTRL for Windows
local mod = wezterm.target_triple:find("windows") and "SHIFT|CTRL" or "SHIFT|SUPER"

-- Helper function to check if we're in nvim
local function is_nvim(pane)
  return pane:get_user_vars().IS_NVIM == "true" or pane:get_foreground_process_name():find("n?vim") or pane:get_foreground_process_name():find("node") 
end

-- Define split navigation function
local function create_split_nav(resize_or_move, mods, key, dir)
  local event = "SplitNav_" .. resize_or_move .. "_" .. dir
  wezterm.on(event, function(win, pane)
    if is_nvim(pane) then
      -- pass the keys through to vim/nvim
      win:perform_action({ SendKey = { key = key, mods = mods } }, pane)
    else
      if resize_or_move == "resize" then
        win:perform_action({ AdjustPaneSize = { dir, 3 } }, pane)
      else
        local panes = pane:tab():panes_with_info()
        local is_zoomed = false
        for _, p in ipairs(panes) do
          if p.is_zoomed then
            is_zoomed = true
          end
        end
        if is_zoomed then
          dir = dir == "Up" or dir == "Right" and "Next" or "Prev"
        end
        win:perform_action({ ActivatePaneDirection = dir }, pane)
        win:perform_action({ SetPaneZoomState = is_zoomed }, pane)
      end
    end
  end)
  return {
    key = key,
    mods = mods,
    action = wezterm.action.EmitEvent(event),
  }
end

-- Smart split function
local smart_split = wezterm.action_callback(function(window, pane)
  local dim = pane:get_dimensions()
  if dim.pixel_height > dim.pixel_width then
    window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
  else
    window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
  end
end)

-- Configure the settings
-- config.disable_default_key_bindings = true
config.keys = {
  -- Scrollback
  { mods = mod, key = "k", action = act.ScrollByPage(-0.5) },
  { mods = mod, key = "j", action = act.ScrollByPage(0.5) },
  -- New Tab
  { mods = mod, key = "t", action = act.SpawnTab("CurrentPaneDomain") },
  -- Splits
  { mods = mod, key = "Enter", action = smart_split },
  { mods = mod, key = "|", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { mods = mod, key = "_", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { mods = mod, key = "(", action = act.DecreaseFontSize },
  { mods = mod, key = ")", action = act.IncreaseFontSize },
  -- Move Tabs
  { mods = mod, key = ">", action = act.MoveTabRelative(1) },
  { mods = mod, key = "<", action = act.MoveTabRelative(-1) },
  -- Activate Tabs
  { mods = mod, key = "l", action = act({ ActivateTabRelative = 1 }) },
  { mods = mod, key = "h", action = act({ ActivateTabRelative = -1 }) },
  { mods = mod, key = "R", action = wezterm.action.RotatePanes("Clockwise") },
  -- Pane selection
  { mods = mod, key = "S", action = wezterm.action.PaneSelect({}) },
  -- Clipboard
  { mods = mod, key = "c", action = act.CopyTo("Clipboard") },
  { mods = mod, key = "Space", action = act.QuickSelect },
  { mods = mod, key = "X", action = act.ActivateCopyMode },
  { mods = mod, key = "f", action = act.Search("CurrentSelectionOrEmptyString") },
  { mods = mod, key = "v", action = act.PasteFrom("Clipboard") },
  {
    mods = mod,
    key = "u",
    action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
  },
  { mods = mod, key = "m", action = act.TogglePaneZoomState },
  { mods = mod, key = "p", action = act.ActivateCommandPalette },
  { mods = mod, key = "d", action = act.ShowDebugOverlay },
  -- Navigation
  create_split_nav("resize", "CTRL", "LeftArrow", "Right"),
  create_split_nav("resize", "CTRL", "RightArrow", "Left"),
  create_split_nav("resize", "CTRL", "UpArrow", "Up"),
  create_split_nav("resize", "CTRL", "DownArrow", "Down"),
  create_split_nav("move", "CTRL", "h", "Left"),
  -- create_split_nav("move", "CTRL", "j", "Down"), -- Conflicting with fzf
  -- create_split_nav("move", "CTRL", "k", "Up"), -- Conflicting with fzf
  create_split_nav("move", "CTRL", "l", "Right"),
}

-- Set PoweShell 7 as the default shell
config.default_prog = { 'pwsh.exe', '-NoLogo' }

-- Color scheme
config.color_scheme = 'rose-pine'

-- Font
-- config.font = wezterm.font('JetBrains Mono')
config.font = wezterm.font('TX-02')

-- Cursor
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 650
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- Window
config.window_close_confirmation = "NeverPrompt"
config.window_padding = {
  -- left = 0,
  right = 0,
  -- top = 0,
  bottom = 0,
}

return config
