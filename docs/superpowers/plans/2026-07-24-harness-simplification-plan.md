# Harness 包简化实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 Cline Harness 包简化为纯模板文件夹，删除所有脚本、CI、测试，只保留核心模板文件，用户可手动复制到新项目使用。

**Architecture:** 直接删除不需要的文件，重写 README.md 为简单的复制说明，更新 .gitignore 移除脚本相关规则。

**Tech Stack:** 文件操作（删除、重写），无需特殊技术栈。

## Global Constraints

- 保留所有核心模板文件：.clinerules/, .agents/skills/, memory/, specs/, design/
- 保留配置文件：harness.config.json, cline-desktop-settings.json
- 保留文档：CHANGELOG.md, harness_coding_tutor.md
- 删除所有脚本：deploy.ps1, setup-cline.ps1, verify-harness.ps1
- 删除 CI 流程：.github/workflows/harness-ci.yml
- 删除测试套件：tests/ 目录
- 删除脚本工具：scripts_cline_harness/ 目录
- 重写 README.md 为简单复制说明

---

### Task 1: 删除不需要的脚本文件

**Files:**
- Delete: `deploy.ps1`
- Delete: `setup-cline.ps1`
- Delete: `verify-harness.ps1`

**Interfaces:**
- Consumes: 无
- Produces: 无（删除操作）

- [ ] **Step 1: 删除 deploy.ps1**

```bash
rm deploy.ps1
```

- [ ] **Step 2: 删除 setup-cline.ps1**

```bash
rm setup-cline.ps1
```

- [ ] **Step 3: 删除 verify-harness.ps1**

```bash
rm verify-harness.ps1
```

- [ ] **Step 4: 验证脚本已删除**

```bash
ls *.ps1
```

Expected: 没有 .ps1 文件输出

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: 删除部署和验证脚本"
```

---

### Task 2: 删除 CI 和测试目录

**Files:**
- Delete: `.github/workflows/harness-ci.yml`
- Delete: `.github/` 目录
- Delete: `tests/` 目录
- Delete: `scripts_cline_harness/` 目录

**Interfaces:**
- Consumes: 无
- Produces: 无（删除操作）

- [ ] **Step 1: 删除 .github 目录**

```bash
rm -rf .github
```

- [ ] **Step 2: 删除 tests 目录**

```bash
rm -rf tests
```

- [ ] **Step 3: 删除 scripts_cline_harness 目录**

```bash
rm -rf scripts_cline_harness
```

- [ ] **Step 4: 验证目录已删除**

```bash
ls -d .github tests scripts_cline_harness 2>/dev/null || echo "目录已删除"
```

Expected: 输出 "目录已删除"

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: 删除 CI 流程、测试套件和脚本工具"
```

---

### Task 3: 重写 README.md

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: 设计文档中的 README 结构
- Produces: 新的简化 README

- [ ] **Step 1: 读取当前 README.md**

```bash
head -20 README.md
```

- [ ] **Step 2: 创建新的 README.md**

```markdown
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
```

- [ ] **Step 3: 验证 README 内容**

```bash
head -30 README.md
```

Expected: 显示新的简化 README 内容

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: 重写 README 为简单复制说明"
```

---

### Task 4: 更新 .gitignore

**Files:**
- Modify: `.gitignore`

**Interfaces:**
- Consumes: 当前 .gitignore 内容
- Produces: 更新后的 .gitignore

- [ ] **Step 1: 读取当前 .gitignore**

```bash
cat .gitignore
```

- [ ] **Step 2: 更新 .gitignore**

移除与脚本相关的忽略规则，保留必要的忽略规则：

```gitignore
# Python 产物
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# 虚拟环境
.env
.venv
env/
venv/
ENV/

# IDE 文件
.vscode/
.idea/
*.swp
*.swo
*~

# Hook 日志
*.log
hook-*.json
```

- [ ] **Step 3: 验证 .gitignore 更新**

```bash
cat .gitignore
```

Expected: 显示更新后的 .gitignore 内容

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git commit -m "chore: 更新 .gitignore 移除脚本相关规则"
```

---

### Task 5: 最终验证

**Files:**
- 无（验证操作）

**Interfaces:**
- Consumes: 所有之前的任务
- Produces: 验证结果

- [ ] **Step 1: 验证文件结构**

```bash
echo "=== 验证删除的文件 ==="
ls deploy.ps1 setup-cline.ps1 verify-harness.ps1 2>/dev/null || echo "脚本已删除"

echo "=== 验证删除的目录 ==="
ls -d .github tests scripts_cline_harness 2>/dev/null || echo "目录已删除"

echo "=== 验证保留的文件 ==="
ls -d .clinerules .agents memory specs design 2>/dev/null && echo "核心模板保留"

echo "=== 验证配置文件 ==="
ls harness.config.json cline-desktop-settings.json 2>/dev/null && echo "配置文件保留"

echo "=== 验证文档 ==="
ls README.md CHANGELOG.md harness_coding_tutor.md 2>/dev/null && echo "文档保留"
```

- [ ] **Step 2: 验证 README 内容**

```bash
grep -q "手动复制" README.md && echo "README 包含复制说明"
grep -q "cline-desktop-settings.json" README.md && echo "README 包含配置说明"
grep -q "harness_coding_tutor.md" README.md && echo "README 包含教程链接"
```

- [ ] **Step 3: 最终 Commit**

```bash
git add -A
git commit -m "chore: 完成 Harness 包简化"
```

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-24-harness-simplification-plan.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?