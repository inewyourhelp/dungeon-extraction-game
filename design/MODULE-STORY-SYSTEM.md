# 🎭 MODULE: 剧情演绎系统 (Story System)

**版本:** v1.0 | **创建日期:** 2026-04-02 | **维护人:** 中书 🐉

---

## 📋 **文档定位说明**

### ✅ **本文档做什么：**
- 定义 NPC 分类体系（大世界/领地/地牢三层分布）
- 设计对话树结构与触发条件机制
- 规划好感度系统（数值范围、增减规则、效果反馈）
- 明确与其他五大模块的数据接口关系

### ❌ **本文档不做：**
- 具体对话文本内容 → 交给文案策划文档
- NPC 战斗属性 → 交给 Roguelike 地牢模块
- 建筑功能定义 → 交给领地建设模块
- 大世界移动规则 → 交给大世界系统模块

---

## 🗺️ **一、NPC 分类体系**

### 【1.1 三层分布架构】

根据 `CORE-GAMEPLAY-ARCHITECTURE-v1.0.md` 定义，NPC 按存在位置分为三层：

```┌─────────────────────────────────────────────────────────────┐
│                    大世界系统 (World)                        │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐           │
│   │城镇 NPC◄─┼───►│固定节点 ├───►│随机事件 NPC│           │
│   │(Town)    │     │NPC       │     │          │           │
│   └─────┬────┘     └────┬─────┘     └────┬─────┘           │
│         │               │                  │               │
│         ▼───────────────▼──────────────────▼               │
│              Roguelike 地牢 (Dungeon)                       │
│    ┌─────┬─────┬─────┬─────┬─────┬─────┐                  │
│    │战斗NPC│商人NPC│任务NPC│Boss NPC│特殊NPC│              │
│    └─────┴─────┴─────┴─────┴─────┴─────┘                  │
├─────────────────────────────────────────────────────────────┤
│              领地建设系统 (Base)                            │
│     招募 NPC + 功能型 NPC（贯穿所有模块）                    │
└───────────────────────────────────────────────────────────┘```

---

### 【1.2 NPC 类型详细定义】

#### 🏰 **大世界层 NPC**

##### 【城镇 NPC (Town NPCs)】
```typescript
interface TownNPC {
  id: string;
  name: string;
  position: HexCoord;        // 固定在大世界城镇坐标
  type: 'quest_giver' | 'merchant' | 'info_source' | 'recruiter';
  faction: string;           // 所属阵营
  isPermanent: true;         // 永久存在
}
```

**类型细分：**
| 类型 | 图标 | 功能描述 |
|------|------|----------|
| `quest_giver` | 📜 | 主线/支线任务发布者 |
| `merchant` | 💰 | 固定商人（买卖装备/消耗品） |
| `info_source` | ℹ️ | 情报提供者（地图提示/背景故事） |
| `recruiter` | 👥 | NPC 招募官（解锁可招募角色池） |

**分布规则：**
- 每个城镇固定配置：1×任务发布者 + 1×商人 + 1×情报员
- 高级城镇额外解锁：招募官、特殊功能 NPC

---

##### 【固定节点 NPC (Fixed Node NPCs)】
```typescript
interface FixedNodeNPC {
  id: string;
  name: string;
  nodeId: string;            // 关联的固定节点 ID
  type: 'guard' | 'boss' | 'vendor';
  spawnCondition?: any;      // 生成条件（任务完成/等级要求等）
}
```

**类型细分：**
| 类型 | 图标 | 功能描述 |
|------|------|----------|
| `guard` | 🛡️ | 守卫 NPC（可战斗或对话解锁通路） |
| `boss` | 👹 | Boss NPC（固定节点最终战） |
| `vendor` | 🏪 | 特殊商人（稀有物品/蓝图交易） |

---

##### 【随机事件 NPC (Random Event NPCs)】
```typescript
interface RandomEventNPC {
  id: string;
  position: HexCoord;        // 动态生成位置
  type: 'traveling_merchant' | 'bandit' | 'wandering_soul';
  duration: number;          // 存在时长（秒）
  spawnRule: SpawnCondition; // 生成条件
}
```

