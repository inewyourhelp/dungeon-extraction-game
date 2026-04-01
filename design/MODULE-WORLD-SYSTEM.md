# 🌍 MODULE: 大世界系统 (World System)

**版本:** v1.0 | **创建日期:** 2026-04-02 | **维护人:** 中书 🐉

---

## 📋 **文档定位说明**

### ✅ **本文档做什么：**
- 定义大世界系统的核心机制（地图结构、移动规则、视野系统）
- 明确节点分布策略与密度控制
- 提供数据结构参考和状态流转图

### ❌ **本文档不做：**
- 具体数值设定（伤害倍率、冷却时间等）→ 交给战斗模块
- 建筑升级体系 → 交给领地建设模块
- NPC 对话树设计 → 交给剧情演绎模块
- 地牢内部流程 → 交给 Roguelike 地牢模块

---

## 🗺️ **一、地图结构**

### 【1.1 六边形网格布局】

#### 核心参数：
```markdown
世界尺寸：60 × 40 个六边形格子（总计 ~9,600 格）
单格边长：约 50 米（游戏内距离单位）
地图比例：1:500（玩家视角缩放范围）
```

#### 坐标系统：
```typescript
// 六边形坐标转换（Axial 坐标系）
type HexCoord = {
  q: number;  // 轴向 Q
  r: number;  // 轴向 R
  s?: number; // s = -q-r (冗余，用于计算)
}

// 像素位置转换
function hexToPixel(hex: HexCoord, size: number): {x: number, y: number}
function pixelToHex(x: number, y: number, size: number): HexCoord
```

#### 区域划分：
| 区域类型 | 范围 (q,r) | 特性 |
|----------|------------|------|
| **安全区** | 中心 ±5 格 | 无敌人、可自由建造 |
| **探索区 A** | 中心 +6~20 格 | 低难度、基础资源 |
| **探索区 B** | 中心 +21~35 格 | 中难度、稀有资源 |
| **危险区 C** | 中心 +36~40 格 | 高难度、精英敌人 |

---

### 【1.2 节点分布方式】

#### 固定节点 (Fixed Nodes)：
```typescript
interface FixedNode {
  id: string;           // 唯一标识
  name: string;         // 显示名称
  position: HexCoord;   // 六边形坐标
  type: NodeType;        // 类型枚举
  difficulty: number;    // 难度等级 (1-5)
  unlockCondition?: any; // 解锁条件（可选）
}
```

**节点类型分类：**
| 类型 | 图标 | 描述 | 数量 |
|------|------|------|------|
| `town` | 🏰 | 城镇/据点 | 3-5 |
| `dungeon_entrance` | ⚔️ | 地牢入口 | 8-12 |
| `boss_nest` | 👹 | Boss 巢穴 | 4-6 |
| `landmark` | 🗿 | 地标建筑 | 5-8 |

#### 随机节点 (Random Nodes)：
```typescript
interface RandomNode {
  id: string;
  position: HexCoord;
  type: RandomNodeType;
  spawnCondition: SpawnRule;  // 生成条件
  duration: number;           // 持续时间（秒）
}
```

**随机节点类型：**
| 类型 | 图标 | 描述 | 刷新周期 |
|------|------|------|----------|
| `camp` | ⛺ | 临时营地/商人 | 1-3 小时 |
| `battle` | ⚔️ | 遭遇战 | 即时生成 |
| `treasure` | 💰 | 宝箱点 | 2-6 小时 |
| `event` | ✨ | 特殊事件 | 4-12 小时 |

---

### 【1.3 节点密度控制】

#### 固定节点分布规则：
```typescript
// 城镇：中心区域优先，最多距离 10 格
const townPositions = generateHexRing(0, 5) .filter(n => n.distance <= 10);

// 地牢入口：均匀分布在探索区 A/B
const dungeonPositions = distributeEvenly(
  {minDist: 12, maxDist: 30}, 
  count: 10
);
```

#### 随机节点密度公式：
```typescript
// 动态密度控制（基于玩家活跃度）
function calculateNodeDensity(playerCount: number): number {
  const baseDensity = 0.05;        // 基础 5% 格子有节点
  const playerBonus = playerCount * 0.01;  // 每玩家 +1%
  return Math.min(baseDensity + playerBonus, 0.2); // 上限 20%
}
```

---

## 🏃 **二、移动机制**

### 【2.1 基础移动规则】

#### 消耗计算：
```typescript
interface MoveCost {
  stamina: number;    // 体力消耗
  time: number;       // 耗时（秒）
}

function calculateMoveCost(
  from: HexCoord, 
  to: HexCoord,
  terrainFrom: TerrainType,
  terrainTo: TerrainType,
  playerStats: PlayerStats
): MoveCost {
  const distance = hexDistance(from, to); // 六边形距离
  const baseStamina = distance * 10;      // 每格 10 体力
  const baseTime = distance * 2;          // 每格 2 秒
  
  // 地形修正
  const terrainModifier = getTerrainModifier(terrainFrom, terrainTo);
  
  return {
    stamina: Math.round(baseStamina * terrainModifier),
    time: Math.round(baseTime * terrainModifier)
  };
}
```

