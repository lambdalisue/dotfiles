-- Definitions into remote modules come back as deno:/ URIs, which only the
-- server can read. Fill such a buffer from deno/virtualTextDocument before the
-- default handler jumps into it.
local function load_virtual_document(client, uri)
  local bufnr = vim.uri_to_bufnr(uri)
  if vim.api.nvim_buf_line_count(bufnr) > 1 or vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] ~= "" then
    return
  end
  local response = client:request_sync("deno/virtualTextDocument", { textDocument = { uri = uri } }, 3000, bufnr)
  if not (response and response.result) then
    return
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(response.result, "\n"))
  vim.bo[bufnr].readonly = true
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].modifiable = false
  vim.lsp.buf_attach_client(bufnr, client.id)
end

local function locations_handler(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and type(result) == "table" then
    for _, location in ipairs(vim.islist(result) and result or { result }) do
      local uri = location.uri or location.targetUri
      if uri and uri:match("^deno:") then
        load_virtual_document(client, uri)
      end
    end
  end
  return vim.lsp.handlers[ctx.method](err, result, ctx, config)
end

-- root_dir lives in plugin.d/lsp.lua, which splits buffers between this
-- server and ts_ls
return {
  cmd = { "deno", "lsp" },
  cmd_env = { NO_COLOR = true },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  handlers = {
    ["textDocument/definition"] = locations_handler,
    ["textDocument/typeDefinition"] = locations_handler,
    ["textDocument/references"] = locations_handler,
  },
}
