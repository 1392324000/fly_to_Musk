---
name: fly
description: Fly capsule ecosystem — cross-agent bootstrap, routing, and capsule lifecycle management. Activates when user mentions fly, capsules, ecosystem, or any initialization keyword.
weight: 1000
triggers:
  - fly
  - capsule
  - ecosystem
  - bootstrap
  - init
  - startup
  - router
---

# Fly: 跨智能体胶囊生态路由引擎

> Fly 是一个**智能体无关的胶囊生态**。胶囊是自包含的可执行单元，由 fly 路由引擎调度。fly 可以做初始化检查、关键词路由、胶囊链触发，但**不做业务逻辑**。

---

## 1. 核心原则

1. **胶囊 ≠ agent skill。** 胶囊是基于许可证由 fly 调度的独立单元，不要尝试注册为 agent skill。
2. **每个胶囊完全自包含。** 脚本、配置、数据全在胶囊目录内，不混入同级目录。
3. **DB 是搜索索引，不是胶囊备份。** Hub 的 DB 只存搜索所需字段，完整内容在磁盘文件。
4. **fly 不做业务逻辑。** 只做初始化检查和路由。
5. **胶囊不能覆盖 → 释放给 agent。**

## 2. 环境变量

```bash
# Hub 地址（唯一注入点）
export FLY_HUB_URL="https://flytomusk.xyz"
```

所有组件通过此变量获取 Hub 地址。

## 3. 目录结构

```
~/.fly/
├── capsules/
│   ├── skill/<cid>/        # 系统级技能胶囊（共享）
│   ├── knowledge/<cid>/    # 系统级知识胶囊（共享）
│   └── registry.json       # 胶囊注册表
├── users/
│   ├── current.json        # 当前账户
│   └── <address>/          # 各用户数据
│       ├── preferences.json # {lang: "zh"} 等
│       ├── wallet.json      # 钱包密钥
│       └── auth.json        # Hub 认证
├── venv/                   # 共享虚拟环境
├── scripts/                # 辅助脚本
└── cron_results/           # 定时任务结果
```

## 4. 初始化流程

### 第 0 步：语言设置
询问用户偏好语言，写入 `preferences.json`。所有输出使用此语言。

### 第 1 步：Hub URL 注入
```bash
export FLY_HUB_URL="https://flytomusk.xyz"
```

### 第 2 步：虚拟环境
```bash
~/.fly/venv/bin/pip install requests cryptography eth-account mnemonic bip32 ecdsa pycryptodome
```

### 第 3 步：基础设施胶囊
从 `~/.fly/capsules/registry.json` 读取基础设施胶囊列表，从 Hub 下载缺失的：
- `account_management` (📦 账户管理)
- `wallet_management` (💳 钱包管理)
- `capsule_creator` (🏗️ 胶囊创作)
- `capsule_purchase` (🛒 胶囊购买)
- `cron_manager` (⏰ 定时任务)

### 第 4 步：账户状态检查
运行 `account_setup.py --status` 检查登录状态。

### 第 5 步：Hub 连通性检查
```bash
curl -sf https://flytomusk.xyz/api/capsules/search?q=
```

## 5. 路由引擎

### 路由顺序
```
用户输入
  → 活跃工作流（step guard）→ 有则推进
  → 本地打分（已安装胶囊关键词匹配）
    → 最佳分 > 0 → 路由到该胶囊执行
    → 全部 0 分 → 调 Hub API 搜索
      → 有结果 → 已安装用本地 / 未安装引导下载
      → 无结果 → 释放给 agent
```

### 打分规则
每个关键词命中累加 `len(keyword)^0.5` 分，精确匹配翻倍。

### 胶囊执行
agent 读取胶囊的 `natural_language` 和 `pseudocode`，按工作流步骤执行胶囊脚本。每次调用设环境变量：
- `FLY_CAPSULE_ID` — 当前胶囊 ID
- `FLY_CAPSULE_DIR` — 当前胶囊目录

## 6. 胶囊交互设计规则

### 可选输入用 choices，不用 text input
```markdown
# ❌ 错误：text input → 回车产生空串，防不胜防
code = clarify('请输入邀请码（没有直接回车）')

# ✅ 正确：选择题先行
has = clarify('是否有邀请码？', choices=['有', '没有/使用默认'])
code = clarify('请输入8位邀请码') if has == '有' else ''
```

### 每个分支入口加执行层 guard
胶囊的 natural_language 和 pseudocode 中，每个 if/else 分支入口必须用 `▶ 必须执行：<分支名>` + `⚠` 标注。

### 一次只问一个问题
逐轮收集，最后一轮统一执行。不得同时抛出多个问题，不得收一项执行一项。

## 7. Cron 系统

cron_manager 胶囊是定时任务注册中心。Hermes cron 是执行引擎。Agent 是桥接层。

架构：
```
cron_manager 胶囊        ← 注册表 + 管理 CLI
agent cron 系统          ← 定时执行 + 结果交付
agent                    ← 桥接注册表 ↔ cron 系统
```

## 8. 关键词统一规则

- 所有胶囊的关键词字段为纯英文数组
- 路由时用户输入默认匹配英文关键词
- 未命中时 agent 自动将查询翻译为英文再匹配

## 9. 用户偏好语言

首次初始化选择偏好语言后，所有机械步骤输出、状态摘要、agent 回复均使用此语言。
机制：胶囊 pseudocode 只写自然意图，agent 读 `preferences.lang` 自动渲染对应语言。
