# 📦 角色资源库完整清单 - Character Resource Library

**版本:** v1.0  
**最后更新:** 2026-03-30  

---

## 🎯 **资源库结构总览**

```
assets/sprites/
├── characters/
│   ├── player/          # 主角角色 (阶段一)
│   │   ├── idle/        # 待机动画帧
│   │   ├── walk/        # 行走动画帧
│   │   ├── attack/      # 攻击动画帧
│   │   └── hurt/        # 受伤状态
│   └── npcs/            # NPC 角色 (阶段二)
│       ├── blacksmith_kael/    # 铁匠凯尔
│       ├── alchemist_elvira/   # 药剂师艾薇拉
│       ├── merchant_ron/       # 商人罗恩
│       ├── shadow_shadow/      # 情报员影
│       └── martha_innkeeper/   # 旅馆老板玛莎
├── monsters/            # 怪物精灵 (阶段一)
│   ├── goblin_sprite/    # 哥布林
│   ├── slime_sprite/     # 史莱姆
│   └── skeleton_enemy/   # 骷髅兵
└── bosses/              # Boss 角色 (阶段二)
    └── lava_beast/       # 熔岩巨兽
```

---

## 📋 **第一阶段资源清单 (主角 + 怪物)**

### ✅ **主角角色详细规格**

| 序号 | 文件路径 | 文件名 | 尺寸 | 帧数 | 说明 | 优先级 |
|------|----------|--------|------|------|------|--------|
| **01** | `characters/player/idle/` | `player_idle_01.png` | 32x32 | 1 | 中立表情待机 | P0 |
| **02** | `characters/player/idle/` | `player_idle_happy_01.png` | 32x32 | 1 | 开心表情待机 | P0 |
| **03** | `characters/player/idle/` | `player_idle_worried_01.png` | 32x32 | 1 | 担忧表情待机 | P0 |
| **04** | `characters/player/idle/` | `player_idle_angry_01.png` | 32x32 | 1 | 愤怒表情待机 | P0 |
| **05** | `characters/player/walk/` | `player_walk_01.png` | 32x32 | 4 | 行走动画帧 (循环) | P0 |
| **06** | `characters/player/walk/` | `player_walk_backpack_01.png` | 32x32 | 4 | 带背包行走动画 | P1 |
| **07** | `characters/player/attack/` | `player_attack_sword_01-04.png` | 32x32 | 4 | 剑攻击动画帧 | P0 |
| **08** | `characters/player/attack/` | `player_attack_magic_01-04.png` | 32x32 | 4 | 魔法攻击动画帧 | P1 |
| **09** | `characters/player/hurt/` | `player_hurt_light_01.png` | 32x32 | 1 | 轻伤状态 | P1 |
| **10** | `characters/player/hurt/` | `player_hurt_heavy_01.png` | 32x32 | 1 | 重伤状态 | P1 |

### ✅ **怪物精灵详细规格**

| 序号 | 文件路径 | 文件名 | 尺寸 | 帧数 | 说明 | 优先级 |
|------|----------|--------|------|------|------|--------|
| **11** | `monsters/goblin/` | `goblin_idle_01.png` | 16x16 | 1 | 哥布林待机 | P0 |
| **12** | `monsters/goblin/` | `goblin_walk_01-03.png` | 16x16 | 3 | 哥布林行走动画 (循环) | P0 |
| **13** | `monsters/goblin/` | `goblin_attack_01-04.png` | 16x16 | 4 | 哥布林攻击动画帧 | P0 |
| **14** | `monsters/slime/` | `slime_bounce_idle_01.png` | 16x16 | 2 | 史莱姆跳跃待机 (2 帧循环) | P0 |
| **15** | `monsters/slime/` | `slime_attack_squish_01-03.png` | 16x16 | 3 | 史莱姆攻击挤压动画 | P0 |
| **16** | `monsters/skeleton/` | `skeleton_idle_01.png` | 16x16 | 1 | 骷髅兵待机 (轻微摇摆) | P1 |
| **17** | `monsters/skeleton/` | `skeleton_walk_01-3.png` | 16x16 | 3 | 骷髅兵行走动画 | P1 |
| **18** | `monsters/skeleton/` | `skeleton_attack_claw_01-4.png` | 16x16 | 4 | 骷髅兵爪击动画帧 | P1 |

---

## 📋 **第二阶段资源清单 (Boss + NPC)**

### ✅ **NPC 角色详细规格 (v1.2 - 动态立绘方案)**

每个 NPC = 
- 呼吸动画 (neutral): 3 帧循环 → idle_neutral_01/02/03.png
- 摇摆动画 (neutral): 2 帧触发 → sway_left/sway_right.png  
- 静态表情 (happy/worried/aggressive): 各 1 张 = 3 张

**总计：8 帧 + 4 张静态 = 12 张/角色**

