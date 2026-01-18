extends CanvasLayer
class_name EventAnnouncer

# --- 全局静态单例 (方便任意位置调用) ---
static var instance: EventAnnouncer

# --- 信号系统 ---
# 当一条广播开始播放时
signal announcement_started(title: String)
# 当队列中所有广播播放完毕时
signal all_announcements_finished

# --- 节点绑定 (根据你的截图路径) ---
@onready var banner_container: PanelContainer = $BannerContainer
@onready var title_label: Label = $BannerContainer/ContentBox/TitleLabel
@onready var desc_label: Label = $BannerContainer/ContentBox/DescLabel
# 截图中的 Separator 不需要代码控制，所以不用绑定

# --- 数据结构定义 ---
# 既然颜色已预设，数据只需包含文本信息
class AnnouncementData:
	var title: String
	var description: String

# --- 内部状态 ---
var _queue: Array[AnnouncementData] = []
var _is_playing: bool = false
const DISPLAY_DURATION: float = 5.0 # 硬编码停留时间

# --- 生命周期 ---

func _enter_tree() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()

func _exit_tree() -> void:
	if instance == self:
		instance = null

func _ready() -> void:
	# 初始化：确保面板是不可见的
	# 这里我们修改透明度为0，并缩放为0，为入场动画做准备
	banner_container.modulate.a = 0
	banner_container.scale = Vector2.ZERO
	
	# 【自动化测试入口】
	# 仅在编辑器模式下，且当前是独立运行此场景时触发
#	if OS.has_feature("editor") and get_parent() == get_tree().root:
#		print("--- Debug模式: 启动测试用例 ---")
#		run_debug_test()

# --- 公共 API (Public Methods) ---

## 添加一条新的警告信息到队列
## 样式模仿 Windows 标题栏风格
## @param title: 标题核心词 (例如传入 "Trojan"，显示为 "WARNING Trojan.exe ... X")
## @param description: 详细描述
func show_warning(title: String, description: String) -> void:
	# 1. 构建数据对象
	var data = AnnouncementData.new()
	
	# --- 字符串拼接逻辑 Start ---
	
	# A. 定义左侧前缀 (自动加上 .exe)
	# 修正了你代码中的拼写: WARING -> WARNING
	var prefix_str = "WARNING %s.exe" % title
	
	# B. 定义右侧后缀 (关闭按钮)
	var suffix_str = "X"
	
	# C. 定义这一行总共能容纳多少个字符 (这个数字需要你根据Label宽度和字体大小手动微调)
	# 建议先设为 60 或 80，运行后看看长短再调
	var total_char_capacity = 115
	
	# D. 计算中间需要的空格数量
	# 使用 maxi(5, ...) 是为了兜底：如果标题特别长，导致算出来是负数，
	# 这里的逻辑会强制至少保留 5 个空格，防止前后文字粘在一起
	var space_count = maxi(5, total_char_capacity - prefix_str.length() - suffix_str.length())
	
	# E. 最终拼接: 前缀 + N个空格 + 后缀
	data.title = "%s%s%s" % [prefix_str, " ".repeat(space_count), suffix_str]
	
	# --- 字符串拼接逻辑 End ---
	
	data.description = description
	
	# 2. 加入队列
	_queue.append(data)
	
	# 3. 尝试播放
	if not _is_playing:
		_process_queue()
# --- 内部逻辑 (Private Logic) ---

func _process_queue() -> void:
	if _queue.is_empty():
		_is_playing = false
		all_announcements_finished.emit()
		return
	
	_is_playing = true
	var current_data = _queue.pop_front()
	
	# 设置内容
	title_label.text = current_data.title
	desc_label.text = current_data.description
	
	announcement_started.emit(current_data.title)
	
	# 修正中心点 (防止缩放歪了)
	banner_container.pivot_offset = banner_container.size / 2
	
	# --- 动画序列 (绝对线性版) ---
	var tween = create_tween()
	
	# 默认 Tween 是串行的 (Serial)，这很好，我们要利用这一点
	
	# ============================================
	# 1. [入场阶段]
	# ============================================
	# 主动画：缩放 (0.5秒)
	tween.tween_property(banner_container, "scale", Vector2.ONE, 0.5)\
		.from(Vector2.ZERO)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
		
	# 伴随动画：透明度 (0.3秒)
	# 使用 .parallel()，让它"骑"在上面那个缩放动画身上同时发生
	tween.parallel().tween_property(banner_container, "modulate:a", 1.0, 0.3)
	
	# ============================================
	# 2. [停留阶段]
	# ============================================
	# 因为没加 .parallel()，这行代码必须等上面所有动画都跑完才会开始执行
	# 这就是我们要的"卡住"效果！
	tween.tween_interval(DISPLAY_DURATION)
	
	# ============================================
	# 3. [退场阶段]
	# ============================================
	# 同样，这行代码必须等 interval (5秒) 跑完才会开始
	
	# 主动画：透明度变0 (0.5秒)
	tween.tween_property(banner_container, "modulate:a", 0.0, 0.5)
	
	# 伴随动画：向上飘 (0.5秒)
	# 使用 .parallel()，让它和透明度变化同时发生
	tween.parallel().tween_property(banner_container, "position:y", -50.0, 0.5).as_relative()
	
	# ============================================
	# 4. [收尾]
	# ============================================
	tween.finished.connect(func():
		banner_container.position.y += 50.0 # 归位
		_process_queue()
	)
# --- 🧪 测试代码 ---

func run_debug_test() -> void:
	# 模拟连续触发三个事件，验证队列系统
	
	await get_tree().create_timer(1.0).timeout
	print("测试: 触发第一条警告")
	show_warning("ALARGESUMOFBUGS", "检测到大量bugs正在接近！")
	
	# 模拟短时间内连续调用，验证它们是否会排队而不是重叠
	await get_tree().create_timer(2.0).timeout
	print("测试: 触发第二条警告 (应该进入队列)")
	show_warning("SUPERBOSS", "键盘映射有点问题，怎么回事？")
	
	print("测试: 触发第三条警告 (应该进入队列)")
	show_warning("SYSTEMMSG", "干得好！")
