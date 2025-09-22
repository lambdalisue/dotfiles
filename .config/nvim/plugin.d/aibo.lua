require("aibo").setup({
  prompt = {
    keymaps = {
      next = "<Down>",
      prev = "<Up>",
    }
  },
  console = {
    keymaps = {
      next = "<Down>",
      prev = "<Up>",
    }
  },
})

vim.api.nvim_create_user_command("Claude", "Aibo claude", {})
vim.api.nvim_create_user_command("Codex", "Aibo codex", {})
