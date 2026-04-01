# 🎲 MODULE: 随机节点系统 (Random Nodes)

**版本:** v1.0 | **创建日期:** 2026-04-02 | **维护人:** 中书 🐉

---

## 📋 **文档定位说明**

### ✅ **本文档做什么：**
- 定义随机事件类型与分类（战斗/探索/交易/剧情/特殊）
- 设计事件触发条件与概率公式
- 配置奖励池分层系统（L1~L4）
- 实现动态难度调整算法（DDA）
- 制定事件冷却与唯一性控制机制

### ❌ **本文档不做：**
- 具体战斗数值平衡 → 交给 Roguelike 地牢模块
- NPC 对话树设计 → 交给剧情演绎模块
- 装备属性定义 → 交给对应系统文档
- 固定节点功能 → 已归入 MODULE-FIXED-NODES.md

---

## 🎯 **一、事件类型总览**

### 【1.1 五大事件类别】

```typescript
enum RandomEventType {
  COMBAT,     // ⚔️ 战斗类 - 敌对遭遇
  EXPLORATION,// 🔍 探索类 - 发现与收集
  TRADING,    // 💰 交易类 - 经济互动
  STORY,      // 📖 剧情类 - 叙事推进
  SPECIAL      // ✨ 特殊类 - 机制性事件
}
```

### 【1.2 事件类型枚举表（30+ 种）】

#### ⚔️ **战斗类 (Combat Events)**

| ID | 名称 | 描述 | 基础概率 | 难度系数 | 前置条件 |
|----|------|------|----------|----------|----------|
| `combat_normal` | 普通遭遇战 | 随机怪物群遭遇 | 25% | 1.0x | - |
| `combat_elite` | 精英怪战斗 | 强化版精英敌人 | 8% | 1.5x | 等级≥10 |
| `combat_boss` | BOSS 战 | 小型 BOSS 遭遇 | 3% | 2.0x | 等级≥20 + 任务进度 |
| `combat_ambush` | 伏击战 | 突然袭击，首回合劣势 | 5% | 1.2x | - |
| `combat_wave` | 波次战斗 | 多波敌人连续进攻 | 4% | 1.3x | 等级≥15 |

---

#### 🔍 **探索类 (Exploration Events)**

| ID | 名称 | 描述 | 基础概率 | 难度系数 | 前置条件 |
|----|------|------|----------|----------|----------|
| `explore_chest` | 宝箱发现 | 随机掉落物品/金币 | 15% | - | - |
| `explore_secret` | 隐藏通道 | 发现秘密路径（跳过节点） | 2% | - | 侦查技能≥Lv3 |
| `explore_ruins` | 遗迹探索 | 古代遗迹，解谜获取奖励 | 6% | - | 等级≥12 |
| `explore_map` | 地图碎片 | 收集后可解锁新区域 | 8% | - | - |
| `explore_trap` | 陷阱机关 | 触发后造成 debuff/伤害 | 7% | - | - |

---

#### 💰 **交易类 (Trading Events)**

| ID | 名称 | 描述 | 基础概率 | 难度系数 | 前置条件 |
|----|------|------|----------|----------|----------|
| `trade_merchant` | 流动商人 | 随机商品买卖机会 | 10% | - | - |
| `trade_blackmarket` | 黑市交易 | 稀有物品，高风险高回报 | 3% | - | 等级≥25 + 声望要求 |
| `trade_barter` | 以物易物 | 用特定物品交换其他物品 | 4% | - | - |
| `trade_gamble` | 赌博 | 下注博弈，可能翻倍或全输 | 5% | - | 等级≥18 |

---

#### 📖 **剧情类 (Story Events)**

| ID | 名称 | 描述 | 基础概率 | 难度系数 | 前置条件 |
|----|------|------|----------|----------|----------|
| `story_help` | NPC 求助 | 帮助被困角色，获得好感度 | 8% | - | - |
| `story_quest` | 支线任务触发 | 开启新任务线 | 4% | - | 主线进度要求 |
| `story_choice` | 阵营选择 | 二选一影响后续剧情 | 2% | - | 特定剧情节点后 |
| `story_moral` | 道德抉择 | 善恶值变化，影响结局 | 3% | - | 等级≥20 |

---

#### ✨ **特殊类 (Special Events)**

