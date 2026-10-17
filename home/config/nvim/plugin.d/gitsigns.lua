local gitsigns = require("gitsigns")

gitsigns.setup({
  on_attach = function(bufnr)
    local function map(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true })
    end
    map("gs", gitsigns.preview_hunk)
    map("gp", function()
      gitsigns.nav_hunk("prev")
    end)
    map("gn", function()
      gitsigns.nav_hunk("next")
    end)
  end,
})
