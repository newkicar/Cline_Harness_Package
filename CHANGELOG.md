# Changelog

All notable changes to the Cline Harness package.

## [1.2.4] - 2026-07-13

### Changed

- **工作流分级**：引入「核心/扩展」两级分类，减少新手选择困难
  - `ARCHITECTURE.md` 新增工作流分级说明表
  - `INDEX.md` 标注 ★ 核心 / ○ 扩展
  - `README.md` 体系结构和任务表同步更新
- **deploy.ps1** 扩展工作流默认全部部署，`-Extras` 参数已废弃（AI 自动路由选择工作流）
- **truth-documents.md** 精简为「最小真源集」：5 份核心文档必须维护，18 份可选文档按需创建
- **session-end.md** Phase 4 重命名为「文档健康度」，新增 4a 核心真源检查 + 4b 可选文档审计

### Added

- `deploy.ps1` 的 `-Extras` 参数文档（README.md）
- `verify-harness.ps1` 新增规则 ID 一致性检查（解析 PreRules.ps1 中的 RuleId，检测重复）
- `test-pretooluse.ps1` 新增 SEC-SQL-001（SQL 注入拦截）和 CODE-PY-001（空 except 拦截）测试
- `tests/fixtures/pretooluse-dotenv-warn.json` — SEC-READ-WARN-001 测试用例

### Fixed

- **版本号不一致**：harness.config.json、README.md、README-EN.md、harness_coding_tutor.md 统一为 1.2.4
- **README -Extras 文档与实际实现不符**：修正为"全部部署，AI 自动路由"
- **test-pretooluse.ps1**：SEC-READ-001 测试从 `.env` 改为 `.env.production`（符合新规则）
- **清理废弃 fixture**：删除 `pretooluse-secret-read.json`（.env 不再 BLOCK）
- **ARCHITECTURE.md / INDEX.md / README-EN.md**：同步 -Extras 废弃说明
- **deploy.ps1**：移除 -Extras 死代码，简化为向后兼容提示
- **harness-ci.yml**：简化为单一入口（调用 verify-harness.ps1），删除重复的 verify.yml
- **test-pretooluse.ps1**：新增 CODE-JS-001（debugger 检测）和 PT-YAGNI-001（可疑抽象警告）测试
- **README-EN.md**：新增 Extension Workflows / -Extras deprecated 说明段落

---

## [1.2.3] - 2026-07-12

### Added

- PreToolUse 新增规则：
  - `SEC-READ-WARN-001` — 读取 .env 文件时 WARN（不再 BLOCK，开发环境可读取）
  - `CODE-PY-002` — 宽泛 `except Exception:` 捕获警告
  - `DUP-001` — 函数数量过多警告（Python >20, JS/TS >30）
- `harness.config.json` 新增 `rules_version` 字段
- `cline-desktop-settings.json` 新增 `rules.l2_enabled` 配置项
- `deploy.ps1` L2 配置化加载：同时更新 settings.json 中的 l2_enabled

### Changed

- `SEC-READ-001` 放宽：`.env` 从 BLOCK 降级为 WARN（通过新增 SEC-READ-WARN-001）
- `SEC-READ-001` 精确化：仅拦截 `.env.production/.env.staging/.env.prod`，不再拦截所有 `.env`
- `SEC-READ-001` 凭据文件精确化：`credentials.json`、`secrets.json` 替代 `credentials?`
- `CODE-PY-001` 升级：从 WARN 改为 BLOCK（空 except 永远不允许）
- `PostToolUse.ps1` Invoke-Linter 新增 ESLint 支持（JS/TS 文件）
- `deploy.ps1` L2 启用时同时更新 harness.config.json 和 cline-desktop-settings.json

### Fixed

- `deploy.ps1` 移除重复的 L2 逻辑代码

---

## [1.2.2] - 2026-07-08

### Fixed

- `setup-cline.ps1`: 第37行 `verify-harness.cmd` → `verify-harness.ps1`，消除 .cmd 残留
- `README.md`: 统一 L2 描述，改为 "L2 可自动检测提示，也可手动启用"，与 `deploy.ps1` 实际行为一致
- `README-EN.md`: 版本号 1.2.1 → 1.2.2；L2 描述与中文版对齐；补全 §3 提示段落

### Added

- L3 新增工作流：
  - `baseline-startup.md` — 「项目跑不起来」→ 先建启动基线
  - `error-rescue.md` — 「反复修不好」→ 停手→还原→根因分析
  - `context-handoff.md` — 上下文交接格式（借鉴 Sliver）
  - `ai-debt-audit.md` — AI 债务体检（借鉴 Sliver）
  - `user-acceptance-walkthrough.md` — 用户验收陪跑（借鉴 Sliver）
  - `drift-scan-workflow.md` — 代码/文档/依赖漂移检测
  - `ci-feedback-workflow.md` — CI 失败自动修复
  - `task-risk-gates.md` — 任务风险分级（借鉴 Sliver）
  - `natural-language-routing.md` — 自然语言路由（借鉴 Sliver）
