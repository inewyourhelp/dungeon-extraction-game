# 🗺️ PART 1: 大地图系统架构

**章节**: 第一章  
**内容范围**: 概述、基地系统、地下城入口、城镇交易、场景切换

---

## 一、大地图系统架构

### 🗺️ 1.1 系统概述与设计理念

**核心理念:**  
> "以基地为核心，通过探索地下城获取资源，建设强化角色，形成良性循环"

**设计目标:**
- ✅ **清晰的空间认知**: 玩家能明确区分不同功能区域
- ✅ **流畅的地点切换**: 减少加载等待时间，保持游戏节奏
- ✅ **深度互动体验**: NPC、建筑、环境都有叙事价值

---

### 1.2 基地系统详解

#### 1.2.1 基地核心功能模块

| 建筑类型 | 主要功能 | 升级效果 | 解锁条件 | 人口需求 |
|----------|----------|----------|----------|----------|
| **主堡** | 游戏存档点、任务接取处 | 扩展仓库容量、解锁新功能 | 初始建筑 | 50 人 |
| **兵营** | 招募 NPC 士兵、训练战斗单位 | 提升士兵战斗力、解锁特殊兵种 | 主堡 Lv.2 | 100 人 |
| **铁匠铺** | 装备强化、武器锻造 | 解锁稀有配方、提升成功率 | 主堡 Lv.3 | 80 人 |
| **炼金塔** | 制作消耗品、研究新技能 | 解锁高级配方、缩短制作时间 | 主堡 Lv.4 | 120 人 |
| **仓库** | 物资存储、道具管理 | 扩大存储空间、自动分类整理 | 初始建筑 | 30 人 |
| **瞭望塔** | 侦察地下城情况、显示怪物分布 | 解锁更远距离视野、标记稀有资源 | 主堡 Lv.5 | 150 人 |

#### 1.2.2 人口管理系统

**人口来源与消耗:**

```gdscript
class PopulationManager:
    var current_population := 0
    var max_capacity := 100
    
    # NPC 招募流程
    func recruit_npc(npc_type: String, cost_gold: int) -> bool:
        if current_population >= max_capacity:
            return false
        
        # 检查建筑等级是否满足要求
        if not has_required_buildings(npc_type):
            return false
        
        # 扣除金币并增加人口
        game.gold -= cost_gold
        current_population += 1
        
        # NPC 分配到对应建筑工作
        assign_npc_to_building(npc_type)
        
        return true
    
    # 建筑人口需求检查
    func has_required_buildings(npc_type: String) -> bool:
        match npc_type:
            "soldier":
                return building_manager.get_level("barracks") >= 2
            "blacksmith":
                return building_manager.get_level("forge") >= 3
            "alchemist":
                return building_manager.get_level("alchemy_tower") >= 4
        
        return false

# NPC 对话触发机制
func trigger_npc_dialogue(npc_id: String):
    var dialogue_tree := load_dialogue_tree(npc_id)
    
    # 检查对话条件
    if not check_dialogue_conditions(npc_id):
        show_generic_greeting()
        return
    
    # 显示个性化对话
    show_special_dialogue(dialogue_tree, get_npc_relationship(npc_id))

# NPC 关系系统 (影响对话内容和任务难度)
var npc_relationships: Dictionary = {}

func update_npc_relationship(npc_id: String, delta: int):
    if not npc_relationships.has(npc_id):
        npc_relationships[npc_id] = 50  # 初始中立值
    
    var new_value := clamp(npc_relationships[npc_id] + delta, 0, 100)
    npc_relationships[npc_id] = new_value

# 关系等级划分:
# - 0~20: 敌对 (NPC 拒绝交易，可能攻击玩家)
# - 21~49: 冷淡 (正常交易但无折扣)
# - 50~79: 友好 (提供价格优惠，解锁隐藏任务)
# - 80~100: 信赖 (特殊对话，赠送稀有物品)
```

---

### 1.3 地下城入口机制

#### 1.3.1 入口类型与解锁条件

| 入口名称 | 位置 | 解锁条件 | 难度等级 | 特殊说明 |
|----------|------|----------|----------|----------|
| **新手地牢** | 基地西侧 | 初始解锁 | Lv.1-3 | 怪物稀少，适合熟悉机制 |
| **废弃矿坑** | 森林边缘 | 主堡 Lv.3 | Lv.4-6 | 富含矿石资源 |
| **古遗迹** | 沙漠深处 | 瞭望塔 Lv.2 | Lv.7-9 | 可能有古代机关 |
| **深渊裂隙** | 火山口 | 完成主线任务 | Lv.10+ | Boss 战区域 |

