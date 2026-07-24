# Harness 包简化设计文档

## 1. 项目背景和目标

### 1.1 背景
当前 Cline Harness 包版本 1.2.4 包含复杂的部署脚本、CI 流程、测试套件和教程文档。用户反馈这些功能过于复杂，从未使用过安装命令，希望回归简单手动复制的方式。

### 1.2 目标
将 Harness 包简化为纯模板文件夹，用户新建项目时手动复制核心组件即可使用，无需任何脚本或复杂配置。

## 2. 当前状态分析

### 2.1 当前文件结构
- **脚本文件**: deploy.ps1, setup-cline.ps1, verify-harness.ps1
- **CI 流程**: .github/workflows/harness-ci.yml
- **测试套件**: tests/ 目录（test-hooks.ps1, test-pretooluse.ps1, fixtures/）
- **脚本工具**: scripts_cline_harness/regenerate-manifest.ps1
- **教程文档**: harness_coding_tutor.md (658行)
- **核心模板**: .clinerules/, .agents/skills/, memory/, specs/, design/
- **配置文件**: harness.config.json, cline-desktop-settings.json
- **文档**: README.md, CHANGELOG.md

### 2.2 问题分析
1. 脚本复杂：用户不会使用 PowerShell 脚本
2. CI 冗余：个人项目不需要 GitHub Actions
3. 测试多余：用户不需要验证 Harness 完整性
4. 文档冗长：README 包含大量脚本使用说明

## 3. 简化方案设计

### 3.1 删除文件列表
1. `deploy.ps1` - 部署脚本
2. `setup-cline.ps1` - 设置脚本
3. `verify-harness.ps1` - 验证脚本
4. `.github/workflows/harness-ci.yml` - CI 流程
5. `tests/` - 整个测试目录
6. `scripts_cline_harness/` - 整个脚本目录

### 3.2 保留文件列表
1. `.clinerules/` - 整个规则目录（L1/L3 + hooks）
2. `.agents/skills/` - 整个技能目录
3. `memory/` - 内存模板目录
4. `specs/` - 需求模板目录
5. `design/` - 设计模板目录
6. `harness.config.json` - 配置文件
7. `cline-desktop-settings.json` - Cline 设置文件
8. `CHANGELOG.md` - 版本历史
9. `harness_coding_tutor.md` - 教程文件
10. `README.md` - 将重写为简单复制说明

### 3.3 README 重写设计
新的 README.md 将包含：
1. 项目标题和简介（一句话说明）
2. 使用方法：手动复制以下目录到新项目根目录
   - `.clinerules/`
   - `.agents/skills/`
   - `memory/`
   - `specs/`
   - `design/`
3. 配置说明：在 Cline 中导入 `cline-desktop-settings.json`
4. 核心组件说明（简要）
5. 保留 `harness_coding_tutor.md` 链接

## 4. 实施步骤

### 4.1 删除不需要的文件
1. 删除 `deploy.ps1`
2. 删除 `setup-cline.ps1`
3. 删除 `verify-harness.ps1`
4. 删除 `.github/` 目录
5. 删除 `tests/` 目录
6. 删除 `scripts_cline_harness/` 目录

### 4.2 重写 README.md
1. 保留项目标题和简介
2. 简化使用方法为手动复制
3. 添加配置说明
4. 简化核心组件说明
5. 保留教程链接

### 4.3 更新 .gitignore
1. 移除与脚本相关的忽略规则
2. 保留必要的忽略规则（如 Python 产物、IDE 文件等）

## 5. 验证方法

### 5.1 文件结构验证
确认删除了所有脚本、CI、测试文件，保留了所有核心模板文件。

### 5.2 README 内容验证
确认 README 包含：
1. 简单的复制说明
2. 配置说明
3. 核心组件说明
4. 教程链接

### 5.3 功能验证
1. 手动复制核心模板到新项目
2. 在 Cline 中导入 cline-desktop-settings.json
3. 验证规则和 hooks 正常工作

## 6. 预期结果

简化后的 Harness 包将：
1. 成为一个纯模板文件夹
2. 用户只需手动复制即可使用
3. 无需任何脚本或复杂配置
4. 保留所有核心功能（规则、hooks、技能、模板）
5. 文档简洁明了，易于理解