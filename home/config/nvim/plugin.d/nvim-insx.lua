require('insx.preset.standard').setup()

local insx = require('insx')

insx.add('<', insx.with(require('insx.recipe.auto_pair')({
  open = '<',
  close = '>'
}), {
  insx.with.priority(10),
  insx.with.in_string(false),
  insx.with.in_comment(false),
  insx.with.undopoint(),
}))
insx.add('<C-]>', require('insx.recipe.fast_wrap')({
  close = '>',
}))

-- <Tab> to jump to next closing brackets / symbols
insx.add('<C-]>', require('insx.recipe.jump_next')({
  jump_pat = {
    ([=[\%%#[^%s]*%s\zs]=]):format(';', insx.esc(';')),
    ([=[\%%#[^%s]*%s\zs]=]):format(')', insx.esc(')')),
    ([=[\%%#[^%s]*%s\zs]=]):format('\\]', insx.esc(']')),
    ([=[\%%#[^%s]*%s\zs]=]):format('}', insx.esc('}')),
    ([=[\%%#[^%s]*%s\zs]=]):format('>', insx.esc('>')),
    ([=[\%%#[^%s]*%s\zs]=]):format('"', insx.esc('"')),
    ([=[\%%#[^%s]*%s\zs]=]):format("'", insx.esc("'")),
    ([=[\%%#[^%s]*%s\zs]=]):format('`', insx.esc('`')),
    ([=[\%#.*\zs]=]),
  }
}))
