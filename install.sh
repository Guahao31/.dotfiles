#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$HOME/.dotfiles"

echo -e "${GREEN}>>> 初始化 Dotfiles 部署脚本...${NC}"

read -p "是否开启 ssh 模式（适用于已配置 GitHub SSH Key 的机器）？[y/N] " use_ssh

restore_config() {
  if [ -n "$OLD_INSTEAD_OF" ]; then
    # 如果原有配置有值，恢复回去
    git config --global url."git@github.com:".insteadOf "$OLD_INSTEAD_OF"
    echo -e "${GREEN} 已恢复原有 Git 配置：url.git@github.com.insteadOf = ${OLD_INSTEAD_OF}${NC}"
  else
    # 如果原有无配置，直接删除临时添加的规则
    git config --global --unset url."git@github.com:".insteadOf
    echo -e "${GREEN} 已删除临时 Git 配置，恢复原状${NC}"
  fi
}

if [[ "$use_ssh" =~ ^[Yy]$ ]]; then
  OLD_INSTEAD_OF=$(git config --global --get url."git@github.com:".insteadOf)
  trap restore_config EXIT
  echo -e "${GREEN}>>> 正在配置 Git 使用 SSH 代替 HTTPS...${NC}"
  git config --global url."git@github.com:".insteadOf "https://github.com/"
  echo "SSH 模式已启用"
else
  echo "保持 HTTPS 访问 GitHub"
  git config --unset url."git@github.com:".insteadOf 2>/dev/null
fi

# --------------------------------------------------------------------------
# 1. 操作系统检测与依赖安装
# --------------------------------------------------------------------------
OS_TYPE="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="macos"
elif [[ -f /etc/os-release ]]; then
  if grep -qE "ID=(ubuntu|debian)" /etc/os-release; then
    OS_TYPE="ubuntu"
  fi
fi

install_package() {
  local cmd_name=$1
  local pkg_name=$2
  if ! command -v "$cmd_name" &>/dev/null; then
    echo -e "${YELLOW}>>> 安装 $cmd_name...${NC}"
    if [[ "$OS_TYPE" == "macos" ]]; then
      brew install "$pkg_name"
    elif [[ "$OS_TYPE" == "ubuntu" ]]; then
      sudo apt-get update -y && sudo apt-get install -y "$pkg_name"
    fi
  fi
}

# 必须先安装 git, zsh, curl
install_package "git" "git"
install_package "zsh" "zsh"
install_package "curl" "curl"
install_package "tmux" "tmux"
install_package "nvim" "neovim"

# --------------------------------------------------------------------------
# 2. Oh My Zsh 安装 (Unattended + 镜像源支持)
# --------------------------------------------------------------------------
echo -e "${GREEN}>>> 检查 Oh My Zsh...${NC}"

if [ -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${GREEN}>>> Oh My Zsh 已存在，跳过安装。${NC}"
else
  OMZ_URL="https://install.ohmyz.sh"
  # OMZ_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

  # 核心逻辑：使用 --unattended
  # sh -c "$(curl ...)" "" --unattended
  sh -c "$(curl -fsSL $OMZ_URL)" "" --unattended

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}>>> Oh My Zsh 安装成功！${NC}"

    # 删除 OMZ 自动生成的 .zshrc，防止冲突，因为后面我们要 link 自己的
    if [ -f "$HOME/.zshrc" ]; then
      echo "备份默认生成的 .zshrc 到 .zshrc.pre-dotfiles"
      mv "$HOME/.zshrc" "$HOME/.zshrc.pre-dotfiles"
    fi
  else
    echo -e "${RED}>>> Oh My Zsh 安装失败，请检查网络连接。${NC}"
    exit 1
  fi
fi

# --------------------------------------------------------------------------
# 3. 链接自定义配置 (Symlinks)
# --------------------------------------------------------------------------
link_file() {
  local src=$1
  local dst=$2
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    # 已经是软链接，进行覆盖
    rm "$dst"
  elif [ -e "$dst" ]; then
    # 是实体文件，备份
    mv "$dst" "$dst.bak"
  fi
  ln -s "$src" "$dst"
  echo "Linked: $dst -> $src"
}

echo -e "${GREEN}>>> 链接配置文件...${NC}"

# 1. ZSH 配置
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# 2. ZSH 自定义插件/主题目录
echo -e "${GREEN}>>> 检查并安装 omz 插件...${NC}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
declare -a ZSH_PLUGINS=(
  "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
  "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

for plugin_info in "${ZSH_PLUGINS[@]}"; do
  plugin_name=$(echo "$plugin_info" | awk '{print $1}')
  plugin_url=$(echo "$plugin_info" | awk '{print $2}')
  plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"

  if [ -d "$plugin_dir" ]; then
    echo -e "${GREEN} [已存在] $plugin_name${NC}"
  else
    echo -e "${YELLOW} [安装中] $plugin_name${NC}"
    git clone --depth=1 "$plugin_url" "$plugin_dir"

    if [ $? -eq 0 ]; then
      echo -e "${GREEN} 安装成功: $plugin_name${NC}"
    else
      echo -e "${RED} 安装失败: $plugin_name${NC}"
    fi
  fi
done
echo -e "${GREEN} 安装 autojump...${NC}"
git clone https://github.com/wting/autojump.git /tmp
chmod +x /tmp/autojump/install.py
/tmp/autojump/install.py

echo -e "${GREEN}>>> 检查并安装 omz 主题...${NC}"
# for now, only sapceship-theme install
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
if [ -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then
  echo -e "${GREEN} 安装成功: spaceship theme${NC}"
else
  echo -e "${RED} 安装失败: spaceship theme${NC}"
fi

# 3. TMUX
git submodule update --init --recursive
link_file "$DOTFILES_DIR/tmux/oh-my-tmux/.tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

# 4. NVIM
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi
link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# --------------------------------------------------------------------------
# 4. 结尾处理
# --------------------------------------------------------------------------
# 切换默认 Shell
if [[ "$SHELL" != */zsh ]]; then
  echo -e "${GREEN}>>> 正在切换默认 Shell 到 Zsh...${NC}"
  chsh -s "$(command -v zsh)"
fi

echo -e "${GREEN}>>> 安装完成！请重启终端。${NC}"
