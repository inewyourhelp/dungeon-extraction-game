# 🏰 MODULE: Roguelike 地牢系统 (Roguelike Dungeon)

**版本:** v1.0 | **创建日期:** 2026-04-02 | **维护人:** 中书 🐉

---

## 📋 **文档定位说明**

### ✅ **本文档做什么：**
- 定义地牢结构生成算法（房间类型、连接规则、难度曲线）
- 设计房间事件系统（战斗房/宝箱房/商店房等）
- 实现永久死亡机制与资源继承规则
- 配置进度追踪与结算系统
- 制定各难度等级的平衡参数

### ❌ **本文档不做：**
- 具体战斗数值 → 交给 CORE-GAMEPLAY-ARCHITECTURE.md
- NPC 对话树设计 → 交给 MODULE-STORY-SYSTEM.md
- 装备属性定义 → 已归入对应系统文档
- 固定节点功能 → 已归入 MODULE-FIXED-NODES.md

---

## 🎯 **一、地牢结构生成**

### 【1.1 房间类型枚举】

```typescript
enum DungeonRoomType {
  ENTRANCE,    // 🚪 入口房 - 每层固定第一个
  COMBAT,      // ⚔️ 战斗房 - 普通遭遇战/精英怪/BOSS
  TREASURE,    // 💰 宝箱房 - 奖励获取点
  SHOP,        // 🏪 商店房 - 交易机会
  REST,        // 🛏️ 休息房 - HP/SP恢复
  DEAD_END,    // 🚧 死路房 - 无事件，仅路径连接
  SPECIAL       // ✨ 特殊房 - 机制性房间（解谜/赌博等）
}
```

---

### 【1.2 地牢结构参数】

#### 层数与房间配置：

| 难度等级 | E | D | C | B | A | S |
|----------|---|---|---|---|---|---|
| **总层数** | 1 | 2 | 3 | 4 | 5 | 6+ |
| **每层房间数** | 5-7 | 6-9 | 8-12 | 10-15 | 12-18 | 15-25 |
| **生成算法** | 固定路线 | Prim | Prim+Boruvka混合 | Boruvka | 复杂Boruvka | 专家模式 |

#### 房间类型分布（每层）：

```markdown
【基础配置】（所有难度通用）
├─ 🚪 入口房 (ENTRANCE)    : 固定 1 个，每层第一个
├─ ⚔️ 战斗房 (COMBAT)       : 40-60% （主要房间类型）
│   ├─ 普通遭遇战：60%
│   ├─ 精英怪：20%
│   ├─ BOSS 战：10%（仅最后一层最后一个）
│   └─ 伏击战：10%
├─ 💰 宝箱房 (TREASURE)     : 15-25%
├─ 🏪 商店房 (SHOP)         : 8-15%
├─ 🛏️ 休息房 (REST)         : 5-10%
└─ ✨ 特殊房 (SPECIAL)       : 3-5%

【死路房】(DEAD_END)
- 自动生成以填充迷宫结构，不占用上述比例
```

---

### 【1.3 地牢生成算法】

#### 核心流程：

```typescript
function generateDungeon(difficulty: DungeonDifficulty): Dungeon {
  const layers = getLayerCount(difficulty);
  const dungeon: Dungeon = { layers: [] };
  
  for (let layerIndex = 0; layerIndex < layers; layerIndex++) {
    const layer = generateSingleLayer(layerIndex, difficulty);
    dungeon.layers.push(layer);
  }
  
  return dungeon;
}

function generateSingleLayer(layerIndex: number, difficulty: DungeonDifficulty): Layer {
  const totalRooms = calculateRoomCount(layerIndex, difficulty);
  const layer: Layer = { rooms: [], connections: [] };
  
  // Step 1: 放置入口房（固定位置）
  const entranceRoom = createEntranceRoom();
  layer.rooms.push(entranceRoom);
  
  // Step 2: 根据难度选择生成算法
  let algorithm = getGenerationAlgorithm(difficulty);
  if (difficulty <= 'D') {
    algorithm = 'fixed';  // E-D级：固定路线（新手友好）
  }
  
  // Step 3: 生成房间布局
  const roomLayout = runGenerationAlgorithm(algorithm, totalRooms, layer.rooms);
  
  // Step 4: 分配房间类型（按概率表）
  assignRoomTypes(layer.rooms, layerIndex === getMaxLayerCount(difficulty) - 1);
  
  // Step 5: 建立连接关系
  buildConnections(layer.rooms, roomLayout.connections);
  
  return layer;
}
```

