# Harness Coding 教程

> 从入门到精通：让 AI 产出软件工程级别代码的完整体系
>
> 版本：1.2.4 | 基于 `.clinerules/` 体系整理

---

## 学习路线

```
第一部分：为什么需要 Harness？（道）
   ↓
新增：Harness 的设计哲学（大模型 × 软件工程）
   ↓
第二部分：编程范式（法）
   ↓
第三部分：工程保障（术）
   ↓
第四部分：工具选型与实践（器）
   ↓
第五部分：总结与展望
```

---

## 道：为什么需要 Harness？

### 1. AI 编码的困境

AI 写代码快，但质量不稳定。常见问题：

| 问题 | 后果 |
|------|------|
| 硬编码测试数据 | 生产环境数据污染 |
| 截断长字符串 | URL/Base64/SQL 执行失败 |
| 启动时自动 seed | 隐蔽、难审计、生产危险 |
| 用正则匹配自然语言 | 语义理解差，误匹配 |
| 文件过大、职责不清 | 违反单一职责，难维护 |

**根本原因**：AI 缺乏"工程边界"意识。没有宪法的 AI ≈ 能力强但没经验的实习生。

### 2. Harness 的定位

Harness 是**给 AI 编码助手用的工程规范系统**。

- 不是产品代码，而是**规范 AI 如何产生产品代码**
- 类比：宪法 → 法律 → 行政法规 → 部门规章
- 目标：让 AI 产出**层次清晰、逻辑分明、可扩展、易维护、健壮、泛化**的代码

### 3. 核心思想

| 思想 | 说明 |
|------|------|
| **规则不是限制** | 而是防止速度失控，让 AI 生成更有序 |
| **模型负责生成，Harness 负责管理** | 结果必须可见、可控、可验证、可维护 |
| **写完代码 ≠ 完成任务** | 必须先验证，再说完成 |

> **能力边界说明**：Harness 的核心能力是**规则定义 + Hooks 拦截**（PreToolUse/PostToolUse），这是机械执行的 PowerShell 脚本。其余能力（CI 反馈、图谱查询、TDD 强制）依赖外部工具（GitHub Actions、MCP 服务器、superpowers），Harness 在这些场景中扮演"指导何时调用"的角色。

### 4. 三层防线

```
预防（PreToolUse） → 审计（PostToolUse） → 验证（Workflow）
     ↓                    ↓                    ↓
  写文件前拦截         写文件后扫描         全项目验证
  安全门禁             泄漏检测             测试/Lint/CI
```

---

## 设计哲学：大模型 × 软件工程

> 本节解释 Harness 为什么这样设计——针对大模型的 8 大特点，我们采取了 8 大应对策略。

### 5. 大模型的特点与 Harness 的应对

| # | 大模型特点 | Harness 应对策略 | 对应机制 |
|---|-----------|-----------------|---------|
| 1 | **注意力稀释**：prompt 越长，AI 越容易忽略关键规则 | **渐进式披露**：规则分层，按需加载 | L1 常驻 / L2 检测 / L3 路由 / Skills 按需 |
| 2 | **幻觉**：AI 编造不存在的 API/参数 | **约束优先**：告诉 AI 什么不能做，比告诉该怎么做更有用 | PreToolUse BLOCK 规则 + 安全红线 |
| 3 | **缺乏私域知识**：不知道你的业务逻辑和项目约定 | **真源文档注入**：把私有知识精准送达 | PRD/HLD/Architecture/Memory Bank |
| 4 | **上下文窗口有限**：无法记住所有细节 | **Map 式导航**：像地图一样，走到哪里看到哪里 | 自然语言路由 + 工作流选择 |
| 5 | **缺乏长期记忆**：每次对话都是"新开始" | **Memory Bank**：跨会话延续状态 | progress.md / blockers.md / decisions.md |
| 6 | **过度自信**：AI 倾向于给出肯定答案 | **测试先行**：用可执行规格约束 AI | BDD/TDD 强制流程 |
| 7 | **模式匹配偏好**：AI 倾向于复制粘贴示例 | **反硬编码**：拒绝死代码，强制泛化 | GEN-001 + Ponytail 阶梯 + 3 变体测试 |
| 8 | **难以权衡取舍**：AI 不知道什么是"够用" | **编码品味**：最小可行方案优先 | Ponytail 7 层过滤 + PT-MINIMAL 文件大小守卫 |

