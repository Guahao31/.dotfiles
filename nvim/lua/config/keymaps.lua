-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

-- 【macOS System Clipboard Mapping】LazyVim - Override default y/d/p to system clipboard (+ register)
-- Compatible: local macOS / SSH remote (with bridge) / Docker (with bridge)
local map = vim.keymap.set

-- Normal mode(n): Copy/Cut to system clipboard
map("n", "y", '"+y', { desc = "Copy to system clipboard" })
map("n", "Y", '"+Y', { desc = "Copy to EOL to system clipboard" })
map("n", "d", '"+d', { desc = "Cut to system clipboard" })
map("n", "D", '"+D', { desc = "Cut to EOL to system clipboard" })

-- Visual mode(v): Copy/Cut selected content to system clipboard (MUST separate config)
map("v", "y", '"+y', { desc = "Visual: Copy to system clipboard" })
map("v", "d", '"+d', { desc = "Visual: Cut to system clipboard" })

-- Normal mode(n): Paste from system clipboard (p=below cursor, P=above cursor)
map("n", "p", '"+p', { desc = "Paste from system clipboard (below)" })
map("n", "P", '"+P', { desc = "Paste from system clipboard (above)" })
