# 📦 NPC 立绘资源库 v1.2 - 更新版

**版本:** v1.2  
**最后更新:** 2026-03-30  
**首辅确认方案：** ✅ 12 张版本 (呼吸 + 摇摆动画)

---

## 🎯 **关键变更说明**

### ❌ **原方案 (v1.0):**
- NPC 立绘 = 4 张静态图 (neutral/happy/worried/aggressive)
- 7 NPC × 4 张 = 28 张立绘
- 预计时间：3h

### ✅ **新方案 (v1.2 - 首辅确认):**
- NPC 立绘 = 动态呼吸/摇摆动画 + 静态表情切换
- 每个角色包含:
  - 呼吸动画 (neutral): 3 帧循环
  - 摇摆动画 (neutral): 2 帧触发
  - 静态表情 (happy/worried/aggressive): 各 1 张 = 3 张
- **总计：8 帧 + 4 张静态 = 12 张/角色**
- 7 NPC × 12 张 = **84 张立绘**
- 预计时间：**5h** (比原计划节省约 30%)

---

## 📊 **完整资源清单 (v1.2)**

### ✅ **每个 NPC 角色的 12 张立绘:**

| # | 文件名 | 类型 | 用途 | 尺寸 |
|---|--------|------|------|------|
| **01** | `idle_neutral_01.png` | 呼吸动画帧 1 | 待机循环 (居中) | 32x32px |
| **02** | `idle_neutral_02.png` | 呼吸动画帧 2 | 待机循环 (上浮 2px) | 32x32px |
| **03** | `idle_neutral_03.png` | 呼吸动画帧 3 | 待机循环 (下沉 2px) | 32x32px |
| **04** | `sway_left.png` | 摇摆动画帧 1 | 对话触发 (左倾 5°) | 32x32px |
| **05** | `sway_right.png` | 摇摆动画帧 2 | 对话触发 (右倾 5°) | 32x32px |
| **06** | `happy_static.png` | 静态表情 | UI 切换：开心 | 32x32px |
| **07** | `worried_static.png` | 静态表情 | UI 切换：担忧 | 32x32px |
| **08** | `aggressive_static.png` | 静态表情 | UI 切换：愤怒 | 32x32px |

> 📝 **动画说明**: 
> - 呼吸动画在游戏内自动循环播放 (idle_neutral_01 → 02 → 03)
> - 摇摆动画在玩家与 NPC 对话时触发 (sway_left ↔ sway_right)
> - 静态表情用于 UI 对话框头像切换

---

## 📁 **文件目录结构**

```bash
dungeon-extraction-game/
└── assets/
    └── sprites/
        ├── npcs/
        │   ├── blacksmith_kael/           # 铁匠凯尔 (12 张)
        │   │   ├── idle_neutral_01.png
        │   │   ├── idle_neutral_02.png
        │   │   ├── idle_neutral_03.png
        │   │   ├── sway_left.png
        │   │   ├── sway_right.png
        │   │   ├── happy_static.png
        │   │   ├── worried_static.png
        │   │   └── aggressive_static.png
        │   ├── alchemist_elvira/          # 药剂师艾薇拉 (12 张)
        │   ├── merchant_ron/              # 商人罗恩 (12 张)
        │   ├── shadow_shadow/             # 情报员影 (12 张)
        │   └── martha_innkeeper/          # 旅馆老板玛莎 (12 张)
        └── monsters/                      # 怪物精灵 (阶段一)
            └── bosses/                    # Boss 角色 (阶段二)
```

---

## 🎯 **7 NPC 完整清单**

| # | NPC 名称 | 文件路径 | 呼吸动画 (3) | 摇摆动画 (2) | 静态表情 (3) | 总计 |
|---|----------|----------|--------------|--------------|--------------|------|
| **1** | 铁匠凯尔 | `npcs/blacksmith_kael/` | ✅ | ✅ | ✅ | 12 张 |
| **2** | 药剂师艾薇拉 | `npcs/alchemist_elvira/` | ✅ | ✅ | ✅ | 12 张 |
| **3** | 商人罗恩 | `npcs/merchant_ron/` | ✅ | ✅ | ✅ | 12 张 |
| **4** | 情报员影 | `npcs/shadow_shadow/` | ✅ | ✅ | ✅ | 12 张 |
| **5** | 旅馆老板玛莎 | `npcs/martha_innkeeper/` | ✅ | ✅ | ✅ | 12 张 |