### 6. 渐进式披露：为什么文件要这么多？

**核心问题**：为什么不把所有规则写在一个文件里？

**答案**：因为大模型有注意力机制。一次性给 AI 100 条规则，它只会记住最后 5 条。

```
渐进式披露的 5 个层级：

Level 0: Cline 启动时加载（永远不忘）
  └── L1 核心规则（00-core.md, 01-ponytail.md）
      ├── 安全红线 5 条 → 永远不忘记
      ├── 异常传播策略 → 内层不吞，边界处理
      └── 交付清单 → 写完 ≠ 完成

Level 1: 根据项目特征手动启用（按需加载）
  └── L2 领域规则（deploy.ps1 -L2 显式启用，不自动检测）
      ├── Agent 项目 → 02-deepagents-code-rule.md
      └── PyTorch 项目 → 03-pytorch-code-rule.md

> **注意**：L2 不会自动检测项目特征。通过 `deploy.ps1 -L2 deepagents,pytorch` 显式启用 = 用户明确知道"这个任务需要 L2"。

Level 2: 根据任务类型路由（用户触发）
  └── L3 工作流（自然语言 → 选择合适 workflow）
      ├── "修 bug" → bugfix-workflow
      ├── "跑不起来" → baseline-startup
      └── "报错了修不好" → error-rescue

Level 3: 根据 Skill 描述由 AI 自主决定（AI 触发）
  └── .agents/skills/*/SKILL.md
      ├── description 告诉 AI 这个 Skill 做什么
      ├── description 告诉 AI 什么时候用
      └── AI 自己决定是否需要激活

Level 4: 运行时通过 MCP 按需查询（代码触发）
  └── codebase-memory-mcp
      ├── search_graph：找代码定义
      ├── query_graph：复杂图查询
      └── trace_path：调用链追溯
```

**设计理由**：

```
如果不做渐进式披露：
  → 一次性给 AI 所有规则 → 注意力稀释 → 关键规则被忽略
  → 上下文窗口爆满 → 响应变慢 → 质量下降

做了渐进式披露后：
  → AI 只看到当前需要的规则 → 注意力集中 → 执行质量高
  → 按需加载 → 上下文窗口高效利用
  → 像地图一样，走到哪里看到哪里，不需要一开始就展示全图
```

### 7. 信息架构：按什么维度分类文件？

文件分类不是随意的，遵循两个正交维度：

```
维度一：按「变化频率」分类

┌─────────────────────────────────────────────────────┐
│ 低频变化（几个月改一次）                              │
│   L1 核心规则：安全红线、架构原则                     │
├─────────────────────────────────────────────────────┤
│ 中频变化（每个项目不同）                              │
│   L2 领域规则：随项目类型启用                         │
├─────────────────────────────────────────────────────┤
│ 高频变化（每次任务不同）                              │
│   L3 工作流：按任务类型选择                           │
├─────────────────────────────────────────────────────┤
│ 最高频变化（每次项目不同）                            │
│   L4 模板：PRD/HLD/Memory — 每个项目内容不同           │
└─────────────────────────────────────────────────────┘

维度二：按「执行时机」分类

┌─────────────────────────────────────────────────────┐
│ 静态规则：.clinerules/*.md → Cline 加载后常驻          │
│   → AI 随时可以查阅                                  │
├─────────────────────────────────────────────────────┤
│ 动态流程：workflows/*.md → 按需激活                   │
│   → 用户触发或自然语言路由时选择                      │
├─────────────────────────────────────────────────────┤
│ 运行时钩子：hooks/*.ps1 → 每次写文件触发               │
│   → 机械执行，不依赖 AI 理解                          │
└─────────────────────────────────────────────────────┘
```

