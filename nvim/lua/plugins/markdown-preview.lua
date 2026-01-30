return {
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.g.mkdp_enable_mathjax = 1 -- 启用MathJax渲染LaTeX公式
      vim.g.mkdp_mathjax_autoload = 1
      vim.g.mkdp_mathjax_path = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"
    end,
  },
}
