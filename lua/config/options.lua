-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- System clipboard over SSH (this nvim runs headless on a server, inside tmux +
-- kitty over SSH). The default provider only writes a server-side tmux buffer,
-- so a remote `y` never reaches the MacBook. Wire OSC 52: copy emits an escape
-- that tmux forwards and kitty turns into a real local clipboard write.
--
-- Paste must NOT query the terminal: kitty is `read-clipboard-ask`, so an OSC 52
-- read prompts + stalls on every `p`. Instead we cache what nvim copies and
-- return that, so y -> p is instant. To paste the Mac clipboard *into* nvim, use
-- kitty's own paste (Cmd+V), not the + register.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  local cache = { ["+"] = { { "" }, "v" }, ["*"] = { { "" }, "v" } }
  local function copy(reg)
    local emit = osc52.copy(reg)
    return function(lines, regtype)
      cache[reg] = { lines, regtype or "v" }
      emit(lines)
    end
  end
  vim.g.clipboard = {
    name = "OSC 52 (copy-only)",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = {
      ["+"] = function() return cache["+"] end,
      ["*"] = function() return cache["*"] end,
    },
  }

  -- LazyVim clears `clipboard` under SSH and its options load after this file, so
  -- rather than fight that, mirror every *yank* (plain `y`, default register)
  -- into + -- which the OSC 52 provider above pushes to the Mac. Deletes and
  -- named-register yanks stay local. Paste with `p` (local) or kitty Cmd+V (Mac).
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("osc52_yank_sync", { clear = true }),
    callback = function()
      local ev = vim.v.event
      if ev.operator == "y" and ev.regname == "" then
        vim.fn.setreg("+", ev.regcontents, ev.regtype)
      end
    end,
  })
end

-- Disable unused language providers (legacy remote-plugin hosts).
-- LazyVim and our React/Django stack rely on LSP, not these. Silences the
-- corresponding :checkhealth warnings without installing anything.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
