# 🗺️ MODULE: 固定节点系统 (Fixed Nodes)

**版本:** v1.0 | **创建日期:** 2026-04-02 | **维护人:** 中书 🐉

---

## 📋 **文档定位说明**

### ✅ **本文档做什么：**
- 定义固定节点类型与分布规则
- 设计城镇功能分区与服务系统
- 规划地牢入口难度分级与进入条件
- 制定特殊节点（传送点/商店/竞技场）机制
- 明确节点间的连接关系与可达性

### ❌ **本文档不做：**
- 地牢内部探索流程 → 交给 Roguelike 地牢模块
- NPC 对话树设计 → 交给剧情演绎模块
- 战斗机制细节 → 交给 Roguelike 地牢模块
- 装备/道具属性定义 → 交给对应系统文档

---

## 🗺️ **一、节点类型总览**

### 【1.1 节点分类】

```typescript
enum FixedNodeType {
  TOWN,           // 城镇节点 - 核心枢纽
  DUNGEON_ENTRY,  // 地牢入口 - 挑战起点
  TELEPORT,       // 传送点 - 快速移动
  SHOP,           // 商店节点 - 交易服务
  QUEST_GIVER,    // 任务发布处 - 剧情推进
  ARENA           // 竞技场 - PVP/PVE 挑战
}
```

### 【1.2 节点层级结构】

```markdown
┌─────────────────────────────────────────────────────┐
│                   大世界地图                         │
│                                                     │
│    ┌──────────┐     ┌──────────┐                   │
│    │ 城镇 A    ├───►│地牢入口 A │  ← 直接连接       │
│    └────┬─────┘     └────┬─────┘                   │
│         │                │                          │
│    ┌────▼────────────────▼────┐                    │
│    │      传送网络            │                    │
│    └──┬──────┬────────┬──────┘                    │
│       ▼      ▼        ▼                           │
│   [传送] [商店]  [任务]  [竞技场]                  │
│     节点   节点   节点    节点                     │
└─────────────────────────────────────────────────────┘
```

---

## 🏙️ **二、城镇节点 (Town Nodes)**

### 【2.1 城镇定位】

**核心功能：** 玩家在大世界中的**安全枢纽**，提供全方位服务

```typescript
interface TownNode {
  id: string;
  name: string;
  tier: 'village' | 'town' | 'city' | 'metropolis';  // 城镇等级
  position: HexCoord;                                  // 大世界坐标
  
  // 功能分区
  districts: District[];
  
  // NPC 分布
  npcs: TownNPC[];
  
  // 解锁条件
  unlockCondition?: UnlockCondition;
}
```

---

### 【2.2 城镇等级】

| 等级 | 名称 | 最大分区数 | 最大 NPC 数 | 解锁条件 |
|------|------|------------|-----------|----------|
| `village` | 村庄 | 3 | 10 | 初始解锁 |
| `town` | 小镇 | 5 | 25 | 完成新手教程 + 声望≥100 |
| `city` | 城市 | 8 | 50 | 声望≥500 + 主线进度 30% |
| `metropolis` | 大都市 | 12 | 100 | 声望≥2000 + 主线进度 70% |

---

### 【2.3 功能分区】

#### 六大分区类型：

```typescript
enum DistrictType {
  RESIDENTIAL,   // 居住区 - NPC 招募/住宿
  COMMERCIAL,    // 商业区 - 商店/交易
  CRAFTING,      // 工匠区 - 装备制作/修理
  TRAINING,      // 训练区 - 角色提升
  SOCIAL,        // 社交区 - 任务发布/情报交换
  DUNGEON_GATE   // 地牢门 - 直接进入地牢
}
```

#### 分区详情表：