**类型细分：**
| 类型 | 图标 | 功能描述 | 刷新周期 |
|------|------|----------|----------|
| `traveling_merchant` | 🛒 | 流动商人（特殊商品） | 1-3 小时 |
| `bandit` | ⚔️ | 强盗（遭遇战或贿赂选项） | 即时生成 |
| `wandering_soul` | 👻 | 游魂（剧情碎片/隐藏任务） | 4-12 小时 |

---

#### 🏰 **领地层 NPC**

##### 【招募 NPC (Recruited Characters)】
```typescript
interface RecruitedNPC {
  id: string;
  name: string;
  characterId: string;       // 角色档案 ID
  assignment?: {             // 岗位分配（可选）
    buildingId: string;
    dutyType: 'producer' | 'guard' | 'idle';
  };
  equipment?: CharacterEquipment;  // 装备配置
  skills?: CharacterSkill[];        // 技能配置
}
```

**招募渠道：**
```markdown
1. **城镇招募官** - 每日刷新可招募角色池（受声望影响）
2. **任务奖励** - 完成特定剧情线解锁专属角色
3. **地牢解救** - Roguelike 探索中拯救被困角色
4. **好感度解锁** - 与 NPC 关系达到阈值后加入
```

---

##### 【功能型 NPC (Functional NPCs)】
```typescript
interface FunctionalNPC {
  id: string;
  name: string;
  buildingId: string;        // 关联建筑
  functionType: FunctionType;
}
```

**类型细分：**
| 类型 | 图标 | 功能描述 | 关联建筑 |
|------|------|----------|----------|
| `trainer` | 🥋 | 战斗训练（角色经验 +20%） | 训练场 |
| `repairman` | 🔧 | 装备修理（速度 +50%） | 武器库 |
| `healer` | 🏥 | HP 自动恢复 (+50%/秒) | 医院 |
| `restorer` | 💤 | SP 自动恢复 (+30%/秒) | 旅馆 |

---

#### ⚔️ **Roguelike 地牢层 NPC**

##### 【战斗型 NPC (Combat NPCs)】
```typescript
interface CombatNPC {
  id: string;
  name: string;
  roomType: 'COMBAT';
  enemyType: 'NORMAL' | 'ELITE' | 'BOSS' | 'AMBUSH';
  level: number;
  stats: EnemyStats;
}
```

**敌人类型概率（每层）：**
| 层数 | 普通遭遇战 | 精英怪 | BOSS 战 | 伏击战 |
|------|------------|--------|---------|--------|
| Layer 1 | 70% | 20% | - | 10% |
| Last Layer | 50% | 40% | **10%** | - |

---

##### 【商人 NPC (Merchant NPCs)】
```typescript
interface MerchantNPC {
  merchantType: 'TRAVELING' | 'FIXED' | 'BLACK_MARKET';
  goods: ShopItem[];
  currency: 'GOLD' | 'SPECIAL_CURRENCY';
}
```

**商人类型：**
| 类型 | 图标 | 商品池 | 价格修正 |
|------|------|--------|----------|
| `TRAVELING` | 🛒 | 消耗品为主 | ×1.0 |
| `FIXED` | 🏪 | 装备/技能书 | ×0.9（折扣） |
| `BLACK_MARKET` | 🎭 | 稀有物品/特殊道具 | ×1.5（溢价） |

---

##### 【任务型 NPC (Quest NPCs)】
```typescript
interface QuestNPC {
  id: string;
  name: string;
  questId: string;           // 关联任务 ID
  dialogueTreeId: string;    // 专属对话树
}
```

**触发场景：**
- 地牢中遇到的被困者（解救任务）
- 神秘旅人（隐藏剧情线入口）
- 古代守卫（解谜/战斗混合事件）

---