#### 地形类型与修正系数：
| 地形 | 移动消耗倍率 | 描述 |
|------|--------------|------|
| `plain` | 1.0x | 平原，标准速度 |
| `forest` | 1.5x | 森林，视野受限 |
| `mountain` | 2.0x | 山地，移动缓慢 |
| `swamp` | 2.5x | 沼泽，易受困 |
| `road` | 0.8x | 道路，快速通行 |

---

### 【2.2 速度类型】

#### 三种移动模式：
```markdown
1. **步行 (Walk)**
   - 消耗：标准体力
   - 速度：正常
   - 用途：日常探索、节省资源

2. **奔跑 (Sprint)**
   - 消耗：2x 体力
   - 速度：1.5x 快
   - 限制：需要持续耐力条，耗尽后强制休息

3. **冲刺 (Dash)**
   - 消耗：技能 CD + 大量体力
   - 速度：3x 快
   - 用途：紧急撤离、跨越障碍
```

---

### 【2.3 特殊移动】

#### 传送机制：
```typescript
interface Teleport {
  from: HexCoord;
  to: HexCoord;
  cost: {gold: number, item?: string};
  cd: number;           // 冷却时间（秒）
}
```

**传送类型：**
| 类型 | 条件 | 消耗 |
|------|------|------|
| `town_teleport` | 城镇传送阵 | 金币 × 距离 |
| `base_recall` | 已建立的基地 | 免费，每日限 3 次 |
| `item_teleport` | 消耗传送卷轴 | 物品消耗 |

#### 跳跃机制：
```typescript
// 跨越障碍（如矮墙、小沟壑）
interface Jump {
  from: HexCoord;
  to: HexCoord;        // 必须是相邻格
  requirement: {agility: number};  // 敏捷要求
  cost: {stamina: number};
}
```

---

## 👁️ **三、视野系统**

### 【3.1 FOV 计算】

#### 基础视野范围：
```typescript
function calculateFOV(
  position: HexCoord,
  terrain: Map<HexCoord, TerrainType>,
  baseRange: number = 6
): Set<string> {
  const visible = new Set<string>();
  
  // 六边形 BFS + 视线遮挡检查
  for (const hex of getHexRing(position, baseRange)) {
    if (isLineOfSightClear(position, hex, terrain)) {
      visible.add(hexToKey(hex));
    }
  }
  
  return visible;
}
```

#### 视野范围修正：
| 因素 | 修正系数 |
|------|----------|
| 基础视野 | 6 格半径 |
| 高地优势 | +2 格 |
| 森林/建筑遮挡 | -1~3 格 |
| 侦察技能 | +1~4 格 |

---

### 【3.2 迷雾效果】

#### 三种状态：
```markdown
1. **已探索 (Explored)**
   - 显示：灰度地图，保留地形信息
   - 条件：曾经进入过视野范围

2. **可见 (Visible)**
   - 显示：全彩地图 + 动态实体
   - 条件：当前在视野范围内

3. **未探索 (Unexplored)**
   - 显示：黑色迷雾
   - 条件：从未被任何角色探索过
```

#### 状态流转图：
```
未探索 ──(进入视野)──► 可见 ──(移出视野)──► 已探索
                                         │
                                   (永久保留)
```

---

### 【3.3 侦察机制】

#### 主动侦察技能：
```typescript
interface ScoutSkill {
  name: string;
  rangeBonus: number;     // 视野范围加成
  revealType: 'terrain' | 'enemies' | 'both';  // 揭示类型
  duration: number;        // 持续时间（秒）
  cost: {stamina: number};
}
```

**技能示例：**
| 技能名 | 范围加成 | 揭示内容 | 消耗 |
|--------|----------|----------|------|
| `侦查术` | +2 格 | 地形+敌人 | 15 体力 |
| `鹰眼` | +4 格 | 仅敌人位置 | 30 体力 |
| `地图标记` | - | 永久记录节点 | 无消耗 |

---

## 📊 **四、数据结构总览**

### 【World State】:
```typescript
interface WorldState {
  // 地图数据
  gridSize: {width: number, height: number};
  terrainMap: Map<string, TerrainType>;      // 坐标 → 地形
  
  // 节点数据
  fixedNodes: Map<string, FixedNode>;
  randomNodes: Map<string, RandomNode>;
  
  // 探索进度
  exploredSet: Set<string>;                   // 已探索格子
  visibleSet: Set<string>;                    // 当前可见格子
  
  // 动态数据
  activeEvents: Map<string, EventData>;
}
```

---

## 🔄 **五、与其他模块的接口**

### 【输入】:
- 从【领地建设系统】获取：角色等级、装备、技能 → 影响移动速度/视野
- 从【剧情演绎系统】获取：NPC 好感度 → 解锁特殊传送点

### 【输出】:
- 向【固定节点系统】提供：节点坐标、类型、难度
- 向【随机节点系统】提供：可生成区域、密度参数
- 向【Roguelike 地牢】传递：入口位置信息

---

## 📁 **待创建子文档**

```
design/MODULE-WORLD-SYSTEM.md      ← 本文档（核心机制）
├── WORLD-TERRAIN-TYPES.md          ← 地形详细定义
├── WORLD-NODE-DISTRIBUTION.md      ← 节点分布算法
└── WORLD-FOV-ALGORITHM.md          ← 视野计算实现细节
```

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*