| ID | 名称 | 描述 | 基础概率 | 难度系数 | 前置条件 |
|----|------|------|----------|----------|----------|
| `special_buff` | 增益 buff | 临时属性提升（持续 N 层） | 6% | - | - |
| `special_debuff` | Debuff 施加 | 负面状态，降低能力 | 5% | - | - |
| `special_heal` | 自然恢复 | HP/SP自动回复 | 7% | - | - |
| `special_curse` | 诅咒效果 | 持续 debuff，需特定方法解除 | 2% | - | 等级≥30 |
| `special_blessing` | 祝福效果 | 强力 buff，稀有触发 | 1% | - | 声望≥500 |

---

### 【1.3 事件类型分布统计】

```markdown
总事件数：30 种
├─ ⚔️ 战斗类 (Combat)    : 5 种  → 25% + 8% + 3% + 5% + 4% = 45%
├─ 🔍 探索类 (Exploration): 5 种  → 15% + 2% + 6% + 8% + 7% = 38%
├─ 💰 交易类 (Trading)   : 4 种  → 10% + 3% + 4% + 5% = 22%
├─ 📖 剧情类 (Story)     : 4 种  → 8% + 4% + 2% + 3% = 17%
└─ ✨ 特殊类 (Special)   : 7 种  → 6% + 5% + 7% + 2% + 1% = 21%

总计：143%（因战斗类概率较高，实际运行时会归一化）
```

---

## 🎲 **二、触发条件设计**

### 【2.1 概率计算公式】

#### 核心公式：
```typescript
function calculateEventProbability(
  event: RandomEvent,
  player: PlayerState,
  dungeonDifficulty: DungeonDifficulty
): number {
  // 基础概率 × 难度系数 × 玩家属性修正 × 随机波动
  const baseProb = event.baseProbability;
  
  // 难度系数：E=0.8, D=1.0, C=1.2, B=1.5, A=2.0, S=3.0
  const difficultyMultiplier = getDifficultyMultiplier(dungeonDifficulty);
  
  // 玩家属性修正（根据事件类型）
  const playerModifier = calculatePlayerModifier(event, player);
  
  // 随机波动：±10%
  const randomFluctuation = 0.9 + Math.random() * 0.2;
  
  return clamp(baseProb * difficultyMultiplier * playerModifier * randomFluctuation, 0, 1);
}
```

#### 难度系数表：

| 地牢等级 | E | D | C | B | A | S |
|----------|---|---|---|---|---|---|
| **难度系数** | 0.8x | 1.0x | 1.2x | 1.5x | 2.0x | 3.0x |

#### 玩家属性修正示例：

```typescript
// 根据事件类型应用不同修正
function calculatePlayerModifier(event: RandomEvent, player: PlayerState): number {
  switch (event.category) {
    case 'combat':
      // 战斗类：高等级玩家遭遇强敌概率↑
      return 1.0 + (player.level - dungeonRecommenedLevel) * 0.02;
      
    case 'exploration':
      // 探索类：高侦查技能发现隐藏物概率↑
      const scoutSkill = player.skills.find(s => s.id === 'scout')?.level || 0;
      return 1.0 + scoutSkill * 0.1;
      
    case 'trading':
      // 交易类：高魅力属性获得优惠概率↑
      return 1.0 + player.attributes.charm * 0.05;
      
    default:
      return 1.0;
  }
}
```

---

### 【2.2 前置条件检查】

```typescript
interface EventPrerequisite {
  type: 'level' | 'item' | 'quest' | 'reputation' | 'skill';
  target: string;        // 目标值（等级/物品 ID/任务 ID 等）
  operator: 'gte' | 'lte' | 'eq' | 'has' | 'not_has'; // 比较运算符
}

function checkPrerequisites(event: RandomEvent, player: PlayerState): boolean {
  if (!event.prerequisites) return true;
  
  for (const prereq of event.prerequisites) {
    const satisfied = checkSinglePrerequisite(prereq, player);
    if (!satisfied) return false;
  }
  return true;
}
```

#### 前置条件类型示例：

