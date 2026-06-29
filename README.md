# Fly — 跨智能体胶囊生态 🚀

> 一个 agent 无关的胶囊生态系统。一次部署，68+ 个 agent 通用。

## 快速开始

### 一键部署（推荐）

```bash
curl -fsSL https://flytomusk.xyz/install.sh | bash
```

### 通过 Vercel Skills 生态安装

如果已安装 `npx`（Node.js），可以只装 fly 技能到所有 agent：

```bash
npx skills add 1392324000/fly_to_Musk --skill fly --agent '*' -g -y
```

之后打开任意支持的 agent，输入 `fly` 即可启动生态初始化。

### 验证安装

```bash
npx skills list | grep fly
```

## 支持的 Agent

| Agent | 安装方式 | 路径 |
|-------|---------|-----|
| Hermes Agent | `npx skills` / 直接推送 | `~/.hermes/skills/fly/` |
| Claude Code | `npx skills` / 直接推送 | `~/.claude/skills/fly/` |
| Cursor | `npx skills` | `~/.cursor/skills/fly/` |
| Codex | `npx skills` | `~/.codex/skills/fly/` |
| OpenCode | `npx skills` | `~/.config/opencode/skills/fly/` |
| Windsurf | `npx skills` | `~/.codeium/windsurf/skills/fly/` |
| GitHub Copilot | `npx skills` | `~/.copilot/skills/fly/` |
| +60 更多 | `npx skills` | 自动检测 |

## 仓库结构

```
fly_to_Musk/
├── README.md               # 本文件
├── install.sh              # 一键部署脚本（curl | bash）
└── skills/
    └── fly/
        └── SKILL.md        # fly 胶囊生态技能指令
```

## 架构设计

```
用户命令 (fly / 胶囊 / 关键词)
  ↓
Agent 加载 SKILL.md → 识别为 fly 生态请求
  ↓
初始化检查 → Hub URL → venv → 基础设施胶囊 → 账户
  ↓
路由引擎 → 关键词匹配 → 胶囊执行
  ↓
Hub 胶囊市场 (搜索/下载/发布)
```

**核心原则：**
- 胶囊 ≠ agent skill — 胶囊是自包含的业务单元
- fly 只做路由，不做业务逻辑
- 一次部署，全 agent 覆盖

## 链接

- Hub: [https://flytomusk.xyz](https://flytomusk.xyz)
- Skills.sh: [https://skills.sh](https://skills.sh)
