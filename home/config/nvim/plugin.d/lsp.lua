local group = vim.api.nvim_create_augroup("my-lsp", {})
local border = "rounded"

-- A TypeScript buffer belongs to Deno unless a package.json is the only
-- project marker above it, so standalone scripts still get Deno.
local function deno_root(bufnr)
  return vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
end

local function node_root(bufnr)
  return vim.fs.root(bufnr, "package.json")
end

local function edit_start(item)
  local edit = item.textEdit
  local range = edit and (edit.range or edit.insert)
  return range and range.start.character
end

-- tsserver answers `s.toU|` with members replacing `toU` plus a few items,
-- such as `[Symbol]`, that replace the `.` as well. vim.lsp.completion starts
-- every item at the leftmost edit, which turns the prefix into `.toU` and
-- filters out all members; drop the stragglers so the members survive.
local function drop_items_starting_early(client)
  local request = client.request
  client.request = function(self, method, params, handler, bufnr)
    if method == "textDocument/completion" and handler then
      local inner = handler
      handler = function(err, result, ...)
        local items = type(result) == "table" and (result.items or result) or {}
        local latest = vim.iter(items):map(edit_start):fold(nil, function(acc, start)
          return math.max(acc or start, start)
        end)
        if latest then
          local kept = vim.tbl_filter(function(item)
            local start = edit_start(item)
            return start == nil or start == latest
          end, items)
          if result.items then
            result.items = kept
          else
            result = kept
          end
        end
        return inner(err, result, ...)
      end
    end
    return request(self, method, params, handler, bufnr)
  end
end

vim.lsp.config("denols", {
  on_init = drop_items_starting_early,
  root_dir = function(bufnr, on_dir)
    local root = deno_root(bufnr)
    if root then
      on_dir(root)
    elseif not node_root(bufnr) then
      on_dir(vim.fs.root(bufnr, ".git") or vim.fn.getcwd())
    end
  end,
  settings = {
    deno = {
      enable = true,
      lint = true,
      cacheOnSave = true,
    },
  },
})

vim.lsp.config("ts_ls", {
  on_init = drop_items_starting_early,
  root_dir = function(bufnr, on_dir)
    if deno_root(bufnr) then
      return
    end
    local root = node_root(bufnr)
    if root then
      on_dir(root)
    end
  end,
})

vim.lsp.config("eslint", {
  settings = {
    -- Formatting stays with the language server of the buffer
    format = false,
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
    },
  },
})

vim.lsp.config("lua_ls", {
  before_init = function(_, config)
    local ok, luals = pcall(require, "lese.luals")
    if ok then
      local workspace = config.settings.Lua.workspace
      workspace.library = luals.library(workspace.library)
    end
  end,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      diagnostics = {
        unusedLocalExclude = { "_*" },
      },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        buildScripts = { enable = true },
        features = "all",
      },
      imports = {
        granularity = { enforce = true },
      },
      inlayHints = {
        bindingModeHints = { enable = true },
        closureReturnTypeHints = { enable = "with_block" },
      },
    },
  },
})

vim.lsp.enable({
  "bashls",
  "denols",
  "eslint",
  "gopls",
  "jsonls",
  "lua_ls",
  "protols",
  "pyright",
  "ruff",
  "rust_analyzer",
  "tailwindcss",
  "terraformls",
  "ts_ls",
  "vimls",
  "yamlls",
})

vim.diagnostic.config({
  virtual_text = { current_line = true },
  float = { border = border },
  severity_sort = true,
})

vim.lsp.inlay_hint.enable(true)

local function enable_completion(client, bufnr)
  vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
  -- The buffer-word popup of 'autocomplete' would race the LSP one
  vim.bo[bufnr].autocomplete = false
  if vim.b[bufnr].my_lsp_complete_on_type then
    return
  end
  vim.b[bufnr].my_lsp_complete_on_type = true
  -- autotrigger fires only on the server's trigger characters such as ".".
  -- Adding word characters to that list is not an option: tsserver answers
  -- nothing to a triggerCharacter it does not know. Request an invoked
  -- completion instead, scheduled so the typed character is in the buffer.
  vim.api.nvim_create_autocmd("InsertCharPre", {
    group = group,
    buffer = bufnr,
    callback = function()
      if vim.fn.pumvisible() == 0 and vim.v.char:match("[%w_]") then
        vim.schedule(vim.lsp.completion.get)
      end
    end,
  })
end

local function code_action(kind)
  return function()
    vim.lsp.buf.code_action({ context = { only = { kind } } })
  end
end