```markdown
【等级要求】
{ type: 'level', target: '10', operator: 'gte' }  // 等级≥10

【物品需求】
{ type: 'item', target: 'ancient_key', operator: 'has' }  // 拥有古代钥匙

【任务进度】
{ type: 'quest', target: 'main_quest_ch3', operator: 'completed' }  // 主线第三章已完成

【技能要求】
{ type: 'skill', target: 'scout', operator: 'gte', value: 3 }  // 侦查技能≥Lv3
```

---

### 【2.3 冷却时间控制】

#### 事件唯一性机制：

```typescript
interface EventCooldown {
  scope: 'global' | 'dungeon' | 'session';  // 作用范围
  duration: number;                          // 冷却时长（秒）
  triggerOn: 'start' | 'complete' | 'fail'; // 触发时机
}
```

#### 冷却规则表：

| 事件类型 | Scope | 冷却时间 | Trigger |
|----------|-------|----------|---------|
| `combat_boss` | session | ∞ (一次性) | complete |
| `explore_secret` | dungeon | ∞ (每层一次) | start |
| `trade_blackmarket` | global | 86400s (1 天) | start |
| `story_choice` | session | ∞ (选后锁定) | complete |
| `special_blessing` | global | 259200s (3 天) | start |

---

## 🎁 **三、奖励池分层配置**

### 【3.1 四层奖励结构】

```markdown
┌─────────────────────────────────────────────────────┐
│                   L4 BOSS 层                         │
│         神器部件 / 成就奖励 / 剧情推进               │
├─────────────────────────────────────────────────────┤
│                   L3 精英层                          │
│           传说装备 / 特殊道具 / 称号解锁              │
├─────────────────────────────────────────────────────┤
│                   L2 进阶层                          │
│         稀有装备 / 技能书 / 消耗品套装                │
├─────────────────────────────────────────────────────┤
│                   L1 基础层                          │
│           金币 (50-200) / 普通装备碎片 / 经验值        │
└─────────────────────────────────────────────────────┘
```

---

### 【3.2 各层级奖励详情】

#### L1 **基础层**（普通事件掉落）

```typescript
interface RewardPool_L1 {
  gold: { min: 50, max: 200 };           // 金币
  exp: { min: 100, max: 300 };           // 经验值
  items: [                                // 物品掉落表
    { id: 'common_weapon_frag', prob: 0.3 },
    { id: 'common_armor_frag', prob: 0.25 },
    { id: 'potion_hp_small', prob: 0.4 }
  ];
}
```

**掉落配置：**
| 物品类型 | 概率 | 数量范围 |
|----------|------|----------|
| 普通武器碎片 | 30% | 1-2 |
| 普通防具碎片 | 25% | 1-2 |
| 小 HP 药水 | 40% | 1-3 |
| 材料（木材/石材） | 35% | 2-5 |

---

#### L2 **进阶层**（精英事件掉落）

```typescript
interface RewardPool_L2 {
  gold: { min: 200, max: 800 };
  exp: { min: 300, max: 1000 };
  items: [
    { id: 'rare_equipment', prob: 0.15 },
    { id: 'skill_book_common', prob: 0.2 },
    { id: 'consumable_set', prob: 0.25 }
  ];
}
```

**掉落配置：**
| 物品类型 | 概率 | 数量范围 |
|----------|------|----------|
| 稀有装备（完整） | 15% | 1 |
| 普通技能书 | 20% | 1 |
| 消耗品套装 | 25% | 1-2 |
| 中级材料 | 30% | 3-8 |

---

#### L3 **精英层**（BOSS 事件掉落）

```typescript
interface RewardPool_L3 {
  gold: { min: 800, max: 2500 };
  exp: { min: 1000, max: 3000 };
  items: [
    { id: 'legendary_equipment', prob: 0.08 },
    { id: 'special_item', prob: 0.12 },
    { id: 'title_unlock', prob: 0.05 }
  ];
}
```

**掉落配置：**
| 物品类型 | 概率 | 数量范围 |
|----------|------|----------|
| 传说装备 | 8% | 1 |
| 特殊道具（一次性） | 12% | 1 |
| 称号解锁 | 5% | - |
| 高级材料 | 20% | 5-15 |

---

#### L4 **BOSS 层**（最终 BOSS 掉落）

```typescript
interface RewardPool_L4 {
  gold: { min: 2500, max: 10000 };
  exp: { min: 3000, max: 10000 };
  items: [
    { id: 'artifact_part', prob: 0.15 },
    { id: 'achievement_unlock', prob: 1.0 },
    { id: 'story_progress_item', prob: 1.0 }
  ];
}
```

