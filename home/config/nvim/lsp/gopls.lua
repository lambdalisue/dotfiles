return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  -- go.work wins over a nearer go.mod so a module in a workspace shares one server
  root_markers = { "go.work", "go.mod", ".git" },
}
