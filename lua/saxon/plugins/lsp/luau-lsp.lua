local function rojo_project()
  return vim.fs.root(0, function(name)
    return name:match(".+%.project%.json$")
  end)
end

return {
  "lopi-py/luau-lsp.nvim",
  opts = {
    platform = {
      type = rojo_project() and "roblox" or "standard",
    },
    fflags = {
      enable_new_solver = true,
      sync = true,
      DebugLuauForceStrictMode = false,
      override = {
        LuauTableTypeMaximumStringifierLength = "0",
      },
    },
    types = {},

    sourcemap = {
      enabled = true,
      autogenerate = true,
      rojo_project_file = "default.project.json",
      sourcemap_file = "sourcemap.json",
    },

    plugin = {
      enabled = true,
      port = 3667,
    },

    -- ✅ modern replacement for `server.settings`
    lsp = {
      config = {
        ["luau-lsp"] = {
          completion = {
            imports = { enabled = true },
          },
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
