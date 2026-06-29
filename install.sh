#!/usr/bin/env bash
# ==============================================================================
# Fly 胶囊生态 — 一键部署脚本 v3.0
# ==============================================================================
# 用法:
#   curl -fsSL https://flytomusk.xyz/install.sh | bash
#   或从 GitHub:
#   npx skills add 1392324000/fly_to_Musk --agent '*' -g -y
# ==============================================================================
set -euo pipefail

# ── 颜色 ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${CYAN}INFO${NC}  $1"; }
ok()    { echo -e "${GREEN}OK${NC}    $1"; }
warn()  { echo -e "${YELLOW}WARN${NC}  $1"; }
fail()  { echo -e "${RED}FAIL${NC}  $1"; exit 1; }

HUB_URL="${1:-${FLY_HUB_URL:-https://flytomusk.xyz}}"

echo -e "\n${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Fly 胶囊生态 — 一键部署 v3.0         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}\n"

# ════════════════════════════════════════════
# 阶段 1: 环境检查
# ════════════════════════════════════════════
info "检查环境..."
command -v python3 >/dev/null 2>&1 || fail "需要 Python 3"
PYTHON=$(command -v python3)
ok "Python: $($PYTHON --version 2>&1)"

# ════════════════════════════════════════════
# 阶段 2: 跨 Agent 技能安装（两层策略）
# ════════════════════════════════════════════
AGENT_COUNT=0

install_fly_skill() {
  local agent_dir="$1"
  local agent_name="$2"
  local target="$HOME/$agent_dir/fly"

  if [ -d "$HOME/$agent_dir" ]; then
    mkdir -p "$target"
    curl -fsSL "$HUB_URL/bootstrap/fly.md" > "$target/SKILL.md" 2>/dev/null && {
      ok "  ${agent_name} → ~/${agent_dir}/fly/"
      AGENT_COUNT=$((AGENT_COUNT + 1))
    } || warn "  ${agent_name} — 下载失败"
  fi
}

# 第 1 层: npx skills 生态（覆盖 68+ agents）
if command -v npx &>/dev/null; then
  info "检测到 npx，尝试通过 Vercel skills 生态安装..."
  if npx skills add 1392324000/fly_to_Musk --skill fly --agent '*' -g -y 2>/dev/null; then
    ok "Vercel skills 生态安装完成（覆盖全部检测到的 agent）"
    AGENT_COUNT=$((AGENT_COUNT + 1))
  else
    warn "Vercel skills 安装失败，降级到直接嗅探..."
  fi
else
  warn "未安装 npx（需要 Node.js），使用直接文件复制..."
fi

# 第 2 层: 直接嗅探已知 agent 路径（降级/补漏）
if [ "$AGENT_COUNT" -eq 0 ] || ! command -v npx &>/dev/null; then
  info "通过 agent 路径嗅探安装..."

  # 常见 agent 全局路径表
  install_fly_skill ".hermes/skills"          "Hermes Agent"
  install_fly_skill ".claude/skills"          "Claude Code"
  install_fly_skill ".cursor/skills"          "Cursor"
  install_fly_skill ".codex/skills"           "Codex"
  install_fly_skill ".config/opencode/skills" "OpenCode"
  install_fly_skill ".windsurf/skills"        "Windsurf"
  install_fly_skill ".agents/skills"          "Cline/Gemini/GitHub Copilot"
  install_fly_skill ".continue/skills"        "Continue"
  install_fly_skill ".roo/skills"             "Roo Code"
  install_fly_skill ".openhands/skills"       "OpenHands"

  if [ "$AGENT_COUNT" -eq 0 ]; then
    warn "未自动检测到已知 agent。"
    warn "你可以手动安装 fly 技能到任意 agent 的 skills 目录："
    warn "  mkdir -p ~/<agent>/skills/fly"
    warn "  curl -fsSL $HUB_URL/bootstrap/fly.md > ~/<agent>/skills/fly/SKILL.md"
    echo ""
  fi
fi

# ════════════════════════════════════════════
# 阶段 3: Fly 生态基础设施
# ════════════════════════════════════════════

# Hub URL 注入
info "配置环境..."
grep -q 'FLY_HUB_URL' ~/.bashrc 2>/dev/null || \
  echo "export FLY_HUB_URL=\"$HUB_URL\"" >> ~/.bashrc
export FLY_HUB_URL="$HUB_URL"
ok "FLY_HUB_URL 已配置"

# 目录结构
mkdir -p ~/.fly/{capsules/{skill,knowledge},users,venv,scripts,cron_results}
ok "目录结构已创建"

# 虚拟环境
if [ ! -f ~/.fly/venv/bin/python3 ]; then
  info "创建 Python 虚拟环境..."
  python3 -m venv ~/.fly/venv
  ~/.fly/venv/bin/pip install --quiet \
    requests cryptography eth-account mnemonic bip32 ecdsa pycryptodome 2>/dev/null || \
    warn "部分 pip 依赖安装失败"
  ok "虚拟环境已创建"
else
  ok "虚拟环境已存在"
fi

# Current.json
if [ ! -f ~/.fly/users/current.json ]; then
  echo '{"current_user": null}' > ~/.fly/users/current.json
fi

# ════════════════════════════════════════════
# 完成
# ════════════════════════════════════════════
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Fly 生态部署完成！                     ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "  环境:  $HUB_URL"
echo "  Agent: $AGENT_COUNT 个 agent 已安装 fly 技能"
echo "  路径:  ~/.fly/"
echo ""
echo "  首次使用需要初始化: agent 会引导你完成语言选择、"
echo "  钱包创建和账户注册。直接输入: fly"
echo ""
echo "  💡 跨 agent 覆盖验证:"
echo "     npx skills list | grep fly    # 看哪些 agent 装了"
echo "     npx skills remove fly         # 卸载"
echo ""
