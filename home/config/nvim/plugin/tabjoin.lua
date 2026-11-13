-- The window itself moves rather than its buffer being opened anew in a
-- split, so that it keeps its options, jumplist and view.

local function warn(msg)
  vim.notify("tabjoin: " .. msg, vim.log.levels.WARN)
end

local function is_floating(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

local function count_splits(tab)
  local n = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if not is_floating(win) then
      n = n + 1
    end
  end
  return n
end

local function join(tabnr)
  local tab = vim.api.nvim_list_tabpages()[tabnr]
  local src_win = vim.api.nvim_get_current_win()
  local src_tab = vim.api.nvim_get_current_tabpage()
  if not tab then
    warn(tabnr == 0 and "no previous tab page" or ("no tab page " .. tabnr))
    return
  elseif tab == src_tab then
    warn("the window is already in that tab page")
    return
  elseif is_floating(src_win) then
    warn("a floating window cannot be joined")
    return
  end

  local dst_win = vim.api.nvim_tabpage_get_win(tab)
  -- A cell is about twice as tall as it is wide, so a window wider than twice
  -- its height looks wide.
  local wide = vim.api.nvim_win_get_width(dst_win) > vim.api.nvim_win_get_height(dst_win) * 2

  -- The last window of a tab page cannot be moved, so a stand-in keeps the
  -- tab page alive until the window has left, and the tab page is closed then.
  local last = count_splits(src_tab) == 1
  if last then
    vim.api.nvim_open_win(0, false, { split = "below", win = src_win })
  end
  vim.api.nvim_win_set_config(src_win, { win = dst_win, split = wide and "right" or "below" })
  vim.api.nvim_set_current_win(src_win)
  if last then
    vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(src_tab))
  end
end

for n = 1, 9 do
  vim.keymap.set("n", "<C-w>m" .. n, function()
    join(n)
  end, { desc = "Join the window into tab page " .. n })
end
vim.keymap.set("n", "<C-w>mm", function()
  join(vim.fn.tabpagenr("#"))
end, { desc = "Join the window into the previous tab page" })
vim.keymap.set("n", "<C-w>M", function()
  join(vim.fn.tabpagenr("#"))
end, { desc = "Join the window into the previous tab page" })