#### 1.3.2 入口切换逻辑

```gdscript
class DungeonEntranceManager:
    var current_dungeon_type := "beginner"
    var player_level := 1
    
    func enter_dungeon(dungeon_id: String):
        # 检查解锁条件
        if not is_unlocked(dungeon_id):
            show_error("该地牢尚未解锁！请提升主堡等级或完成前置任务")
            return
        
        # 检查玩家等级是否满足要求
        var min_level := get_dungeon_min_level(dungeon_id)
        if player_level < min_level:
            show_warning("建议玩家等级达到 %d 后再进入" % min_level)
        
        # 加载地下城场景
        load_dungeon_scene(dungeon_id)
        
        # 重置地下城状态
        reset_dungeon_state()
    
    func is_unlocked(dungeon_id: String) -> bool:
        match dungeon_id:
            "beginner":
                return true
            
            "abandoned_mine":
                return building_manager.get_level("main_keep") >= 3
            
            "ancient_ruins":
                return building_manager.get_level("watchtower") >= 2
            
            "abyssal_chasm":
                return quest_manager.is_quest_completed("main_story_chapter_1")
        
        return false
    
    func reset_dungeon_state():
        # 重置地牢层级计数器
        current_layer := 0
        
        # 重置任务计时器
        session_timer.start()
        
        # 生成随机任务
        quest_generator.generate_random_quest()

# 地下城加载流程 (优化体验，减少等待)
func load_dungeon_scene(dungeon_id: String):
    var scene_path := "res://scenes/dungeons/" + dungeon_id + ".tscn"
    
    # 预加载资源
    preload_resources(scene_path)
    
    # 显示加载界面
    show_loading_screen()
    
    # 异步加载场景
    var scene = load(scene_path)
    var instance = scene.instantiate()
    
    get_tree().current_scene.add_child(instance)
    get_tree().change_scene_to_packed(scene)

# 预加载资源函数 (减少卡顿)
func preload_resources(scene_path: String):
    ResourceLoader.load_threaded_request(scene_path)
    
    while ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        get_tree().process()
        await get_tree().create_timer(0.1).timeout
    
    show_loading_complete()
```

---

### 1.4 中立城镇交易功能

#### 1.4.1 城镇结构与功能分布

**地图布局:**
```
[集市广场] ← 玩家初始到达区域
├── [铁匠铺] - 装备购买/强化
├── [药剂店] - 消耗品交易
├── [情报屋] - 任务接取/消息更新
└── [旅馆] - 休息恢复/住宿服务

[住宅区] (需解锁)
├── [NPC 住所] - 深度对话/特殊任务
└── [仓库租赁处] - 扩展存储
```

#### 1.4.2 交易机制详解

**商品价格公式:**