---

#### 生成算法详解：

##### 📌 **固定路线（E-D级 - 新手教学）**
```markdown
入口房 → 战斗房1 → 宝箱房 → 战斗房2 → 休息房 → BOSS房
     │         │          │          │          │        │
     └─────────┴──────────┴──────────┴──────────┴────────┘
              (简单线性，无分支选择)
```

##### 📌 **Prim 算法（C-B级 - 标准模式）**
```typescript
function primAlgorithm(startRoom: Room, targetCount: number): RoomLayout {
  const visited = new Set([startRoom.id]);
  const unvisited = generateEmptyRooms(targetCount - 1);
  const connections: Connection[] = [];
  
  while (visited.size < targetCount) {
    // 找出所有已访问房间的未连接邻居
    const edges = getAllPossibleEdges(visited, unvisited);
    
    // 随机选择一条边（权重可选）
    const selectedEdge = pickRandomEdge(edges);
    
    // 添加新房间和连接
    addRoomAndConnection(selectedEdge);
  }
  
  return { rooms: [...visited], connections };
}
```

##### 📌 **Boruvka 算法（A-S级 - 硬核模式）**
```typescript
function boruvkaAlgorithm(roomCount: number): RoomLayout {
  // 初始化：每个房间独立成组件
  const components = roomCount; 
  const connections: Connection[] = [];
  
  while (components > 1) {
    // 每个组件选择最小权重边连接其他组件
    for (const component of getComponents()) {
      const minEdge = findMinWeightEdge(component);
      if (minEdge && !isCycle(connections, minEdge)) {
        addConnection(minEdge);
        mergeComponents(minEdge.fromComp, minEdge.toComp);
        components--;
      }
    }
  }
  
  return { rooms: getAllRooms(), connections };
}
```

---

### 【1.4 难度曲线设计】

#### 三种曲线类型：

##### 📈 **线性递增（E-D级 - 新手友好）**
```markdown
层数：    1     2     3     4     5
敌人LV:  5 →   8    →  11   →  14   →  17
难度系数：1.0x → 1.3x → 1.6x → 1.9x → 2.2x
```

##### 📈 **S型曲线（C-B级 - 标准模式）**
```markdown
层数：    1     2     3     4     5
敌人LV:  5 →   7    →  12   →  16   →  19
难度系数：1.0x → 1.2x → 1.8x → 2.4x → 2.9x
(前期平缓，中期陡增，后期放缓)
```

##### 📈 **阶梯式上升（A-S级 - 硬核模式）**
```markdown
层数：    1     2     3     4     5
敌人LV:  5 →   6    →  10   →  11   →  18
难度系数：1.0x → 1.1x → 1.8x → 1.9x → 3.0x
(每两层一个大台阶)
```

---

## ⚔️ **二、房间事件系统**

### 【2.1 战斗房 (Combat Room)】

#### 敌人配置：

```typescript
interface CombatRoom {
  type: 'COMBAT';
  enemyType: 'NORMAL' | 'ELITE' | 'BOSS' | 'AMBUSH';
  enemies: Enemy[];
  waveCount?: number;        // 波次战斗的波数
  dropTable: DropConfig;     // 掉落配置
}
```

#### 敌人类型概率（每层）：

| 层数 | 普通遭遇战 | 精英怪 | BOSS 战 | 伏击战 |
|------|------------|--------|---------|--------|
| Layer 1 | 70% | 20% | - | 10% |
| Layer 2 | 65% | 25% | - | 10% |
| Layer 3 | 60% | 30% | - | 10% |
| ... | ... | ... | ... | ... |
| Last | 50% | 40% | **10%** | - |

#### 伏击战机制：
```markdown
【首回合劣势】
- 玩家 HP 降低至 80%
- 技能 CD 延长 50%
- 敌人先手攻击（跳过玩家第一回合）
```

---

### 【2.2 宝箱房 (Treasure Room)】

#### 宝箱类型：