| 分区类型 | 图标 | 村庄 | 小镇 | 城市 | 大都市 |
|----------|------|------|------|------|--------|
| `residential` | 🏠 | ✅ | ✅ | ✅ | ✅ |
| `commercial` | 🏪 | ✅ | ✅ | ✅ | ✅ |
| `crafting` | 🔨 | ❌ | ✅ | ✅ | ✅ |
| `training` | 💪 | ❌ | ❌ | ✅ | ✅ |
| `social` | 🍺 | ❌ | ❌ | ✅ | ✅ |
| `dungeon_gate` | ⚔️ | 1 个 | 2 个 | 3 个 | 5 个 |

---

### 【2.4 NPC 分布】

#### NPC 类型分类：

```typescript
interface TownNPC {
  id: string;
  name: string;
  type: NPCType;           // NPC 类型
  district: DistrictType;  // 所在分区
  services: Service[];     // 提供的服务
  schedule?: Schedule;      // 活动时间表（可选）
}
```

#### NPC 类型与服务对应：

| NPC 类型 | 图标 | 所在分区 | 提供服务 |
|----------|------|----------|----------|
| `recruiter` | 👥 | residential | 角色招募、解散队伍 |
| `innkeeper` | 🛏️ | residential | 住宿休息、HP/SP 恢复 |
| `merchant` | 💰 | commercial | 物品买卖、资源交易 |
| `blacksmith` | 🔨 | crafting | 装备制作、修理、强化 |
| `trainer` | 🎯 | training | 技能学习、属性提升 |
| `quest_giver` | 📜 | social | 任务发布、剧情推进 |
| `gossip` | 👂 | social | 情报交换、传闻收集 |

---

### 【2.5 服务系统详解】

#### 【招募服务 (Recruiter)】

```typescript
interface RecruitmentService {
  availableCharacters: Character[];    // 可招募角色池
  refreshInterval: number;             // 刷新间隔（秒）
  recruitmentCost: {gold: number};     // 招募费用
}
```

**服务规则：**
```markdown
- 每日自动刷新可招募角色列表（06:00 服务器时间）
- 刷新数量 = 城镇等级系数 × 3
  - 村庄：1 人/天
  - 小镇：2 人/天
  - 城市：3 人/天
  - 大都市：5 人/天
- 招募费用 = 角色稀有度 × 基础价格
```

---

#### 【交易服务 (Merchant)】

```typescript
interface TradingService {
  buyList: {itemId: string, price: number}[];    // 出售列表
  sellList: {itemId: string, minPrice: number}[]; // 收购列表
  currencyTypes: ('gold' | 'reputation' | 'special')[];
}
```

**价格机制：**
```markdown
卖出价 = 基础价格 × (1 - 好感度折扣)
买入价 = 基础价格 × (1 + 城镇等级加成)

示例：好感度 80% → 商品打 2 折购买
```

---

#### 【工匠服务 (Blacksmith)】

```typescript
interface CraftingService {
  recipes: Recipe[];           // 可制作配方
  repairCostMultiplier: number;// 修理费用倍率
  enhanceMaxLevel: number;     // 强化最高等级
}
```

**服务功能：**
| 功能 | 描述 | 消耗 |
|------|------|------|
| 🛠️ **修理** | 恢复装备耐久度 | 金币 × 耐久度 × 0.1 |
| 🔨 **制作** | 根据配方合成装备 | 材料 + 金币 |
| ⚡ **强化** | 提升装备等级 (+1~+MAX) | 金币 + 强化石 |

---

#### 【训练服务 (Trainer)】

```typescript
interface TrainingService {
  learnableSkills: Skill[];    // 可学习技能列表
  attributeTraining: {          // 属性提升
    type: AttributeType;
    costPerPoint: number;
    maxLevel: number;
  }[];
}
```

**训练规则：**
```markdown
- 单次属性提升消耗 = 基础值 × (当前等级 ^ 1.5)
- 每日免费训练次数 = 城镇等级 × 2
- 额外训练需支付金币
```

---

## ⚔️ **三、地牢入口节点 (Dungeon Entry)**

### 【3.1 难度分级】

```typescript
enum DungeonDifficulty {
  E,  // 入门级 - 新手教学
  D,  // 简单   - 早期游戏
  C,  // 普通   - 中期游戏
  B,  // 困难   - 中后期游戏
  A,  // 专家   - 高级玩家
  S,  // 传说   - 顶级挑战
}
```

