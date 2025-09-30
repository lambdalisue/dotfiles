local claude = "claude --permission-mode bypassPermissions"
local opener = "rightbelow vsplit"

vim.keymap.set(
  "n",
  "<leader>ii",
  string.format("<Cmd>Aibo -focus %s<CR>", claude),
  { desc = "Chat with Claude" }
)
vim.keymap.set(
  "n",
  "<leader>II",
  string.format("<Cmd>Aibo -opener='%s' %s<CR>", opener, claude),
  { desc = "Chat with Claude" }
)

vim.keymap.set("n", "<leader>is", "<Cmd>AiboSend -input<CR>", { desc = "Send to AI" })
vim.keymap.set("v", "<leader>is", ":AiboSend -input<CR>", { desc = "Send to AI" })
