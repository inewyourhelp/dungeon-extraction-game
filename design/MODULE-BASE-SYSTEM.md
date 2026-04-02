# 🏰 MODULE: 领地建设系统 (Base System)

**版本:** v1.0 | **创建日期:** 2026-04-02 | **维护人:** 中书 🐉

---

## 📋 **文档定位说明**

### ✅ **本文档做什么：**
- 定义基地类型与升级体系
- 设计建筑分类、功能与解锁条件
- 规划角色管理（招募/配置/成长）
- 制定资源产出/消耗规则

### ❌ **本文档不做：**
- 战斗机制 → 交给 Roguelike 地牢模块
- 装备属性定义 → 交给装备系统文档
- NPC 对话树 → 交给剧情演绎模块
- 大世界移动规则 → 交给大世界系统模块

---

## 🏗️ **一、基地类型**

### 【1.1 初始营地 (Initial Camp)】

#### 基础设定：
```markdown
解锁条件：游戏开始时自动获得
初始建造位：5 个固定位置（非网格系统）
可建造建筑数：最多 5 座
```

#### 核心功能：
| 功能 | 描述 |
|------|------|
| 🛡️ **安全区** | 无敌人入侵，角色自动恢复 HP/SP |
| 📦 **基础存储** | 100 格物品栏 + 50 格资源仓 |
| ⚙️ **简单修理** | 修复武器耐久度（消耗金币） |

---

### 【1.2 高级基地 (Advanced Base)】

#### 升级条件：
```typescript
interface BaseUpgradeCondition {
  requiredResources: {gold: number, material: string};
  requiredBuildings: string[];      // 必须已建造的建筑
  minPlayerLevel: number;
  completionTasks?: string[];        // 需完成的成就/任务
}
```

**升级需求示例：**
```markdown
初始营地 → 高级基地：
- 消耗：5000 金币 + 100 单位木材 + 50 单位石材
- 要求：已建造「工作台 Lv3」+ 「仓库 Lv2」
- 角色等级：至少 10 级
```

#### 核心功能增强：
| 功能 | 初始营地 | 高级基地 |
|------|----------|----------|
| 📦 **存储容量** | 100/50 | 300/200 |
| ⚙️ **修理速度** | 慢 (10s) | 快 (2s) |
| 🔧 **可建造数** | Lv0: 5 个 | Lv1-5: +2/级 (最高 15 个) |
| 👥 **NPC 上限** | 3 人 | 8 人 |

#### 升级解锁机制：
```markdown
【建造位解锁规则】
每升一级增加 2 个建造位（固定位置）
Lv0: 5 个 → Lv1: 7 个 → Lv2: 9 个 → Lv3: 11 个 → Lv4: 13 个 → Lv5: 15 个（满级）
```

---

### 【1.3 特殊据点 (Special Outpost)】

#### 类型分类：
```markdown
1. **前线哨站 (Frontline)**
   - 位置：靠近危险区 C
   - 特性：快速进入高难度地牢
   - 限制：无法建造防御建筑

2. **贸易枢纽 (Trade Hub)**
   - 位置：城镇附近
   - 特性：解锁商人交易功能
   - 限制：无法建造战斗相关建筑

3. **研究设施 (Research Lab)**
   - 位置：需完成特定剧情线
   - 特性：解锁科技树系统
   - 限制：高维护成本
```

---

## 🏢 **二、建筑系统**

### 【2.1 建筑分类】

#### 六大类别：
| 类别 | 图标 | 作用 |
|------|------|------|
| `production` | ⚙️ | 资源生产（木材/石材/金属） |
| `storage` | 📦 | 物品/资源存储扩展 |
| `combat` | ⚔️ | 战斗相关（训练场/武器库） |
| `support` | 🏥 | 辅助功能（医院/旅馆） |
| `decoration` | 🎨 | 外观装饰（无实际功能） |
| `special` | ✨ | 特殊建筑（传送阵/祭坛） |

---

### 【2.2 建筑详细定义】

#### 生产类建筑：
```typescript
interface ProductionBuilding {
  id: string;
  name: string;
  category: 'production';
  output: {resource: string, amount: number};  // 产出资源
  input?: {resource: string, amount: number};  // 消耗资源（可选）
  productionTime: number;                       // 生产周期（秒）
  maxLevel: number;
}
```

**建筑列表：**
| ID | 名称 | 产出 | 消耗 | 周期 | 最大等级 |
|----|------|------|------|------|----------|
| `lumber_mill` | 伐木场 | 木材 ×5 | - | 60s | 5 |
| `stone_quarry` | 采石场 | 石材 ×3 | 木材 ×1 | 90s | 5 |
| `smelter` | 冶炼炉 | 金属 ×2 | 石材 ×2 + 煤炭 ×1 | 120s | 5 |

