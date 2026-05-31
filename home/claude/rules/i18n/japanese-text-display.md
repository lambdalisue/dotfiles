# Displaying Japanese Text Correctly in UI

When implementing UI that includes Japanese text, consult
https://heistak.github.io/your-code-displays-japanese-wrong/
before writing string-handling code.

Key pitfalls to avoid:

- Treat strings as sequences of Unicode code points (or grapheme
  clusters), never raw bytes — Japanese characters are multi-byte in
  UTF-8.
- Do not truncate, slice, or measure string "length" by byte count;
  use code-point / grapheme-aware operations.
- Choose fonts that fully cover Japanese glyphs (kanji, hiragana,
  katakana) and avoid Han-unification fallback to Chinese glyph forms
  by specifying `lang="ja"` / appropriate font stacks.
- Preserve full-width characters and avoid unintended normalization
  that corrupts intended display (e.g. full-width vs half-width).
- Be careful with line-breaking; Japanese allows breaks between most
  characters but has kinsoku (禁則) rules for certain punctuation.
