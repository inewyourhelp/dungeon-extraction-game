# 🛠️ 核心系统开发文档

## 📋 目录

- [PlayerController](#playercontroller) - 玩家移动控制器
- [CollisionSystem](#collisionsystem) - 碰撞检测工具类
- [测试场景](#测试场景)

---

## 🏃 PlayerController

**文件位置**: `scripts/core/player_controller.gd`

### 功能特性

✅ **WASD/方向键控制** - 支持键盘输入  
✅ **平滑移动** - 加速度和摩擦力系统  
✅ **动画状态管理** - idle/walking 自动切换  
✅ **碰撞处理** - 使用 CharacterBody2D 内置机制  

### 核心参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `move_speed` | float | 160.0 | 基础移动速度 (像素/秒) |
| `acceleration` | float | 800.0 | 启动加速度 |
| `friction` | float | 800.0 | 停止摩擦力 |
| `idle_animation` | StringName | "idle" | 待机动画名称 |
| `walking_animation` | StringName | "walking" | 行走动画名称 |

### 使用示例

```gdscript
# 1. 将 PlayerController 脚本挂载到 CharacterBody2D 节点上
# 2. 配置参数 (在 Inspector 面板或代码中)
@export var move_speed: float = 200.0

# 3. 运行游戏，使用 WASD 或方向键控制移动
```

### 动画集成

需要为角色准备两个动画：
- `idle`: 待机状态 (无输入时播放)
- `walking`: 行走状态 (有输入时播放)

可以在 AnimationPlayer 节点中定义这些动画。

---

## 🧱 CollisionSystem

**文件位置**: `scripts/core/collision_system.gd`

### 功能特性

✅ **射线检测** - 检查前方是否有墙壁  
✅ **圆形碰撞** - 适合角色包围盒检测  
✅ **自动修正** - 防止穿墙，提供反弹效果  
✅ **单例模式** - 全局可访问的工具类  

### 核心函数

#### `check_wall_collision()`
```gdscript
var result = CollisionSystem.check_wall_collision(
	raycaster,           # RayCast2D 实例
	start_position,      # Vector2: 射线起点
	direction,           # Vector2: 检测方向 (归一化)
	max_distance,        # float: 最大检测距离
	collision_mask       # int: 碰撞掩码 (可选)
)

# 返回结果：
{
	is_blocked = true/false,
	collision_point = Vector2(100, 200),
	distance = 50.0,
	surface_normal = Vector2.RIGHT
}
```

#### `check_circle_wall_collision()`
```gdscript
var result = CollisionSystem.check_circle_wall_collision(
	circle_shape,        # CircleShape2D: 圆形形状
	global_position,     # Vector2: 圆心坐标
	collision_layer,     # int: 自身碰撞层
	collision_mask       # int: 目标碰撞掩码
)

# 返回结果：
{
	has_collision = true/false,
	colliding_objects = [RID1, RID2],
	penetration_depth = 5.0
}
```

#### `resolve_wall_collision()`
```gdscript
var new_velocity = CollisionSystem.resolve_wall_collision(
	character,           # CharacterBody2D: 角色实例
	collision_data,      # Dictionary: 碰撞数据
	bounce_factor        # float: 反弹系数 (0.3)
)

# 返回修正后的速度向量，用于防止穿墙
```

---

## 🧪 测试场景

### PlayerCharacter 场景
**文件**: `scenes/player_character.tscn`

包含：
- CharacterBody2D 根节点
- Sprite2D (角色精灵)
- CollisionShape2D (碰撞形状)
- AnimationPlayer (动画控制)

**使用方法**:
1. 在 Godot 编辑器中打开场景
2. 将 Sprite2D 纹理替换为实际角色图片
3. 配置动画名称参数
4. 运行测试移动效果

### TestDungeon 场景
**文件**: `scenes/test_dungeon.tscn`

包含：
- PlayerSpawn (玩家出生点)
- Walls (四面墙壁，用于碰撞测试)
- Obstacle (中央障碍物)
- CollisionSystem (工具类节点)

**使用方法**:
1. 加载场景后，在 Inspector 中配置 PlayerCharacter
2. 运行游戏，验证：
   - ✅ WASD/方向键控制移动
   - ✅ 碰到墙壁会停下
   - ✅ 不会穿墙
   - ✅ 动画状态切换正常

---

## 📝 开发规范

### 命名约定
- **变量**: snake_case (如 `move_speed`)
- **常量**: UPPER_SNAKE_CASE (如 `MAX_SPEED`)
- **函数**: snake_case (如 `_get_input_direction()`)
- **类名**: PascalCase (如 `PlayerController`)

### 注释规范
```gdscript
# 单行注释：简要说明
@export var move_speed: float = 160.0 \
	"""多行文档字符串：详细说明参数用途"""

# 私有变量前加下划线：_current_animation
# 公共接口无需下划线：set_debug_mode()
```

### 代码质量检查清单
- [ ] 所有导出参数都有文档注释
- [ ] 函数有清晰的参数和返回值说明
- [ ] 核心逻辑有中文注释解释
- [ ] 变量命名语义清晰
- [ ] 没有硬编码的魔法值 (使用 @export)

---

## 🔧 调试技巧

### 启用调试视图
```gdscript
# 在 PlayerController 中
player_controller.set_debug_mode(true)
# 或直接在 Inspector 面板勾选 "Debug Show Hitbox"
```

### 查看碰撞信息
```gdscript
# 在 _physics_process 中添加日志
if Input.is_action_just_pressed("ui_page_down"):
	print("[DEBUG] Velocity:", velocity)
	print("[DEBUG] Is Moving:", _is_moving)
```

---

## 🚀 下一步开发

- [ ] **Phase 2**: 添加跳跃/攀爬动作
- [ ] **Phase 3**: 集成动画状态机 (Animator)
- [ ] **Phase 4**: 添加敌人碰撞检测
- [ ] **Phase 5**: 实现物品拾取系统

---

*🛠️ 缮治开发 | Agent Team 程序开发工程师*  
*最后更新：2026-03-18*