```gdscript
class TradeSystem:
    var base_price := 100
    var relationship_discount := 0.0  # NPC 关系折扣 (最大 30%)
    var market_fluctuation := 0.1     # 市场波动系数
    
    func calculate_item_price(item_id: String, quantity: int) -> float:
        # 基础价格 × 数量
        var base_total := get_base_price(item_id) * quantity
        
        # NPC 关系折扣
        var npc_id := get_trader_npc_id()
        var relationship_level := clamp(npc_relationships.get(npc_id, 50), 0, 100)
        var discount_rate := (relationship_level - 50) / 166.67  # 简化计算
        
        base_total *= (1.0 - discount_rate)
        
        # 市场波动 (随机 ±10%)
        var fluctuation_factor := 1.0 + randf_range(-market_fluctuation, market_fluctuation)
        
        return int(base_total * fluctuation_factor)

# 物品稀有度定价表
enum Rarity {
    COMMON,       # 普通 - 基础价格 × 1
    UNCOMMON,     # 罕见 - 基础价格 × 3
    RARE,         # 稀有 - 基础价格 × 10
    EPIC,         # 史诗 - 基础价格 × 50
    LEGENDARY     # 传奇 - 基础价格 × 200
}

func get_base_price(item_id: String) -> float:
    var item_data := get_item_database()[item_id]
    
    match item_data.rarity:
        Rarity.COMMON:
            return item_data.base_value * 1.0
        
        Rarity.UNCOMMON:
            return item_data.base_value * 3.0
        
        Rarity.RARE:
            return item_data.base_value * 10.0
        
        Rarity.EPIC:
            return item_data.base_value * 50.0
        
        Rarity.LEGENDARY:
            return item_data.base_value * 200.0
    
    return item_data.base_value

# 交易界面 UI 实现
class TradeUI extends CanvasLayer:
    var trader_npc: String = ""
    var selected_item_id := ""
    
    func open_trading_window(npc_id: String, inventory_items: Array):
        trader_npc = npc_id
        
        # 清空旧物品列表
        $ItemList.clear()
        
        # 填充可交易物品
        for item in inventory_items:
            var price := calculate_item_price(item.id, item.quantity)
            
            var item_button := create_trade_item_button(
                name=item.name,
                icon=item.icon,
                price=price,
                quantity=item.quantity
            )
            
            $ItemList.add_child(item_button)

# 购买/出售逻辑
func execute_transaction(transaction_type: String, item_id: String, quantity: int):
    var price := calculate_item_price(item_id, quantity)
    
    match transaction_type:
        "buy":
            if game.gold < price:
                show_error("金币不足！")
                return false
            
            # 扣除金币，添加物品到背包
            game.gold -= price
            player_inventory.add_item(item_id, quantity)
            
            show_success("购买成功！花费 %d 金币" % price)
            
        "sell":
            if not player_inventory.has_item(item_id, quantity):
                show_error("库存不足！")
                return false
            
            # 扣除物品，增加金币
            player_inventory.remove_item(item_id, quantity)
            game.gold += int(price * 0.8)  # 出售价格打八折
            
            show_success("出售成功！获得 %d 金币" % int(price * 0.8))

# NPC 关系对交易的影响
func apply_relationship_effect(npc_id: String):
    var relationship := npc_relationships.get(npc_id, 50)
    
    if relationship >= 80:
        # 信赖等级：解锁隐藏商品，价格再降 10%
        unlock_hidden_items()
        apply_additional_discount(0.10)
        
        show_dialogue("Kael", "老朋友，这些稀有材料就卖给你吧！")
    
    elif relationship >= 50:
        # 友好等级：提供常规折扣
        apply_regular_discount(0.15)
        
        show_dialogue("Kael", "老朋友，今天想打造什么武器？我最近研究出几个新配方。")

```

---

### 1.5 地点间切换逻辑

#### 1.5.1 场景转换机制

**设计原则:** 快速切换 + 视觉过渡 + 叙事衔接

| 切换类型 | 加载时间 | 过渡效果 | 适用场景 |
|----------|----------|----------|----------|
| **基地 ↔ 城镇** | < 1s | 淡入淡出 | 日常活动 |
| **城镇 ↔ 地牢入口** | 2-3s | 地图缩放动画 | 任务触发 |
| **地牢层间切换** | 1-2s | 传送门特效 | 探索推进 |

#### 1.5.2 场景管理流程

```gdscript
class SceneManager:
    var current_scene := "base"
    var transition_timer := 0.0
    var is_transitioning := false
    
    func switch_scene(target_scene: String):
        if is_transitioning or target_scene == current_scene:
            return
        
        # 保存当前场景状态
        save_current_state()
        
        # 显示过渡 UI
        show_transition_ui(get_transition_type(current_scene, target_scene))
        
        # 异步加载目标场景
        load_async(target_scene)
        
        is_transitioning = true
    
    func get_transition_type(from: String, to: String) -> String:
        match from + "_" + to:
            "base_town":
                return "fade"
            
            "town_dungeon_entrance":
                return "map_zoom"
            
            "dungeon_layer_n_to_n+1":
                return "portal_effect"
        
        return "instant"

# 过渡效果实现
func show_transition_ui(effect_type: String):
    var transition_scene := load("res://scenes/ui/transition_" + effect_type + ".tscn")
    var instance = transition_scene.instantiate()
    
    get_tree().current_scene.add_child(instance)
    
    # 等待过渡动画完成
    await instance.animation_finished
    
    is_transitioning = false

# 场景状态保存与恢复
func save_current_state():
    state_saver.save({
        "player_position": player.global_position,
        "inventory_snapshot": player_inventory.export_to_json(),
        "quest_progress": quest_manager.export_progress()
    })

func load_saved_state():
    var saved_data := state_saver.load()
    
    if saved_data:
        player.global_position = saved_data.player_position
        player_inventory.import_from_json(saved_data.inventory_snapshot)
        quest_manager.import_progress(saved_data.quest_progress)

```

---

**章节完成状态**: ✅ 第一章完整  
**下一步**: PART 2 - 即时探索与触发机制
