-- Install https://github.com/BurntSushi/ripgrep to use 'builtin.curator.rg'
-- Install https://www.nerdfonts.com/ to use 'builtin.renderer.nerdfont'
-- Install https://github.com/thinca/vim-qfreplace to use 'Qfreplace'
-- Install https://github.com/lambdalisue/vim-lese-mr (and vim-mr) to use the
-- mru, mrw, mrr and mrd pickers

local builtin = require("lese.builtin")
local std = require("lese.std")

local SEPARATOR = package.config:sub(1, 1)

local function merge(...)
  local out = {}
  for _, actions in ipairs({ ... }) do
    for name, action in pairs(actions) do
      out[name] = action
    end
  end
  return out
end

local my_path_actions = merge(
  builtin.action.default_open_actions,
  builtin.action.default_systemopen_actions,
  builtin.action.default_cd_actions
)

local my_quickfix_actions = merge(builtin.action.default_quickfix_actions, {
  ["quickfix:qfreplace"] = builtin.action.quickfix({ after = "Qfreplace" }),
})

local my_misc_actions = merge(
  builtin.action.default_echo_actions,
  builtin.action.default_yank_actions,
  builtin.action.default_submatch_actions
)

local EXCLUDED_FILES = {
  ".7z", ".DS_Store", ".avi", ".bmp", ".class", ".dll", ".dmg", ".doc",
  ".docx", ".dylib", ".ear", ".exe", ".fla", ".flac", ".flv", ".gif", ".ico",
  ".id_ed25519", ".id_rsa", ".iso", ".jar", ".jpeg", ".jpg", ".key", ".mkv",
  ".mov", ".mp3", ".mp4", ".mpeg", ".mpg", ".o", ".obj", ".ogg", ".pdf",
  ".png", ".ppt", ".pptx", ".rar", ".so", ".swf", ".tar.gz", ".war", ".wav",
  ".webm", ".wma", ".wmv", ".xls", ".xlsx", ".zip", "id_ed25519", "id_rsa",
}

local EXCLUDED_DIRECTORIES = {
  "$RECYCLE.BIN", ".cache", ".git", ".hg", ".ssh", ".svn",
  "__pycache__", -- Python
  "build", -- C/C++
  "node_modules", -- Node.js
  "target", -- Rust
  ".coverage",
  "nvim" .. SEPARATOR .. "pack",
  "zsh" .. SEPARATOR .. ".addons",
}

