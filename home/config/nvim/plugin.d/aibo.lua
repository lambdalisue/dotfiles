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