#### 升级公式：
```typescript
// 产出量 = 基础值 × (1 + 等级 × 0.5)
function calculateOutput(building: ProductionBuilding, level: number): number {
  return Math.round(building.output.amount * (1 + level * 0.5));
}
```

---

#### 存储类建筑：
```typescript
interface StorageBuilding {
  id: string;
  name: string;
  category: 'storage';
  itemType: 'item' | 'resource' | 'both';
  baseCapacity: number;     // 基础容量
  capacityPerLevel: number; // 每级增加容量
}
```

**建筑列表：**
| ID | 名称 | 类型 | 基础容量 | 每级 + |
|----|------|------|----------|-------|
| `warehouse` | 仓库 | resource | 100 | +50 |
| `locker` | 储物柜 | item | 50 | +25 |

---

#### 战斗类建筑：
```typescript
interface CombatBuilding {
  id: string;
  name: string;
  category: 'combat';
  function: CombatFunction;  // 功能类型
}
```

**建筑列表：**
| ID | 名称 | 功能 |
|----|------|------|
| `training_ground` | 训练场 | 角色经验获取 +20% |
| `weaponry` | 武器库 | 武器修理速度 +50% |
| `armory` | 军械所 | 解锁高级装备制作 |

---

#### 辅助类建筑：
```typescript
interface SupportBuilding {
  id: string;
  name: string;
  category: 'support';
  function: SupportFunction; // 功能类型
}
```

**建筑列表：**
| ID | 名称 | 功能 |
|----|------|------|
| `hospital` | 医院 | HP 自动恢复 +50%/秒 |
| `inn` | 旅馆 | SP 自动恢复 +30%/秒 |
| `barracks` | 兵营 | NPC 招募上限 +2 |

---

### 【2.3 建筑升级体系】

#### 通用升级规则：
```typescript
interface BuildingUpgrade {
  fromLevel: number;
  toLevel: number;
  cost: {gold: number, resources: Record<string, number>};
  prerequisite?: string[];    // 前置建筑要求
}
```

**升级成本公式：**
```markdown
金币消耗 = 基础值 × (1.5 ^ 目标等级)
资源消耗 = 基础值 × (1.3 ^ 目标等级)
```

#### 示例：伐木场升级表
| 等级 | 木材产出/周期 | 升级成本 |
|------|---------------|----------|
| Lv1 | 5 / 60s | - |
| Lv2 | 7.5 / 60s | 500G + 木材×20 |
| Lv3 | 10 / 60s | 1250G + 木材×40 + 石材×10 |
| Lv4 | 12.5 / 60s | 2875G + 木材×60 + 石材×20 |
| Lv5 | 15 / 60s | 6125G + 木材×80 + 石材×30 + 金属×10 |

---

## 👥 **三、角色管理**

### 【3.1 招募机制】

#### 招募渠道：
```markdown
1. **自然刷新** - 城镇每日随机出现可招募 NPC
2. **任务奖励** - 完成特定剧情线解锁专属角色
3. **地牢解救** - Roguelike 探索中拯救被困角色
4. **声望招募** - 高声望值解锁隐藏角色池
```

#### 招募成本：
```typescript
interface RecruitmentCost {
  gold: number;
  resources?: Record<string, number>;
  reputation?: number;         // 声望要求
  unlockCondition?: any;       // 特殊解锁条件
}
```

---

### 【3.2 角色配置】

#### 岗位分配系统：
```typescript
interface RoleAssignment {
  characterId: string;
  buildingId?: string;         // 分配到的建筑（生产类）
  dutyType: DutyType;          // 职责类型
}
```

**职责类型：**
| 类型 | 描述 | 可分配建筑 |
|------|------|------------|
| `producer` | 生产者 | 伐木场/采石场/冶炼炉 |
| `guard` | 守卫 | 城墙/哨塔（防御用） |
| `idle` | 待命 | 无分配，可自由行动 |

#### 配置规则：
```markdown
- 每个生产建筑最多分配 1 名角色
- 角色分配后获得该建筑产出的「经验值」
- 未分配的角色在基地内游荡（不产生收益）
```

---

### 【3.3 技能配置】

#### 技能类型：
```typescript
type SkillType = 'passive' | 'active' | 'production';

interface CharacterSkill {
  skillId: string;
  type: SkillType;
  level: number;
  targetBuilding?: string;     // 生产技能关联的建筑
}
```

**技能分类：**
| 类型 | 描述 | 示例 |
|------|------|------|
| `passive` | 被动增益 | 「力量 +1」「HP 恢复 +10%」 |
| `active` | 主动技能 | 「侦查术」「冲刺」 |
| `production` | 生产加成 | 「伐木效率 +20%」 |

