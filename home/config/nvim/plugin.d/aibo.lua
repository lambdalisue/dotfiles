local aibo = require("aibo")

aibo.setup({
  prompt = {
    on_attach = function(bufnr, info)
      -- History navigation in insert mode (when completion menu is not visible)
      -- Uses <Plug> mappings defined in prompt_window.lua
      vim.keymap.set("i", "<C-p>", function()
        if vim.fn.eval("coc#pum#visible()") == 1 then
          return vim.fn.eval("coc#pum#prev(1)")
        elseif vim.fn.eval("coc#inline#visible()") == 1 then
          return vim.fn.eval("coc#inline#prev()")
        elseif vim.fn.pumvisible() == 1 then
          return "<C-p>"
        end
        return "<Plug>(aibo-history-prev)"
      end, { buffer = bufnr, expr = true, remap = true, silent = true })

      vim.keymap.set("i", "<C-n>", function()
        if vim.fn.eval("coc#pum#visible()") == 1 then
          return vim.fn.eval("coc#pum#next(1)")
        elseif vim.fn.eval("coc#inline#visible()") == 1 then
          return vim.fn.eval("coc#inline#next()")
        elseif vim.fn.pumvisible() == 1 then
          return "<C-n>"
        end
        return "<Plug>(aibo-history-next)"
      end, { buffer = bufnr, expr = true, remap = true, silent = true })
    end,
  }
})

local claude = string.format(
  "claude --mcp-config %s --permission-mode bypassPermissions",
  vim.fn.expand("~/.claude/mcp.json")
)
local codex = "codex --dangerously-bypass-approvals-and-sandbox"
local gemini = "gemini --yolo"

vim.keymap.set(
  "n",
  "<leader>iC",
  string.format("<Cmd>Aibo -focus %s --continue<CR>", claude),
  { desc = "Chat with Claude" }
)
vim.keymap.set(
  "n",
  "<leader>ic",
  string.format("<Cmd>Aibo %s<CR>", claude),
  { desc = "Chat with Claude" }
)
vim.keymap.set(
  "n",
  "<leader>iX",
  string.format("<Cmd>Aibo -focus %s resume --last<CR>", codex),
  { desc = "Chat with Codex" }
)
vim.keymap.set(
  "n",
  "<leader>ix",
  string.format("<Cmd>Aibo %s<CR>", codex),
  { desc = "Chat with Codex" }
)
vim.keymap.set(
  "n",
  "<leader>iG",
  string.format("<Cmd>Aibo -focus %s resume --last<CR>", gemini),
  { desc = "Chat with Gemini" }
)
vim.keymap.set(
  "n",
  "<leader>ig",
  string.format("<Cmd>Aibo %s<CR>", gemini),
  { desc = "Chat with Gemini" }
)

vim.keymap.set("n", "<leader>is", "<Cmd>AiboSend -input<CR>", { desc = "Send to AI" })
vim.keymap.set("v", "<leader>is", ":AiboSend -input<CR>", { desc = "Send to AI" })