### 8. 私有知识注入策略

大模型不掌握你的业务逻辑。Harness 通过 5 种方式把私有知识精准送达：

| 私有知识类型 | 注入方式 | 对应文件 | 注入时机 |
|-------------|---------|---------|---------|
| **业务规则** | 真源文档 | `specs/PRD.md`, `design/HLD.md` | 项目初始化时 |
| **架构决策** | 架构真源 + ADR | `memory/architecture.md`, `memory/decisions.md` | 架构变更时 |
| **项目约定** | 核心规则 + Hooks | `00-core.md`, `.clinerules/hooks/` | 部署时 |
| **领域知识** | L2 规则 + Skills | `l2/*.md`, `.agents/skills/` | 项目检测/Skill 激活时 |
| **进度状态** | Memory Bank | `memory/progress.md`, `memory/blockers.md` | 每次 Session 结束时 |

**关键设计**：Memory Bank 必须用 `write_to_file` 而非 `replace_in_file`，因为：

- `write_to_file` = 全量覆盖，AI 看到的是完整最新状态
- `replace_in_file` = 局部替换，AI 可能基于过期上下文修改

### 9. 注意力管理机制

规则文件不是平铺的，而是按**优先级**排列：

```
00-core.md 的结构设计：

§1 角色与工作流          ← AI 最先看到：理解自己是谁、怎么工作
§2 安全红线              ← 第二条：绝对不能忘的底线
§3 代码质量底线           ← 第三条：泛化、语义、长字符串
§4 架构与可维护性         ← 第四条：分层、职责、依赖
§5 交付自检清单          ← 最后一条：完成前的最终确认
```

**为什么安全红线在前？**

- 大模型的"近因效应"：靠近末尾的内容更容易被关注
- 但安全是第一位的，所以即使它在前面，也要通过 L1 常驻加载确保不被遗忘
- 交付清单放最后：AI 在生成最终回答前会扫到

**为什么 L2 默认不加载？**

- L2 是领域特化规则，与当前任务无关
- 加载 L2 会稀释 L1 安全红线的注意力
- 通过 `deploy.ps1 -L2` 显式启用 = AI 明确知道"这个任务需要 L2"

### 10. 记忆延续机制

大模型没有长期记忆。Harness 通过 Memory Bank 模拟"记忆"：

```
Session 结束时的自动记忆更新（session-end）：

触发条件：disconnect / manual / "收工"
  ↓
Phase 1: 验证（调用 verify-changes）
  ↓
Phase 2: 更新 Memory
  ├── progress.md 追加 Session 记录
  ├── blockers.md 更新阻塞项
  └── decisions.md 记录架构决策
  ↓
Phase 3: 确认（用户检查 Memory 是否正确）
```

**为什么 session-end 要自动触发？**

- 依赖 AI "记得"更新进度 = 不可靠
- 自动触发 = 机械执行，确保每次 Session 都有记录
- 类似 Git 的 `pre-commit` hook：不让你选择"更不更新"，只让你选择"更不提交"

---

## 法：编程范式

### 11. BDD/TDD 开发范式

#### BDD（行为驱动开发）：Given-When-Then 思维

BDD 的核心是**用自然语言描述行为**，而不是用代码描述实现。

```gherkin
Feature: 用户登录

  Scenario: 正确凭据登录成功
    Given 用户已注册
    When 用户输入正确的用户名和密码
    And 点击登录按钮
    Then 跳转到首页
    And 显示欢迎消息
```

**Harness 强制流程**：

1. BDD 行为定义 → 用户确认 → TDD 测试实现 → 代码实现
2. **严禁在测试代码完成前编写任何业务实现代码**

#### TDD（测试驱动开发）：测试先行

TDD 的红绿循环：RED → GREEN → REFACTOR

**为什么先写测试能防止 AI 乱写代码？**

