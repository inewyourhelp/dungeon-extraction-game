# 🤝 贡献者指南 - Dungeon Extraction

## 📋 项目规范

### 🎯 命名规范

#### **文件/文件夹命名**
- **格式:** `snake_case` (小写 + 下划线)
- **示例:**
  - ✅ `role_hero`, `item_sword`, `map_dungeon_01`
  - ❌ `RoleHero`, `ItemSword`, `MapDungeon01`

#### **版本控制**
- **格式:** `vX.Y.Z` (主版本号。次版本号。修订号)
- **示例:** `v1.0.0`, `v2.1.3`

---

### 🎨 像素尺寸标准

| 元素类型 | 推荐尺寸 | 说明 |
|----------|----------|------|
| **角色精灵** | 16x16 / 32x32 | 经典像素比例 |
| **UI 图标** | 24x24 / 32x32 | 清晰易读 |
| **地图图块** | 16x16 / 32x32 | 与角色一致 |
| **特效动画** | 动态，单帧≤64x64 | 避免过大性能消耗 |

---

### 📄 文件格式规范

#### **文本/脚本文件**
- `.json` - 数据配置（卡牌、物品等）
- `.lua` - 游戏逻辑脚本
- `.md` - 设计文档
- `.yaml` - 卡牌定义文件

#### **资源文件**
- `.png` - 图片（必须带 alpha 透明通道）
- `.wav` - SFX (短音效)
- `.ogg` - 音乐 (背景音乐)

---

### 🗂️ 目录结构规范

```
DungeonExtraction/
├── assets/              # 所有资源文件
│   ├── sprites/        # 像素角色/场景图
│   │   └── [category]/ # 按类别分组（role, enemy, building）
│   ├── ui/             # UI 元素
│   │   └── icons/      # UI 图标
│   ├── audio/          # 音频资源
│   │   ├── music/      # 背景音乐
│   │   └── sfx/        # 音效
│   └── maps/           # 关卡地图数据
├── cards/              # 🃏 卡牌定义文件 (新增)
├── config/             # 配置文件
│   ├── cards/          # 卡牌模板
│   └── systems/        # 系统配置
├── docs/               # 设计文档
├── scripts/            # 游戏逻辑脚本
│   ├── core/           # 核心系统
│   ├── combat/         # 战斗系统
│   └── base/           # 基地建设
├── tasks/              # 📝 任务记录与进度跟踪
└── world/              # 🎨 世界观相关内容
    ├── story/          # 剧情剧本
    └── lore/           # 背景设定
```

---

### 📝 Git 提交规范

#### **Commit Message 格式**
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

#### **Type 类型**
- `feat` - 新功能
- `fix` - Bug 修复
- `docs` - 文档更新
- `style` - 格式调整（不影响代码逻辑）
- `refactor` - 重构
- `test` - 测试相关
- `chore` - 构建/工具配置

#### **示例**
```bash
feat(combat): 添加回合制战斗核心机制
fix(cards): 修复卡牌还原冷却时间计算错误
docs(lore): 补充白魔导师背景故事细节
```

---

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd DungeonExtraction
```

### 2. 创建功能分支
```bash
git checkout -b feat/your-feature-name
```

### 3. 开发并提交
```bash
git add .
git commit -m "feat(combat): 添加回合制战斗核心机制"
```

### 4. 推送到远程
```bash
git push origin feat/your-feature-name
```

---

## 📞 联系方式

- **项目负责人:** @尚书 (mainAgent)
- **最终决策者:** @相爷 (人类负责人)
- **世界观设计:** 待补充

---

*本规范将持续更新，请保持关注！*

