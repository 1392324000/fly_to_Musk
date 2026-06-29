#!/usr/bin/env bash
# ==============================================================================
# Fly 技能 -- 跨 Agent 一键安装 v4
# ==============================================================================
# 职责 ONLY: 把 fly SKILL.md 安装到各 agent 的 skills 目录。
# Fly 生态初始化（~/.fly/、venv、胶囊下载）由 agent 读 SKILL.md 后执行。
# ==============================================================================
# 用法:
#   curl -fsSL https://flytomusk.xyz/install.sh | bash
#   或通过 npx skills:
#   npx skills add 1392324000/fly_to_Musk --skill fly --agent '*' -g -y
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${CYAN}INFO${NC}  $1"; }
ok()    { echo -e "${GREEN}OK${NC}    $1"; }
warn()  { echo -e "${YELLOW}WARN${NC}  $1"; }

HUB_URL="${1:-${FLY_HUB_URL:-https://flytomusk.xyz}}"

echo -e "\n${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Fly 技能 -- 跨 Agent 安装              ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}\n"

AGENT_COUNT=0

install_fly_skill() {
  local agent_dir="$1"
  local agent_name="$2"
  local target="$HOME/$agent_dir/fly"

  if [ -d "$HOME/$agent_dir" ]; then
    mkdir -p "$target"
    curl -fsSL "$HUB_URL/bootstrap/fly.md" > "$target/SKILL.md" 2>/dev/null && {
      ok "  ${agent_name} -> ~/${agent_dir}/fly/"
      AGENT_COUNT=$((AGENT_COUNT + 1))
    } || warn "  ${agent_name} -- download failed"
  fi
}

# Layer 1: npx skills ecosystem (68+ agents)
if command -v npx &>/dev/null; then
  info "npx detected, installing via Vercel skills ecosystem..."
  if npx skills add 1392324000/fly_to_Musk --skill fly --agent '*' -g -y 2>/dev/null; then
    ok "Vercel skills install complete"
    AGENT_COUNT=$((AGENT_COUNT + 1))
  else
    warn "npx skills failed, falling back to direct sniffing..."
  fi
else
  warn "npx not found (Node.js required), using direct file copy..."
fi

# Layer 2: direct agent path sniffing (fallback)
if [ "$AGENT_COUNT" -eq 0 ] || ! command -v npx &>/dev/null; then
  info "Sniffing agent paths..."
  install_fly_skill ".hermes/skills"          "Hermes Agent"
  install_fly_skill ".claude/skills"          "Claude Code"
  install_fly_skill ".cursor/skills"          "Cursor"
  install_fly_skill ".codex/skills"           "Codex"
  install_fly_skill ".config/opencode/skills" "OpenCode"
  install_fly_skill ".windsurf/skills"        "Windsurf"
  install_fly_skill ".continue/skills"        "Continue"
  install_fly_skill ".roo/skills"             "Roo Code"
  install_fly_skill ".openhands/skills"       "OpenHands"

  if [ "$AGENT_COUNT" -eq 0 ]; then
    warn "No known agents detected."
    echo "Manual: mkdir -p ~/<agent>/skills/fly && curl -fsSL $HUB_URL/bootstrap/fly.md > ~/<agent>/skills/fly/SKILL.md"
  fi
fi

echo ""
if [ "$AGENT_COUNT" -gt 0 ]; then
  echo -e "${GREEN}Done!${NC} Installed fly skill to $AGENT_COUNT agent(s)."
else
  echo -e "${YELLOW}Not installed to any agent.${NC}"
fi
echo "Open any agent and type 'fly' to start initialization."