- AI 不能"边写边想"，先写测试迫使 AI 先想清楚需求
- 测试是**可执行的规格说明**，比自然语言更精确
- 测试覆盖**边界情况和异常路径**，AI 容易忽略这些

### 12. 泛化原则——拒绝死代码

**死代码** = 仅适配单一测试用例的代码逻辑。

#### 反硬编码的三层境界

| 境界 | 做法 | 示例 |
|------|------|------|
| 第一层：变量抽象 | 示例数据 → 常量 | `DEFAULT_BUDGET = config.get("default_budget", 0)` |
| 第二层：工厂函数 | 硬编码字符串 → 工厂 | `create_user(name="test")` |
| 第三层：配置驱动 | 环境相关值 → 配置文件 | `API_ENDPOINT = os.getenv("API_ENDPOINT")` |

#### 鲁棒性自查：3 个变体输入测试法

写完代码后，自问：
> "3 个**不在 Prompt 中**的变体输入能否被正确处理？"

### 13. 语义理解 > 正则

| 场景 | 推荐方式 |
|------|---------|
| UUID、ISO 时间戳、手机号 | ✅ 正则（强格式死数据） |
| 用户消息、LLM 输出 | ✅ 语义理解（可变格式） |

**判定标准**：若该内容可换种说法表达 → **严禁使用正则**。

### 14. 长字符串完整性原则

| 用途 | 是否可截断 |
|------|-----------|
| 展示/调研/分析 | ✅ 可截断 |
| 程序运行依赖 | ❌ 禁止截断 |

**判断标准**：如果字符串被 `curl`、`requests.get()`、`os.path.join()`、Agent 工具调用等直接使用 → 禁止截断。

**AI 自检**：在输出长字符串前，自问「这个字符串会被程序直接运行吗？」→ 是则完整输出。

### 15. Seed Data 必须显式调用

| 做法 | 是否推荐 |
|------|---------|
| `python manage.py seed_demo_data` | ✅ 显式调用 |
| `SEED_DEMO=true python app.py` | ✅ 环境变量控制 |
| 启动时自动判断并写入 | ❌ 禁止 |

### 16. Ponytail 编码品味

> Lazy means efficient, not careless. The best code is the code never written.

**编码品味阶梯**：

```
1. Does this need to be built at all? (YAGNI)
2. Does it already exist in this codebase?
3. Does the standard library already do this?
4. Does a native platform feature cover it?
5. Does an already-installed dependency solve it?
6. Can this be one line?
7. Only then: write the minimum code that works.
```

**核心规则**：

- 不创建未请求的抽象
- 能不引入新依赖就不引入
- 不生成无人要求的 boilerplate
- 删除优于添加，无聊优于巧妙

---

## 术：工程保障

### 17. 安全红线——不可逾越的底线

> 唯一权威来源。其他 rules/skills 引用本节，勿重复展开。

1. **输入验证**：所有外部输入在 API 层校验
2. **SQL**：必须参数化查询或 ORM
3. **加密**：禁止自实现加密算法，使用 BCrypt/Argon2
4. **敏感信息**：禁止日志记录 PII、Token、密码
5. **依赖**：不引入已知严重漏洞的包

**异常传播策略**：

- **内层逻辑**：严禁 `try-catch` 吞异常。遇错即抛
- **系统边界**：添加结构化错误处理

### 18. 验证闭环——写完代码 ≠ 完成任务

> ⚠️ **铁律：写完代码 ≠ 完成任务。必须先验证，再说完成。**

**Think-Act-Verify 标准工作流**：

```
Context → Plan → Develop → Verify → Persist
   ↓        ↓       ↓        ↓        ↓
读上下文  3句话  设计/TDD  验证     更新Memory
         说明范围 测试先行  闭环     状态
```

**Hook 审计 vs Workflow 验证**：

| 维度 | Hook 审计 | Workflow 验证 |
|------|----------|--------------|
| 触发时机 | 每次写文件后 | Session 结束时 |
| 扫描范围 | 单个文件（快、局部） | 全项目（慢、完整） |
| 互补关系 | Hook 发现问题 → Workflow 确认 | |

