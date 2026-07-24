# Cline Harness 工程规则套装

> 让 AI 助手（Cline）产出**软件工程级别**的代码：层次清晰、逻辑分明、可扩展、易维护、健壮、泛化。

## 使用方法

### 1. 复制核心模板

将以下目录复制到**目标项目根目录**：

| 组件 | 路径 | 说明 |
|------|------|------|
| 规则与钩子 | `.clinerules/` | L1/L3 + hooks（必选） |
| Skills | `.agents/skills/` | 按需激活的技能（必选） |
| Memory 模板 | `memory/` | 进度/阻塞/决策（必选） |
| 需求/设计模板 | `specs/`, `design/` | L4 模板（必选） |
| Speckit | `.specify/` | 需求驱动开发工具链（可选） |
| Harness 配置 | `harness.config.json` | 版本和 L2 模块配置 |

### 2. 配置 Cline

在 Cline 中导入 `cline-desktop-settings.json` 的 hooks / rules / skills / workflows 配置。

### 3. 核心组件说明

- **L1 核心规则**：`.clinerules/00-core.md`（安全红线）、`01-ponytail.md`（开发哲学）
- **Hooks**：PreToolUse.ps1（写文件前拦截）、PostToolUse.ps1（写文件后审计）
- **L3 工作流**：按任务类型选择工作流（详见 `.clinerules/workflows/INDEX.md`）
- **L4 模板**：PRD、HLD、验收标准、API 契约、Memory Bank

### 4. 学习资料

- [Harness 编程教程](harness_coding_tutor.md) - 658 行"道法术器"方法论指南
- [CHANGELOG](CHANGELOG.md) - 版本历史

## 日常使用

| 操作 | 说明 |
|------|------|
| **描述任务** | 直接用自然语言描述需求，Cline 会自动选择合适的工作流 |
| **说「收工」** | 触发 session-end：先验证 → 再更新 Memory → 再确认 |
| **用 speckit** | 说「用 speckit 流程」激活完整需求→实施工作流 |
