-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- 全局永久关闭拼写检查
vim.opt.spell = false

-- 强制所有文件类型禁用拼写检查（防止插件/文件类型自动开启）
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.spell = false
  end,
})
