-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Detect Django HTML templates as htmldjango (any .html under a templates/ dir)
vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
  },
  pattern = {
    [".*/templates/.*%.html"] = "htmldjango",
    [".*/jinja2/.*%.html"] = "htmldjango",
  },
})
