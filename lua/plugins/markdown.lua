return {
  -- Force markdownlint-cli2 to read a fixed global config regardless of cwd.
  --
  -- nvim-lint pipes the buffer to `markdownlint-cli2 -` via stdin, and in stdin
  -- mode the tool only looks for `.markdownlint*` in the literal cwd (it does
  -- NOT walk parent dirs). That makes a `~/.markdownlint.yaml` unreliable, so we
  -- point it at an absolute path here. `prepend_args` is appended by LazyVim,
  -- giving `markdownlint-cli2 - --config ~/.markdownlint.yaml` (verified to work).
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          prepend_args = { "--config", vim.fn.expand("~/.markdownlint.yaml") },
        },
      },
    },
  },
}