#### 难度参数表：

| 等级 | 名称 | 推荐等级 | 进入消耗 | 刷新机制 |
|------|------|----------|----------|----------|
| E | 入门级 | 1-5 | 免费 | 永久开放 |
| D | 简单 | 5-10 | 10G/次 | 每日重置 |
| C | 普通 | 10-20 | 50G/次 | 每日重置 |
| B | 困难 | 20-35 | 200G/次 | 每周重置 |
| A | 专家 | 35-50 | 1000G/次 | 每周重置 |
| S | 传说 | 50+ | 5000G + 特殊物品 | 每月重置 |

---

### 【3.2 进入条件】

```typescript
interface DungeonEntryCondition {
  minLevel?: number;           // 最低等级要求
  maxLevel?: number;           // 最高等级限制（防止越级）
  requiredItems?: string[];    // 必需物品
  requiredQuest?: string;      // 前置任务
  requiredReputation?: number; // 声望要求
  entryCost?: {gold: number};  // 进入消耗
}
```

#### 各难度进入条件示例：

```markdown
【E 级 - 入门】
- 推荐等级：1-5
- 进入消耗：免费
- 无其他限制

【D/C 级 - 简单/普通】
- 推荐等级：5-20
- 进入消耗：10G~50G
- 需完成新手教程

【B/A 级 - 困难/专家】
- 推荐等级：20-50
- 进入消耗：200G~1000G
- 声望要求：≥100/≥500
- 需完成特定前置任务

【S 级 - 传说】
- 推荐等级：50+
- 进入消耗：5000G + 「古代钥匙」×1
- 声望要求：≥2000
- 需通关所有 A 级地牢
```

---

### 【3.3 刷新机制】

```typescript
interface DungeonRefreshRule {
  type: 'permanent' | 'daily' | 'weekly' | 'monthly';
  resetTime?: string;        // 重置时间（HH:mm）
  maxEntriesPerReset?: number;// 每次重置最大进入次数
}
```

**刷新规则：**
```markdown
- Permanent: 永久开放，无限制
- Daily: 每日 06:00 重置，可重新进入
- Weekly: 每周三 06:00 重置
- Monthly: 每月 1 日 06:00 重置
```

---

## 🚦 **四、特殊节点**

### 【4.1 传送点 (Teleport)】

```typescript
interface TeleportNode {
  id: string;
  name: string;
  connectedNodes: string[];    // 可传送到的节点列表
  teleportCost?: {gold: number};// 传送费用（可选）
  unlockCondition?: UnlockCondition;
}
```

**传送规则：**
```markdown
- 首次使用需解锁（完成任务或支付解锁费）
- 已解锁的传送点之间免费传送
- 未解锁的传送点：10G × 距离系数
- 冷却时间：30 秒/次
```

---

### 【4.2 商店节点 (Shop)】

```typescript
interface ShopNode {
  id: string;
  name: string;
  category: 'general' | 'weapon' | 'armor' | 'consumable' | 'special';
  inventory: {itemId: string, quantity: number, price: number}[];
  refreshRule?: RefreshRule;    // 库存刷新规则（可选）
}
```

**商店分类：**
| 类型 | 出售内容 | 刷新机制 |
|------|----------|----------|
| `general` | 通用消耗品 | 每日重置 |
| `weapon` | 武器类装备 | 每周重置 |
| `armor` | 防具类装备 | 每周重置 |
| `consumable` | 药水/材料 | 每日重置 |
| `special` | 特殊物品 | 固定库存 |

---

### 【4.3 任务发布处 (Quest Giver)】

```typescript
interface QuestGiverNode {
  id: string;
  availableQuests: Quest[];     // 可接取任务列表
  questCategories: string[];    // 任务分类
}
```