```markdown
┌─────────────────────────────────────────────┐
│              💰 普通宝箱                      │
│   - 金币：50-200 × 难度系数                  │
│   - 消耗品：1-3 个（小药水/弹药）            │
│   - 普通装备碎片：1-2 个                     │
├─────────────────────────────────────────────┤
│              💎 稀有宝箱                      │
│   - 金币：200-800 × 难度系数                 │
│   - 稀有装备（完整）：15%                    │
│   - 技能书：20%                              │
│   - 消耗品套装：25%                          │
├─────────────────────────────────────────────┤
│              🎁 传说宝箱                      │
│   - 金币：800-2500 × 难度系数                │
│   - 传说装备：8%                             │
│   - 特殊道具：12%                            │
│   - 称号解锁：5%                             │
├─────────────────────────────────────────────┤
│              ☠️ 陷阱宝箱                      │
│   - 开启即触发：伤害 (50-100) + Debuff       │
│   - 侦查技能≥Lv3可发现（90%概率）            │
│   - 发现后可安全拆除或绕过                   │
└─────────────────────────────────────────────┘
```

#### 宝箱房分布：
- **普通宝箱**：70%
- **稀有宝箱**：25%
- **传说宝箱**：5%（仅 B-S级难度）
- **陷阱宝箱**：10%（混入上述类型中）

---

### 【2.3 商店房 (Shop Room)】

#### 商品池配置：

```typescript
interface ShopRoom {
  merchantType: 'TRAVELING' | 'FIXED' | 'BLACK_MARKET';
  goods: ShopItem[];
  currency: 'GOLD' | 'SPECIAL_CURRENCY';
}
```

#### 商品类型与价格：

| 商品类别 | 具体物品 | 基础价格 | 刷新规则 |
|----------|----------|----------|----------|
| **消耗品** | HP药水/SP药水/弹药 | 20-100G | 每层刷新 |
| **装备** | 武器/防具（随机品质） | 100-500G | 每层刷新 |
| **技能书** | 普通/稀有技能书 | 200-800G | 每 2 层刷新 |
| **蓝图** | 装备升级图纸 | 500-2000G | BOSS 层专属 |

#### 流动商人机制：
```markdown
【商品池大小】
- E-D级：3-5 种商品
- C-B级：5-8 种商品
- A-S级：8-12 种商品

【价格浮动】
- 基础价格 × (0.8 ~ 1.2) × 难度系数
```

---

### 【2.4 休息房 (Rest Room)】

#### 恢复机制：

```markdown
【自然恢复】（免费）
- HP: 回复至 100%
- SP: 回复至 100%
- 技能 CD: 清除所有冷却
- Buff: 保留（不消失）
- Debuff: 清除所有负面状态

【消耗品使用】（可选）
- 可使用强力恢复道具（超出自然恢复上限）
```

#### 休息房限制：
```markdown
- 每层最多 1 个休息房
- 使用后该房间变为"已探索"，不可再次进入
- A-S级难度：休息房可能附带 Debuff（如"疲劳" - 属性降低 10%）
```

---

### 【2.5 特殊房 (Special Room)】

#### 赌博机：
```markdown
【下注规则】
- 下注金额：100-1000G（自选）
- 获胜概率：30%（固定）
- 回报倍数：2.5x
- 失败：损失全部下注金额

【风险等级】
| 难度 | E-D | C-B | A-S |
|------|-----|-----|-----|
| 胜率 | 40% | 30% | 20% |
| 回报 | 2x  | 2.5x| 3x  |
```

#### 解谜房：
```markdown
【谜题类型】
- 图案匹配：记忆并重现符号序列
- 逻辑推理：根据线索推断答案
- 机关触发：按正确顺序激活机关

【奖励】
- 成功：稀有宝箱 + 成就解锁
- 失败：无惩罚，但浪费一次机会（每局限 1 次）
```

---

## 💀 **三、永久死亡机制**

### 【3.1 资源分类】

#### 🔄 **局内资源（每局重置）**
```markdown
- ⚡ 生命值 (HP)
- 🔋 技能点 (SP) 
- ⏰ 技能冷却时间 (CD)
- 🎯 Buff/Debuff状态
- 🗺️ 当前地牢进度
```

#### 💎 **局外资源（永久保留）**
```markdown
- 💰 金币 (Gold)
- 📜 蓝图 (Blueprints) - 用于解锁/升级装备
- 🏆 成就 (Achievements)
- 🔓 解锁内容：新角色、新武器、新技能
- 📖 图鉴收集（敌人/物品记录）
```

---

### 【3.2 死亡结算】

