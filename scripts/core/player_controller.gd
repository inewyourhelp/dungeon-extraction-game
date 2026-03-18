# player_controller.gd - 玩家控制器
# 🛠️ 缮治开发 | Agent Team 程序开发工程师
# 负责：WASD/方向键控制英雄移动，平滑移动，动画状态

extends CharacterBody2D

## ============================================
## 配置参数
## ============================================

@export_group("🏃 移动设置")

@export var move_speed: float = 160.0 \
	"""基础移动速度 (像素/秒)"""

@export var acceleration: float = 800.0 \
	"""加速度，控制启动/停止的平滑度"""

@export var friction: float = 800.0 \
	"""摩擦力，减速时的衰减率"""

@export_group("🎭 动画状态")

@export var idle_animation: StringName = "idle" \
	"""待机动画名称"""

@export var walking_animation: StringName = "walking" \
	"""行走动画名称"""

@export_group("👁️ 调试信息")

@export var debug_show_hitbox: bool = false \
	"""是否显示碰撞箱调试视图"""


## ============================================
## 私有变量
## ============================================

var _current_animation: StringName = idle_animation \
	"""当前播放的动画名称"""

var _is_moving: bool = false \
	"""是否正在移动"""

var _direction: Vector2 = Vector2.ZERO \
	"""当前移动方向 (归一化)"""


## ============================================
## 节点引用
## ============================================

@onready_var sprite_2d: Sprite2D = $Sprite2D \
	"""角色精灵组件"""

@onready_var animation_player: AnimationPlayer = $AnimationPlayer \
	"""动画播放器组件"""

@onready_var collision_shape: CollisionShape2D = $CollisionShape2D \
	"""碰撞形状组件"""


## ============================================
## 生命周期函数
## ============================================

func _ready() -> void:
	"""节点就绪时初始化"""
	# 设置初始动画状态
	if animation_player and has_node(animation_player):
		animation_player.play(_current_animation)
	
	print("[🛠️ PlayerController] 玩家控制器已就绪")


func _physics_process(delta: float) -> void:
	"""物理更新循环 (60FPS)"""
	# 1. 获取输入方向
	_direction = _get_input_direction()
	
	# 2. 应用平滑移动
	_apply_movement(delta)
	
	# 3. 更新动画状态
	_update_animation_state()
	
	# 4. 执行移动并处理碰撞
	if move():
		pass  # 移动成功，无需额外操作
	
	# 5. 调试视图
	_debug_render()


## ============================================
## 核心逻辑
## ============================================

func _get_input_direction() -> Vector2:
	"""
	获取玩家输入的方向 (归一化)
	
	Returns:
		Vector2: 归一化的移动方向，无输入时返回 ZERO
	"""
	var input_vector := Vector2.ZERO
	
	# WASD / 方向键
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	elif Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	elif Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	
	# 归一化：防止斜向移动速度过快
	if input_vector.length() > 0.0:
		input_vector = input_vector.normalized()
	
	return input_vector


func _apply_movement(delta: float) -> void:
	"""
	应用平滑移动效果 (加速度/摩擦力)
	
	Args:
		delta: 帧时间间隔
	"""
	var target_velocity := _direction * move_speed
	
	if velocity.length() > 0.0:
		# 正在移动：使用插值实现平滑加速/减速
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# 静止状态：快速对齐目标速度 (避免启动延迟)
		velocity = target_velocity
	
	# 处理停止时的摩擦力
	if _direction.length() == 0.0 and velocity.length() > 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func _update_animation_state() -> void:
	"""更新动画播放状态"""
	var is_now_moving := _direction.length() > 0.5
	
	# 只在动画状态变化时切换 (避免频繁重播)
	if _is_moving != is_now_moving and animation_player:
		_is_moving = is_now_moving
		
		if _is_moving:
			animation_player.play(walking_animation)
			_current_animation = walking_animation
		else:
			animation_player.play(idle_animation)
			_current_animation = idle_animation


func move() -> bool:
	"""
	执行移动并处理碰撞
	
	Returns:
		bool: 是否成功移动 (没有遇到不可逾越的障碍)
	"""
	var moved := false
	
	# 尝试 X 轴移动
	if velocity.x != 0.0:
		velocity.x = velocity.x / move_speed * move_speed  # 归一化 X 速度
		move_and_slide()
		moved = true
	
	# 尝试 Y 轴移动
	if velocity.y != 0.0:
		velocity.y = velocity.y / move_speed * move_speed  # 归一化 Y 速度
		move_and_slide()
		moved = true
	
	return moved


## ============================================
## 调试功能
## ============================================

func _debug_render() -> void:
	"""显示碰撞箱调试视图 (仅开发环境)"""
	if not debug_show_hitbox or not collision_shape:
		return
	
	# 在编辑器中高亮显示碰撞形状
	collision_shape.modulate = Color.YELLOW if _is_moving else Color.GREEN


## ============================================
## 公共接口
## ============================================

func set_debug_mode(enabled: bool) -> void:
	"""开启/关闭调试模式"""
	debug_show_hitbox = enabled
	print("[🛠️ PlayerController] 调试模式：", "ON" if enabled else "OFF")


func get_velocity() -> Vector2:
	"""获取当前速度向量"""
	return velocity


func set_speed(new_speed: float) -> void:
	"""动态调整移动速度"""
	move_speed = max(0.0, new_speed)
	print("[🛠️ PlayerController] 速度调整为：", move_speed)