**任务类型：**
| 类别 | 描述 | 示例 |
|------|------|------|
| `fetch` | 收集类 | 「收集 10 个古代碎片」 |
| `elimination` | 清除类 | 「击败地牢中的 Boss」 |
| `escort` | 护送类 | 「保护 NPC 到达目的地」 |
| `investigation` | 调查类 | 「查明事件真相」 |

---

### 【4.4 竞技场 (Arena)】

```typescript
interface ArenaNode {
  id: string;
  matchTypes: ('pve' | 'pvp')[];    // 匹配类型
  rankSystem?: RankConfig;           // 排名系统配置（可选）
  entryFee?: {gold: number};         // 入场费
}
```

**竞技场模式：**
| 模式 | 描述 | 奖励 |
|------|------|------|
| `PVE` | 对战 AI 对手 | 金币 + 经验 + 掉落物 |
| `PVP` | 玩家对战 | 排名积分 + 赛季奖励 |

---

## 🔗 **五、节点关系图**

### 【5.1 连接规则】

```typescript
interface NodeConnection {
  from: string;    // 源节点 ID
  to: string;      // 目标节点 ID
  type: 'direct' | 'teleport' | 'conditional';  // 连接类型
  condition?: any; // 连接条件（conditional 时）
}
```

**连接类型说明：**
```markdown
- Direct: 大世界地图上直接可达（相邻或路径连通）
- Teleport: 需通过传送点中转
- Conditional: 满足特定条件后才可通行
```

---

### 【5.2 节点关系图示例】

```markdown
                    ┌─────────────┐
                    │   城镇 A     │
                    │ (枢纽节点)  │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ┌───────┐          ┌───────┐          ┌───────┐
   │传送点 │          │商店   │          │地牢入口│
   └───┬───┘          └───────┘          └────┬──┘
       │                                      │
       ▼                                      ▼
   ┌───────┐                              ┌───────┐
   │城镇 B  │◄─────[传送]─────►│城镇 C     │
   └──┬────┘                    └────┬────┘
      │                              │
   [地牢入口]                  [竞技场]
```

---

### 【5.3 可达性分析】

#### 从任意节点到达目标的最短路径：

| 起点 → 终点 | 城镇 | 地牢入口 | 传送点 | 商店 | 竞技场 |
|-------------|------|----------|--------|------|--------|
| **城镇** | 0 步 | 1 步 (直接) | 1 步 | 1 步 | 2 步 |
| **地牢入口** | 1 步 | - | 2 步 | 2 步 | 3 步 |
| **传送点** | 1 步 | 2 步 | 0 步 | 2 步 | 2 步 |
| **商店** | 1 步 | 2 步 | 1 步 | 0 步 | 2 步 |
| **竞技场** | 2 步 | 3 步 | 2 步 | 2 步 | 0 步 |

---

## 📊 **六、数据结构总览**

### 【FixedNode State】:
```typescript
interface FixedNodeState {
  // 节点基础信息
  id: string;
  type: FixedNodeType;
  name: string;
  position: HexCoord;
  
  // 解锁状态
  isUnlocked: boolean;
  unlockTime?: number;      // 解锁时间戳
  
  // 节点特定数据
  townData?: {
    districts: District[];
    npcs: TownNPC[];
  };
  
  dungeonEntryData?: {
    difficulty: DungeonDifficulty;
    isAccessible: boolean;   // 当前是否可进入
    entriesRemaining?: number;// 剩余进入次数
  };
  
  teleportData?: {
    connectedNodes: string[];
  };
  
  shopData?: {
    inventory: ItemStock[];
    lastRefreshTime: number;
  };
}
```

---

## 🔄 **七、与其他模块的接口**

### 【输入】:
- 从【大世界系统】获取：节点位置坐标、玩家当前位置
- 从【领地建设系统】获取：角色配置、背包物品
- 从【剧情演绎系统】获取：任务进度、NPC 好感度

### 【输出】:
- 向【Roguelike 地牢】传递：进入地牢的角色配置
- 向【领地建设系统】反馈：招募的 NPC、购买的物品
- 向【剧情演绎系统】更新：任务完成状态、好感度变化

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*
