# Fly — 跨智能体胶囊生态 🚀

> 一个 agent 无关的胶囊生态系统。一次部署，68+ 个 agent 通用。

## 快速开始



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
