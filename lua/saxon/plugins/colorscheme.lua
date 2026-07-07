-- Colorscheme switching is driven by the `theme` CLI.
-- It writes the active theme name to lua/saxon/theme.lua (`return "<name>"`),
-- and this file maps that name to a plugin + setup + :colorscheme.
--
-- To add a theme:
--   1) add its plugin spec to `plugins` (keyed by provider/plugin name)
--   2) point `provider[<theme>]` at that provider name
--   3) (optional) `scheme_of[<theme>]` if the :colorscheme name differs
--   4) (optional) `setups[<theme>]` for plugin-specific options
--   5) (optional) add to `transparent` to let the wallpaper show through
--   6) register the theme in ~/.config/theme/themes.json (ghostty name + wallpaper)

local ok, active = pcall(require, "saxon.theme")
if not ok or type(active) ~= "string" then
  active = "tokyonight"
end

-- theme name -> plugin (provider) that supplies it
local provider = {
  tokyonight = "tokyonight",
  aura = "aura-theme",
  ["catppuccin-mocha"] = "catppuccin",
}

-- theme name -> :colorscheme to run (defaults to the theme name)
-- expo/lilac are pluginless ports living in ~/.config/nvim/colors/<name>.lua
local scheme_of = {
  tokyonight = "tokyonight",
  aura = "aura-dark",
  expo = "expo",
  lilac = "lilac",
  ["catppuccin-mocha"] = "catppuccin-mocha",
}

-- Themes we force-transparent so the wallpaper shows through.
-- Only do this for themes DESIGNED for it (tokyonight handles its own via
-- setup; our expo/lilac ports bake bg=NONE into their colors files). Plugin
-- themes like aura set backgrounds on 100+ groups, so force-clearing a handful
-- leaves a patchwork of solid stripes/patches — let those render solid instead.
local transparent = {}

-- theme name -> setup run before :colorscheme (plugin-specific options)
local setups = {
  tokyonight = function()
    vim.o.background = "dark"
    require("tokyonight").setup({
      style = "night",
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
      -- keep the tab/buffer line blending with the wallpaper
      on_highlights = function(hl)
        hl.TabLine = { bg = "none" }
        hl.TabLineSel = { bg = "none" }
        hl.TabLineFill = { bg = "none" }
        hl.BufferLineFill = { bg = "none" }
        hl.BufferLineBackground = { bg = "none" }
        hl.BufferLineTabSelected = { bg = "none" }
      end,
    })
  end,
  aura = function()
    vim.o.background = "dark"
    -- Aura's neovim colorschemes live in a subpackage of the repo
    vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/aura-theme/packages/neovim")
  end,
  ["catppuccin-mocha"] = function()
    vim.o.background = "dark"
    require("catppuccin").setup({
      flavour = "mocha",
      -- native transparency handles all groups cleanly, so we let the
      -- wallpaper show through without the crude force-clear pass
      transparent_background = true,
      -- keep the tab/buffer line blending with the wallpaper
      custom_highlights = function()
        return {
          TabLine = { bg = "NONE" },
          TabLineSel = { bg = "NONE" },
          TabLineFill = { bg = "NONE" },
          BufferLineFill = { bg = "NONE" },
          BufferLineBackground = { bg = "NONE" },
          BufferLineTabSelected = { bg = "NONE" },
        }
      end,
    })
  end,
}

-- every colorscheme plugin spec, keyed by provider name
local plugins = {
  tokyonight = { "folke/tokyonight.nvim", name = "tokyonight" },
  ["aura-theme"] = { "daltonmenezes/aura-theme", name = "aura-theme" },
  catppuccin = { "catppuccin/nvim", name = "catppuccin" },
}

-- groups whose background we clear when a theme opts into transparency
local TRANSPARENT_GROUPS = {
  "Normal", "NormalNC", "NormalFloat", "SignColumn", "LineNr", "FoldColumn",
  "CursorLineNr", "EndOfBuffer", "StatusLine", "StatusLineNC",
  "TabLine", "TabLineFill", "TabLineSel", "TelescopeNormal",
  "NvimTreeNormal", "NeoTreeNormal", "WinBar", "WinBarNC",
}

local function make_transparent()
  for _, name in ipairs(TRANSPARENT_GROUPS) do
    local okh, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    h = okh and h or {}
    h.bg = "NONE"
    h.ctermbg = "NONE"
    h.link = nil
    pcall(vim.api.nvim_set_hl, 0, name, h)
  end
end

local function apply(name)
  name = name or active
  local setup = setups[name]
  if setup then
    pcall(setup)
  end
  pcall(vim.cmd.colorscheme, scheme_of[name] or name)
  if transparent[name] then
    make_transparent()
  end
end

-- :ThemeReload — re-read the active theme file and apply it live.
-- Ensures the target plugin is loaded first (in case it was lazy).
vim.api.nvim_create_user_command("ThemeReload", function()
  package.loaded["saxon.theme"] = nil
  local okr, name = pcall(require, "saxon.theme")
  if not okr or type(name) ~= "string" then
    name = "tokyonight"
  end
  local prov = provider[name] or name
  pcall(function()
    require("lazy").load({ plugins = { prov } })
  end)
  apply(name)
  vim.notify("theme: " .. name, vim.log.levels.INFO)
end, { desc = "Re-apply the active theme set by the `theme` CLI" })

-- Build specs: the active theme's plugin loads at startup and applies it;
-- the others install but stay lazy so `theme <name>` + :ThemeReload works.
local active_provider = provider[active]
local specs = {}
for pname, spec in pairs(plugins) do
  spec = vim.deepcopy(spec)
  if pname == active_provider then
    spec.lazy = false
    spec.priority = 1000
    spec.config = function()
      apply(active)
    end
  else
    spec.lazy = true
  end
  table.insert(specs, spec)
end

-- Pluginless themes (a colors/<name>.lua file, e.g. expo/lilac) have no plugin
-- to hang config on. Apply immediately at import — the colors/ dir is always on
-- the runtimepath, and this runs before plugins like lualine load, so they read
-- the right colors at setup (core/options.lua already set termguicolors).
if not active_provider then
  apply(active)
end

return specs
