local null_ls = require "null-ls"

local b = null_ls.builtins

local sources = {

  -- webdev stuff
  b.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
  b.diagnostics.eslint_d,
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css" } }, -- so prettier works only on these filetypes

  -- Lua
  b.formatting.stylua,

  -- python
  b.formatting.black,
  b.diagnostics.flake8,

  -- ruby
  b.diagnostics.rubocop,
  b.formatting.rubocop,
}

null_ls.setup {
  debug = true,
  sources = sources,
}
