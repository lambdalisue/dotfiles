vim.api.nvim_create_user_command("Claude",
  "Aibo -focus -opener='topleft vsplit' claude --permission-mode bypassPermissions", {})
vim.api.nvim_create_user_command("Codex", "Aibo -focus -opener='topleft vsplit' codex", {})
vim.api.nvim_create_user_command("Ollama", "Aibo -focus -opener='topleft vsplit' ollama run gpt-oss", {})

vim.keymap.set("n", "<leader>ii", "<Cmd>Claude<CR>", { desc = "Chat with Claude" })
vim.keymap.set("n", "<leader>ix", "<Cmd>Codex<CR>", { desc = "Chat with Codex" })
vim.keymap.set("n", "<leader>io", "<Cmd>Ollama<CR>", { desc = "Chat with Ollama" })
vim.keymap.set("n", "<leader>is", "<Cmd>AiboSend -input<CR>", { desc = "Send to AI" })
vim.keymap.set("v", "<leader>is", ":AiboSend -input<CR>", { desc = "Send to AI" })
vim.keymap.set("v", "<leader>it", ':AiboSend -prefix="Translate the following to Japanese\\n\\n" -submit<CR>',
  { desc = "Translate with AI" })
