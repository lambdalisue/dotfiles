require([
  'codemirror/keymap/vim',
  'nbextensions/vim_binding/vim_binding'
], function() {
  // Use gj/gk instead of j/k
  CodeMirror.Vim.map("j", "<Plug>(vim-binding-gj)", "normal");
  CodeMirror.Vim.map("k", "<Plug>(vim-binding-gk)", "normal");
  CodeMirror.Vim.map("gj", "<Plug>(vim-binding-j)", "normal");
  CodeMirror.Vim.map("gk", "<Plug>(vim-binding-k)", "normal");

  // Emacs like binding
  CodeMirror.Vim.defineAction('[i]<BS>', function(cm) {
    cm.execCommand('delCharBefore');
  });
  CodeMirror.Vim.defineAction('[i]<Del>', function(cm) {
    cm.execCommand('delCharAfter');
  });
  CodeMirror.Vim.defineAction('[i]<Tab>', function(cm) {
    cm.execCommand('indentMore');
  });
  CodeMirror.Vim.defineAction('[i]<CR>', function(cm) {
    cm.execCommand('newlineAndIndent');
  });
  CodeMirror.Vim.mapCommand("<C-h>", "action", "[i]<BS>", {}, { "context": "insert" });
  CodeMirror.Vim.mapCommand("<C-d>", "action", "[i]<Del>", {}, { "context": "insert" });
  CodeMirror.Vim.mapCommand("<C-m>", "action", "[i]<CR>", {}, { "context": "insert" });
  CodeMirror.Vim.mapCommand("<C-j>", "action", "[i]<CR>", {}, { "context": "insert" });
  CodeMirror.Vim.mapCommand("<C-i>", "action", "[i]<Tab>", {}, { "context": "insert" });

  CodeMirror.Vim.map("<C-a>", "<Esc>^i", "insert");
  CodeMirror.Vim.map("<C-e>", "<Esc>$a", "insert");
  CodeMirror.Vim.map("<C-f>", "<Esc>la", "insert");
  CodeMirror.Vim.map("<C-b>", "<Esc>ha", "insert");

  console.log('Custom keymaps are applied.');
});
