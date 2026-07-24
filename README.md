# Cline Harness 工程规则套装

> 让 AI 助手（Cline）产出**软件工程级别**的代码：层次清晰、逻辑分明、可扩展、易维护、健壮、泛化。

## 使用方法

### 1. 复制核心模板

将以下目录复制到**目标项目根目录**：

| 组件 | 路径 | 说明 |
|------|------|------|
| 规则与钩子 | `.clinerules/` | L1/L3 + hooks（必选） |
| Skills | `.agents/skills/` | 按需激活的技能（必选） |
| Speckit | `.specify/` | 需求驱动开发工具链（可选） |
| Harness 配置 | `harness.config.json` | 版本和 L2 模块配置 |

### 2. 配置 Cline

在 Cline 中导入 `cline-desktop-settings.json` 的 hooks / rules / skills / workflows 配置。

### 3. 核心组件说明

- **L1 核心规则**：`.clinerules/00-core.md`（安全红线）、`01-ponytail.md`（开发哲学）
- **Hooks**：PreToolUse.ps1（写文件前拦截）、PostToolUse.ps1（写文件后审计）
- **L3 工作流**：按任务类型选择工作流（详见 `.clinerules/workflows/INDEX.md`）

### 4. `.specify/` 目录说明

`.specify/` 是 Speckit 需求驱动开发工具链，**按需使用**：

| 场景 | 是否需要 `.specify/` | 说明 |
|------|---------------------|------|
| 日常 bug 修复、小改动 | 不需要 | 直接用 `bugfix-workflow.md` |
| 新功能开发（简单） | 不需要 | 直接用 `new-feature-workflow.md` |
| 大型功能、多模块、需要完整需求→计划→实施流程 | **需要** | 使用 speckit 工作流：`speckit-specify` → `speckit-plan` → `speckit-implement` |
| 需要项目宪法、架构决策追溯 | **需要** | speckit 提供完整的文档体系 |

**启用方式**：在项目根目录创建 `.specify/extensions.yml`，或在对话中说「用 speckit 流程」。

**不用 speckit 时**：`.specify/` 目录可忽略，不影响核心规则和工作流的使用。

### 4. 学习资料

- [Harness 编程教程](harness_coding_tutor.md) - 658 行"道法术器"方法论指南
- [CHANGELOG](CHANGELOG.md) - 版本历史

### 5. 自检（可选）

部署后运行 `verify-harness.ps1` 验证 Harness 包完整性：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1
```

**CI 自动检查**：推送到 GitHub 时，`.github/workflows/harness-ci.yml` 会自动运行验证。

## 日常使用

| 操作 | 说明 |
|------|------|
| **描述任务** | 直接用自然语言描述需求，Cline 会自动选择合适的工作流 |
| **说「收工」** | 触发 session-end：先验证 → 再更新 Memory → 再确认 |
| **用 speckit** | 说「用 speckit 流程」激活完整需求→实施工作流 |
