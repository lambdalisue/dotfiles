require("aibo").setup({
  prompt = {
    on_attach = function(bufnr)
      vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = bufnr })
    end,
  },
  console = {
    on_attach = function(bufnr)
      vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = bufnr })
      vim.keymap.set("n", "Q", "<Cmd>bwipeout!<CR>", { buffer = bufnr })
    end,
  },
})

vim.api.nvim_create_user_command("Claude", "Aibo -jump -opener='botright vsplit' claude", {})
vim.api.nvim_create_user_command("Codex", "Aibo -jump -opener='botright vsplit' codex", {})
vim.api.nvim_create_user_command("Ollama", "Aibo -jump -opener='botright vsplit' ollama run gpt-oss", {})

vim.keymap.set("n", "<leader>ii", "<Cmd>Claude<CR>", { desc = "Chat with Claude" })
vim.keymap.set("n", "<leader>ix", "<Cmd>Codex<CR>", { desc = "Chat with Codex" })
vim.keymap.set("n", "<leader>io", "<Cmd>Ollama<CR>", { desc = "Chat with Ollama" })
vim.keymap.set("n", "<leader>is", "<Cmd>AiboSend -input<CR>", { desc = "Send to AI" })
vim.keymap.set("v", "<leader>is", ":AiboSend -input<CR>", { desc = "Send to AI" })
vim.keymap.set("v", "<leader>it", ':AiboSend -prefix="Translate the following to Japanese\\n\\n" -submit<CR>',
  { desc = "Translate with AI" })
