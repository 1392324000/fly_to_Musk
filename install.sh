#!/usr/bin/env bash
# ==============================================================================
# Fly æè½ -- è·¨ Agent ä¸é®å®è£ v4
# ==============================================================================
# èè´£ ONLY: æ fly SKILL.md å®è£å°å agent ç skills ç®å½ã
# Fly çæåå§åï¼~/.fly/ãvenvãè¶åä¸è½½ï¼ç± agent è¯» SKILL.md åæ§è¡ã
# ==============================================================================
# ç¨æ³:
#   curl -fsSL https://flytomusk.xyz/install.sh | bash
#   æéè¿ npx skills:
#   npx skills add 1392324000/fly_to_Musk --skill fly --agent '*' -g -y
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${CYAN}INFO${NC}  $1"; }
ok()    { echo -e "${GREEN}OK${NC}    $1"; }
warn()  { echo -e "${YELLOW}WARN${NC}  $1"; }

HUB_URL="${1:-${FLY_HUB_URL:-https://flytomusk.xyz}}"

echo -e "\n${BOLD}ââââââââââââââââââââââââââââââââââââââââââââ${NC}"
echo -e "${BOLD}â   Fly æè½ -- è·¨ Agent å®è£              â${NC}"
echo -e "${BOLD}ââââââââââââââââââââââââââââââââââââââââââââ${NC}\n"

AGENT_COUNT=0

install_fly_skill() {
  local agent_dir="$1"
  local agent_name="$2"
  local target="$HOME/$agent_dir/fly"

  if [ -d "$HOME/$agent_dir" ]; then
    mkdir -p "$target"
    curl -fsSL "$HUB_URL/bootstrap/fly.md" > "$target/SKILL.md" 2>/dev/null && {
      ok "  ${agent_name} â ~/${agent_dir}/fly/"
      AGENT_COUNT=$((AGENT_COUNT + 1))
    } || warn "  ${agent_name} -- download failed"
  fi
}

# Layer 1: npx skills ecosystem (68+ agents)
if command -v npx &>/dev/null; then
  info "æ£æµå° npxï¼éè¿ Vercel skills çæå®è£..."
  if npx skills add 1392324000/fly_to_Musk --skill fly --agent '*' -g -y 2>/dev/null; then
    ok "Vercel skills å®è£å®æ"
    AGENT_COUNT=$((AGENT_COUNT + 1))
  else
    warn "npx skills å¤±è´¥ï¼éçº§å°ç´æ¥åæ¢..."
  fi
else
  warn "æªå®è£ npxï¼é Node.jsï¼ï¼ä½¿ç¨ç´æ¥æä»¶å¤å¶..."
fi

# Layer 2: direct agent path sniffing (fallback)
if [ "$AGENT_COUNT" -eq 0 ] || ! command -v npx &>/dev/null; then
  info "éè¿ agent è·¯å¾åæ¢å®è£..."
  install_fly_skill ".hermes/skills"          "Hermes Agent"
  install_fly_skill ".claude/skills"          "Claude Code"
  install_fly_skill ".cursor/skills"          "Cursor"
  install_fly_skill ".codex/skills"           "Codex"
  install_fly_skill ".config/opencode/skills" "OpenCode"
  install_fly_skill ".windsurf/skills"        "Windsurf"
  install_fly_skill ".continue/skills"        "Continue"
  install_fly_skill ".roo/skills"             "Roo Code"
  install_fly_skill ".openhands/skills"       "OpenHands"
  install_fly_skill ".openclaw/skills"        "OpenClaw"

  if [ "$AGENT_COUNT" -eq 0 ]; then
    warn "æªæ£æµå°ä»»ä½å·²ç¥ agentã"
    echo "æå¨å®è£: mkdir -p ~/<agent>/skills/fly && curl -fsSL $HUB_URL/bootstrap/fly.md > ~/<agent>/skills/fly/SKILL.md"
  fi
fi

echo ""
if [ "$AGENT_COUNT" -gt 0 ]; then
  echo -e "${GREEN}â å®è£å®æï¼${NC} å·²å®è£å° $AGENT_COUNT ä¸ª agentã"
else
  echo -e "${YELLOW}â ï¸  æªå®è£å°ä»»ä½ agentã${NC}"
fi
echo "æå¼ä»»ä¸ agentï¼è¾å¥ fly å³å¯å¯å¨åå§åã"