---

### 【3.4 装备分配】

#### 装备槽位：
```typescript
interface CharacterEquipment {
  weapon?: string;     // 武器
  armorHead?: string;  // 头部防具
  armorBody?: string;  // 身体防具
  armorLeg?: string;   // 腿部防具
  accessory?: string;  // 饰品（最多 2 个）
}
```

#### 分配规则：
```markdown
- 装备必须与角色职业兼容（如法师不能穿重甲）
- 基地内可自由更换 NPC 的装备
- 装备耐久度在「武器库」修理
```

---

## 💰 **四、资源系统**

### 【4.1 资源分类】

#### 三大类别：
| 类别 | 类型 | 用途 |
|------|------|------|
| **基础资源** | 木材/石材/金属/食物 | 建筑升级、制作材料 |
| **高级资源** | 稀有矿石/古代遗物 | 特殊建筑、科技研发 |
| **货币** | 金币 (Gold) | 通用交易媒介 |

---

### 【4.2 产出公式】

#### 生产建筑产出：
```typescript
function calculateProduction(
  building: ProductionBuilding,
  level: number,
  assignedCharacter?: Character
): {amount: number, time: number} {
  // 基础产出 × 等级加成 × 角色技能加成
  const baseOutput = building.output.amount;
  const levelBonus = 1 + level * 0.5;
  const skillBonus = assignedCharacter?.productionSkill || 1.0;
  
  return {
    amount: Math.round(baseOutput * levelBonus * skillBonus),
    time: building.productionTime
  };
}
```

---

### 【4.3 消耗规则】

#### 主要消耗场景：
```markdown
1. **建筑升级** - 消耗金币 + 对应资源
2. **新建筑建造** - 一次性材料投入
3. **维护费用** - 每日自动扣除（基于建筑等级）
4. **角色招募** - 金币 + 声望
5. **技能学习** - 金币 + 特殊教材
```

#### 维护费公式：
```markdown
每日维护费 = Σ(建筑基础维护费 × 等级 × 0.2)

示例：Lv3 伐木场 (基础 10G) → 10 × 3 × 0.2 = 6G/天
```

---

### 【4.4 存储限制】

#### 容量计算：
```typescript
function getTotalCapacity(base: Base, resourceType: string): number {
  // 基础容量 + 仓库建筑容量
  let capacity = base.baseStorage;
  
  for (const building of base.buildings) {
    if (building.type === 'warehouse') {
      capacity += building.baseCapacity * building.level;
    }
  }
  
  return capacity;
}
```

#### 溢出处理：
```markdown
- **生产时存储满** - 产出暂停，不累积
- **地牢带回物品超出容量** - 只能携带部分，其余丢弃
- **交易收到超额资源** - 自动拒绝多余部分
```

---

### 【4.5 交易规则】

#### 交易类型：
```markdown
1. **NPC 商人** - 固定买卖价格（受好感度影响）
2. **玩家市场** - 自由定价，系统抽成 5%
3. **资源兑换** - 特定建筑内可转换资源类型
```

#### 兑换比例示例：
| 输入 | 输出 | 损耗 |
|------|------|------|
| 木材 ×10 | 石材 ×1 | 10% |
| 石材 ×10 | 金属 ×1 | 20% |
| 金属 ×10 | 金币 ×50 | - |

---

## 📊 **五、数据结构总览**

### 【Base State】:
```typescript
interface BaseState {
  // 基地信息
  id: string;
  type: 'camp' | 'base' | 'outpost';
  level: number;
  position: HexCoord;  // 在大世界的位置
  
  // 建筑数据
  buildings: Map<string, {
    buildingId: string;
    level: number;
    assignedCharacter?: string;
    productionQueue?: ProductionTask[];
  }>;
  
  // 资源库存
  resources: Record<string, number>;  // resourceType → amount
  inventory: Item[];                   // 物品列表
  gold: number;
  
  // 角色管理
  characters: Character[];              // 已招募的角色
}
```

---

## 🔄 **六、与其他模块的接口**

### 【输入】:
- 从【大世界系统】获取：基地位置坐标、可建造区域
- 从【Roguelike 地牢】接收：战利品、资源、经验值
- 从【剧情演绎系统】获取：解锁条件、特殊角色

### 【输出】:
- 向【大世界系统】提供：传送点、NPC 位置信息
- 向【Roguelike 地牢】传递：角色配置、装备状态
- 向【剧情演绎系统】反馈：好感度变化、任务完成

---

*维护人：中书 🐉 | 策划先行 · 设计驱动*