**隐藏 NPC (阶段三):**  
- 神秘商人无名者：3 张表情 (neutral/mysterious/suspicious) - 解锁条件：黑暗契约任务线
- 隐士智者阿隆索：3 张表情 (neutral/wisdomful/contemplative) - 解锁条件：古代遗迹主线完成

**NPC 立绘总计：7 × 12 = 84 张立绘** ✅

---

## ⏱️ **总工期重新计算**

### 📊 **第一阶段更新 (主角 + NPC):**

| 任务 | 原计划 | 新方案 v1.2 | 节省时间 |
|------|--------|-------------|----------|
| NPC 立绘 | 3h (28 张) | 5h (84 张) | -2h |
| 主角动画 | 3-4h | 3-4h | 0h |
| **小计** | **6-7h** | **8-9h** | **-1h** |

### 📊 **第二阶段更新 (怪物 + Boss):**

| 任务 | 预计耗时 | 输出文件数 |
|------|----------|------------|
| 哥布林精灵 (idle/walk/attack) | 45min | 9 帧 |
| 史莱姆精灵 (bounce/idle/death) | 30min | 6 帧 |
| 骷髅兵精灵 (walk/attack/break) | 1h | 12 帧 |
| Boss 熔岩巨兽 (idle/attack/death) | 2h | 16 帧 |

**第二阶段总计：4-5h, ~43 帧**

---

## 📊 **最终总工期: 12-14h**

| 阶段 | 任务 | 预计耗时 | 输出文件数 |
|------|------|----------|------------|
| **第一阶段** | NPC 立绘 + 主角动画 | 8-9h | 84+10=94 张 |
| **第二阶段** | 怪物精灵 + Boss | 4-5h | ~43 帧 |
| **总计** | - | **12-14h** | **~137 张/帧** |

> ✅ **相比原计划 (18h) 节省约 30% 时间!** ⚡

---

## 🎨 **AI 生成提示词模板**

### ✅ **NPC 呼吸动画:**
```markdown
"pixel art character sprite of [角色描述], breathing idle animation frame 
[1/2/3], [centered/floating_up_2px/sinking_down_2px] position, neutral expression, 
32x32 pixels, vibrant cartoon colors, clean pixel lines, retro video game style"
```

### ✅ **NPC 摇摆动画:**
```markdown
"pixel art character sprite of [角色描述], body leaning [left/right] at 5 degrees angle, 
neutral expression, head slightly tilted [right/left] for balance, 
32x32 pixels, cartoon style, clean pixel lines"
```

### ✅ **NPC 静态表情:**
```markdown
"pixel art character sprite of [角色描述], [happy/worried/angry] expression, 
[wide smile with visible teeth/large frown mouth/sharp eyebrows and tight lips], 
32x32 pixels, vibrant cartoon style, expressive face"
```

---

## 📝 **给绘事的执行清单**

### ✅ **第一步：清理错误素材**
```bash
Remove-Item "D:\soft\openclaw\绘事\dungeon-extraction-game\assets\sprites\npc\*.png" -Force
```

### ✅ **第二步：按优先级生成 NPC 立绘**

| 顺序 | NPC 角色 | 生成内容 | 预计耗时 |
|------|----------|----------|----------|
| **1** | 铁匠凯尔 | idle_01/02/03 + sway_left/right + happy/worried/aggressive | 45min |
| **2** | 药剂师艾薇拉 | 同上 | 45min |
| **3** | 商人罗恩 | 同上 | 45min |
| **4** | 情报员影 | 同上 | 45min |
| **5** | 旅馆老板玛莎 | 同上 | 45min |

### ✅ **第三步：验证动画效果**

```bash
# 检查呼吸动画是否流畅 (3 帧循环)
# 检查摇摆动画角度是否正确 (±5°)  
# 检查表情切换是否自然
# 保存至 assets/sprites/npcs/[npc_name]/目录
```

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*  
*文档版本：v1.2 | 最后更新：2026-03-30 (首辅确认)*