##### 【特殊 NPC (Special NPCs)】
```typescript
interface SpecialNPC {
  id: string;
  name: string;
  specialType: 'GAMBLER' | 'ORACLE' | 'TRICKSTER';
}
```

**类型细分：**
| 类型 | 图标 | 功能描述 |
|------|------|----------|
| `GAMBLER` | 🎲 | 赌博机（下注金币） |
| `ORACLE` | 🔮 | 预言者（提示宝箱/陷阱位置） |
| `TRICKSTER` | 😈 | 恶作剧者（真假选项/心理博弈） |

---

### 【1.3 NPC 状态管理】

#### 🔄 **状态机设计**

```typescript
type NPCState = 'IDLE' | 'CONVERSING' | 'COMBAT' | 'DEAD' | 'RECRUITED';

interface NPC {
  // ...其他属性
  state: NPCState;
  stateTransition?: any;      // 状态转换条件
}
```

**状态流转图：**
```
┌─────────┐     ┌──────────────┐     ┌────────┐     ┌──────────┐
│ IDLE    │────►│ CONVERSING   │◄────│ ALIVE  │────►│ COMBAT   │
└────┬────┘     └──────┬───────┘     └────┬───┘     └────┬─────┘
     │                │                    │              │
     ▼                ▼                    ▼              ▼
┌─────────┐     ┌──────────────┐     ┌────────┐     ┌──────────┐
│DEAD     │◄────│ RECRUITED    │     │ESCAPED │     │FLED      │
└─────────┘     └──────────────┘     └────────┘     └──────────┘
```

**状态定义：**
| 状态 | 描述 | 可交互条件 |
|------|------|------------|
| `IDLE` | 待机中，等待玩家靠近 | ✅ 可随时对话 |
| `CONVERSING` | 正在与玩家对话 | ❌ 不可重复触发 |
| `ALIVE` | 存活状态（非战斗） | ✅ 可对话/可战斗 |
| `COMBAT` | 战斗中 | ❌ 仅能战斗，不能对话 |
| `DEAD` | 已死亡 | ❌ 永久不可交互 |
| `RECRUITED` | 已招募加入领地 | ✅ 可在领地内管理 |

---

## 🗣️ **二、对话树系统**

### 【2.1 对话结构规范】

#### 📌 **基础数据结构**

```typescript
interface DialogueNode {
  id: string;                // 节点唯一标识
  speakerId: string;         // 说话者 NPC ID
  text: string;              // 对话文本内容
  options?: DialogueOption[];// 分支选项（可选）
}

interface DialogueOption {
  id: string;
  text: string;              // 选项文本
  targetNodeId: string;      // 跳转目标节点 ID
  conditions?: TriggerCondition[];  // 显示条件（可选）
  effects?: NodeEffect[];     // 触发效果（可选）
}
```

#### 📌 **对话树可视化示例**

```
┌─────────────────────────────────────────────────────┐
│              [ROOT] 开场白                           │
│   "旅行者，你看起来不像这里的本地人..."             │
├──────────┬──────────────┬───────────────────────────┤
│          │              │                           │
▼          ▼              ▼                           ▼
【选项 A】 【选项 B】    【选项 C:需好感度≥50】  【选项 D:需任务完成】
"我是来冒险的"   "我在找工作"   "老朋友的问候"   "关于那个任务..."
    │              │              │                    │
    ▼              ▼              ▼                    ▼
[战斗触发]   [招募对话]   [特殊剧情线]      [任务推进]
```

---

### 【2.2 选项类型分类】

#### 📋 **四大选项类别**

| 类型 | 图标 | 描述 | 典型用途 |
|------|------|------|----------|
| `QUEST` | 📜 | 任务相关选项 | 接受/拒绝任务、查询进度 |
| `TRADE` | 💰 | 交易相关选项 | 购买/出售物品、询价 |
| `RELATIONSHIP` | ❤️ | 好感度影响选项 | 友好/中立/敌对态度 |
| `INFORMATION` | ℹ️ | 信息查询选项 | 背景故事、地图提示、NPC 信息 |

---

### 【2.3 触发条件机制】

