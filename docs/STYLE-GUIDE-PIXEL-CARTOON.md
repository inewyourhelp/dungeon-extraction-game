# 🎨 像素卡通风格指南 - Pixel Cartoony Style Guide

**版本:** v1.0  
**最后更新:** 2026-03-30  

---

## 📋 **核心风格定义**

### ✅ **官方确认风格:**
```markdown
【像素卡通风格】(Pixel Cartoony)
├─ 经典像素比例：16x16 / 32x32
├─ 卡通化角色设计 ( exaggerated features )
├─ 带一点色气元素 ( suggestive/adult-themed )
└─ ❌ 拒绝高清渲染图 (photorealistic renders)
```

---

## 🎨 **风格参考示例**

### 📚 **推荐参考作品:**

| 游戏/作品 | 风格特点 | 值得借鉴的元素 |
|-----------|----------|----------------|
| **《星露谷物语》(Stardew Valley)** | 温暖像素风，角色表情丰富 | NPC 设计、色彩搭配 |
| **《泰拉瑞亚》(Terraria)** | 2D 像素冒险，怪物多样 | 怪物精灵设计 |
| **《元气骑士》(Soul Knight)** | 卡通化战斗角色，技能特效 | 攻击动画帧 |
| **《空洞骑士》(Hollow Knight)** | 手绘质感 + 像素精度 | Boss 设计、氛围营造 |
| **《传说之下》(Undertale)** | 简单像素 + 强烈个性 | 表情状态变化 |

### 🖼️ **风格关键词 (用于 AI 生成提示词):**

```markdown
正例提示词:
"pixel art, cartoon style, cute character design, 
suggestive elements, adult-themed but not explicit, 
32x32 pixels, vibrant colors, clean lines, 
video game sprite, retro aesthetic"

反例 (避免):
"photorealistic, 4K render, realistic skin texture, 
detailed anatomy, cinematic lighting, 8K resolution"
```

---

## 🎨 **色度元素尺度规范**

### ✅ **允许范围 (建议/成年向):**

| 元素类型 | 允许程度 | 具体说明 | 示例 |
|----------|----------|----------|------|
| **服装剪裁** | ✅ 宽松允许 | 紧身衣、露腰装、短裙等 | 女角色穿短上衣 + 短裤 |
| **身体曲线** | ✅ 适度强调 | 突出 S 型轮廓，但不夸张 | 腰部收细、臀部圆润 |
| **肌肤暴露度** | ⚠️ 谨慎处理 | 可露锁骨、肩膀、大腿上部 | 避免过度暴露胸部/腹部 |
| **暗示性姿势** | ✅ 艺术化处理 | 挑逗但非色情 | 侧身站立、手抚头发 |
| **内衣可见度** | ❌ 禁止直接展示 | 可通过透明材质暗示 | 薄纱透视但不清晰 |

### 🚫 **绝对禁区 (不可触碰):**

```markdown
❌ 明确禁止内容:
├─ 生殖器/性器官直接描绘
├─ 性行为过程或暗示
├─ 未成年人角色性化
├─ 血腥暴力与性结合
└─ 非自愿/强迫场景

平台合规要求:
├─ Steam: 18+ 分级需明确标注
├─ App Store: 避免过度暴露
└─ PC 游戏：成人内容需年龄验证
```

### 🎯 **推荐尺度 (安全且有趣):**

| NPC/角色类型 | 服装建议 | 色度元素处理 |
|--------------|----------|--------------|
| **女冒险者** | 短上衣 + 短裤 + 长靴 | 露腰、大腿上部，突出曲线 |
| **女法师** | 修身长袍 + 高开叉裙摆 | 锁骨、肩膀裸露，薄纱透视 |
| **女战士** | 轻型铠甲 + 短裙甲 | 腹部微露，肌肉线条 |
| **男角色** | 标准冒险者装束 | 适度展现肌肉，避免过度性感化 |

---

## 🖼️ **像素比例规范**

### ✅ **官方确认尺寸:**

