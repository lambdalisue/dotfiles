require("aibo").setup()

vim.api.nvim_create_user_command("Claude", "Aibo claude", {})
vim.api.nvim_create_user_command("Codex", "Aibo codex", {})