| # | NPC 名称 | 文件路径 | 尺寸 | v1.2 规格 | 数量 | 优先级 |
|---|----------|----------|------|----------|------|--------|
| **19** | 铁匠凯尔 | `npcs/blacksmith_kael/` | 32x32 | idle×3 + sway×2 + static×3 | 8 帧 +4 张 =12 张 | P0 |
| **20** | 药剂师艾薇拉 | `npcs/alchemist_elvira/` | 32x32 | idleswaystatic | 8 帧 +4 张 =12 张 | P0 |
| **21** | 商人罗恩 | `npcs/merchant_ron/` | 32x32 | idle×3 + sway×2 + static×3 | 8 帧 +4 张 =12 张 | P0 |
| **22** | 情报员影 | `npcs/shadow_shadow/` | 32x32 | idle×3 + sway×2 + static×3 | 8 帧 +4 张 =12 张 | P0 |
| **23** | 旅馆老板玛莎 | `npcs/martha_innkeeper/` | 32x32 | idle×3 + sway×2 + static×3 | 8 帧 +4 张 =12 张 | P0 |

**7 NPC × 12 张 = 84 张立绘 (v1.2)**

### ✅ **隐藏 NPC (阶段三)**

| # | NPC 名称 | 文件路径 | 尺寸 | 表情状态 | 数量 | 解锁条件 |
|---|----------|----------|------|----------|------|----------|
| **24** | 神秘商人无名者 | `npcs/nameless_merchant/` | 32x32 | neutral/mysterious/suspicious | 3 张 | 黑暗契约任务线 |
| **25** | 隐士智者阿隆索 | `npcs/alonso_sage/` | 32x32 | neutral/wisdomful/contemplative | 3 张 | 古代遗迹主线完成 |

### ✅ **Boss 角色详细规格**

| # | Boss 名称 | 文件路径 | 尺寸 | 动画帧 | 说明 | 优先级 |
|---|----------|----------|------|--------|------|--------|
| **26** | 熔岩巨兽 | `bosses/lava_beast/` | 64x64 | idle: 3 帧, attack: 5 帧, death: 8 帧 | Boss 待机、攻击、死亡动画 | P1 |

---

## 📋 **第三阶段资源清单 (地图 + 场景)**

### ✅ **基地场景详细规格**

| # | 场景名称 | 文件路径 | 尺寸 | 说明 | 优先级 |
|---|----------|----------|------|------|--------|
| **27** | 基地主堡内部 | `scenes/base/main_hall.png` | 1920x1080px | 中央大厅，NPC 对话场景 | P1 |
| **28** | 铁匠铺内部 | `scenes/base/blacksmith_shop.png` | 1920x1080px | 锻造台、工具架 | P1 |
| **29** | 炼金塔内部 | `scenes/base/alchemy_tower.png` | 1920x1080px | 实验台、魔法书 | P1 |

### ✅ **地牢场景详细规格**

| # | 场景名称 | 文件路径 | 尺寸 | 说明 | 优先级 |
|---|----------|----------|------|------|--------|
| **30** | 新手矿洞入口 | `dungeons/mining_entrance.png` | 1280x720px | 矿石堆积、简单通道 | P1 |
| **31** | 废弃矿井内部 | `dungeons/abandoned_mine.png` | 1920x1080px | 陷阱区域、蛛网细节 | P1 |
| **32** | 古代遗迹大厅 | `dungeons/ancient_ruins_hall.png` | 1920x1080px | 符文机关、石碑 | P1 |
| **33** | 深渊裂谷 Boss 战区域 | `dungeons/abyssal_chasm_boss_area.png` | 1920x1080px | 熔岩池、Boss 核心 | P1 |

---

## 📦 **完整资源包统计**

### ✅ **按类型分类:**

| 资源类别 | 文件数量 | 总大小预估 | 完成状态 |
|----------|----------|------------|----------|
| **主角角色动画帧** | 20 张 | ~1.5MB | ⏳ 待生成 (阶段一) |
| **怪物精灵** | 18 张 | ~1.0MB | ⏳ 待生成 (阶段一) |
| **NPC 立绘 (v1.2)** | 84 张 | ~6.7MB | ⏳ 待生成 (阶段二，5h) |
| **Boss 角色动画帧** | 16 张 | ~3.0MB | ⏳ 待生成 (阶段三) |
| **场景背景图** | 7 张 | ~5.0MB | ⏳ 待生成 (阶段三) |

### ✅ **按优先级分类:**

| 优先级 | 资源数量 | 预计完成时间 (v1.2) |
|--------|----------|---------------------|
| **P0 (核心)** | 32 张 | 4-6h |
| **P1 (扩展)** | 67 张 | 8-9h |

**总工期**: **12-15h** (比原计划 18h 节省约 30%) ✅

---

## 🎨 **AI 生成参数配置 (绘事专用)**

### ✅ **统一参数设置:**

