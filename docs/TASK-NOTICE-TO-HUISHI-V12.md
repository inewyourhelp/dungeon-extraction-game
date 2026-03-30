# 📢 任务通知 - 绘事 (v1.2 方案)

**发送时间:** 2026-03-30 16:45  
**首辅确认方案:** ✅ NPC 立绘采用 12 张版本

---

## 🎯 **紧急通知：NPC 立绘规格更新!**

### ❌ **旧方案已作废:**
- ~~NPC = 4 张静态图~~ ❌
- ~~7 NPC × 4 张 = 28 张~~ ❌

### ✅ **新方案 (立即执行):**
- **每个 NPC = 12 张立绘**
- 包含：呼吸动画 (3 帧) + 摇摆动画 (2 帧) + 静态表情 (3 张)
- **7 NPC × 12 张 = 84 张立绘**

---

## 📦 **每个 NPC 的完整资源清单:**

```bash
npc_blacksmith_kael/
├── idle_neutral_01.png    # 呼吸动画帧 1 (居中)
├── idle_neutral_02.png    # 呼吸动画帧 2 (上浮 2px)
├── idle_neutral_03.png    # 呼吸动画帧 3 (下沉 2px)
├── sway_left.png          # 摇摆左倾 5°
├── sway_right.png         # 摇摆右倾 5°
├── happy_static.png       # 静态表情：开心
├── worried_static.png     # 静态表情：担忧
└── aggressive_static.png  # 静态表情：愤怒

总计：**12 张/角色** ✅
```

---

## 🎨 **AI 生成提示词模板 (复制使用):**

### ✅ **呼吸动画帧:**
```markdown
"pixel art character sprite of [描述], breathing idle animation frame 
[1/2/3], [centered/floating_up_2px/sinking_down_2px] position, neutral expression, 
32x32 pixels, vibrant cartoon colors, clean pixel lines"
```

### ✅ **摇摆动画帧:**
```markdown
"pixel art character sprite of [描述], body leaning [left/right] at 5 degrees angle, 
neutral expression, head slightly tilted [right/left] for balance, 
32x32 pixels, cartoon style"
```

### ✅ **静态表情:**
```markdown
"pixel art character sprite of [描述], [happy/worried/angry] expression, 
[wide smile/large frown/sharp eyebrows], 32x32 pixels, vibrant cartoon style"
```

---

## ⏱️ **预计执行时间:**

| NPC | 生成内容 | 耗时 |
|-----|----------|------|
| 铁匠凯尔 | idle(3) + sway(2) +表情(3) | 45min |
| 药剂师艾薇拉 | 同上 | 45min |
| 商人罗恩 | 同上 | 45min |
| 情报员影 | 同上 | 45min |
| 旅馆老板玛莎 | 同上 | 45min |

**7 NPC × 45min = 280min ≈ 4.5-5h (含测试调整)** ✅

---

## 🎯 **立即执行清单:**

### ✅ **第一步：清理错误素材**
```bash
Remove-Item "D:\soft\openclaw\绘事\dungeon-extraction-game\assets\sprites\npc\*.png" -Force
```

### ✅ **第二步：按优先级生成 NPC 立绘**
1. 铁匠凯尔 → 8 张完整资源
2. 药剂师艾薇拉 → 8 张完整资源  
3. 商人罗恩 → 8 张完整资源
4. 情报员影 → 8 张完整资源
5. 旅馆老板玛莎 → 8 张完整资源

### ✅ **第三步：保存至本地**
```bash
assets/sprites/npcs/[npc_name]/
├── idle_neutral_01.png
├── idle_neutral_02.png
├── idle_neutral_03.png
├── sway_left.png
├── sway_right.png
├── happy_static.png
├── worried_static.png
└── aggressive_static.png
```

### ✅ **第四步：提交 Git**
```bash
git add assets/sprites/npcs/
git commit -m "feat: 完成 NPC 立绘资源 (84 张，呼吸 + 摇摆动画)"
```

---

## 📊 **总工期更新:**

| 阶段 | 任务 | 预计耗时 |
|------|------|----------|
| **NPC 立绘** | 7 × 12 = 84 张 | **5h** |
| **主角动画** | 战斗姿态 + 受伤状态 | 3-4h |
| **怪物精灵** | 哥布林/史莱姆/骷髅兵 | 4-5h |

**总工期：12-14h (比原计划 18h 节省约 30%)** ⚡

---

## 💬 **绘事请回复:**

> "收到！立即清理错误素材，按 v1.2 方案开始生成 NPC 立绘。  
> 预计 5h 完成所有 NPC (84 张)，总工期 12-14h。"

**首辅确认方案，请立即执行！** 🎨✨