| 场景/用途 | 推荐尺寸 | 说明 |
|-----------|----------|------|
| **主角角色立绘** | 32x32 px | 主视角，细节可稍多 |
| **怪物/敌人精灵** | 16x16 ~ 32x32 px | 根据体型调整 |
| **NPC 头像 (UI)** | 80x80 px | 圆形裁剪用于对话界面 |
| **Boss 角色** | 64x64 px | 复杂 Boss 可更大 |

### 📐 **像素比例参考:**

```markdown
32x32 角色结构划分:
├─ 头部：8px (1/4)
├─ 躯干：12px (3/8)
├─ 腿部：10px (5/16)
└─ 总高度：32px

16x16 角色简化版:
├─ 头部：4px
├─ 躯干：6px
├─ 腿部：6px
└─ 总高度：16px
```

---

## 🎨 **角色资源库完整清单**

### ✅ **第一阶段 (主角 + 怪物):**

| 序号 | 素材名称 | 规格要求 | 数量 | 优先级 |
|------|----------|----------|------|--------|
| **01** | 主角立绘 - 基础姿态 | 32x32, neutral/happy/worried/aggressive | 4 张 | P0 |
| **02** | 主角战斗姿态 | 32x32, 攻击/防御/施法 | 6 张 | P0 |
| **03** | 主角受伤状态 | 32x32, 轻伤/重伤 | 2 张 | P1 |
| **04** | 哥布林精灵 | 16x16, idle/walk/attack | 3 帧 × 3 = 9 张 | P0 |
| **05** | 史莱姆精灵 | 16x16, bounce/idle/death | 3 帧 × 2 = 6 张 | P0 |
| **06** | 骷髅兵精灵 | 16x16, walk/attack/break | 4 帧 × 3 = 12 张 | P1 |

### ✅ **第二阶段 (Boss + NPC):**

| 序号 | 素材名称 | 规格要求 | 数量 | 优先级 |
|------|----------|----------|------|--------|
| **07** | NPC 立绘 - 铁匠凯尔 | 32x32, 4 种表情状态 | 4 张 | P0 |
| **08** | NPC 立绘 - 药剂师艾薇拉 | 32x32, 4 种表情状态 | 4 张 | P0 |
| **09** | NPC 立绘 - 商人罗恩 | 32x32, 4 种表情状态 | 4 张 | P0 |
| **10** | NPC 立绘 - 情报员影 | 32x32, 4 种表情状态 | 4 张 | P0 |
| **11** | NPC 立绘 - 旅馆老板玛莎 | 32x32, 4 种表情状态 | 4 张 | P0 |
| **12** | Boss 熔岩巨兽 | 64x64, idle/attack/boss phase 2 | 8 帧 × 3 = 24 张 | P1 |

### ✅ **第三阶段 (地图 + 场景):**

| 序号 | 素材名称 | 规格要求 | 数量 | 优先级 |
|------|----------|----------|------|--------|
| **13** | 基地主堡内部 | 1920x1080px, PNG | 1 张 | P1 |
| **14** | 新手矿洞入口 | 1280x720px, PNG | 1 张 | P1 |
| **15** | 废弃矿井场景 | 1920x1080px, PNG | 1 张 | P1 |
| **16** | 古代遗迹大厅 | 1920x1080px, PNG | 1 张 | P1 |
| **17** | 深渊裂谷 Boss 战区域 | 1920x1080px, PNG | 1 张 | P1 |

---

## 🎨 **AI 生成提示词模板 (绘事专用)**

### ✅ **主角角色生成模板:**

```markdown
positive prompt:
"pixel art character design, cartoon style, 
32x32 pixels, young adventurer male/female, 
suggestive elements - tight crop top and shorts, 
exposed midriff, curvy body silhouette, 
vibrant colors, clean pixel lines, 
retro video game sprite, cute but mature, 
neutral/happy/worried/aggressive expression"

negative prompt:
"photorealistic, realistic skin texture, detailed anatomy, 
cinematic lighting, 4K render, adult explicit content, 
naked, genitalia, blood, gore, low resolution"

parameters:
- width: 32px
- height: 32px
- pixel_ratio: 1.0 (no anti-aliasing)
- color_palette: vibrant, cartoon-like
```

