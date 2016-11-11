## vim-metarepeat

vim-metarepeat provides an operator (like) mapping which runs dot repeat for
every occurence matched by last pattern (@/) in range (specified by motion or
textobject).

neovim-metarepeat is inspired by 'Occurrence modifier, preset-occurrence,
persistence-selection' feature
http://qiita.com/t9md/items/0bc7eaff726d099943eb#occurrence-modifier-preset-occurrence-persistence-selection

But it's not a port of these feature. In similar to vim-mode-plus terms,
vim-metarepeat provides 'preset-operation-for-occurence' feature (it's just
a operator + 'gn') and provides a way to apply the operation for each
occurences in textobject.


![anim](https://cloud.githubusercontent.com/assets/3797062/20180056/1a0e62da-a79c-11e6-801c-84f41d188770.gif)

```
This is 1st paragraph abc.
2nd abc also include abc abc abc.
3rd abc include abc abc abc

This is 2nd paragraph abc.
2nd line also include text text text.
3rd abc include abc abc abc
4th abc
```

1. `gg0/te<CR>` (move to first `text`)
2. `*j0wgo` (insert `text` into `@/` and move to `line`, then pre-set `line` as well)
3. `cgnabc<Esc>` (first operation)
4. `ggVjjjjg.` (apply operation to first 5 lines)
5. `jjg.Vj` (skip 2nd line in 2nd paragrap and apply operation to the rest of lines)

(with [haya14busa/vim-asterisk](https://github.com/haya14busa/vim-asterisk))
