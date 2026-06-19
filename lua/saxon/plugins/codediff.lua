local function pick_branch_diff()
  local branches = vim.fn.systemlist("git branch -r 2>/dev/null")
  local cleaned = {}
  for _, b in ipairs(branches) do
    local name = b:match("^%s*(.-)%s*$")
    if not name:match("HEAD") then
      table.insert(cleaned, name)
    end
  end
  vim.ui.select(cleaned, { prompt = "Diff against branch:" }, function(choice)
    if choice then
      vim.cmd("CodeDiff " .. choice .. "...")
    end
  end)
end

-- The CodeDiff-only fuzzy file finder, bound to <leader>f inside diff buffers.
local DIFF_FIND_KEY = "<leader>f"

-- Absolute paths of the files in the given CodeDiff session's tab.
local function diff_files(tabpage)
  local ok, accessors = pcall(require, "codediff.ui.lifecycle.accessors")
  if not ok then
    return nil
  end

  local ctx = accessors.get_git_context(tabpage)
  if not ctx or not ctx.git_root then
    return nil
  end

  local root = ctx.git_root
  local function git(args)
    local cmd = { "git", "-C", root }
    vim.list_extend(cmd, args)
    local out = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
      return {}
    end
    return out
  end

  local orig, mod = ctx.original_revision, ctx.modified_revision
  local rel
  if orig and mod and mod ~= "WORKING" then
    -- Two-revision diff (e.g. branch vs branch)
    rel = git({ "diff", "--name-only", "-M", orig, mod })
  elseif orig then
    -- Revision vs working tree (e.g. :CodeDiff HEAD~)
    rel = git({ "diff", "--name-only", "-M", orig })
    vim.list_extend(rel, git({ "ls-files", "--others", "--exclude-standard" }))
  else
    -- Working-tree status mode (:CodeDiff)
    rel = git({ "diff", "--name-only", "HEAD" })
    vim.list_extend(rel, git({ "ls-files", "--others", "--exclude-standard" }))
  end

  local seen, files = {}, {}
  for _, p in ipairs(rel) do
    if p ~= "" and not seen[p] then
      seen[p] = true
      table.insert(files, root .. "/" .. p)
    end
  end
  return files, root
end

-- Telescope picker over the diff's files (same UX as <leader>ff, scoped list).
local function find_in_diff_files()
  local tabpage = vim.api.nvim_get_current_tabpage()
  local files, root = diff_files(tabpage)
  if files == nil then
    vim.notify("Not in a CodeDiff session", vim.log.levels.WARN)
    return
  end
  if #files == 0 then
    vim.notify("No changed files in this diff", vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local make_entry = require("telescope.make_entry")
  local opts = { cwd = root }

  pickers
    .new(opts, {
      prompt_title = "Diff files (" .. #files .. ")",
      finder = finders.new_table({
        results = files,
        entry_maker = make_entry.gen_from_file(opts),
      }),
      sorter = conf.file_sorter(opts),
      previewer = conf.file_previewer(opts),
    })
    :find()
end

-- Register <leader>f on all buffers of a CodeDiff session (nowait, so it fires
-- without waiting for the global <leader>ff; only active inside the diff).
local function bind_diff_find(tabpage)
  local ok, accessors = pcall(require, "codediff.ui.lifecycle.accessors")
  if not ok then
    return
  end
  accessors.set_tab_keymap(tabpage, "n", DIFF_FIND_KEY, find_in_diff_files, { desc = "Fuzzy find diff files" })
end

local function setup_diff_find_autocmds()
  local group = vim.api.nvim_create_augroup("CodeDiffFuzzyFind", { clear = true })

  -- Bind when a diff opens and re-bind when a file is selected (new buffers).
  for _, event in ipairs({ "CodeDiffOpen", "CodeDiffFileSelect" }) do
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = event,
      callback = function(args)
        local tabpage = args.data and args.data.tabpage
        if tabpage then
          bind_diff_find(tabpage)
        end
      end,
    })
  end

  -- Clean up the buffer-local keymap before the session is torn down, so it
  -- doesn't linger on real file buffers reused elsewhere.
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeDiffClose",
    callback = function(args)
      local tabpage = args.data and args.data.tabpage
      if not tabpage then
        return
      end
      local ok, accessors = pcall(require, "codediff.ui.lifecycle.accessors")
      if not ok then
        return
      end
      local sess = accessors.get_session(tabpage)
      if sess and sess.keymap_buffers then
        for bufnr, _ in pairs(sess.keymap_buffers) do
          if vim.api.nvim_buf_is_valid(bufnr) then
            pcall(vim.keymap.del, "n", DIFF_FIND_KEY, { buffer = bufnr })
          end
        end
      end
    end,
  })
end

return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  init = setup_diff_find_autocmds,
  keys = {
    { "<leader>gp", pick_branch_diff,                desc = "PR diff vs branch" },
    { "<leader>gg", "<cmd>CodeDiff main...<CR>",      desc = "Diff against main" },
    { "<leader>gj", "<cmd>CodeDiff HEAD~<CR>",        desc = "Diff against previous commit" },
    { "<leader>gd", "<cmd>CodeDiff<CR>",             desc = "Diff working tree" },
    { "<leader>gh", "<cmd>CodeDiff history<CR>",     desc = "Git commit history" },
  },
  opts = {
    diff = {
      layout = "inline",
      jump_to_first_change = true,
    },
  },
}