#### 🎯 **条件类型枚举**

```typescript
type ConditionType = 
  | 'FRIENDSHIP'           // 好感度门槛
  | 'QUEST_PROGRESS'       // 任务进度要求
  | 'ITEM_OWNED'           // 物品持有检查
  | 'CHARACTER_LEVEL'      // 角色等级要求
  | 'SKILL_UNLOCKED'       // 技能解锁状态
  | 'FACTION_REPUTATION'   // 阵营声望要求
  | 'FLAG_SET'             // 剧情标志位检查
  | 'TIME_RANGE'           // 时间范围限制;

interface TriggerCondition {
  type: ConditionType;
  targetId: string;        // 目标 ID（物品/任务/技能等）
  operator: 'EQ' | 'GT' | 'LT' | 'GTE' | 'LTE' | 'NE';
  value: any;              // 比较值
}
```

#### 📊 **条件组合示例**

```typescript
// 示例：同时满足多个条件才能显示选项
const specialOption: DialogueOption = {
  id: 'opt_secret_reveal',
  text: "你知道那个秘密吗？",
  targetNodeId: 'node_secret_story',
  conditions: [
    { type: 'FRIENDSHIP', targetId: 'npc_001', operator: 'GTE', value: 70 },
    { type: 'QUEST_PROGRESS', targetId: 'quest_mystery', operator: 'EQ', value: 'completed' },
    { type: 'ITEM_OWNED', targetId: 'item_key_fragment', operator: 'GT', value: 0 }
  ]
};
// 结果：好感度≥70 AND 任务已完成 AND 持有钥匙碎片 ≥1 → 显示选项
```

---

### 【2.4 节点效果系统】

#### ⚡ **效果类型定义**

```typescript
type EffectType =
  | 'SET_FRIENDSHIP'        // 设置好感度数值
  | 'MODIFY_FRIENDSHIP'     // 增减好感度
  | 'START_QUEST'           // 开始任务
  | 'COMPLETE_QUEST'        // 完成/推进任务
  | 'GIVE_ITEM'             // 给予物品
  | 'TAKE_ITEM'             // 收取物品
  | 'GIVE_GOLD'             // 给予金币
  | 'TAKE_GOLD'             // 收取金币
  | 'SET_FLAG'              // 设置剧情标志位
  | 'UNLOCK_NPC'            // 解锁可招募 NPC
  | 'TRIGGER_COMBAT'        // 触发战斗;

interface NodeEffect {
  type: EffectType;
  targetId?: string;        // 目标 ID（可选）
  value?: any;              // 效果值（可选）
}
```

#### 📋 **效果应用示例**

```markdown
【好感度增减】
- SET_FRIENDSHIP: npc_001 = 50        → 直接设置为 50
- MODIFY_FRIENDSHIP: npc_001 += 10    → 当前值 +10

【任务推进】
- START_QUEST: quest_first_blood      → 开启新手任务
- COMPLETE_QUEST: quest_first_blood   → 完成任务并结算奖励

【物品交易】
- GIVE_ITEM: item_potion_heal × 3     → 玩家获得 3 个治疗药水
- TAKE_ITEM: item_rare_herb × 1       → 从玩家处收取 1 个稀有草药
```

---

## ❤️ **三、好感度系统**

### 【3.1 数值范围与等级划分】

#### 📊 **好感度等级表**

| 等级 | 名称 | 数值范围 | 图标 | 关系描述 |
|------|------|----------|------|----------|
| L0 | 陌生 | 0-24 | 👤 | "从未谋面，互不相识" |
| L1 | 初识 | 25-49 | 🤝 | "有过一面之缘" |
| L2 | 友好 | 50-74 | 😊 | "聊得来的朋友" |
| L3 | 信任 | 75-89 | ❤️ | "可以托付后背的伙伴" |
| L4 | 亲密 | 90-100 | 💕 | "生死之交，心意相通" |

**数值范围：** `0 ~ 100`（封顶 100）

---

### 【3.2 好感度增减规则】

