# 🎬 NPC 立绘动画规格 - NPC Animation Specification

**版本:** v1.0  
**最后更新:** 2026-03-30  
**首辅确认方案：** ✅ 12 张版本

---

## 📊 **最终确认配置**

### ✅ **每个 NPC 角色的完整资源清单 (12 张):**

| # | 文件名 | 类型 | 说明 | 尺寸 |
|---|--------|------|------|------|
| **01** | `idle_neutral_01.png` | 呼吸动画帧 1 | 居中待机 | 32x32px |
| **02** | `idle_neutral_02.png` | 呼吸动画帧 2 | 上浮 2px | 32x32px |
| **03** | `idle_neutral_03.png` | 呼吸动画帧 3 | 下沉 2px | 32x32px |
| **04** | `sway_left.png` | 摇摆动画帧 1 | 左倾 5° | 32x32px |
| **05** | `sway_right.png` | 摇摆动画帧 2 | 右倾 5° | 32x32px |
| **06** | `happy_static.png` | 静态表情 | 开心状态 | 32x32px |
| **07** | `worried_static.png` | 静态表情 | 担忧状态 | 32x32px |
| **08** | `aggressive_static.png` | 静态表情 | 愤怒状态 | 32x32px |
| **09-12** | (可选扩展) | - | - | - |

> 📝 **说明**: 呼吸动画循环播放，摇摆动画在对话时触发，静态表情用于 UI 切换。

---

## 🎨 **AI 生成提示词模板 (绘事专用)**

### ✅ **呼吸动画帧:**

```markdown
# 帧 1 - 居中待机
"pixel art character sprite of [角色描述], breathing idle animation frame 1/3, 
perfectly centered position, neutral expression, 
body slightly relaxed posture, 32x32 pixels, 
vibrant cartoon colors, clean pixel lines"

# 帧 2 - 上浮动画  
"pixel art character sprite of [角色描述], breathing idle animation frame 2/3, 
body floating upward by 2 pixels, neutral expression,
slight shoulder lift, 32x32 pixels, vibrant cartoon style"

# 帧 3 - 下沉动画
"pixel art character sprite of [角色描述], breathing idle animation frame 3/3, 
body sinking downward by 2 pixels, neutral expression,
shoulders relaxed down, 32x32 pixels, vibrant cartoon style"
```

### ✅ **摇摆动画帧:**

```markdown
# 左倾
"pixel art character sprite of [角色描述], body leaning left at 5 degrees angle, 
neutral expression, head slightly tilted right for balance, 
32x32 pixels, cartoon style, clean pixel lines"

# 右倾  
"pixel art character sprite of [角色描述], body leaning right at 5 degrees angle,
neutral expression, head slightly tilted left for balance,
32x32 pixels, cartoon style, clean pixel lines"
```

### ✅ **静态表情:**

```markdown
# 开心
"pixel art character sprite of [角色描述], happy expression, 
wide smile with visible teeth, eyes curved upward in joy, 
cheeks slightly raised, 32x32 pixels, vibrant cartoon style"

# 担忧
"pixel art character sprite of [角色描述], worried expression, 
eyebrows angled inward and upward, small frown mouth,
eyes slightly narrowed, 32x32 pixels, cartoon style"

# 愤怒
"pixel art character sprite of [角色描述], angry/aggressive expression,
eyebrows sharply angled downward, tight straight mouth,
intense eyes, 32x32 pixels, vibrant colors, cartoon style"
```

---

## 📁 **文件命名规范**

```bash
assets/sprites/npcs/[npc_name]/
├── idle_neutral_01.png      # 呼吸动画帧 1
├── idle_neutral_02.png      # 呼吸动画帧 2  
├── idle_neutral_03.png      # 呼吸动画帧 3
├── sway_left.png            # 摇摆左倾
├── sway_right.png           # 摇摆右倾
├── happy_static.png         # 静态表情：开心
├── worried_static.png       # 静态表情：担忧
└── aggressive_static.png    # 静态表情：愤怒

# 示例路径:
assets/sprites/npcs/blacksmith_kael/idle_neutral_01.png
assets/sprites/npcs/alchemist_elvira/happy_static.png
```

---

## ⏱️ **预计执行时间**

| NPC 角色 | 呼吸动画 (3) | 摇摆动画 (2) | 静态表情 (3) | 单角色耗时 |
|----------|--------------|--------------|--------------|------------|
| 铁匠凯尔 | 15min | 10min | 15min | **40min** |
| 药剂师艾薇拉 | 15min | 10min | 15min | **40min** |
| 商人罗恩 | 15min | 10min | 15min | **40min** |
| 情报员影 | 15min | 10min | 15min | **40min** |
| 旅馆老板玛莎 | 15min | 10min | 15min | **40min** |

**7 NPC × 40min = 280min ≈ 4.5-5h (含测试调整)**

---

## 🎯 **给绘事的执行清单**

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
```

---

## 📊 **总工期重新计算**

| 阶段 | 任务 | 预计耗时 | 输出文件数 |
|------|------|----------|------------|
| **NPC 立绘** | 7 NPC × 12 张 | **5h** | 84 张 |
| **主角动画** | 战斗姿态 + 受伤状态 | 3-4h | ~10 张 |
| **怪物精灵** | 哥布林/史莱姆/骷髅兵 | 4-5h | ~27 帧 |

**总工期：12-14h (比原计划 18h 节省约 30%)** ✅

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*  
*文档版本：v1.0 | 最后更新：2026-03-30*