# Gua's dotfiles

最近需要频繁更换服务器，是时候写一个 `.dotfiles` 用来同步简单的开发环境了:)

目前配置的内容有：

- [Z shell](https://www.zsh.org/)
    - [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) 与插件 [autojump](https://github.com/wting/autojump)、[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)、[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
    - themes: [spaceship](https://github.com/spaceship-prompt/spaceship-prompt)
- [tmux](https://github.com/tmux/tmux)
    - [oh-my-tmux](https://github.com/gpakosz/.tmux) 以及一些个人配置(`tmux/.tmux.conf.local`)
- [nvim](https://github.com/neovim/neovim)
    - [lazy-vim](https://github.com/LazyVim/LazyVim) （懒人表示能用就行）以及一些个人配置

可能遇到的问题：

- 使用 MarkdownPreview 时遇到报错 `Pre build and node is not found`
    - 根据 [Issue 7](https://github.com/iamcco/markdown-preview.nvim/issues/7) 尝试在 nvim 中进行 `:call mkdp#util#install()`