#### ➕ **增加途径**

| 方式 | 触发场景 | 增减量 | 备注 |
|------|----------|---------|------|
| **送礼** | 向 NPC 赠送物品 | +5 ~ +20 | 根据礼物偏好度调整 |
| **完成任务** | 完成 NPC 委托的任务 | +10 ~ +30 | 按任务难度分级 |
| **对话选择** | 选择友好选项 | +2 ~ +10 | 单次对话上限 +10 |
| **战斗协助** | Roguelike 中救助 NPC | +15 ~ +25 | 高风险高回报 |
| **日常互动** | 每日首次对话 | +1 | 冷却时间 24 小时 |

#### ➖ **减少途径**

| 方式 | 触发场景 | 增减量 | 备注 |
|------|----------|---------|------|
| **拒绝任务** | 拒绝 NPC 委托 | -5 ~ -10 | 视任务重要性而定 |
| **敌对选项** | 选择冒犯性对话 | -3 ~ -15 | 单次对话下限 -15 |
| **战斗伤害** | 误伤友方 NPC | -20 ~ -50 | 严重惩罚 |
| **任务失败** | 未能完成承诺 | -10 ~ -20 | 信誉损失 |

---

### 【3.3 好感度效果反馈】

#### 🎁 **等级解锁内容**

```markdown
【L0 陌生 (0-24)】
├─ ❌ 无法进行深度对话
├─ ❌ 无法接受专属任务
└─ ✅ 基础交易（原价）

【L1 初识 (25-49)】
├─ ✅ 解锁普通对话分支
├─ ✅ 可接受简单支线任务
├─ 💰 交易折扣：95% OFF
└─ ❌ 无法招募

【L2 友好 (50-74)】
├─ ✅ 解锁中级对话分支
├─ ✅ 可接受中等难度任务
├─ 💰 交易折扣：85% OFF
├─ 🎁 送礼偏好系统激活
└─ ❌ 无法招募

【L3 信任 (75-89)】
├─ ✅ 解锁高级对话分支（剧情线）
├─ ✅ 可接受高难度任务/隐藏任务
├─ 💰 交易折扣：70% OFF
├─ 👥 可招募加入领地
└─ ✨ 解锁特殊功能（如情报共享）

【L4 亲密 (90-100)】
├─ ✅ 全对话分支解锁
├─ 💰 交易折扣：50% OFF（半价！）
├─ 🎁 专属任务线开启
├─ ❤️ 特殊剧情事件触发
└─ 👑 可能解锁隐藏结局/成就
```

---

### 【3.4 送礼偏好系统】

#### 🎯 **偏好度计算公式**

```typescript
function calculateGiftEffect(npc: NPC, item: Item): number {
  // 基础好感度增益
  const baseValue = item.rarity === 'LEGENDARY' ? 20 :
                    item.rarity === 'RARE' ? 10 :
                    item.rarity === 'UNCOMMON' ? 5 : 3;
  
  // 偏好修正系数（1.5x ~ 0.5x）
  const preferenceMultiplier = npc.preferences[item.type] || 1.0;
  
  return Math.round(baseValue * preferenceMultiplier);
}
```

#### 📋 **物品类型偏好表**

| NPC 职业 | 最爱 (1.5x) | 喜欢 (1.2x) | 普通 (1.0x) | 不喜欢 (0.8x) | 讨厌 (0.5x) |
|----------|-------------|-------------|------------|--------------|------------|
| `warrior` | 武器类 | 食物类 | 消耗品 | 书籍类 | 饰品类 |
| `mage` | 书籍类 | 材料类 | 消耗品 | 武器类 | 食物类 |
| `rogue` | 饰品类 | 工具类 | 消耗品 | 防具类 | 书籍类 |

---

## 📊 **四、数据结构总览**

### 【NPC State】:
```typescript
interface NPCState {
  // 基础信息
  id: string;
  name: string;
  type: NpcType;             // 类型枚举
  layer: 'world' | 'base' | 'dungeon';  //