### 19. CI 反馈闭环

> ⚠️ **可选功能**：Harness 提供 `ci-feedback-workflow.md` 文档指导"如果 CI 失败了该怎么修复"，但 Harness 本身不包含 CI 基础设施（GitHub Actions / GitLab CI）。

如果你配置了 CI：

```
AI 写代码 → CI 检查 → 
  ├─ 通过 → 告诉你「没问题」
  └─ 失败 → 参考 ci-feedback-workflow.md 手动修复
```

如果你没有 CI：

- 使用 `verify-changes.md` 做本地验证
- CI 是可选的，不影响 Harness 核心功能

### 20. 任务风险分级

| 风险等级 | 说明 | 治理成本 |
|---------|------|---------|
| 普通工程任务 | 修 bug、局部 UI、单文件改动 | 窄查、窄改、窄验 |
| 轻量任务 | docs/copy/静态资源/样式 | scoped read-edit-validate |
| 标准任务 | 功能或流程变更 | 需要真源 + 用户确认 |
| 高风险任务 | 架构/数据库/权限/支付/部署 | 强制完整治理 |

### 21. 真源文档体系

**真源文档 = 项目的单一事实来源**

- 聊天决策不是正式真源，直到写入相关真源文档
- 用户中途变更需求 → 先更新真源文档，再写代码

**核心真源文档**：

| 文档 | 用途 | 对应功能 |
|------|------|---------|
| `specs/PRD.md` + `design/HLD.md` | 项目简报 + 技术选型 | 替代 project-brief + tech-stack |
| `memory/progress.md` + `specs/acceptance-criteria.md` | 当前阶段实施真源 + 验收标准 | 阶段进度与交付标准 |
| `memory/decisions.md` + `tests/` | 决策记录 + 测试证据 | 替代 AGENTS.md + quality-evidence |
| `memory/architecture.md` | 架构真源 | 架构设计与变更记录 |

> **注意**：这些文件是**模板**，需要用户在实际项目中填充内容。Harness 提供结构和最佳实践指导，但不会自动写入项目具体内容。

**建议**：每个阶段开始前提问自己——"我有足够的真源文档来做这个决定吗？"如果没有，先写文档再写代码。

### 22. 自然语言路由

用户不需要记命令，直接说需求即可。AI 自动判断应该使用哪个工作流。

| 用户说 | AI 自动路由到 | 对应工作流文件 |
|--------|-------------|---------------|
| "我想从零做一个项目" | 立项 → new-feature-workflow | `new-feature-workflow.md` |
| "项目跑不起来" | 建立启动基线 | `baseline-startup.md` |
| "我要加一个功能" | 功能开工评估 → 风险评估 | `new-feature-workflow.md` + `task-risk-gates.md` |
| "上下文太长，换窗口继续" | 生成交接文本 | `context-handoff.md` |
| "项目越来越乱了" | AI 债务体检 | `ai-debt-audit.md` |
| "报错了，一直修不好" | 报错救援 | `error-rescue.md` |
| "修这个 bug" | 修 bug / 小改动 | `bugfix-workflow.md` |
| "PyTorch 实验" | DL 实验流程 | `dl-experiment-workflow.md` |
| "用 speckit 流程" | Speckit 子体系 | `speckit/` 系列 |

### 23. AI 债务体检

审计 AI 生成的重复文件、假数据、自定义 wrapper、依赖蔓延。

| 债务类型 | 检查项 |
|---------|--------|
| 重复文件 | 同名或相似名的组件/工具函数/测试文件 |
| 假数据 | Mock API 响应、Fake 用户数据、假成功标志 |
| 自定义 Wrapper | 对标准库/流行库的多余封装 |
| 依赖蔓延 | 未使用依赖、过多依赖、过时依赖 |

### 24. 上下文交接

当对话上下文已满、或接手他人项目时，生成结构化的交接文本：

