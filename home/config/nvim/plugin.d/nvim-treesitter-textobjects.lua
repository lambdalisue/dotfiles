require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
})

local select = require("nvim-treesitter-textobjects.select")

for lhs, query in pairs({
  af = "@function.outer",
  ["if"] = "@function.inner",
  ac = "@class.outer",
  ic = "@class.inner",
}) do
  vim.keymap.set({ "x", "o" }, lhs, function()
    select.select_textobject(query, "textobjects")
  end, { nowait = true })
end
