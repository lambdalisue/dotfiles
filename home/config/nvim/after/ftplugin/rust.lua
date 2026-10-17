-- rust-analyzer's extensions to the protocol
-- https://rust-analyzer.github.io/book/contributing/lsp-extensions.html

local function get_client()
  return vim.lsp.get_clients({ bufnr = 0, name = "rust_analyzer" })[1]
end

local function request(method, params, handler)
  local client = get_client()
  if not client then
    return false
  end
  if type(params) == "function" then
    params = params(client)
  end
  client:request(method, params, function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
    elseif handler then
      handler(result, client)
    end
  end, 0)
  return true
end

local function position_params(client)
  return vim.lsp.util.make_position_params(0, client.offset_encoding)
end

local function jump_to(location, client)
  location = vim.islist(location) and location[1] or location
  if not location then
    return
  end
  if location.targetUri then
    location = { uri = location.targetUri, range = location.targetSelectionRange }
  end
  vim.lsp.util.show_document(location, client.offset_encoding, { focus = true })
end

local function matching_brace()
  local ok = request("experimental/matchingBrace", function(client)
    local params = position_params(client)
    return { textDocument = params.textDocument, positions = { params.position } }
  end, function(positions, client)
    local uri = vim.uri_from_bufnr(0)
    jump_to({ uri = uri, range = { start = positions[1], ["end"] = positions[1] } }, client)
  end)
  if not ok then
    vim.cmd("normal! %")
  end
end

local function open_docs()
  request("experimental/externalDocs", position_params, function(result)
    local url = type(result) == "table" and (result["local"] or result.web) or result
    if url then
      vim.ui.open(url)
    end
  end)
end

local function run(runnable)
  local args = runnable.args
  local cmd = vim.list_extend({ "cargo" }, args.cargoArgs)
  if args.executableArgs and #args.executableArgs > 0 then
    table.insert(cmd, "--")
    vim.list_extend(cmd, args.executableArgs)
  end
  vim.cmd("botright new")
  vim.cmd.resize(math.floor(vim.o.lines / 2))
  vim.fn.jobstart(cmd, { term = true, cwd = args.cwd or args.workspaceRoot })
end

local function select_runnable(at_cursor, filter)
  request("experimental/runnables", function(client)
    local params = position_params(client)
    return { textDocument = params.textDocument, position = at_cursor and params.position or nil }
  end, function(runnables)
    runnables = vim.tbl_filter(filter or function()
      return true
    end, runnables or {})
    if #runnables == 1 then
      return run(runnables[1])
    end
    vim.ui.select(runnables, {
      prompt = "Run",
      format_item = function(item)
        return item.label
      end,
    }, function(item)
      if item then
        run(item)
      end
    end)
  end)
end

local function set_target(target)
  local client = get_client()
  if not client then
    return
  end
  client.settings["rust-analyzer"] = client.settings["rust-analyzer"] or {}
  local settings = client.settings["rust-analyzer"]
  settings.cargo = settings.cargo or {}
  settings.cargo.target = target
  client:notify("workspace/didChangeConfiguration", { settings = client.settings })
end

local function map(lhs, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, nowait = true })
end

map("%", matching_brace)
map("gK", open_docs)
map("g<C-^>", function()
  request("experimental/parentModule", position_params, jump_to)
end)
map("gT", function()
  select_runnable(true, function(item)
    return vim.startswith(item.label, "test")
  end)
end)
map("<F5>", function()
  request("rust-analyzer/reloadWorkspace", nil)
end)
map("<Space>rr", function()
  select_runnable(false)
end)
map("[[", function()
  vim.diagnostic.jump({ count = -vim.v.count1 })
  vim.cmd("normal! zv")
end)
map("]]", function()
  vim.diagnostic.jump({ count = vim.v.count1 })
  vim.cmd("normal! zv")
end)

for name, target in pairs({
  RustAnalyzerTargetPlatform = vim.NIL,
  RustAnalyzerTargetWindows = "x86_64-pc-windows-gnu",
  RustAnalyzerTargetMacOS = "x86_64-apple-darwin",
  RustAnalyzerTargetLinux = "x86_64-unknown-linux-gnu",
}) do
  vim.api.nvim_buf_create_user_command(0, name, function()
    set_target(target)
  end, {})
end