```typescript
function onPlayerDeath(run: RunData) {
  // Step 1: 保留局外资源
  savePersistentResources(run);
  
  // Step 2: 统计本局数据
  const summary = calculateRunSummary(run);
  
  // Step 3: 结算奖励
  applyRewards(summary);
  
  // Step 4: 显示结算界面
  showSettlementScreen(summary);
}
```

#### 结算数据统计：
```markdown
【本局收益】
- 💰 获得金币：XXX G
- 📜 获得蓝图：X 个
- ⚔️ 获得装备：X 件（品质分布）
- 📖 获得技能书：X 本
- 🏆 解锁成就：X 个

【战斗统计】
- ⚔️ 总战斗数：XX 场
- ✅ 胜利：XX 场 (胜率 XX%)
- 💀 死亡楼层：Layer X
- ⏱️ 存活时间：X分X秒

【最高纪录对比】
- 📈 最深层数：本次 X / 历史 Y
- 💰 最多金币：本次 XXX / 历史 YYY
```

---

### 【3.3 继承机制（可选）】

```markdown
【永久 Buff 系统】
某些特殊事件可解锁"永久 Buff"，带入下一局：
- 🛡️ 开局 HP +10%（需完成特定成就）
- ⚔️ 伤害 +5%（收集齐套装后解锁）
- 💰 金币获取 +10%（商人声望达标）

【限制】
- 最多同时装备 3 个永久 Buff
- A-S级难度：永久 Buff效果减半
```

---

## 📊 **四、进度追踪系统**

### 【4.1 局内进度显示】

```typescript
interface RunProgress {
  // 位置信息
  currentLayer: number;
  totalLayers: number;
  currentRoomIndex: number;    // 当前层第几个房间
  
  // 清除进度
  clearedRoomsInLayer: number;
  totalRoomsInLayer: number;
  
  // 本局收益
  goldEarned: number;
  itemsAcquired: Item[];
  achievementsUnlocked: string[];
}
```

#### UI 显示示例：
```markdown
┌──────────────────────────────────────────┐
│  🗺️ Layer 3/5    [████░░░░] 60%         │
│  🚪 Room 4/8     [████░░░]   50%         │
│                                          │
│  💰 本局金币：1,250 G                    │
│  ⚔️ 已击败：12 敌人 (3精英)               │
│  🏆 解锁成就："初出茅庐"                 │
└──────────────────────────────────────────┘
```

---

### 【4.2 死亡回放（可选功能）】

```markdown
【回放内容】
- ⚔️ 最后战斗的完整过程
- 📊 伤害统计（玩家输出/承受）
- 💀 致死原因分析

【触发条件】
- A-S级难度：自动播放
- E-C级难度：手动选择是否观看
```

---

## ⚖️ **五、难度平衡设计**

### 【5.1 各难度等级特性】

| 特性 | E | D | C | B | A | S |
|------|---|---|---|---|---|---|
| **总层数** | 1 | 2 | 3 | 4 | 5 | 6+ |
| **每层房间** | 5-7 | 6-9 | 8-12 | 10-15 | 12-18 | 15-25 |
| **生成算法** | 固定 | Prim | Prim混合 | Boruvka | 复杂Boruvka | 专家模式 |
| **敌人强度** | 0.8x | 1.0x | 1.2x | 1.5x | 2.0x | 3.0x |
| **永久 Buff** | ✅全效 | ✅全效 | ✅全效 | ⚠️减半 | ❌禁用 | ❌禁用 |
| **休息房 Debuff**| ❌ | ❌ | ⚠️ | ✅ | ✅ | ✅ |

---

### 【5.2 难度推荐等级】

```markdown
【进入条件】
- E级：无限制（新手教学）
- D级：角色等级≥5
- C级：角色等级≥10 + 完成E/D级通关
- B级：角色等级≥15 + 完成C级通关
- A级：角色等级≥20 + 完成B级通关 + 特定成就
- S级：角色等级≥30 + 完成A级全清 + 隐藏条件
```

---

## 🔄 **六、与其他模块的接口**

### 【输入】:
- 从【领地建设系统】获取：玩家等级、装备配置、技能池
- 从【固定节点系统】获取：地牢入口位置、难度解锁状态
- 从【随机节点系统】获取：事件模板（战斗/宝箱/商店等）

### 【输出】:
- 向【领地建设系统】反馈：局外资源收益（金币/蓝图/成就）
- 向【固定节点系统】更新：地牢进度、解锁状态
- 向【剧情演绎系统】传递：触发的剧情分支、任务完成度

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*
