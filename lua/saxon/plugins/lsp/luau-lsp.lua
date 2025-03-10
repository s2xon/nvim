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
    types = {
      roblox_security_level = "PluginSecurity",
      definition_files = { "~/Downloads/Types.d.luau" },
    },
    sourcemap = {
      enabled = true,
      autogenerate = true, -- automatic generation when the server is attached
      rojo_project_file = "default.project.json",
      sourcemap_file = "sourcemap.json",
    },
    plugin = {
      enabled = true,
      port = 3667,
    },
    server = {
      settings = {
        -- https://github.com/folke/neoconf.nvim/blob/main/schemas/luau_lsp.json
        ["luau-lsp"] = {
          completion = {
            imports = {
              enabled = true, -- enable auto imports
            },
          },
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
