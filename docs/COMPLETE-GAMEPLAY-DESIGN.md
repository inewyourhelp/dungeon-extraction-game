# 🎮 Complete Gameplay Design Document v2.0

**项目**: 地下城提取游戏 (Dungeon Extraction Game)  
**版本**: 2.0 - 核心架构重构版  
**最后更新**: 2026-03-19  
**作者**: 中书 (首席策划官) 🧠

---

## 📋 目录

1. [游戏概述](#1-游戏概述)
2. [建筑系统重构](#2-建筑系统重构)
3. [撤离机制 - 抗侵蚀属性驱动](#3-撤离机制--抗侵蚀属性驱动)
4. [时间系统设计](#4-时间系统设计)
5. [职业系统三层架构](#5-职业系统三层架构)
6. [装备系统调整](#6-装备系统调整)
7. [核心循环流程](#7-核心循环流程)

---

## 1. 游戏概述

### 🎯 核心玩法
玩家扮演一名地下城的探索者，在危险的地牢中搜集资源、击败怪物、寻找宝藏。但地牢随时可能坍塌——你必须在**抗侵蚀属性耗尽前成功撤离**。

### 💡 设计哲学
- **风险与回报**: 深入越深，收益越高，但时间压力越大
- **策略多样性**: 通过建筑升级、职业选择、装备搭配打造不同 Build
- **永久成长**: 每次撤离成功都能强化角色，失败则失去地牢内所有收获

---

## 2. 建筑系统重构

### 🏗️ 核心设计理念
将建筑分为**基础经济类**和**特殊功能类**，实现更清晰的资源循环。

---

### 2.1 基础建筑：工厂体系

#### 📌 功能定位
- **唯一产出**: 金币 (Gold)
- **人口消耗**: 玩家可自由分配人口到不同工厂
- **效率机制**: 基于人口投入的动态产出公式

#### 🏭 工厂类型

| 工厂名称 | 基础产出 | 解锁条件 | 特殊说明 |
|---------|---------|---------|---------|
| **采矿场** | 10 Gold/分钟 | 初始解锁 | 最基础的金币来源 |
| **冶炼厂** | 25 Gold/分钟 | 采矿场 Lv.3 | 消耗矿石，产出更高 |
| **锻造工坊** | 60 Gold/分钟 | 冶炼厂 Lv.5 + 铁匠铺 | 需要铁匠铺作为前置 |
| **商贸行会** | 150 Gold/分钟 | 所有基础建筑满级 | 后期经济核心 |

#### 📊 人口分配效率公式

```python
def calculate_factory_output(base_rate: float, allocated_population: int, total_population: int) -> float:
    """
    计算工厂实际产出
    
    Args:
        base_rate: 基础产出速率 (Gold/分钟)
        allocated_population: 分配到该工厂的人口数
        total_population: 玩家总人口数
    
    Returns:
        实际产出速率 (Gold/分钟)
    """
    
    # 1. 人口密度系数 (0.5 - 2.0)
    population_density = allocated_population / max(1, total_population)
    
    if population_density <= 0.3:
        density_multiplier = 0.5 + (population_density * 1.5)  # 0.5 -> 1.0
    elif population_density <= 0.6:
        density_multiplier = 1.0 + ((population_density - 0.3) * 1.67)  # 1.0 -> 1.5
    else:
        density_multiplier = min(2.0, 1.5 + (population_density - 0.6) * 1.25)  # 1.5 -> 2.0
    
    # 2. 建筑等级加成
    building_level_multiplier = 1.0 + (building_level * 0.3)
    
    # 3. 最终产出
    actual_output = base_rate * density_multiplier * building_level_multiplier
    
    return actual_output
```

#### 🎮 人口分配界面设计

```
┌─────────────────────────────────────────┐
│ 👥 人口管理 (当前：150/200)             │
├─────────────────────────────────────────┤
│ ⛏️ 采矿场        [█████░░] 45人    +85G/min│
│ 🔥 冶炼厂        [███░░░░] 30人    +62G/min│
│ ⚒️ 锻造工坊      [████░░░] 40人   +144G/min│
│ 💰 商贸行会      [░░░░░░░]  0人     0G/min │
├─────────────────────────────────────────┤
│ 📊 总人口投入：115/200                   │
│ ⚠️ 未分配人口无法提供产出                │
└─────────────────────────────────────────┘
```

#### 💡 策略要点
- **过度投资惩罚**: 单厂人口超过总数 60% 后，边际收益递减
- **均衡布局**: 分散投资可稳定经济，但需要更多建筑升级
- **动态调整**: 根据地下城探索周期调整分配（深入前减少工厂人口，保证撤离时间）

---

### 2.2 特殊建筑：功能体系

#### 📌 功能定位
- **独特 NPC 系统**: 每个特殊建筑有专属 NPC 提供互动
- **装备/物品服务**: 通过 NPC 购买或定制提升道具
- **解锁条件严格**: 需要前置建筑和资源投入

#### 🏛️ 特殊建筑列表

##### 🍺 酒馆 (Tavern)

**NPC**: "老酒鬼" 巴纳比  
**功能**:
- ✅ 出售**抗侵蚀药剂**（核心道具）
- ✅ 接受委托任务获取稀有材料
- ✅ 情报交易：购买地牢信息折扣

**解锁条件**:
```yaml
前置建筑: 采矿场 Lv.2
资源消耗: 500 Gold, 100 Wood
人口要求: 至少 20 人驻守
```

**药剂出售列表**:

| 药剂名称 | 效果 | 持续时间 | 价格 | 说明 |
|---------|------|---------|------|------|
| **初级抗蚀剂** | +15% 侵蚀抗性 | 单次地下城 | 200 Gold | 新手必备 |
| **中级抗蚀剂** | +30% 侵蚀抗性 | 单次地下城 | 500 Gold | 中期主力 |
| **高级抗蚀剂** | +50% 侵蚀抗性 | 单次地下城 | 1500 Gold | 后期选择 |
| **传说药剂** | +80% 侵蚀抗性 | 单次地下城 | 5000 Gold | 极限挑战用 |

##### ⚒️ 铁匠铺 (Blacksmith)

**NPC**: "铁锤" 莫格  
**功能**:
- ✅ 装备强化/升级
- ✅ 定制专属武器（消耗稀有材料）
- ✅ 购买特殊工具（开锁器、绳索等）

**解锁条件**:
```yaml
前置建筑: 锻造工坊 Lv.1, 采矿场 Lv.3
资源消耗: 1000 Gold, 200 Iron Ore
人口要求: 至少 30 人驻守
```

##### 📜 法师塔 (Mage Tower)

**NPC**: "智者" 艾莉娅  
**功能**:
- ✅ 法术卷轴购买
- ✅ 技能书解锁（需职业匹配）
- ✅ 炼金配方研究

**解锁条件**:
```yaml
前置建筑: 商贸行会 Lv.2, 铁匠铺 Lv.3
资源消耗: 2000 Gold, 100 Magic Essence
人口要求: 至少 40 人驻守
```

##### 🏥 治疗所 (Sanctuary)

**NPC**: "天使" 塞拉菲娜  
**功能**:
- ✅ 复活已故队友（地牢内死亡）
- ✅ 状态异常解除
- ✅ 永久属性提升（消耗金币和稀有材料）

**解锁条件**:
```yaml
前置建筑: 所有基础建筑 Lv.2
资源消耗: 3000 Gold, 50 Healing Herbs
人口要求: 至少 50 人驻守
```

---

### 🎨 NPC 互动系统

#### 💬 对话树设计
每个 NPC 拥有独特的对话树，包含：
- **日常问候**: 根据时间/天气变化台词
- **服务菜单**: 购买物品、接受任务
- **背景故事**: 解锁世界观碎片
- **好感度系统**: 频繁互动提升信任，获得折扣

#### 📈 好感度机制

```python
def update_npc_affinity(player_id: str, npc_id: str, interaction_type: str):
    """NPC 好感度更新逻辑"""
    
    affinity_changes = {
        'purchase': +2,           # 购买商品
        'quest_complete': +10,    # 完成任务
        'daily_talk': +1,         # 日常对话
        'insult': -5              # 恶意互动（如有）
    }
    
    current_affinity = get_affinity(player_id, npc_id)
    new_affinity = min(100, max(0, current_affinity + affinity_changes[interaction_type]))
    
    # 解锁新服务
    if new_affinity >= 50:
        unlock_discount(npc_id, discount_rate=0.1)  # 9 折
    
    if new_affinity >= 80:
        unlock_special_service(npc_id)  # 特殊服务
    
    set_affinity(player_id, npc_id, new_affinity)
```

#### 🎁 好感度奖励等级

| 等级 | 名称 | 折扣 | 解锁内容 |
|------|------|------|---------|
| 0-19 | 陌生人 | 无 | 基础服务 |
| 20-49 | 熟客 | 5% | 优先购买权 |
| 50-79 | 朋友 | 10% | 限时商品访问 |
| 80-99 | 挚友 | 15% | 定制服务 |
| 100 | 知己 | 20% + 专属礼物 | 隐藏任务解锁 |

---

## 3. 撤离机制 - 抗侵蚀属性驱动

### ⚠️ 核心危机设计

地牢正在**崩塌/腐化**，玩家必须在侵蚀耗尽前找到出口。这不是简单的倒计时，而是需要**策略性管理抗侵蚀属性**。

---

### 3.1 核心公式详解

#### 📐 撤离时间计算

```python
import math

def calculate_extraction_time(base_time: float, corruption_resistance: float) -> dict:
    """
    计算实际可停留时间
    
    Args:
        base_time: 基础撤离时间 (秒)，根据地下城层级设定
        corruption_resistance: 抗侵蚀属性值 (0-100%)
    
    Returns:
        包含详细计算结果的数据结构
    """
    
    # 1. S 形曲线倍率函数
    def sigmoid_curve(resistance: float, scale: float = 5.0) -> float:
        """
        S 形曲线：低抗性时衰减慢，高抗性时衰减快
        
        y = 1 / (1 + e^(-k(x - x0)))
        
        Args:
            resistance: 抗侵蚀百分比 (0-1)
            scale: 曲线缩放因子，默认为 5 秒影响时长
        
        Returns:
            时间倍率系数
        """
        k = scale  # 斜率参数
        x0 = 0.5   # 中点位置
        
        # 防止除零错误
        if resistance <= 0:
            return 0.1  # 最小保底倍数
        elif resistance >= 1.0:
            return 2.0  # 最大上限倍数
        
        # S 形曲线计算
        exponent = -k * (resistance - x0)
        sigmoid_value = 1 / (1 + math.exp(exponent))
        
        # 归一化到 [0.5, 2.0] 范围
        multiplier = 0.5 + sigmoid_value * 1.5
        
        return min(2.0, max(0.5, multiplier))
    
    # 2. 计算实际可停留时间
    time_multiplier = sigmoid_curve(corruption_resistance / 100.0)
    actual_time = base_time * time_multiplier
    
    # 3. 侵蚀进度条更新速率
    corruption_rate = 1.0 / actual_time  # 每秒侵蚀进度百分比
    
    return {
        'base_time': base_time,
        'resistance': corruption_resistance,
        'time_multiplier': round(time_multiplier, 3),
        'actual_time': round(actual_time, 2),
        'corruption_rate': round(corruption_rate * 100, 2)  # %/秒
    }
```

#### 📊 S 形曲线可视化效果

| 抗性值 | 时间倍率 | 实际停留时间 (基础 60s) | 侵蚀速率 (%/秒) |
|-------|---------|---------------------|---------------|
| 0% | 0.5x | 30 秒 | 3.33%/秒 |
| 10% | 0.72x | 43 秒 | 2.33%/秒 |
| 25% | 0.96x | 58 秒 | 1.72%/秒 |
| 50% (中点) | 1.25x | 75 秒 | 1.33%/秒 |
| 75% | 1.64x | 98 秒 | 1.02%/秒 |
| 90% | 1.87x | 112 秒 | 0.89%/秒 |
| 100% | 2.0x | 120 秒 | 0.83%/秒 |

#### 💡 设计意图
- **低抗性**: 玩家急需提升生存能力，否则无法深入
- **中抗性**: 曲线陡峭区，投入产出比最高
- **高抗性**: 边际效益递减，鼓励多样化发展

---

### 3.2 抗侵蚀药剂系统

#### 🧪 药剂类型与效果

##### 📍 地窖可购买型（永久 Buff）

| 药剂名称 | 价格 | 持续时间 | 叠加机制 |
|---------|------|---------|---------|
| **初级抗蚀剂** | 200 Gold | 单次地下城 | ✅ 可叠加，上限 3 层 |
| **中级抗蚀剂** | 500 Gold | 单次地下城 | ✅ 可叠加，上限 2 层 |
| **高级抗蚀剂** | 1500 Gold | 单次地下城 | ✅ 可叠加，上限 1 层 |
| **传说药剂** | 5000 Gold | 单次地下城 | ❌ 不可叠加 |

##### ⚠️ 地窖内无效型（防止作弊）

```python
def apply_potion_effect(potion_type: str, current_resistance: float) -> tuple[float, bool]:
    """
    应用药剂效果
    
    Returns:
        (new_resistance, success)
    """
    
    # 地窖内检测
    if is_inside_dungeon():
        return current_resistance, False
    
    potion_effects = {
        '初级抗蚀剂': {'base_bonus': 15, 'max_stack': 3},
        '中级抗蚀剂': {'base_bonus': 30, 'max_stack': 2},
        '高级抗蚀剂': {'base_bonus': 50, 'max_stack': 1},
        '传说药剂': {'base_bonus': 80, 'max_stack': 1}
    }
    
    effect = potion_effects.get(potion_type)
    if not effect:
        return current_resistance, False
    
    # 叠加计算（含曲线衰减）
    current_stacks = get_active_potions(player_id, potion_type)
    new_stacks = min(effect['max_stack'], current_stacks + 1)
    
    # 曲线衰减公式：每层收益递减
    stack_bonus = effect['base_bonus'] * (1.0 - 0.2 * current_stacks)
    total_bonus = sum(
        potion_effects[p]['base_bonus'] * (1.0 - 0.2 * get_active_potions(player_id, p))
        for p in potion_effects
    )
    
    new_resistance = min(100.0, current_resistance + stack_bonus)
    
    return new_resistance, True
```

#### 🎨 药剂使用界面

```
┌─────────────────────────────────────────┐
│ 💊 抗蚀剂背包 (当前地下城 Buff)          │
├─────────────────────────────────────────┤
│ ✅ 初级抗蚀剂 x2    [+45% 抗性]           │
│ ❌ 中级抗蚀剂 x0    [未装备]              │
│ ⚠️ 高级抗蚀剂 x1    [+50% 抗性，已生效]   │
├─────────────────────────────────────────┤
│ 📊 当前总抗性：95/100%                   │
│ ⏱️ 预计撤离时间：114 秒 (基础 60s)        │
│                                         │
│ [装备] [丢弃] [使用新药剂]               │
└─────────────────────────────────────────┘
```

#### 💡 策略要点
- **预先准备**: 必须在地窖内提前服用，地牢中无效
- **叠加管理**: 多层叠加有衰减，需要权衡性价比
- **风险投资**: 高级药剂提供更高收益，但价格昂贵

---

### 3.3 侵蚀进度条 UI

```gdscript
# corruption_progress_bar.gd
class_name CorruptionProgressBar extends ProgressBar

@export var max_time: float = 60.0      # 基础时间 (秒)
@export var current_resistance: float   # 当前抗性 (%)

var actual_time: float = 0.0
var corruption_rate: float = 0.0

func _ready():
    update_progress()

func update_progress():
    # 重新计算实际时间和侵蚀速率
    var calc_result = calculate_extraction_time(max_time, current_resistance)
    actual_time = calc_result.actual_time
    corruption_rate = calc_result.corruption_rate
    
    # 设置进度条
    max_value = actual_time
    value = get_game_timer()
    
    # 颜色动态变化
    if value < actual_time * 0.5:
        color = Color.GREEN
    elif value < actual_time * 0.8:
        color = Color.YELLOW
    else:
        color = Color.RED
    
    # 显示剩余时间文本
    var remaining = actual_time - value
    $TimeLabel.text = format_time(remaining)

func format_time(seconds: float) -> String:
    var minutes = int(seconds / 60)
    var secs = int(seconds % 60)
    return "%d:%02d" % [minutes, secs]
```

---

## 4. 时间系统设计

### 🌍 设计理念

引入**现实时间等比例缩放机制**，让城镇生活更有节奏感。玩家需要在**地牢探索**和**城镇发展**之间平衡时间投入。

---

### 4.1 时间缩放比例方案

#### ⏱️ 推荐配置（由中书制定）

```yaml
# time_system_config.yaml

# 核心缩放比：现实 1 分钟 = 游戏内 N 小时
time_scale:
  ratio: "1:8"              # 现实 1 分钟 = 游戏 8 小时 (即 1:480)
  alternative_ratio: "1:6"  # 备选方案：更慢节奏
  
# 昼夜周期定义
day_cycle:
  day_duration: 16_game_hours    # 白天时长
  night_duration: 8_game_hours   # 夜晚时长
  total_day_length: 24_game_hours
  
# 现实时间换算表
real_time_conversion:
  "1_game_hour": "7.5_real_minutes"
  "1_game_day": "3_real_hours"    # 完整昼夜循环 = 3 现实小时
  "1_game_week": "21_real_hours"  # 一周 = 约 1 天
```

#### 📊 时间系统参数表

| 游戏时长 | 现实时长 (1:8) | 现实时长 (1:6) | 用途说明 |
|---------|--------------|--------------|---------|
| 1 小时 | 7.5 分钟 | 10 分钟 | NPC 日常活动周期 |
| 4 小时 | 30 分钟 | 40 分钟 | 半日工作/探索时段 |
| 8 小时 | 1 小时 | 1.3 小时 | 半天任务时限 |
| 16 小时 (白天) | 2 小时 | 2.7 小时 | 昼夜周期主体 |
| 24 小时 (一天) | 3 小时 | 4 小时 | NPC 作息循环 |
| 7 天 (一周) | 21 小时 | 28 小时 | 周常任务重置 |

---

### 4.2 时间系统实现方案

#### 🕐 核心计时器脚本

```gdscript
# time_manager.gd
class_name TimeManager extends Node

signal day_changed(day_number: int)
signal time_of_day_changed(hour: int, minute: int)

# 配置参数
@export var time_scale_ratio: float = 480.0  # 1:480 (现实秒：游戏秒)
@export var day_cycle_hours: int = 24

var game_time: Time = Time.new(0, 0, 0)  # day, hour, minute
var is_paused: bool = false

func _process(delta: float):
    if is_paused or not get_parent().is_in_tree():
        return
    
    # 时间推进
    game_time.minute += delta * (60.0 / time_scale_ratio)
    
    if game_time.minute >= 60:
        game_time.hour += int(game_time.minute / 60)
        game_time.minute = fmod(game_time.minute, 60)
    
    if game_time.hour >= 24:
        game_time.day += 1
        game_time.hour = 0
        
        emit_signal("day_changed", game_time.day)
        on_day_end()

func get_real_time_estimate(hours_needed: int) -> String:
    """估算完成某任务需要多少现实时间"""
    var game_minutes = hours_needed * 60
    var real_seconds = game_minutes * time_scale_ratio / 60.0
    
    if real_seconds < 60:
        return "%.1f 秒" % real_seconds
    elif real_seconds < 3600:
        return "%.1f 分钟" % (real_seconds / 60.0)
    else:
        return "%.1f 小时" % (real_seconds / 3600.0)

func pause_time():
    is_paused = true

func resume_time():
    is_paused = false
```

#### 🏙️ 城镇时间活动表

| 游戏时间 | 现实时间 (1:8) | NPC 行为 | 商店状态 |
|---------|--------------|--------|---------|
| 06:00 - 08:00 | 7.5-15 min | 起床、早餐 | 部分营业 |
| 08:00 - 12:00 | 15-45 min | 工作、巡逻 | 🟢 全部开放 |
| 12:00 - 13:00 | 45-52.5 min | 午休 | 🟡 部分休息 |
| 13:00 - 18:00 | 52.5-90 min | 工作、社交 | 🟢 全部开放 |
| 18:00 - 20:00 | 90-105 min | 晚餐、酒馆聚会 | 🟡 部分打烊 |
| 20:00 - 24:00 | 105-135 min | 夜间活动 | 🔴 商店关闭 |
| 00:00 - 06:00 | 135-180 min | 休息、巡逻 | 🔴 全部关闭 |

#### 💡 时间相关机制

##### 📆 周常任务重置
```python
def reset_weekly_tasks():
    """每周日 00:00 重置周常任务"""
    if get_game_time().day_of_week == SUNDAY and get_game_time().hour == 0:
        weekly_tasks = [
            'clear_dungeon_floor_5',
            'earn_10000_gold',
            'defeat_boss_monster'
        ]
        
        for task in weekly_tasks:
            reset_task_progress(task)
        
        send_notification("周常任务已重置！")
```

##### 🌙 昼夜影响系统

| 时段 | 地牢难度变化 | NPC 行为变化 | 特殊事件 |
|------|------------|------------|---------|
| **白天** | 标准难度 | 正常作息 | 无 |
| **黄昏** | +10% 怪物强度 | 提前返回城镇 | 稀有商人出现 |
| **夜晚** | +25% 怪物强度，+30% 掉落率 | 巡逻减少 | 幽灵事件概率提升 |
| **午夜** | +40% 怪物强度，最高掉落率 | 几乎无人活动 | Boss 召唤几率增加 |

---

### 4.3 时间系统 UI 实现

```gdscript
# clock_display.gd
class_name ClockDisplay extends Control

@export var time_manager: TimeManager

func _ready():
    time_manager.day_changed.connect(on_day_changed)

func _process(_delta):
    update_display()

func update_display():
    var gt = time_manager.game_time
    
    # 主时钟显示
    $HourLabel.text = "%02d" % gt.hour
    $MinuteLabel.text = "%02d" % int(gt.minute)
    
    # 日期显示
    $DateLabel.text = "第%d天" % gt.day
    
    # 昼夜图标
    var day_icon = get_day_night_icon(gt.hour, gt.minute)
    $DayNightIcon.texture = load(day_icon)

func get_day_night_icon(hour: int, minute: float) -> String:
    if 6 <= hour or (hour == 0 and minute < 6):
        return "res://textures/day_icon.png"
    elif hour < 18:
        return "res://textures/noon_icon.png"
    else:
        return "res://textures/night_icon.png"

func on_day_changed(day: int):
    $DayPopup.text = f"📅 新的一天！第{day}天开始"
    yield(get_tree().create_timer(2.0), "timeout")
    $DayPopup.hide()
```

---

## 5. 职业系统三层架构

### 🎭 核心设计理念

采用**三阶解锁机制**，从基础方向到进阶分支再到隐藏传奇，逐步揭示角色深度。

---

### 5.1 主职业 (Primary Class)

#### 📌 定义
玩家初始选择的**基础战斗风格**，决定：
- ✅ 基础属性成长倾向
- ✅ 可学习的技能树范围
- ✅ 初始装备类型限制

#### ⚔️ 主职业列表

| 主职业 | 核心属性 | 武器类型 | 定位 | 描述 |
|-------|---------|---------|------|------|
| **战士** | STR > VIT > DEX | 近战物理 | 坦克/输出 | 力量型近战专家，生存能力强 |
| **法师** | INT > MND > CON | 法术远程 | 爆发输出 | 魔法掌控者，高伤害低防御 |
| **游侠** | DEX > AGI > STR | 远程物理 | 游击/辅助 | 敏捷射手，擅长陷阱和闪避 |
| **牧师** | MND > VIT > INT | 法术近战 | 治疗/增益 | 神圣力量使用者，团队核心 |

#### 📊 主职业属性成长公式

```python
def calculate_stat_growth(base_class: str, level: int) -> dict:
    """
    计算等级提升时的属性增长
    
    Args:
        base_class: 主职业名称
        level: 当前等级
    
    Returns:
        {STR, INT, DEX, AGI, VIT, MND} 各属性增长值
    """
    
    growth_rates = {
        '战士': {'STR': 5.0, 'VIT': 3.0, 'DEX': 1.0},
        '法师': {'INT': 6.0, 'MND': 2.0, 'CON': 1.0},
        '游侠': {'DEX': 4.5, 'AGI': 3.5, 'STR': 1.5},
        '牧师': {'MND': 5.5, 'VIT': 2.5, 'INT': 2.0}
    }
    
    rates = growth_rates.get(base_class, {})
    
    # 等级曲线：前期快，后期慢
    level_multiplier = min(1.5, 1.0 + (level - 1) * 0.02)
    
    return {
        stat: rate * level_multiplier 
        for stat, rate in rates.items()
    }
```

---

### 5.2 子职业 (Sub-Class)

#### 📌 定义
在主职业基础上**进阶分支**，需要满足特定条件解锁。解锁后：
- ✅ 获得专属技能树
- ✅ 属性成长微调
- ✅ 特殊被动效果

#### ⚔️ 战士 → 子职业路线

| 子职业 | 解锁条件 | 核心特性 | 定位偏移 |
|-------|---------|---------|---------|
| **剑士** | 战士 Lv.10 + 铁匠铺 Lv.3 | 高攻速、连击系统 | 纯输出 |
| **圣骑士** | 战士 Lv.15 + 牧师好感≥80 | 防御光环、神圣伤害 | 坦克/辅助 |
| **狂战士** | 战士 Lv.20 + 消耗生命药剂 x5 | 低血量高伤害、狂暴模式 | 高风险输出 |
| **守护者** | 战士 Lv.12 + 守护徽章 | 嘲讽技能、团队护盾 | 纯坦克 |

#### 🔮 法师 → 子职业路线

| 子职业 | 解锁条件 | 核心特性 | 定位偏移 |
|-------|---------|---------|---------|
| **元素师** | 法师 Lv.10 + 元素石 x3 | 火/冰/雷三系专精 | 元素爆发 |
| **死灵法师** | 法师 Lv.15 + 灵魂水晶 x5 | 召唤亡灵、生命汲取 | 持续输出 |
| **奥术师** | 法师 Lv.8 + 智慧之书 | 法力回复快、技能冷却缩减 | 持久战专家 |
| **贤者** | 法师 Lv.20 + 牧师好感≥70 | 团队 Buff、群体治疗 | 辅助法师 |

#### 🏹 游侠 → 子职业路线

| 子职业 | 解锁条件 | 核心特性 | 定位偏移 |
|-------|---------|---------|---------|
| **刺客** | 游侠 Lv.12 + 暗影斗篷 | 隐身系统、背刺暴击 | 爆发输出 |
| **猎手** | 游侠 Lv.8 + 陷阱工具包 | 陷阱布置、宠物协同 | 控制/持续 |
| **游侠队长** | 游侠 Lv.15 + 团队徽章 | 队友增益、战术指挥 | 辅助核心 |

#### 🙏 牧师 → 子职业路线

| 子职业 | 解锁条件 | 核心特性 | 定位偏移 |
|-------|---------|---------|---------|
| **圣职者** | 牧师 Lv.10 + 圣光碎片 x5 | 神圣伤害、驱散负面 | 治疗/输出双修 |
| **德鲁伊** | 牧师 Lv.12 + 自然之灵 | 变形系统、自然召唤 | 形态切换 |
| **先知** | 牧师 Lv.18 + 预言水晶 | 预判技能、未来视野 | 战术辅助 |

---

### 5.3 隐藏职业 (Hidden Class)

#### 📌 定义
通过**特殊条件解锁**的传奇职业，拥有独特能力和外观。解锁后：
- ✅ 获得终极技能树
- ✅ 全属性成长优化
- ✅ 专属称号和特效

#### 🔥 隐藏职业列表

| 隐藏职业 | 解锁条件 | 核心能力 | 推荐主/子职业 |
|---------|---------|---------|-------------|
| **龙骑士** | 战士→圣骑士 Lv.30 + 龙鳞 x10 | 龙化形态、龙息技能 | 战士 → 圣骑士 |
| **元素君主** | 法师→元素师 Lv.35 + 三系晶石各 1 | 全元素掌控、天灾召唤 | 法师 → 元素师 |
| **暗影行者** | 游侠→刺客 Lv.28 + 虚空碎片 x5 | 空间穿梭、暗影吞噬 | 游侠 → 刺客 |
| **神之恩典** | 牧师→圣职者 Lv.32 + 神圣之心 | 复活他人、奇迹创造 | 牧师 → 圣职者 |
| **时空行者** | 任意主职业 Lv.40 + 时间沙漏 | 时间暂停、空间扭曲 | 全职业开放 |

#### 🎯 龙骑士解锁流程示例

```python
def unlock_dragon_knight(player_id: str) -> bool:
    """
    检查并解锁龙骑士职业
    
    Args:
        player_id: 玩家 ID
    
    Returns:
        True if unlocked successfully
    """
    
    character = get_character(player_id)
    
    # 条件检查
    if character.primary_class != '战士':
        return False, "必须是战士转职"
    
    if character.sub_class != '圣骑士':
        return False, "必须转职为圣骑士"
    
    if character.level < 30:
        return False, "等级需要达到 30 级"
    
    dragon_scales = get_item_count(player_id, '龙鳞')
    if dragon_scales < 10:
        return False, f"需要 10 个龙鳞，当前拥有 {dragon_scales}"
    
    # 任务链触发
    trigger_quest('龙之试炼', player_id)
    
    return True, "龙骑士解锁任务已开启！"

def complete_dragon_trial(player_id: str):
    """完成龙之试炼任务"""
    
    # 特殊副本：龙巢
    start_instance('dragon_nest', player_id)
    
    # BOSS 战：远古金龙
    boss = spawn_boss('ancient_golden_dragon', difficulty=3.0)
    
    if defeat_boss(boss, player_id):
        # 获得龙骑士职业
        character = get_character(player_id)
        character.primary_class = '龙骑士'
        character.sub_class = None  # 隐藏职业无子职业
        
        # 给予专属技能
        learn_skill(player_id, '龙息吐息', skill_level=1)
        learn_skill(player_id, '龙鳞护甲', skill_level=1)
        
        # 称号和特效
        grant_title('屠龙者')
        equip_effect('dragon_aura', permanent=True)
        
        send_notification("🐉 恭喜！你已觉醒为传说中的龙骑士！")
```

---

### 5.4 转职系统 UI 设计

```gdscript
# class_transfer_ui.gd
class_name ClassTransferUI extends Control

@onready var primary_class_tab = $TabContainer.PrimaryClassTabs
@onready var sub_class_tab = $TabContainer.SubClassTabs
@onready var hidden_class_tab = $TabContainer.HiddenClassTabs

func _ready():
    setup_tabs()

func setup_tabs():
    # 主职业标签页 - 初始解锁
    for class_data in PRIMARY_CLASSES:
        var button = create_class_button(class_data)
        primary_class_tab.add_child(button)
    
    # 子职业标签页 - 根据主职业动态显示
    character.primary_class_changed.connect(on_primary_class_changed)

func on_primary_class_changed(new_class: String):
    clear_subclass_options()
    
    available_subs = get_available_subclasses(new_class)
    
    for sub_data in available_subs:
        if meets_unlock_requirements(sub_data):
            add_subclass_option(sub_data)
        else:
            add_locked_subclass_option(sub_data, reason=unlock_reason)

func show_transfer_dialog(target_class: String, requirements: dict):
    $Dialog.title = f"转职为 {target_class}"
    
    var req_text = ""
    for key, value in requirements.items():
        req_text += f"\n✅ {key}: {value}"
    
    $Dialog.description.text = "需要满足以下条件：" + req_text
    
    $Dialog.buttons[0].text = "确认转职"
    $Dialog.buttons[1].text = "取消"
```

---

## 6. 装备系统调整

### ⚔️ 核心变革：与职业解绑，和技能挂钩

#### 🎯 设计理念
- **自由度提升**: 不再被职业限制武器选择
- **Build 多样化**: 通过技能搭配实现独特玩法
- **策略深度**: 需要平衡技能兼容性和装备属性

---

### 6.1 武器三大分类体系

#### 🔫 远程武器 (Ranged Weapons)

| 小类 | 代表物品 | 伤害类型 | 特点 | 适用技能 |
|------|---------|---------|------|---------|
| **弓弩** | 长弓、复合弓、弩炮 | 物理 | 高精准、中射程 | 瞄准射击、多重箭 |
| **枪械** | 手枪、步枪、霰弹枪 | 物理/火药 | 高射速、后坐力系统 | 快速射击、爆头 |
| **法杖远程** | 奥术法球、元素权杖 | 法术 | 无弹药限制、耗蓝 | 元素投射、魔法飞弹 |
| **投掷类** | 飞刀、手雷、炼金炸弹 | 物理/元素 | 范围伤害、特殊效果 | 投掷精通、爆炸陷阱 |

#### 🗡️ 近战武器 (Melee Weapons)

| 小类 | 代表物品 | 伤害类型 | 特点 | 适用技能 |
|------|---------|---------|------|---------|
| **单手剑** | 长剑、短剑、弯刀 | 物理 | 平衡型、可副手武器 | 连击、闪避反击 |
| **双手剑** | 巨剑、战斧、重锤 | 物理 | 高伤害、慢攻速 | 强力打击、范围横扫 |
| **法刃** | 符文剑、元素刀 | 法术/物理混合 | 附加魔法效果 | 魔法附魔、元素斩击 |
| **双持武器** | 匕首对、拳套 | 物理 | 高攻速、连击数系统 | 连击爆发、背刺 |

#### 🔮 法器与特殊 (Magic & Special)

| 小类 | 代表物品 | 伤害类型 | 特点 | 适用技能 |
|------|---------|---------|------|---------|
| **召唤物** | 召唤法阵、契约器 | 法术/召唤 | 独立单位作战 | 召唤术、宠物强化 |
| **道具类** | 卷轴、炸弹袋 | 混合 | 一次性或消耗品 | 快速使用、物品精通 |
| **特殊装备** | 时间沙漏、空间戒指 | 概念性 | 功能型为主 | 时空操控、空间穿梭 |

---

### 6.2 技能与武器兼容系统

#### 📋 兼容性矩阵

```python
WEAPON_SKILL_COMPATIBILITY = {
    # 远程武器
    'bow': ['瞄准射击', '多重箭', '穿透射击'],
    'gun': ['快速射击', '爆头', '连发'],
    'magic_ranged': ['元素投射', '魔法飞弹', '奥术风暴'],
    'throwable': ['投掷精通', '爆炸陷阱', '精准投掷'],
    
    # 近战武器
    'one_hand_sword': ['连击', '闪避反击', '防御姿态'],
    'two_hand_sword': ['强力打击', '范围横扫', '破防斩'],
    'magic_blade': ['魔法附魔', '元素斩击', '符文解放'],
    'dual_wield': ['连击爆发', '背刺', '旋风斩'],
    
    # 法器特殊
    'summoner': ['召唤术', '宠物强化', '契约解放'],
    'item_user': ['快速使用', '物品精通', '炼金术师'],
    'special_gear': ['时空操控', '空间穿梭', '概念重构']
}

def can_use_skill_with_weapon(skill_name: str, weapon_type: str) -> bool:
    """检查技能与武器是否兼容"""
    
    compatible_skills = WEAPON_SKILL_COMPATIBILITY.get(weapon_type, [])
    
    return skill_name in compatible_skills

def get_recommended_weapons_for_skill(skill_name: str) -> list[str]:
    """获取适合某技能的推荐武器列表"""
    
    recommended = []
    
    for weapon_type, skills in WEAPON_SKILL_COMPATIBILITY.items():
        if skill_name in skills:
            recommended.append(weapon_type)
    
    return recommended
```

#### 🎨 技能装备界面示例

```
┌─────────────────────────────────────────┐
│ ⚔️ 技能配置界面                         │
├─────────────────────────────────────────┤
│ 🔫 当前装备：复合弓 (远程 - 物理)        │
│                                         │
│ 📊 可用技能列表:                        │
│ ✅ [瞄准射击]       Lvl.5   (兼容)      │
│ ✅ [多重箭]         Lvl.3   (兼容)      │
│ ❌ [连击]           Lvl.2   (不兼容)    │
│ ⚠️ [魔法附魔]       Lvl.1   (需转换)     │
│                                         │
│ 💡 建议切换为：元素权杖 (法术远程)      │
│                                         │
│ [学习新技能] [切换武器] [保存配置]      │
└─────────────────────────────────────────┘
```

---

### 6.3 装备属性与强化系统

#### 📊 装备品质等级

| 品质 | 颜色 | 基础属性加成 | 特殊词条数量 | 来源 |
|------|------|------------|------------|------|
| **普通** | 白色 | +5% | 0 | 地牢掉落 |
| **优秀** | 绿色 | +15% | 1 | 地牢精英怪 |
| **稀有** | 蓝色 | +30% | 2 | BOSS 掉落 |
| **史诗** | 紫色 | +50% | 3 | 副本通关奖励 |
| **传说** | 橙色 | +80% | 4-5 | 隐藏成就/锻造 |
| **神话** | 金色 | +120% | 6+ | 终极 BOSS/活动 |

#### 🔧 强化系统公式

```python
def calculate_enhanced_stats(base_stats: dict, enhancement_level: int) -> dict:
    """
    计算强化后的装备属性
    
    Args:
        base_stats: 基础属性字典 {STR, INT, DEX...}
        enhancement_level: 强化等级 (0-20)
    
    Returns:
        强化后属性
    """
    
    # 强化曲线：前期收益高，后期递减
    def get_enhancement_multiplier(level: int) -> float:
        if level <= 10:
            return 1.0 + (level * 0.15)  # 每级 +15%
        elif level <= 15:
            return 2.5 + ((level - 10) * 0.1)  # 每级 +10%
        else:
            return 3.0 + ((level - 15) * 0.05)  # 每级 +5%
    
    multiplier = get_enhancement_multiplier(enhancement_level)
    
    enhanced_stats = {
        stat: int(value * multiplier)
        for stat, value in base_stats.items()
    }
    
    return enhanced_stats

# 示例：一把基础 STR+10 的剑强化到 +15
base_str = 10
level_15_multiplier = 2.75  # 计算得出
enhanced_str = int(10 * 2.75)  # = 27
```

#### ⚠️ 强化失败惩罚

| 当前等级 | 成功率 | 失败惩罚 |
|---------|-------|---------|
| 0-9 | 100% | 无 |
| 10-14 | 85% | 降级 1 级 |
| 15-17 | 60% | 降级 2 级 |
| 18-19 | 35% | 降级 3 级 + 随机词条丢失 |
| 20 | 10% | 归零 + 装备损坏（需修复） |

---

### 6.4 装备获取途径

#### 🎲 掉落概率表

| 来源 | 普通 | 优秀 | 稀有 | 史诗 | 传说 | 神话 |
|------|------|------|------|------|------|------|
| **精英怪** | 35% | 40% | 20% | 4.9% | 0.1% | - |
| **BOSS** | 15% | 25% | 35% | 20% | 4.9% | 0.1% |
| **副本宝箱** | 10% | 20% | 30% | 30% | 9% | 1% |
| **锻造** | - | - | 50% | 40% | 9.9% | 0.1% |
| **活动奖励** | - | 30% | 40% | 25% | 4.9% | 0.1% |

#### 🔨 锻造系统

```python
def craft_item(materials: dict, template_id: str) -> Item:
    """
    锻造物品
    
    Args:
        materials: {材料名：数量}
        template_id: 锻造模板 ID
    
    Returns:
        生成的装备实例
    """
    
    template = get_crafting_template(template_id)
    
    # 材料检查
    for material, required_count in template.required_materials.items():
        if materials.get(material, 0) < required_count:
            raise ValueError(f"缺少材料：{material}")
    
    # 消耗材料
    consume_materials(materials, template.required_materials)
    
    # 品质判定（基于材料和运气）
    base_quality = calculate_base_quality(template)
    luck_bonus = get_player_luck(player_id)
    final_quality_roll = random.uniform(0, 100)
    
    if final_quality_roll < 5:
        quality = '神话'
    elif final_quality_roll < 15:
        quality = '传说'
    elif final_quality_roll < 45:
        quality = '史诗'
    elif final_quality_roll < 70:
        quality = '稀有'
    elif final_quality_roll < 90:
        quality = '优秀'
    else:
        quality = '普通'
    
    # 生成具体装备
    item = generate_item(template, quality)
    
    return item
```

---

## 7. 核心循环流程

### 🔄 游戏主循环

```
┌─────────────────────────────────────────┐
│          城镇发展系统                   │
│                                         │
│  ├── 建筑升级 → 提高产出/解锁功能       │
│  ├── NPC 互动 → 购买道具/接受任务        │
│  ├── 职业培养 → 转职/学习技能           │
│  └── 装备强化 → 提升战斗力              │
└─────────────────────────────────────────┘
                    ↓ (准备充分)
┌─────────────────────────────────────────┐
│          地牢探索系统                   │
│                                         │
│  ├── 抗侵蚀管理 → 药剂叠加/时间规划     │
│  ├── 战斗系统 → 技能连招/装备配合       │
│  ├── 资源搜集 → 材料/金币/稀有掉落      │
│  └── 撤离决策 → 风险收益权衡            │
└─────────────────────────────────────────┘
                    ↓ (成功撤离)
┌─────────────────────────────────────────┐
│          成长反馈系统                   │
│                                         │
│  ├── 经验获取 → 等级提升/属性增长       │
│  ├── 物品整理 → 装备分解/出售           │
│  └── 职业解锁 → 新分支/隐藏职业         │
└─────────────────────────────────────────┘
                    ↓ (继续循环)
```

---

## 📝 版本更新记录

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| v1.0 | 2026-03-17 | 初始设计文档 | 中书 |
| v2.0 | 2026-03-19 | **核心架构重构**：建筑系统、撤离机制、时间系统、职业三层结构、装备解绑 | 中书 |

---

## 🎯 下一步工作

### ✅ 待细化内容
- [ ] 具体数值平衡表（怪物强度/掉落率精确计算）
- [ ] UI/UX详细原型设计
- [ ] NPC 对话树完整脚本编写
- [ ] 隐藏职业任务链详细流程
- [ ] 经济系统通胀控制机制

### 📞 需要程序协助
- [x] 建筑产出公式实现方案确认 ✅
- [x] S 形曲线撤离时间算法验证 ✅
- [x] 时间缩放比例技术可行性评估
- [ ] 职业解锁条件检查逻辑实现
- [ ] 装备兼容系统数据结构设计

---

*🧠 中书 | Agent Team 首席策划官*  
*"策划先行 · 设计驱动"*  
*最后更新：2026-03-19 (v2.0 重构版)* ✨