**掉落配置：**
| 物品类型 | 概率 | 数量范围 |
|----------|------|----------|
| 神器部件 | 15% | 1 |
| 成就解锁 | 100% | - |
| 剧情推进道具 | 100% | 1 |
| 稀有称号 | 3% | - |

---

### 【3.3 奖励计算公式】

```typescript
function calculateReward(
  event: RandomEvent,
  playerLevel: number,
  dungeonDifficulty: DungeonDifficulty
): Reward {
  const basePool = getRewardPool(event.rewardTier);
  
  // 数值根据玩家等级缩放
  const scale = 1.0 + (playerLevel - dungeonRecommendedLevel) * 0.05;
  
  return {
    gold: Math.round(basePool.gold.min * scale),
    exp: Math.round(basePool.exp.min * scale),
    items: rollItems(basePool.items)
  };
}
```

---

## 🔄 **四、动态难度调整（DDA）**

### 【4.1 玩家进度追踪】

```typescript
interface PlayerProgressStats {
  winRate: number;           // 胜率（0-1）
  avgClearTime: number;      // 平均通关时间（秒）
  deathCount: number;        // 死亡次数
  last5Events: EventResult[]; // 最近 5 次事件结果
}
```

---

### 【4.2 自适应调整算法】

```typescript
function calculateDDAAdjustment(stats: PlayerProgressStats): number {
  let adjustment = 0;
  
  // 胜率分析：胜率高→难度↑，胜率低→难度↓
  if (stats.winRate > 0.8) {
    adjustment += 0.1;      // 太轻松了，提升 10% 难度
  } else if (stats.winRate < 0.4) {
    adjustment -= 0.15;      // 太难了，降低 15% 难度
  }
  
  // 通关时间分析：太快→难度↑
  if (stats.avgClearTime < dungeonRecommendedTime * 0.7) {
    adjustment += 0.08;
  }
  
  // 死亡次数分析：频繁死亡→难度↓
  if (stats.deathCount > 3) {
    adjustment -= 0.2;       // 连续死亡，大幅降低难度
  }
  
  return clamp(adjustment, -0.3, 0.3);  // 单次调整范围 ±30%
}
```

---

### 【4.3 保底机制】

```typescript
function checkCompensationTrigger(stats: PlayerProgressStats): boolean {
  // 连续失败 3 次 → 触发简单事件补偿
  const consecutiveFailures = stats.last5Events.filter(e => !e.success).length;
  if (consecutiveFailures >= 3) return true;
  
  // 长时间无奖励 → 强制触发高价值事件
  const rewardsInLast10 = stats.last10Events.filter(e => e.hasReward).length;
  if (rewardsInLast10 < 2) return true;
  
  return false;
}
```

**补偿措施：**
```markdown
- 【难度补偿】：下一事件难度降低 50%
- 【奖励补偿】：强制触发 L3/L4 层奖励池
- 【跳过机制】：允许免费跳过当前节点（每局限 1 次）
```

---

## 📊 **五、数据结构总览**

### 【RandomEvent State】:
```typescript
interface RandomEventState {
  // 事件基础信息
  eventId: string;
  type: RandomEventType;
  category: string;           // 子分类（combat_normal, explore_chest...）
  
  // 触发状态
  isTriggered: boolean;
  cooldownUntil?: number;     // 冷却结束时间戳
  
  // 事件内容
  description: string;        // 事件描述文本
  options?: EventOption[];    // 可选操作（多分支时）
  
  // 奖励配置
  rewardTier: 'L1' | 'L2' | 'L3' | 'L4';
  actualReward?: Reward;      // 实际获得的奖励
}
```

---

## 🔄 **六、与其他模块的接口**

### 【输入】:
- 从【Roguelike 地牢】获取：当前层数、已访问节点列表
- 从【领地建设系统】获取：玩家等级、技能配置、背包物品
- 从【剧情演绎系统】获取：任务进度、阵营好感度

### 【输出】:
- 向【Roguelike 地牢】传递：生成的随机事件内容
- 向【领地建设系统】反馈：获得的奖励（装备/资源）
- 向【剧情演绎系统】更新：触发的剧情分支、好感度变化

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*