local function on_attach(client, bufnr)
  local function map(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, nowait = true })
  end

  -- pyright answers hover for Python; ruff's would only duplicate it
  if client.name == "ruff" then
    client.server_capabilities.hoverProvider = false
  end

  -- copilot.vim runs its server through this client too; its suggestions
  -- come as ghost text, not in the popup menu
  if client.name ~= "GitHub Copilot" and client:supports_method("textDocument/completion") then
    enable_completion(client, bufnr)
  end

  if client:supports_method("textDocument/documentHighlight") then
    local highlight = vim.api.nvim_create_augroup("my-lsp-highlight-" .. bufnr, {})
    vim.api.nvim_create_autocmd("CursorHold", {
      group = highlight,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = highlight,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gD", vim.lsp.buf.declaration)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "gy", vim.lsp.buf.type_definition)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "gq", function()
    vim.lsp.buf.format()
  end)
  -- 'formatexpr' is the LSP one, so the builtin operator formats a range
  map({ "n", "x" }, "gQ", "gq")
  map("n", "qf", function()
    vim.lsp.buf.code_action({ context = { only = { "quickfix" } }, apply = true })
  end)
  map("n", "qr", vim.lsp.buf.rename)
  map({ "n", "x" }, "<Leader>ca", vim.lsp.buf.code_action)
  map({ "n", "x" }, "<Leader>cr", code_action("refactor"))
  map("n", "<Leader>cs", code_action("source"))
  map("i", "<C-s>", function()
    vim.lsp.buf.signature_help({ border = border })
  end)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then
      on_attach(client, ev.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  group = group,
  command = "redrawstatus",
})

-- Code actions are applied synchronously here because BufWritePre must finish
-- editing the buffer before it is written.
local function apply_code_actions(client, bufnr, kind)
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
    },
    context = { only = { kind }, diagnostics = {} },
  }
  local response = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
  for _, action in ipairs(response and response.result or {}) do
    if not action.edit and client:supports_method("codeAction/resolve") then
      local resolved = client:request_sync("codeAction/resolve", action, 1000, bufnr)
      action = resolved and resolved.result or action
    end
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

local format_on_save = true

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(ev)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf, name = "ruff" })) do
      apply_code_actions(client, ev.buf, "source.fixAll.ruff")
      apply_code_actions(client, ev.buf, "source.organizeImports.ruff")
    end
    if format_on_save and #vim.lsp.get_clients({ bufnr = ev.buf, method = "textDocument/formatting" }) > 0 then
      vim.lsp.buf.format({ bufnr = ev.buf, timeout_ms = 3000 })
    end
  end,
})

local function show_documentation()
  if vim.list_contains({ "vim", "help" }, vim.bo.filetype) then
    vim.cmd.help(vim.fn.expand("<cword>"))
  elseif #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" }) > 0 then
    vim.lsp.buf.hover({ border = border })
  else
    vim.cmd("normal! K")
  end
end

-- Scroll a focusable floating window (hover, signature help, diagnostics)
-- when one is open, otherwise page through the buffer as usual.
local function scroll_float_or(key)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" and config.focusable then
      vim.api.nvim_win_call(win, function()
        vim.cmd("normal! " .. vim.keycode(key == "<C-f>" and "<C-d>" or "<C-u>"))
      end)
      return
    end
  end
  vim.cmd("normal! " .. vim.keycode(key))
end

local function jump_diagnostic(count)
  vim.diagnostic.jump({ count = count * vim.v.count1 })
  vim.cmd("normal! zv")
end

vim.keymap.set("n", "K", show_documentation)
vim.keymap.set("x", "K", function()
  vim.lsp.buf.hover({ border = border })
end)
vim.keymap.set("n", "<C-f>", function()
  scroll_float_or("<C-f>")
end, { nowait = true })
vim.keymap.set("n", "<C-b>", function()
  scroll_float_or("<C-b>")
end, { nowait = true })
vim.keymap.set("n", "[g", function()
  jump_diagnostic(-1)
end, { nowait = true })
vim.keymap.set("n", "]g", function()
  jump_diagnostic(1)
end, { nowait = true })
vim.keymap.set("n", "qd", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { nowait = true })

vim.keymap.set("i", "<C-x><C-x>", function()
  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/completion" }) > 0 then
    vim.lsp.completion.get()
  else
    vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "n", false)
  end
end)
-- <C-y> accepts through vim.lsp.completion, which also applies the item's
-- additional edits (auto-imports) and expands its snippet.
vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then
    return "<C-y>"
  end
  return "<CR>"
end, { expr = true })

vim.api.nvim_create_user_command("LspEnableFormatOnSave", function()
  format_on_save = true
end, {})
vim.api.nvim_create_user_command("LspDisableFormatOnSave", function()
  format_on_save = false
end, {})
vim.api.nvim_create_user_command("LspEnableInlayHint", function()
  vim.lsp.inlay_hint.enable(true)
end, {})
vim.api.nvim_create_user_command("LspDisableInlayHint", function()
  vim.lsp.inlay_hint.enable(false)
end, {})
vim.api.nvim_create_user_command("LspOrganizeImport", function()
  vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
end, {})
