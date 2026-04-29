return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      char = { enabled = false },
    },
  },
  keys = {
    -- s remapped here; substitute.lua uses gs instead (see substitude.lua)
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
  },
}
