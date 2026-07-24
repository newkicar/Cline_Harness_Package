# Cline Harness Engineering Rules Package

> Empower AI assistants (Cline) to produce **engineering-grade** code: clear hierarchy, logical structure, scalable, maintainable, robust, generalized.
>
> For VS Code extension [Cline](https://github.com/cline/cline). **Version 1.2.4** — see [CHANGELOG.md](CHANGELOG.md)

---

## Quick Start

### 1. Deployment

**Method A: One-Click Script (Recommended)**

```powershell
# Execute in Harness package directory (PowerShell terminal)
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy.ps1 -TargetDir D:\Projects\my-app -L2 deepagents,pytorch
# If ExecutionPolicy allows: .\deploy.ps1 -TargetDir ... -L2 ...
```

**Method B: Manual Copy**

Copy the following directories/files to the **target project root**:

| Component | Path | Description |
| --------- | ---- | ----------- |
| Rules & Hooks | `.clinerules/` | L1/L3 + hooks (required) |
| Skills | `.agents/skills/` | Skills activated on demand (required) |
| Memory Templates | `memory/` | Progress/Blockers/Decisions (required) |
| Spec/Design Templates | `specs/`, `design/` | L4 templates (required) |
| Harness Config | `harness.config.json` | L2 enablement record |
| Cline Settings | `cline-desktop-settings.json` | Import to Cline (hooks/rules/skills/workflows) |
| Speckit (optional) | `.specify/` | Spec-driven development toolkit |

**L2 Domain Rules (Enable on Demand)**

L2 files are in `.clinerules/l2/`, **not loaded by default**. Enable by project type:

**Extension Workflows**

All 13 workflows (including 9 extension workflows) are deployed by default. AI auto-selects the right workflow based on your natural language description.

> **Note**: `-Extras` parameter is deprecated. Extension workflows are already included in the default `.clinerules/workflows/` deployment.

| Project Type | Command |
| ------------ | ------- |
| Agent / DeepAgents | `deploy.ps1 -L2 deepagents` |
| PyTorch / Deep Learning | `deploy.ps1 -L2 pytorch` |

> **Windows Tip**: Cline Hooks only support `.ps1` (e.g., `PreToolUse.ps1`). Deploy/self-check scripts are also `.ps1`; run them in **PowerShell terminal** with `-File`; do not double-click `.ps1` (may open in Notepad).

After deployment:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-cline.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1
```

**Cline Setup**

1. Import hooks / rules / skills / workflows from `cline-desktop-settings.json` in Cline
2. Install and enable in **Cline MCP Settings** (Harness guides Agent **when to call** these tools via rules/workflow; MCP itself is not in this package):
   - `superpowers` — Design refinement, TDD (see `00-core.md` §1, §3.1)
   - `codebase-memory-mcp` — Drift scan, CI feedback (see MCP integration table below)

### 2. Daily Use

| Operation | Description |
| --------- | ----------- |
| **Describe Task** | Use natural language; Cline auto-selects the right workflow |
| **Say "Done"** | Triggers session-end: verify → update Memory → confirm |
| **Use Speckit** | Say "Use speckit workflow" to activate full spec→implement workflow |

### 3. Memory Bank Update

Harness uses `memory/` directory as the project's Memory Bank (inspired by Cline official Memory Bank):

| File | Purpose | Update Timing |
|------|---------|--------------|
| `memory/progress.md` | Session progress + blockers + next steps | Every Session |
| `memory/blockers.md` | Blockers log | When issues arise |
| `memory/decisions.md` | Architecture decisions (ADR format) | Every decision |
| `memory/architecture.md` | Current architecture snapshot | On architecture changes |

**Auto-update on Done**: Saying "Done" triggers `session-end.md`, which auto-executes Phase 1 verify + Phase 3 Memory write.

**Manual update**: You can also say "update memory bank" anytime to trigger a full documentation review.

### 4. Harness Self-Check

Run `verify-harness.ps1` after deployment to verify Harness package integrity:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1
```

Checks include: L1/L2 core files, PowerShell syntax, Rule ID consistency, Hook regression tests.

**GitHub Actions CI**: When pushing to GitHub, `.github/workflows/harness-ci.yml` automatically runs the same verification on `windows-latest` to prevent bad code from being merged.

### 5. Select L2 Domain Rules

L2 files are stored in `.clinerules/l2/`, **not loaded by default**. During deployment, `deploy.ps1` scans project features and suggests enabling commands. You can also enable manually:

| Your Project Feature | Enable L2 |
| -------------------- | --------- |
| Agent / `create_deep_agent()` | `-L2 deepagents` |
| PyTorch / `import torch` | `-L2 pytorch` |
| Regular project | Do not enable L2 |

> **Tip**: `deploy.ps1` scans the target project for features like `import torch`, `create_deep_agent(` and outputs enablement suggestions. You can skip auto-detection and run `deploy.ps1 -L2 deepagents,pytorch` manually.

### 6. Choose Workflow (by Task Type)

> **Natural Language Routing**: You don't need to memorize commands, just describe your needs. AI will automatically determine the right workflow. See [natural-language-routing.md](.clinerules/workflows/natural-language-routing.md) for details.

| You Say | AI Auto-Routes To |
| ------- | ----------------- |
| "I want to build a project from scratch" | Project initiation → new-feature-workflow |
| "Project won't start" | Establish startup baseline → `baseline-startup.md` |
| "I want to add a feature" | Feature initiation assessment → risk assessment |
| "Context too long, switch to new window" | Generate handoff text → `context-handoff.md` |
| "Project is getting messier" | AI Debt Audit → `ai-debt-audit.md` |
| "It's broken, keeps failing" | Error Rescue → `error-rescue.md` |
| "Fix this bug" | bugfix-workflow |
| "Use speckit workflow" | Speckit sub-system |

| Task Type | Use |
| --------- | --- |
| New feature / API change / Multi-module | `new-feature-workflow` |
| Bug fix / Small change (< 100 lines) | `bugfix-workflow` |
| Project won't start | `baseline-startup` |
| Keeps failing with same error | `error-rescue` |
| PyTorch experiment | `dl-experiment-workflow` |
| Large feature from scratch | `speckit/` series (requires `.specify/extensions.yml` or say "Use speckit workflow") |

### 7. Test Suite

Harness includes a complete testing suite to ensure rule changes don't introduce regressions:

```
tests/
├── test-hooks.ps1              # PostToolUse Hook regression test
├── test-pretooluse.ps1         # PreToolUse Hook regression test
└── fixtures/
    ├── pretooluse-debugger.json     # Tests debugger statement interception
    ├── pretooluse-empty-except.json # Tests empty except interception
    ├── pretooluse-sql-inject.json   # Tests SQL injection interception
    └── pretooluse-suspicious-class.json # Tests suspicious abstraction warning
```

Running:

```powershell
# Run all tests (incl. verify-harness)
powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1

# Run Hook tests only
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\test-hooks.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\test-pretooluse.ps1
```

---

## Architecture

```
Harness System
│
├── L1 — Core Rules (Always Loaded)
│   ├── 00-core.md              Security red lines / Code quality baseline / Architecture principles / Delivery checklist
│   ├── 01-ponytail.md          Development philosophy (lazy senior dev)
│   ├── CONTRIBUTING-RULES.md   How to add new rules
│   ├── ARCHITECTURE.md         System architecture diagram
│   ├── GLOSSARY.md             Glossary
│   └── hooks/                  Pre/Post ToolUse PowerShell hooks
│       ├── PreToolUse.ps1      Pre-write interception (security gate)
│       ├── PostToolUse.ps1     Post-write audit (leak detection)
│       └── session-end.md      Session-end automation
│
├── L2 — Domain-Specific Rules (Enable on Demand, default in l2/ subdirectory)
│   ├── l2/02-deepagents-code-rule.md   Agent projects
│   └── l2/03-pytorch-code-rule.md      Deep learning projects
│
├── L3 — Workflows (Select by Task Type)
│   ├── Main Workflows
│   │   ├── new-feature-workflow.md   New features / API changes / Multi-module
│   │   ├── bugfix-workflow.md        Bug fixes / Small changes
│   │   └── dl-experiment-workflow.md PyTorch experiments
│   ├── Auxiliary Flows
│   │   ├── verify-changes.md         Verification steps (shared by all workflows, incl. CI feedback)
│   │   ├── drift-scan-workflow.md    Code/doc/dependency drift detection
│   │   ├── ci-feedback-workflow.md   CI failure auto-fix
│   │   ├── task-risk-gates.md        Task risk classification (inspired by Sliver)
│   │   ├── natural-language-routing.md Natural language routing (inspired by Sliver)
│   │   ├── baseline-startup.md       Establish startup baseline (new)
│   │   ├── error-rescue.md           Error rescue (new)
│   │   ├── context-handoff.md        Context handoff format (inspired by Sliver)
│   │   ├── ai-debt-audit.md          AI Debt Audit (inspired by Sliver)
│   │   ├── user-acceptance-walkthrough.md User Acceptance Walkthrough (inspired by Sliver)
│   │   └── INDEX.md                  Workflow selection index
│   └── Speckit Sub-System (Optional Activation)
│       └── speckit/                  10 Speckit workflows
│
└── L4 — Templates
    ├── specs/
    │   ├── PRD.md                        Product Requirements Document
    │   └── acceptance-criteria.md        Acceptance Criteria
    ├── design/
    │   ├── HLD.md                        High-Level Design (optional, for large features)
    │   └── contracts/                    API Contracts (optional, for external interfaces)
    └── memory/
        ├── progress.md                   Progress Log
        ├── blockers.md                   Blockers Log
        └── decisions.md                  Architecture Decision Records (ADR)
```

---

## MCP Integration

> MCP installed in **Cline MCP Settings**; Harness guides Agent **when to call** these tools via rules/workflow.

| MCP Server | Tool | Purpose | Integrated File | Dependency |
| ---------- | ---- | ------- | --------------- | ---------- |
| `superpowers` | `test-driven-development` etc. | Design refinement, TDD test implementation | `00-core.md` §1, §3.1 | Requires superpowers MCP |
| `codebase-memory-mcp` | `search_graph` | Millisecond-level code symbol search | drift-scan-workflow | Requires MCP install + index_repository |
| `codebase-memory-mcp` | `query_graph` | Cypher graph query | drift-scan-workflow | Requires MCP install + index_repository |
| `codebase-memory-mcp` | `get_architecture` | Architecture overview | drift-scan-workflow | Requires MCP install + index_repository |
| `codebase-memory-mcp` | `trace_path` | Call chain tracing | ci-feedback-workflow | Requires MCP install + index_repository |
| `codebase-memory-mcp` | `detect_changes` | Change impact analysis | session-end | Requires MCP install + index_repository |

> ⚠️ **External Dependency**: MCP tools require user installation and configuration. Harness plays the role of "guiding when to call" these tools. **Not installing MCP does not affect Harness core functionality** (Hooks interception, workflow docs, rule system).

After installing `codebase-memory-mcp`, say "Index this project" to use it.

---

## Hooks Reference

### PreToolUse (Pre-Write Interception)

> When PreToolUse detects fixable issues, it returns `FixSuggestion`; Cline auto-corrects **before** writing (e.g., add encoding declaration, format).

| Rule ID | Name | Action | Description |
| ------- | ---- | ------ | ----------- |
| SEC-READ-001 | BlockSensitiveFileRead | BLOCK | Block reading production env config, credentials, .pem, .key |
| SEC-READ-WARN-001 | WarnDotEnvRead | WARN | Warn when reading .env files (allowed but reminds user) |
| SEC-CODE-001 | NoHardcodedCredentials | BLOCK | Block hardcoded passwords/API Keys/Tokens |
| SEC-SQL-001 | NoSqlInjectionViaStringConcat | BLOCK | Block SQL string concatenation, use parameterized queries |
| MEM-BANK-001 | RequireMemoryBankHeader | BLOCK | Memory Bank files must have Markdown header |
| MEM-BANK-002 | BlockPartialMemoryUpdate | BLOCK | Memory Bank must use write_to_file, not replace_in_file |
| MEM-BANK-003 | ValidateMemoryBankFormat | BLOCK | Memory Bank format validation |
| GEN-001 | NoTestDataInProductionCode | ALERT | Block test/example data in production code |
| PT-YAGNI-001 | NoUnrequestedAbstractions | WARN | No unrequested abstractions (ponytail) |
| PT-DEP-001 | NoUnrequestedDependencies | WARN | No unrequested new dependencies (ponytail) |
| PT-BOILER-001 | NoUnrequestedBoilerplate | WARN | No unrequested boilerplate (ponytail) |
| PT-MINIMAL-001 | FileSizeGuardWarn | WARN | File >500 lines suggests splitting (ponytail) |
| PT-MINIMAL-002 | FileSizeGuardAlert | ALERT | File >800 lines strongly suggests splitting (ponytail) |
| PT-MINIMAL-003 | FileSizeGuardBlock | BLOCK | File >1000 lines must split (ponytail) |
| OPS-FMT-001 | RequireEncodingDeclaration | WARN | Python files should declare UTF-8 encoding |
| CODE-PY-001 | NoEmptyExcept | BLOCK | No empty except clauses (catches all exceptions including KeyboardInterrupt) |
| CODE-PY-002 | BroadExceptWarning | WARN | Broad except Exception: warning (valid but not recommended) |
| CODE-JS-001 | NoDebuggerStatement | BLOCK | No debugger statements |
| CODE-JS-002 | NoConsoleLogLeftover | WARN | No console.log leftovers in production code |
| DUP-001 | TooManyFunctionsInFile | WARN | Too many functions warning (Python >20, JS/TS >30) |

### PostToolUse (Post-Write Audit)

> When PostToolUse detects fixable issues, it returns `AutoFix`; Cline calls `write_to_file` to auto-correct.

| Rule ID | Name | Action | Description |
| ------- | ---- | ------ | ----------- |
| AUDIT-SEC-001 | DetectLeakedSecrets | ALERT | Detect sk-/ghp-/AKIA key leaks |
| AUDIT-CODE-001 | NoDebugLeftovers | WARN | Detect debugger/console.log/pdb leftovers |
| AUDIT-PY-002 | NoHardcodedPath | WARN | Detect hardcoded Windows paths |

---

## Speckit Sub-System

> A complete Spec-Driven Development workflow, suitable for large features defined from scratch.

**Activation Conditions** (either one):

1. Project root contains `.specify/extensions.yml`
2. User says "Use speckit workflow"

**Workflow**:

```
speckit-specify.md    → Create/update feature spec
speckit-clarify.md    → Clarify requirements (optional)
speckit-plan.md       → Generate implementation plan
speckit-tasks.md      → Break down tasks
speckit-implement.md  → Execute implementation
speckit-checklist.md  → Generate delivery checklist
speckit-converge.md   → Converge completion
```

**Difference from Main Workflow**:

- Main workflow: daily development (requirements already clear)
- Speckit: defining requirements from 0 to 1
- Speckit has its own memory path (`.specify/memory/`)

**Windows Environment**: Speckit Bash scripts (`.specify/scripts/bash/`) require **Git Bash** or **WSL**. Install [Git for Windows](https://git-scm.com/download/win) and verify `where bash` works. PowerShell extensions (e.g., agent-context) run directly.

**Manifest Path**: Workflow files are in `.clinerules/workflows/speckit/`. After updating Speckit files, run:

```powershell
powershell -File scripts_cline_harness/regenerate-manifest.ps1
```

---

## Customization

| Need | Action |
| ---- | ------ |
| PreToolUse too strict | Edit `Enabled` field in corresponding rule in `hooks/PreToolUse.ps1` |
| PostToolUse too slow | Auto-skips if `ruff`/`eslint` not installed; recommend installing linter in project |
| Small bug fix | Use `bugfix-workflow`, no need for full new-feature flow |
| Add new rule | See `CONTRIBUTING-RULES.md` |
| View terminology | See `GLOSSARY.md` |

---

## Directory Structure

```
Project Root/
├── .clinerules/
│   ├── 00-core.md                   # Core rules (required)
│   ├── 01-ponytail.md               # Development philosophy (required)
│   ├── specify-rules.md             # Speckit agent-context (required)
│   ├── l2/                          # L2 templates (not loaded by default)
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
├── README-EN.md
├── README.md
├── deploy.ps1
├── verify-harness.ps1
├── setup-cline.ps1
├── scripts_cline_harness/regenerate-manifest.ps1
├── tests/test-hooks.ps1
├── cline-desktop-settings.json
├── memory/
├── specs/
└── design/
```

---

## Initial Prompt

When initializing a project, enter in Cline:

```
202xxxxx: This project is [description].
Please start according to your rules 00-core.md.
```

Then say "Done" to trigger the full verification + Memory update flow.

---

## New Conversation Prompt

> When conversation context is full, or taking over someone else's project, use this prompt to quickly establish context.

When starting a new conversation, enter in Cline:

```
202xxxxx: This project is [description].

Please read the following files to understand the full project context, then summarize across five dimensions: PRD / Architecture / Progress / Blockers / Decisions:

1. specs/PRD.md
2. specs/acceptance-criteria.md
3. design/HLD.md
4. design/contracts/ (read all sub-files recursively)
5. memory/progress.md
6. memory/blockers.md
7. memory/decisions.md
8. memory/architecture.md 
9. README-EN.md
10. .clinerules/ARCHITECTURE.md

After summarizing, tell me if you're ready to proceed to the next phase.
```

```
Please start according to your rules 00-core.md.
```

Then say "Done" to trigger the full verification + Memory update flow.