- `harness_coding_tutor.md` — 390 行「道法术器」教程，工程方法论 onboarding
- `cline-desktop-settings.json` — Cline 设置模板，一键导入 hooks/rules/skills/workflows

### Changed

- `deploy.ps1` L2 自动检测增强：部署时扫描项目特征（torch / create_deep_agent），提示启用命令
- `deploy.ps1` 自动添加 .gitignore 排除规则：防止 Harness 文件被目标项目 git 提交

## [1.2.1] - 2026-07-05

### Fixed

- `SEC-CODE-001` 三重检测：关键词 + 白名单豁免 + 值模式检测，大幅减少误报

### Added

- SEC-CODE-001 白名单豁免：`SAMPLE_`、`DEMO_`、`TEST_`、`EXAMPLE_`、`FAKE_`、`MOCK_` 前缀豁免
- SEC-CODE-001 值模式检测：只拦截符合真实凭据模式的值（`sk-`、`ghp_`、`AKIA` 等前缀）

## [1.2.0] - 2026-07-05

### Added

- `deploy.ps1` L2 自动检测：部署时扫描项目特征（torch / create_deep_agent），提示启用 L2
- `deploy.ps1` 自动添加 .gitignore 排除规则：防止 Harness 文件被目标项目 git 提交
- `.github/workflows/verify.yml` GitHub Actions CI：push/PR 时自动运行 verify-harness.ps1

### Changed

- `scripts/` → `scripts_cline_harness/` 重命名，避免与其他项目重名
- 所有文档引用同步更新（README.md、README-EN.md）

## [1.1.3] - 2026-07-04

### Fixed

- `PreToolUse.ps1` SEC-CODE-001: 修复 credPatterns 数组内字符串拼接导致三条正则合并为一个的问题（使用 `[char]39`/`[char]34` 替代）
- `PreToolUse.ps1` SEC-CODE-001: ValidationLogic 现在正确检查内容是否包含凭据模式，不再无条件 BLOCK
- `PreToolUse.ps1` OPS-FMT-001: Pattern `^\.py$` → `\.py$`，修复文件路径匹配
- `PreToolUse.ps1` STR-001: JSON payload 正则收紧，减少误报

## [1.1.2] - 2026-07-04

### Added

- `tests/test-pretooluse.ps1` PreToolUse Hook 回归测试（对称于 PostToolUse）
- `tests/fixtures/pretooluse-*.json` PreToolUse 测试用例（valid/secret-read/hardcoded-cred/memory-bank）
- `.gitignore` 补充 Python 运行时产物、虚拟环境、IDE 配置

### Changed

- `verify-harness.ps1` 输出全面中文化 + UTF-8 编码设置
- `verify-harness.ps1` 新增检查 `tests/test-pretooluse.ps1` 路径
- `verify-harness.ps1` 自动调用 PreToolUse 回归测试

## [1.1.1] - 2026-07-04

### Removed

- `.cmd` wrappers for deploy/verify/setup (Cline hooks and tooling use `.ps1` only on Windows)

### Changed

- Docs: run scripts via `powershell -ExecutionPolicy Bypass -File .\*.ps1`

## [1.1.0] - 2026-07-04

### Added

- `tests/test-hooks.ps1` Hook regression tests (HookParse + PostToolUse integration)
- `.clinerules/hooks/lib/HookParse.ps1` shared parse module (testable)
- `harness.config.json` version field and L2 registry
- `setup-cline.ps1` interactive Cline settings checklist
- `QUICKSTART.md` one-page onboarding
- `.clinerules/specify-rules.md` for Speckit agent-context
- `.gitignore` for hook runtime logs

### Changed

- PostToolUse: JSON repair + regex fallback; diff-based scan (no silent skip)
- L2 rules moved to `.clinerules/l2/` with `rules.exclude` in settings
- MCP references: `superpowers-fs` renamed to `superpowers`
- Skills paths unified to `.agents/skills/`
- README: full deploy checklist, MCP layering, Windows/Speckit notes
- `verify-harness.ps1` runs hook tests; UTF-8 BOM for Chinese output

### Fixed

- `.specify/integrations/cline.manifest.json` Speckit workflow paths (`workflows/speckit/`)
- README L2 table uses `deploy.ps1` consistently

## [1.0.0] - 2026-07-01

- Initial L1-L4 harness: rules, hooks, workflows, skills, Speckit integration
