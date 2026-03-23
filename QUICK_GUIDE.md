# ⚡ 中书日常工作快捷指南 (首辅大人请收！)

## 🎯 **核心原则**

1. ✅ **只做自己的任务** - `zhongshu-dev` 分支内工作
2. ✅ **使用 gh CLI 优先** - GitHub 原生工具流
3. ❌ **不触碰他人分支** - `shangshu-dev`, `huishi-dev` 等别碰!

---

## 📥 **开始工作前** (每次必做)

```bash
# 1. 拉取 Feature 主分支和自己的最新代码
git pull origin feature && git pull zhongshu-dev zhongshu-dev

# 2. 检查工作状态
git status
git branch -a
```

---

## 💻 **完成工作后**

### Step 1: 提交代码
```bash
git add .
git commit -m "feat: 你的策划内容描述"
```

### Step 2: 推送到个人分支
```bash
git push origin zhongshu-dev
```

### Step 3: 创建 Pull Request (使用 gh CLI) ⭐
```bash
gh pr create \
  --base feature \
  --head zhongshu-dev:zhongshu-dev \
  --title "feat: 策划新增内容" \
  --body "详细描述本次策划工作\n\n变更列表：\n- [列出修改文件]\n\n测试状态：待审核"
```

### Step 4 (备选): 直接合并到 feature
```bash
git pull origin feature && git merge zhongshu-dev -m "Merge zhongshu-dev into feature"
```

---

## 📋 **策划任务类型**

| 任务类型 | 说明 | 示例 |
|---------|------|------|
| 玩法设计 | 核心机制创新 | "新增地下城探索玩法" |
| 关卡设计 | 迷宫/BOSS 房布局 | "地下城主角色设定 #1" |
| 世界观 | 背景故事扩展 | "完善古代神话体系" |
| 美术需求 | 美术资源文档 | "迷宫场景概念图需求" |
| 程序需求 | 技术实现说明 | "地下城生成算法规范" |

---

## ⚠️ **重要提醒**

- **绝不要直接修改 `origin/feature`！** - 只在自己分支改，用 PR 合并
- **提交信息要规范：**
  ```bash
  feat: 新增 XX 功能 # 新功能
  fix: 修正 XX bug   # 修复问题
  doc: 更新文档      # 文档修改
  ```

---

*🐉 中书开发 | gh CLI 优先模式 | 随时等待 BOSS 指示!*