```markdown
## 项目交接

### 1. 项目概况
- **项目描述**：[一句话描述]
- **当前阶段**：[立项/开发中/验收中/发布中]
- **最近完成**：[最近完成的主要事项]

### 2. Git 状态
- **当前分支**：[branch-name]
- **最近提交**：[commit hash + message]
- **未提交改动**：[是/否]

### 3. 验证证据
- **测试**：[项目测试框架结果，如 pytest/npm test/go test]
- **Lint**：[项目 Linter 结果，如 ruff/eslint/flake8]
- **CI**：[最新 CI 状态，如无 CI 则省略]

### 4. 已知风险
- [风险1：描述 + 缓解措施]

### 5. 下一步命令
- [下一个应该执行的命令或工作流]
```

---

## 器：工具选型与实践

### 25. PreToolUse——写文件前拦截

在文件写入**前**执行安全拦截，防止违规代码产生。

**核心规则**：

| 规则 ID | 名称 | 动作 | 说明 |
|---------|------|------|------|
| SEC-READ-001 | BlockSensitiveFileRead | BLOCK | 禁止读取 .env, credentials, .pem, .key |
| SEC-CODE-001 | NoHardcodedCredentials | BLOCK | 禁止硬编码密码/API Key/Token |
| GEN-001 | NoTestDataInProductionCode | ALERT | 禁止业务代码使用测试数据/示例值 |
| PT-YAGNI-001 | NoUnrequestedAbstractions | WARN | 禁止未请求的抽象（ponytail） |
| PT-DEP-001 | NoUnrequestedDependencies | WARN | 禁止未请求的新依赖（ponytail） |
| PT-MINIMAL-001~003 | FileSizeGuard | 三级递进 | >500 WARN, >800 ALERT, >1000 BLOCK |

**规则动作**：

| 动作 | 含义 | 效果 |
|------|------|------|
| BLOCK | 阻止操作 | Cline 取消该工具调用 |
| WARN | 警告但不阻止 | 在输出中显示警告 |
| ALERT | 严重警告 | 类似 WARN，但用于安全相关项 |

### 26. PostToolUse——写文件后审计

在文件写入**后**执行审计扫描，检测潜在问题。

| 规则 ID | 名称 | 动作 | 说明 |
|---------|------|------|------|
| AUDIT-SEC-001 | DetectLeakedSecrets | ALERT | 检测 sk-/ghp-/AKIA 等密钥泄漏 |
| AUDIT-CODE-001 | NoDebugLeftovers | WARN | 检测 debugger/console.log/pdb 残留 |
| AUDIT-PY-002 | NoHardcodedPath | WARN | 检测硬编码 Windows 路径 |

### 27. Cline 子 Agent 使用指南

> Cline VS Code 插件支持 `use_subagents` 机制，可以派生子 Agent 做并行只读研究。

#### 子 Agent 能力边界

| 能力 | 是否支持 |
|------|---------|
| read_file | ✅ |
| list_files | ✅ |
| search_files | ✅ |
| list_code_definition_names | ✅ |
| 只读 execute_command（ls/grep/git log） | ✅ |
| 写文件 | ❌ |
| browser_action | ❌ |
| MCP 工具 | ❌ |

#### 如何指挥 Cline 调用子 Agent

**方式 1：让 Cline 自己决定**

- Subagents 默认开启（Cline Settings → Features → Agent → Subagents toggle）
- Cline 自动判断是否需要并行探索

**方式 2：显式 Prompt 触发**
在对话中说：

```
Use subagents to conduct an adversarial code review of the recent changes.
```

或中文：

```
请用子 agent 做对抗性评审，检查刚才修改的文件。
```

#### 适用场景

| 场景 | 触发话术 | 用途 |
|------|---------|------|
| 代码库探索 | "用子 agent 探索代码结构" | 并行读取多个目录，生成结构报告 |
| 并行只读审查 | "用子 agent 审查刚才的修改" | 每个子 agent 读一个文件，交审查报告 |
| 变更影响分析 | "用子 agent 追踪调用链" | 搜索函数调用关系，分析影响范围 |

#### 与 Harness 的集成

