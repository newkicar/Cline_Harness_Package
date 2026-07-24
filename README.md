# Cline Harness 工程规则套装

> 让 AI 助手（Cline）产出**软件工程级别**的代码：层次清晰、逻辑分明、可扩展、易维护、健壮、泛化。
>
> 适用于 VS Code 插件 [Cline](https://github.com/cline/cline)。**版本 1.2.4** — 详见 [CHANGELOG.md](CHANGELOG.md)

---

## 快速开始

### 1. 部署

**方式 A：一键脚本（推荐）**

```powershell
# 在 Harness 包目录执行（PowerShell 终端）
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy.ps1 -TargetDir D:\Projects\my-app -L2 deepagents,pytorch
# 若本机 ExecutionPolicy 已允许，也可：.\deploy.ps1 -TargetDir ... -L2 ...
```

**方式 B：手动拷贝**

将以下目录/文件复制到**目标项目根目录**：

| 组件            | 路径                          | 说明                                       |
| --------------- | ----------------------------- | ------------------------------------------ |
| 规则与钩子      | `.clinerules/`                | L1/L3 + hooks（必选）                      |
| Skills          | `.agents/skills/`             | 按需激活的技能（必选）                     |
| Memory 模板     | `memory/`                     | 进度/阻塞/决策（必选）                     |
| 需求/设计模板   | `specs/`, `design/`           | L4 模板（必选）                            |
| Harness 配置    | `harness.config.json`         | L2 启用记录                                |
| Cline 设置      | `cline-desktop-settings.json` | 导入 Cline（hooks/rules/skills/workflows） |
| Speckit（可选） | `.specify/`                   | 需求驱动开发工具链                         |

**L2 领域规则（按需启用）**

L2 文件存放在 `.clinerules/l2/`，**默认不加载**。按项目类型启用：

| 项目类型           | 命令                        |
| ------------------ | --------------------------- |
| Agent / DeepAgents | `deploy.ps1 -L2 deepagents` |
| PyTorch / 深度学习 | `deploy.ps1 -L2 pytorch`    |

> **Windows 提示**：Cline Hook 仅支持 `.ps1`（如 `PreToolUse.ps1`）。部署/自检脚本同为 `.ps1`，请在 **PowerShell 终端**用 `-File` 运行；勿双击 `.ps1`（可能用记事本打开）。

部署后：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-cline.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1
```

**Cline 设置**

1. 在 Cline 中导入 `cline-desktop-settings.json` 的 hooks / rules / skills / workflows 配置
2. 在 **Cline MCP 设置**中安装并启用（Harness 通过 rules/workflow **指导 Agent 调用**，MCP 本体不在本包内）：
   - `superpowers` — 设计细化、TDD（见 `00-core.md` §1、§3.1）
   - `codebase-memory-mcp` — drift scan、CI feedback（见下方 MCP 集成表）

### 2. 日常使用

| 操作           | 说明                                                 |
| -------------- | ---------------------------------------------------- |
| **描述任务**   | 直接用自然语言描述需求，Cline 会自动选择合适的工作流 |
| **说「收工」** | 触发 session-end：先验证 → 再更新 Memory → 再确认    |
| **用 speckit** | 说「用 speckit 流程」激活完整需求→实施工作流         |

### 3. Memory Bank 更新

Harness 使用 `memory/` 目录作为项目的 Memory Bank（借鉴 Cline 官方 Memory Bank 理念）：

| 文件 | 用途 | 更新时机 |
|------|------|---------|
| `memory/progress.md` | Session 进度 + 阻塞 + 下次待办 | 每次 Session |
| `memory/blockers.md` | 阻塞记录 | 遇到问题时 |
| `memory/decisions.md` | 架构决策（ADR 格式） | 每次决策时 |
| `memory/architecture.md` | 当前架构快照 | 架构变更时 |

**收工自动更新**：说「收工」触发 `session-end.md`，自动执行 Phase 1 验证 + Phase 3 写入 Memory。

**手动更新**：也可以随时说「update memory bank」触发完整文档审查。

### 4. Harness 自检

部署后运行 `verify-harness.ps1` 验证 Harness 包完整性：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1
```

检查项包括：L1/L2 核心文件、PowerShell 语法、规则 ID 一致性、Hook 回归测试。

**GitHub Actions CI**：推送代码到 GitHub 时，`.github/workflows/harness-ci.yml` 会自动在 `windows-latest` 上运行相同验证，防止坏代码被合并。

### 5. 选择 L2 领域规则

L2 文件默认存放在 `.clinerules/l2/`，**不自动加载**。部署时 `deploy.ps1` 会扫描项目特征并提示启用命令，也可手动指定：

| 你的项目特征                  | 启用 L2          |
| ----------------------------- | ---------------- |
| Agent / `create_deep_agent()` | `-L2 deepagents` |
| PyTorch / `import torch`      | `-L2 pytorch`    |
| 普通项目                      | 不启用 L2        |

> **提示**：`deploy.ps1` 会在目标项目中扫描 `import torch`、`create_deep_agent(` 等特征，输出启用建议。你也可以跳过自动检测，直接运行 `deploy.ps1 -L2 deepagents,pytorch` 手动启用。

### 6. 选择工作流（按任务类型）

> **自然语言路由**：你不需要记命令，直接说需求即可。AI 会自动判断应该使用哪个工作流。详见 [natural-language-routing.md](.clinerules/workflows/natural-language-routing.md)。

| 你说 | AI 自动路由到 |
| ------ | ------------- |
| "我想从零做一个项目" | 立项 → new-feature-workflow |
| "项目跑不起来" | 建立启动基线 → `baseline-startup.md` |
| "我要加一个功能" | 功能开工评估 → 风险评估 |
| "上下文太长，换窗口继续" | 生成交接文本 → `context-handoff.md` |
| "项目越来越乱了" | AI 债务体检 → `ai-debt-audit.md` |
| "报错了，一直修不好" | 报错救援 → `error-rescue.md` |
| "修这个 bug" | bugfix-workflow |
| "用 speckit 流程" | speckit 子体系 |

| 任务类型                       | 使用                                                                    |
| ------------------------------ | ----------------------------------------------------------------------- |
| ★ 新功能 / API 变更 / 多模块   | `new-feature-workflow`（核心）                                           |
| ★ 修 bug / 小改动（< 100 行）  | `bugfix-workflow`（核心）                                               |
| ★ PyTorch 实验                 | `dl-experiment-workflow`（核心）                                        |
| ○ 项目跑不起来                 | `baseline-startup`                                                      |
| ○ 反复报错修不好               | `error-rescue`                                                          |
| 从零定义需求的大型功能         | `speckit/` 系列（需 `.specify/extensions.yml` 或说「用 speckit 流程」） |

### 7. 测试套件

Harness 自身包含完整的测试体系，确保规则变更不会引入回归：

```
tests/
├── test-hooks.ps1              # PostToolUse Hook 回归测试
├── test-pretooluse.ps1         # PreToolUse Hook 回归测试
└── fixtures/
    ├── pretooluse-debugger.json     # 测试 debugger 语句拦截
    ├── pretooluse-empty-except.json # 测试空 except 拦截
    ├── pretooluse-sql-inject.json   # 测试 SQL 注入拦截
    └── pretooluse-suspicious-class.json # 测试可疑抽象警告
```

运行方式：

```powershell
# 运行全部测试（含 verify-harness）
powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1

# 仅运行 Hook 测试
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\test-hooks.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\test-pretooluse.ps1
```

---

## 体系结构

```
Harness 体系
│
├── L1 — 核心规则（永远加载）
│   ├── 00-core.md              安全红线 / 代码质量底线 / 架构原则 / 交付清单
│   ├── 01-ponytail.md          开发哲学（lazy senior dev）
│   ├── CONTRIBUTING-RULES.md   如何添加新规则
│   ├── ARCHITECTURE.md         体系架构图
│   ├── GLOSSARY.md             术语表
│   └── hooks/                  Pre/Post ToolUse PowerShell 钩子
│       ├── PreToolUse.ps1      写文件前拦截（安全门禁）
│       ├── PostToolUse.ps1     写文件后审计（泄漏检测）
│       └── session-end.md      收工自动化流程
│
├── L2 — 领域特化规则（按需启用，默认在 l2/ 子目录）
│   ├── l2/02-deepagents-code-rule.md   Agent 项目
│   └── l2/03-pytorch-code-rule.md      深度学习项目
│
├── L3 — 工作流（按任务类型选择）
│   ├── ★ 核心工作流（必装，覆盖 90% 日常场景）
│   │   ├── new-feature-workflow.md   ★ 新功能 / API 变更 / 多模块
│   │   ├── bugfix-workflow.md        ★ 修 bug / 小改动
│   │   ├── dl-experiment-workflow.md PyTorch 实验
│   │   └── verify-changes.md         ★ 验证步骤（所有 workflow 共享）
│   ├── ○ 扩展工作流（已默认部署，无需 -Extras）
│   │   ├── baseline-startup.md       ○ 项目跑不起来
│   │   ├── error-rescue.md           ○ 反复报错修不好
│   │   ├── drift-scan-workflow.md    ○ 代码/文档/依赖漂移检测
│   │   ├── ci-feedback-workflow.md   ○ CI 失败自动修复
│   │   ├── task-risk-gates.md        ○ 任务风险分级
│   │   ├── context-handoff.md        ○ 上下文交接格式
│   │   ├── ai-debt-audit.md          ○ AI 债务体检
│   │   ├── user-acceptance-walkthrough.md  ○ 用户验收陪跑
│   │   └── natural-language-routing.md   ○ 自然语言路由索引
│   └── Speckit 子体系（可选激活）
│       └── speckit/                  10 个 speckit workflow
│
└── INDEX.md                      ← 工作流选择索引
│
└── L4 — 模板
    ├── specs/
    │   ├── PRD.md                        产品需求文档
    │   └── acceptance-criteria.md        验收标准
    ├── design/
    │   ├── HLD.md                        高层设计文档（可选，大功能时使用）
    │   └── contracts/                    API 契约（可选，涉及外部接口时使用）
    └── memory/
        ├── progress.md                   进度记录
        ├── blockers.md                   阻塞记录
        └── decisions.md                  架构决策记录 (ADR)
```

---

## MCP 集成

> MCP 安装在 **Cline MCP 设置**中；Harness 在 rules/workflow 中指导 Agent **何时调用**这些工具。

| MCP 服务器            | 工具                         | 用途                   | 集成文件              | 依赖条件 |
| --------------------- | ---------------------------- | ---------------------- | --------------------- | -------- |
| `superpowers`         | `test-driven-development` 等 | 设计细化、TDD 测试实现 | `00-core.md` §1、§3.1 | 需配置 superpowers MCP |
| `codebase-memory-mcp` | `search_graph`               | 毫秒级搜索代码符号     | drift-scan-workflow   | 需安装 MCP + 运行 index_repository |
| `codebase-memory-mcp` | `query_graph`                | Cypher 图查询          | drift-scan-workflow   | 需安装 MCP + 运行 index_repository |
| `codebase-memory-mcp` | `get_architecture`           | 架构概览               | drift-scan-workflow   | 需安装 MCP + 运行 index_repository |
| `codebase-memory-mcp` | `trace_path`                 | 调用链追溯             | ci-feedback-workflow  | 需安装 MCP + 运行 index_repository |
| `codebase-memory-mcp` | `detect_changes`             | 变更影响分析           | session-end           | 需安装 MCP + 运行 index_repository |

> ⚠️ **外部依赖**：MCP 工具需要用户自行安装和配置。Harness 在这些场景中扮演"指导何时调用"的角色。**不安装 MCP 不影响 Harness 核心功能**（Hooks 拦截、工作流文档、规则系统）。

安装 `codebase-memory-mcp` 后说一声「Index this project」即可使用。

---

## Hooks 说明

### PreToolUse（写文件前拦截）

> 当 PreToolUse 发现可自动修复的问题时返回 `FixSuggestion`，Cline 会在写入**前**自动修正（如补编码声明、格式化）。

| 规则 ID        | 名称                       | 动作  | 说明                                   |
| -------------- | -------------------------- | ----- | -------------------------------------- |
| SEC-READ-001   | BlockSensitiveFileRead     | BLOCK | 禁止读取生产环境配置、credentials、.pem、.key |
| SEC-READ-WARN-001 | WarnDotEnvRead         | WARN  | 读取 .env 文件时提醒（允许但警告） |
| SEC-CODE-001   | NoHardcodedCredentials     | BLOCK | 禁止硬编码密码/API Key/Token           |
| SEC-SQL-001    | NoSqlInjectionViaStringConcat | BLOCK | 禁止 SQL 字符串拼接，必须参数化查询   |
| MEM-BANK-001   | RequireMemoryBankHeader    | BLOCK | Memory Bank 文件必须有 Markdown header |
| MEM-BANK-002   | BlockPartialMemoryUpdate   | BLOCK | Memory Bank 禁止用 replace_in_file     |
| MEM-BANK-003   | ValidateMemoryBankFormat   | BLOCK | Memory Bank 格式校验                   |
| GEN-001        | NoTestDataInProductionCode | WARN  | 业务代码使用测试数据/示例值（工厂函数/dataclass/fixtures 目录豁免） |
| PT-YAGNI-001   | NoUnrequestedAbstractions  | WARN  | 设计模式命名的 class 可疑（dataclass/Pydantic/多 class 文件豁免） |
| PT-DEP-001     | NoUnrequestedDependencies  | WARN  | 禁止未请求的新依赖（ponytail）         |
| PT-BOILER-001  | NoUnrequestedBoilerplate   | WARN  | 禁止无人要求的 boilerplate（ponytail） |
| PT-MINIMAL-001 | FileSizeGuardWarn           | WARN  | 文件大小 >500 行建议拆分（ponytail）   |
| PT-MINIMAL-002 | FileSizeGuardAlert          | ALERT | 文件大小 >800 行强烈建议拆分（ponytail） |
| PT-MINIMAL-003 | FileSizeGuardBlock          | BLOCK | 文件大小 >1000 行必须拆分（ponytail）   |
| OPS-FMT-001    | RequireEncodingDeclaration | WARN  | Python 文件建议 UTF-8 编码声明         |
| CODE-PY-001    | NoEmptyExcept              | BLOCK | 禁止空的 except 子句（捕获所有异常包括 KeyboardInterrupt） |
| CODE-PY-002    | BroadExceptWarning         | WARN  | 宽泛的 except Exception: 捕获警告（合法但不推荐） |
| CODE-JS-001    | NoDebuggerStatement        | BLOCK | 禁止 debugger 语句                     |
| CODE-JS-002    | NoConsoleLogLeftover       | WARN  | 禁止生产代码残留 console.log           |
| DUP-001        | TooManyFunctionsInFile     | WARN  | 函数数量过多警告（Python >20, JS/TS >30） |

### PostToolUse（写文件后审计）

> 当 PostToolUse 发现可自动修复的问题时返回 `AutoFix`，Cline 会调用 `write_to_file` 自动修正。

| 规则 ID        | 名称                | 动作  | 说明                               |
| -------------- | ------------------- | ----- | ---------------------------------- |
| AUDIT-SEC-001  | DetectLeakedSecrets | ALERT | 检测 sk-/ghp-/AKIA 等密钥泄漏      |
| AUDIT-CODE-001 | NoDebugLeftovers    | WARN  | 检测 debugger/console.log/pdb 残留 |
| AUDIT-PY-002   | NoHardcodedPath     | WARN  | 检测硬编码 Windows 路径            |

---

## Speckit 子体系

> 一套完整的 Spec-Driven Development 工作流，适合从零定义需求的大型功能。

**激活条件**（二选一）：

1. 项目根目录存在 `.specify/extensions.yml`
2. 用户说「用 speckit 流程」

**工作流程**：

```
speckit-specify.md    → 创建/更新 feature spec
speckit-clarify.md    → 澄清需求（可选）
speckit-plan.md       → 生成实施计划
speckit-tasks.md      → 拆解任务
speckit-implement.md  → 执行实现
speckit-checklist.md  → 生成交付清单
speckit-converge.md   → 收敛完成
```

**与主工作流的区别**：

- 主工作流适合日常开发（已有明确需求时）
- Speckit 适合从 0 到 1 定义需求的场景
- Speckit 有自己的 memory 路径（`.specify/memory/`）

**Windows 环境**：Speckit 的 Bash 脚本（`.specify/scripts/bash/`）需要 **Git Bash** 或 **WSL**。安装 [Git for Windows](https://git-scm.com/download/win) 后确认 `where bash` 可用。PowerShell 扩展（如 agent-context）可直接运行。

**Manifest 路径**：workflow 文件位于 `.clinerules/workflows/speckit/`。更新 Speckit 文件后运行：

```powershell
powershell -File scripts_cline_harness/regenerate-manifest.ps1
```

---

## 自定义

| 需求             | 操作                                                               |
| ---------------- | ------------------------------------------------------------------ |
| PreToolUse 太严  | 编辑 `hooks/PreToolUse.ps1` 中对应规则的 `Enabled` 字段            |
| PostToolUse 太慢 | 项目未安装 `ruff`/`eslint` 时会自动跳过；建议项目内安装对应 linter |
| 小修 bug         | 用 `bugfix-workflow`，不必走完整 new-feature 流程                  |
| 添加新规则       | 参考 `CONTRIBUTING-RULES.md`                                       |
| 查看术语定义     | 参考 `GLOSSARY.md`                                                 |

---

## 目录结构

```
项目根/
├── .clinerules/
│   ├── 00-core.md                   # 核心规则（必选）
│   ├── 01-ponytail.md               # 开发哲学（必选）
│   ├── specify-rules.md             # Speckit agent-context（必选）
│   ├── l2/                          # L2 模板（默认不加载）
│   │   ├── 02-deepagents-code-rule.md
│   │   └── 03-pytorch-code-rule.md
│   ├── ARCHITECTURE.md
│   ├── CONTRIBUTING-RULES.md
│   ├── GLOSSARY.md
│   ├── hooks/
│   │   ├── PreToolUse.ps1
│   │   ├── PostToolUse.ps1
│   │   ├── session-end.md
│   │   └── lib/
│   │       ├── PreRules.ps1
│   │       └── HookParse.ps1
│   └── workflows/
│       ├── INDEX.md
│       ├── new-feature-workflow.md
│       ├── bugfix-workflow.md
│       ├── dl-experiment-workflow.md
│       ├── verify-changes.md
│       ├── drift-scan-workflow.md
│       ├── ci-feedback-workflow.md
│       ├── task-risk-gates.md
│       ├── natural-language-routing.md
│       ├── baseline-startup.md
│       ├── error-rescue.md
│       ├── context-handoff.md
│       ├── ai-debt-audit.md
│       ├── user-acceptance-walkthrough.md
│       └── speckit/
├── .agents/skills/
├── harness.config.json
├── CHANGELOG.md
├── deploy.ps1
├── verify-harness.ps1
├── setup-cline.ps1
├── scripts_cline_harness/regenerate-manifest.ps1
├── tests/
│   ├── test-hooks.ps1              # PostToolUse 回归测试
│   ├── test-pretooluse.ps1         # PreToolUse 回归测试
│   └── fixtures/                   # 测试输入用例
├── cline-desktop-settings.json
├── memory/
├── specs/
└── design/
```

---

## 起始话术

初始化项目时，可以在 Cline 中输入：

```
202xxxxx：这个项目是 [项目描述]。
```

```
请按照你的 rules 00-core.md 开始实施。
```

后续说「收工」即可触发完整的验证 + Memory 更新流程。

---

## 新对话话术

> 当对话上下文已满、或接手他人项目时，使用以下话术快速建立上下文。

开启新对话时，可以在 Cline 中输入：

```
202xxxxx：这个项目是 [项目描述]。

请先阅读以下文件，了解项目完整信息，然后按 PRD/架构/进度/阻塞/决策 五个维度总结发给我：

1. specs/PRD.md
2. specs/acceptance-criteria.md
3. design/HLD.md
4. design/contracts/（递归读取所有子文件）
5. memory/progress.md
6. memory/blockers.md
7. memory/decisions.md
8. memory/architecture.md
9. README.md
10. .clinerules/ARCHITECTURE.md

总结完后告诉我你是否准备好开始下一阶段。
```

```
请按照你的 rules 00-core.md 开始实施。
```

后续说「收工」即可触发完整的验证 + Memory 更新流程。