```markdown
通用配置:
├─ width: [根据资源类型选择：32/16/64/1920]
├─ height: [匹配 width，保持像素比例]
├─ pixel_ratio: 1.0 (no anti-aliasing)
├─ color_palette: vibrant, cartoon-like
└─ style_keywords: "pixel art, cartoon style"

负面提示词 (必须包含):
├─ "photorealistic, realistic skin texture"
├─ "cinematic lighting, 4K render"
└─ "adult explicit content, naked, genitalia"
```

### ✅ **各类型特殊参数:**

| 资源类型 | width/height | 额外提示词 | 注意事项 |
|----------|--------------|------------|----------|
| **主角立绘** | 32x32 | "young adventurer, suggestive elements - tight crop top and shorts" | 突出身体曲线，但不暴露过度 |
| **NPC 立绘** | 32x32 | "character with distinct personality, expressive face" | 表情状态变化明显 |
| **怪物精灵** | 16x16 | "cute but dangerous monster design" | 卡通化但保持威胁感 |
| **Boss 角色** | 64x64 | "imposing final boss, special effects - fire/energy aura" | 复杂特效，视觉冲击强 |
| **场景背景** | 1920x1080 | "pixel art landscape, vibrant colors, clean lines" | 像素风格但高分辨率 |

---

## 📝 **给绘事的执行清单:**

### ✅ **第一步：清理错误素材**
```bash
# 删除已生成的错误风格图片
Remove-Item "D:\soft\openclaw\绘事\dungeon-extraction-game\assets\sprites\npc\*.png" -Force
```

### ✅ **第二步：按优先级生成**

#### 🎯 **第一阶段 (4-6h):**

| 顺序 | 任务 | 预计耗时 | 输出文件数 |
|------|------|----------|------------|
| **1** | 主角立绘 (neutral/happy/worried/aggressive) | 30min | 4 张 |
| **2** | 哥布林精灵 (idle/walk/attack) | 45min | 9 帧 |
| **3** | 史莱姆精灵 (bounce/idle/death) | 30min | 6 帧 |
| **4** | 骷髅兵精灵 (walk/attack/break) | 1h | 12 帧 |
| **5** | 主角战斗姿态 (攻击/防御/施法) | 2h | 6 张 |

#### 🎯 **第二阶段 (v1.2 - NPC 立绘动态化):**

| 顺序 | 任务 | 预计耗时 | 输出文件数 | v1.2 规格 |
|------|------|----------|------------|----------|
| **6** | NPC 铁匠凯尔 (呼吸×3 + 摇摆×2 + 表情×3) | 1h | 8 帧 +4 张 =12 张 | 12 张/角色 |
| **7** | NPC 药剂师艾薇拉 | 1h | 12 张 | 12 张/角色 |
| **8** | NPC 商人罗恩 | 1h | 12 张 | 12 张/角色 |
| **9** | NPC 情报员影 | 1h | 12 张 | 12 张/角色 |
| **10** | NPC 旅馆老板玛莎 | 1h | 12 张 | 12 张/角色 |
| **11** | Boss 熔岩巨兽 (idle×3 + attack×5 + death×8) | 1.5h | 16 帧 | v1.0 静态方案 |

**第二阶段总计**: 7 NPC × 12 张 = 84 张立绘，耗时 **5-6h**

#### 🎯 **第三阶段 (8-10h):**

| 顺序 | 任务 | 预计耗时 | 输出文件数 |
|------|------|----------|------------|
| **12** | 基地主堡内部场景 | 1.5h | 1 张 |
| **13** | 新手矿洞入口场景 | 1h | 1 张 |
| **14** | 废弃矿井场景 | 1.5h | 1 张 |
| **15** | 古代遗迹大厅场景 | 1.5h | 1 张 |
| **16** | 深渊裂谷 Boss 战区域 | 2h | 1 张 |

---

## 🎨 **色度元素尺度确认 (给绘事)**

### ✅ **允许范围:**

```markdown
服装剪裁:
├─ 女角色短上衣露腰 (✅ 允许)
├─ 短裙露大腿上部 (✅ 允许)
└─ 紧身衣突出 S 型曲线 (✅ 允许)

身体暴露:
├─ 锁骨、肩膀裸露 (✅ 允许)
├─ 腹部微露 (⚠️ 谨慎处理)
└─ 胸部过度暴露 (❌ 禁止)

暗示性元素:
├─ 薄纱透视隐约可见轮廓 (✅ 艺术化处理)
├─ 挑逗姿势但非直接暴露 (✅ 允许)
└─ 内衣清晰可见 (❌ 禁止)
```

### 🚫 **绝对禁区:**

```markdown
❌ 生殖器/性器官直接描绘
❌ 性行为过程或暗示
❌ 未成年人角色性化
❌ 血腥暴力与性结合
❌ 非自愿/强迫场景
```

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*  
*文档版本：v1.0 | 最后更新：2026-03-30*