### ✅ **怪物精灵生成模板:**

```markdown
positive prompt:
"pixel art monster sprite, cartoon style, 
16x16 pixels, goblin/slime/skeleton, 
suggestive elements - exaggerated features, 
vibrant colors, clean pixel lines, 
retro video game enemy, cute but dangerous, 
idle/walk/attack animation frames"

negative prompt:
"photorealistic, detailed texture, cinematic lighting, 
adult explicit content, realistic anatomy, low resolution"

parameters:
- width: 16px
- height: 16px
- pixel_ratio: 1.0 (no anti-aliasing)
```

### ✅ **Boss 角色生成模板:**

```markdown
positive prompt:
"pixel art boss character design, cartoon style, 
64x64 pixels, lava monster/giant creature, 
suggestive elements - massive size, glowing core, 
special effects - fire/energy aura, 
vibrant colors, clean pixel lines, 
retro video game final boss, intimidating but stylized"

negative prompt:
"photorealistic, realistic physics, detailed anatomy, 
adult explicit content, naked, genitalia"

parameters:
- width: 64px
- height: 64px
- pixel_ratio: 1.0 (no anti-aliasing)
```

---

## 🎨 **色度元素处理技巧**

### ✅ **推荐方法:**

| 手法 | 说明 | 示例 |
|------|------|------|
| **服装剪裁暗示** | 短上衣露腰、短裙露腿 | 女冒险者穿露腰装 + 短裤 |
| **薄纱透视** | 半透明材质隐约可见轮廓 | 法师长袍下摆半透明 |
| **身体曲线强调** | S 型腰部收细、臀部圆润 | 通过像素排列突出曲线 |
| **姿势挑逗性** | 侧身站立、手抚头发 | 非直接暴露但暗示性感 |

### 🚫 **避免方法:**

| 手法 | 原因 | 替代方案 |
|------|------|----------|
| **过度暴露胸部/腹部** | 容易越界成色情内容 | 改为露锁骨、肩膀 |
| **清晰内衣可见度** | 违反平台规范 | 通过薄纱暗示即可 |
| **直接性器官描绘** | 绝对禁止 | 完全不画或遮挡 |

---

## 📝 **给绘事的执行清单:**

### ✅ **第一步：清理错误素材**
```bash
# 删除已生成的错误风格图片
Remove-Item "D:\soft\openclaw\绘事\dungeon-extraction-game\assets\sprites\npc\*.png" -Force
```

### ✅ **第二步：调整提示词参数**
```markdown
必须包含关键词:
├─ "pixel art, cartoon style" (核心风格)
├─ "32x32 pixels / 16x16 pixels" (尺寸规范)
├─ "suggestive elements, adult-themed but not explicit" (色度尺度)
└─ "vibrant colors, clean pixel lines" (视觉品质)

必须排除关键词:
├─ "photorealistic, realistic skin texture" (拒绝写实)
├─ "cinematic lighting, 4K render" (拒绝高清渲染)
└─ "adult explicit content, naked, genitalia" (禁止内容)
```

### ✅ **第三步：按顺序生成**
```markdown
第一阶段优先级:
1. 主角立绘 - neutral/happy/worried/aggressive (4 张)
2. 哥布林/史莱姆/骷髅兵精灵 (共 27 帧)
3. 主角战斗姿态 (6 张)

第二阶段优先级:
4. NPC 铁匠凯尔 (4 种表情)
5. NPC 药剂师艾薇拉 (4 种表情)
6. ...依次完成 7 个 NPC

第三阶段优先级:
7. Boss 熔岩巨兽 (24 帧)
8. 基地主堡内部场景
9. 新手矿洞/废弃矿井等场景
```

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*  
*文档版本：v1.0 | 最后更新：2026-03-30*
