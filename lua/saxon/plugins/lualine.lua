return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- Pull colors from the ACTIVE colorscheme's highlight groups so the
    -- statusline re-themes itself whenever the `theme` CLI switches themes.
    local function hl(group, attr)
      local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
      if ok and h and h[attr] then
        return string.format("#%06x", h[attr])
      end
    end
    local function pick(attr, groups, fallback)
      for _, g in ipairs(groups) do
        local v = hl(g, attr)
        if v then
          return v
        end
      end
      return fallback
    end

    local function make_theme()
      -- solid bar bg (themes are transparent, so fall back past Normal)
      local bg = pick("bg", { "StatusLine", "Pmenu", "NormalFloat", "Normal" }, "#1a1b26")
      local fg = pick("fg", { "Normal" }, "#c0caf5")
      local muted = pick("fg", { "Comment" }, "#565f89")
      local inactive_bg = pick("bg", { "CursorLine", "Pmenu" }, "#202330")

      local colors = {
        blue = pick("fg", { "Function", "@function" }, "#7aa2f7"), -- normal
        green = pick("fg", { "String", "@string" }, "#9ece6a"), -- insert
        violet = pick("fg", { "Keyword", "@keyword", "Statement" }, "#bb9af7"), -- visual
        yellow = pick("fg", { "WarningMsg", "@number", "Number" }, "#e0af68"), -- command
        red = pick("fg", { "DiagnosticError", "ErrorMsg", "Error" }, "#f7768e"), -- replace
      }

      local function mode(accent)
        return {
          a = { bg = accent, fg = bg, gui = "bold" },
          b = { bg = bg, fg = fg },
          c = { bg = bg, fg = fg },
        }
      end

      return {
        normal = mode(colors.blue),
        insert = mode(colors.green),
        visual = mode(colors.violet),
        command = mode(colors.yellow),
        replace = mode(colors.red),
        inactive = {
          a = { bg = inactive_bg, fg = muted, gui = "bold" },
          b = { bg = inactive_bg, fg = muted },
          c = { bg = inactive_bg, fg = muted },
        },
      }
    end

    local function setup()
      lualine.setup({
        options = {
          theme = make_theme(),
        },
        sections = {
          lualine_x = {
            {
              lazy_status.updates,
              cond = lazy_status.has_updates,
              color = { fg = "#ff9e64" },
            },
            { "encoding" },
            { "fileformat" },
            { "filetype" },
          },
        },
      })
    end

    setup()

    -- re-theme the statusline whenever the colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        setup()
      end,
    })
  end,
}
