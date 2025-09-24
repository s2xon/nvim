return {
  "folke/tokyonight.nvim",
  name = "tokyonight",
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },

      -- ⬇️ make the tab/buffer line blend with the wallpaper
      on_highlights = function(hl)
        -- built-in tabline
        hl.TabLine = { bg = "none" }
        hl.TabLineSel = { bg = "none" }
        hl.TabLineFill = { bg = "none" }

        -- bufferline.nvim (safe to leave in even if you don’t use it)
        hl.BufferLineFill = { bg = "none" }
        hl.BufferLineBackground = { bg = "none" }
        hl.BufferLineTabSelected = { bg = "none" }
      end,
    })

    vim.cmd.colorscheme("tokyonight")
  end,
}