local function ends_with(s, suffix)
  return suffix == "" or s:sub(-#suffix) == suffix
end

local function my_filter_file(path)
  for _, excluded in ipairs(EXCLUDED_FILES) do
    if ends_with(path, excluded) then
      return false
    end
  end
  return true
end

local function my_filter_directory(path)
  for _, excluded in ipairs(EXCLUDED_DIRECTORIES) do
    if ends_with(path, SEPARATOR .. excluded) then
      return false
    end
  end
  return true
end

local function path_list(paths)
  local items = {}
  for i, path in ipairs(paths) do
    items[i] = {
      id = "path:" .. path,
      value = path,
      detail = { path = vim.fn.expand(path) },
    }
  end
  return builtin.source.list(items)
end

local mac_skk_source = path_list({
  "~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries",
  "~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/skk-jisyo.utf8",
})

local claude_source = path_list({
  "./CLAUDE.md",
  "./claude/settings.json",
  "./claude/settings.local.json",
  "~/.claude/CLAUDE.md",
  "~/.claude/settings.json",
  "~/Library/Application Support/cage/presets.yaml",
})

local function sorters()
  return {
    builtin.sorter.noop(),
    builtin.sorter.lexical(),
    builtin.sorter.lexical({ reverse = true }),
  }
end

local function path_renderers()
  return {
    std.compose_renderers(builtin.renderer.smart_path(), builtin.renderer.nerdfont()),
    builtin.renderer.nerdfont(),
    builtin.renderer.noop(),
  }
end

local function project_file_source()
  return builtin.source.file({
    filter_file = my_filter_file,
    filter_directory = my_filter_directory,
    relative_from_base = true,
  })
end

---@param x lese.Entrypoint
local function define_mr_pickers(x)
  local ok, mr = pcall(require, "lese-mr")
  if not ok then
    return
  end
  local cd_and_open = std.compose_actions(builtin.action.cd(), builtin.action.open())

  x.define_picker_from_source("mru", mr.source.mr(), {
    matchers = { builtin.matcher.fzf() },
    sorters = sorters(),
    renderers = path_renderers(),
    previewers = { builtin.previewer.file() },
    actions = merge(
      my_path_actions,
      my_quickfix_actions,
      my_misc_actions,
      mr.action.default_mr_delete_actions
    ),
    default_action = "open",
  })

  x.define_picker_from_source(
    "mrw",
    std.refine_source(
      mr.source.mr({ type = "mrw" }),
      builtin.refiner.cwd(),
      builtin.refiner.relative_path()
    ),
    {
      matchers = { builtin.matcher.fzf() },
      sorters = sorters(),
      renderers = path_renderers(),
      previewers = { builtin.previewer.file() },
      actions = merge(
        my_path_actions,
        my_quickfix_actions,
        my_misc_actions,
        mr.action.default_mr_delete_actions
      ),
      default_action = "open",
    }
  )

  for _, type in ipairs({ "mrr", "mrd" }) do
    x.define_picker_from_source(type, mr.source.mr({ type = type }), {
      matchers = { builtin.matcher.fzf() },
      renderers = path_renderers(),
      actions = merge(
        my_path_actions,
        my_quickfix_actions,
        my_misc_actions,
        mr.action.default_mr_delete_actions,
        { ["cd-and-open"] = cd_and_open }
      ),
      default_action = "cd-and-open",
      coordinator = builtin.coordinator.modern({ hide_preview = true }),
    })
  end
end

---@param x lese.Entrypoint
return function(x)
  x.refine_setting({
    coordinator = builtin.coordinator.modern({
      width_ratio = 0.9,
      height_ratio = 0.8,
    }),
    theme = builtin.theme.MODERN,
  })

  for _, picker in ipairs({
    { "grep", builtin.curator.grep() },
    { "git-grep", builtin.curator.git_grep() },
    { "rg", builtin.curator.rg({ no_ignore_dot = true }) },
  }) do
    x.define_picker_from_curator(
      picker[1],
      std.refine_curator(picker[2], builtin.refiner.relative_path()),
      {
        sorters = sorters(),
        renderers = { builtin.renderer.nerdfont(), builtin.renderer.noop() },
        previewers = { builtin.previewer.file() },
        actions = merge(my_path_actions, my_quickfix_actions, my_misc_actions),
        default_action = "open",
      }
    )
  end

  define_mr_pickers(x)

  x.define_picker_from_source(
    "config",
    std.refine_source(
      std.compose_sources(
        std.bind_source_args(project_file_source(), { "~/ghq/github.com/lambdalisue/dotfiles" }),
        mac_skk_source,
        claude_source
      ),
      builtin.refiner.relative_path()
    ),
    {
      matchers = { builtin.matcher.fzf(), builtin.matcher.regexp() },
      sorters = sorters(),
      renderers = path_renderers(),
      previewers = { builtin.previewer.file(), builtin.previewer.noop() },
      actions = merge(my_path_actions, my_quickfix_actions, my_misc_actions),
      default_action = "open",
    }
  )

  x.define_picker_from_source(
    "file",
    std.refine_source(project_file_source(), builtin.refiner.relative_path()),
    {
      matchers = { builtin.matcher.fzf(), builtin.matcher.regexp() },
      sorters = sorters(),
      renderers = path_renderers(),
      previewers = { builtin.previewer.file(), builtin.previewer.noop() },
      actions = merge(my_path_actions, my_quickfix_actions, my_misc_actions),
      default_action = "open",
    }
  )

  x.define_picker_from_source(
    "file:all",
    std.refine_source(builtin.source.file(), builtin.refiner.relative_path()),
    {
      matchers = { builtin.matcher.fzf() },
      sorters = sorters(),
      renderers = path_renderers(),
      previewers = { builtin.previewer.file() },
      actions = merge(my_path_actions, my_quickfix_actions, my_misc_actions),
      default_action = "open",
    }
  )

  x.define_picker_from_source("line", builtin.source.line(), {
    matchers = { builtin.matcher.substring() },
    sorters = { builtin.sorter.noop() },
    previewers = { builtin.previewer.buffer() },
    actions = merge(
      my_quickfix_actions,
      my_misc_actions,
      builtin.action.default_open_actions,
      builtin.action.default_buffer_actions
    ),
    default_action = "open",
  })

  x.define_picker_from_source("buffer", builtin.source.buffer({ filter = "bufloaded" }), {
    matchers = { builtin.matcher.fzf() },
    sorters = sorters(),
    previewers = { builtin.previewer.buffer() },
    actions = merge(
      my_quickfix_actions,
      my_misc_actions,
      builtin.action.default_open_actions,
      builtin.action.default_buffer_actions
    ),
    default_action = "open",
  })

  x.define_picker_from_source("help", builtin.source.helptag(), {
    matchers = { builtin.matcher.fzf() },
    sorters = sorters(),
    previewers = { builtin.previewer.helptag() },
    actions = merge(my_misc_actions, builtin.action.default_help_actions),
    default_action = "help",
  })

  x.define_picker_from_source("quickfix", builtin.source.quickfix(), {
    matchers = { builtin.matcher.fzf() },
    sorters = sorters(),
    previewers = { builtin.previewer.buffer() },
    actions = merge(builtin.action.default_open_actions, my_misc_actions),
    default_action = "open",
  })

  x.define_picker_from_source(
    "oldfiles",
    std.refine_source(
      builtin.source.oldfiles(),
      builtin.refiner.cwd(),
      builtin.refiner.exists(),
      builtin.refiner.relative_path()
    ),
    {
      matchers = { builtin.matcher.fzf() },
      sorters = sorters(),
      previewers = { builtin.previewer.file() },
      actions = merge(my_path_actions, my_quickfix_actions, my_misc_actions),
      default_action = "open",
    }
  )

  x.define_picker_from_source("history", builtin.source.history(), {
    matchers = { builtin.matcher.fzf() },
    sorters = sorters(),
    actions = merge({ cmd = builtin.action.cmd({ immediate = true }) }, my_misc_actions),
    default_action = "cmd",
  })
end