在 `new-feature-workflow.md` Phase 4 中，对抗性评审通过子 Agent 执行：

- 子 Agent 做只读审查（不能改代码）
- 主 Agent 根据子 Agent 的报告修复问题
- 主 Agent 对自己写的代码有"确认偏误"，子 Agent 提供独立视角

---

### 28. MCP 集成

> ⚠️ **外部依赖**：以下 MCP 工具需要用户自行安装和配置。Harness 在这些场景中扮演"指导何时调用"的角色。

#### superpowers：设计细化、TDD、BDD

| 工具 | 用途 | 依赖条件 |
|------|------|---------|
| `test-driven-development` | TDD 测试实现 | 需配置 superpowers MCP |
| `bdd-practices` | BDD 行为定义 | 需配置 superpowers MCP |
| `karpathy-guidelines` | 编码品味指导 | 需配置 superpowers MCP |
| `robust-design` | 泛化设计 | 需配置 superpowers MCP |
| `semantic-extraction` | 语义理解 | 需配置 superpowers MCP |

#### codebase-memory-mcp：图谱查询提速 100 倍

| 工具 | 用途 | 依赖条件 |
|------|------|---------|
| `search_graph` | 毫秒级搜索代码符号 | 需安装 MCP + 运行 index_repository |
| `query_graph` | Cypher 图查询 | 需安装 MCP + 运行 index_repository |
| `get_architecture` | 架构概览 | 需安装 MCP + 运行 index_repository |
| `trace_path` | 调用链追溯 | 需安装 MCP + 运行 index_repository |
| `detect_changes` | 变更影响分析 | 需安装 MCP + 运行 index_repository |

**不安装 MCP 的影响**：Harness 的核心功能（Hooks 拦截、工作流文档、规则系统）**完全不受影响**。MCP 提供的是额外的代码理解和查询能力。

### 29. 工作流选择

| 任务类型 | 使用 |
|---------|------|
| 新功能 / API 变更 / 多模块改动 | `new-feature-workflow` |
| 修 bug / 小改动（< 100 行） | `bugfix-workflow` |
| PyTorch 实验 | `dl-experiment-workflow` |
| 从零定义需求的大型功能 | `speckit/` 系列 |
| 项目跑不起来 | `baseline-startup` |
| 反复报错修不好 | `error-rescue` |
| 上下文太长换窗口 | `context-handoff` |
| 项目变乱 | `ai-debt-audit` |

---

## 总结

### Harness 的独特优势

**Harness 自有能力（部署即用）**：

1. ✅ Hooks 运行时拦截（PreToolUse/PostToolUse）— 机械执行，不依赖 AI
2. ✅ 规则系统（安全红线、代码质量、泛化原则）— L1 常驻加载
3. ✅ 工作流文档（14 个 workflow）— 覆盖立项→开发→验收→发布
4. ✅ 自然语言路由 — AI 理解用户需求，选择合适工作流
5. ✅ 渐进式披露 — 规则分层，按需加载
6. ✅ Memory Bank 模板 — 跨会话延续状态
7. ✅ 项目治理能力 — 提升代码质量、设定安全红线

**外部依赖（可选增强）**：

| 能力 | 依赖 | 影响 |
|------|------|------|
| CI 反馈闭环 | GitHub Actions / GitLab CI | 无 CI 时用 verify-changes 本地验证 |
| Drift Scan | codebase-memory-mcp + 索引 | 无 MCP 时不影响核心功能 |
| 图谱查询 | codebase-memory-mcp | 无 MCP 时不影响核心功能 |
| BDD/TDD 强制 | superpowers MCP | 无 MCP 时 AI 仍可跳过，但规则文档存在 |

### 核心原则速记

```
道：规则不是限制，而是防止速度失控
法：先想清楚再做，先测试再写代码
术：预防 → 审计 → 验证，三层防线
器：选对工具，用对时机

哲学：大模型不缺知识，缺限制
      大模型不掌握私域知识，需精准注入
      大模型有上下文限制，需渐进式披露
