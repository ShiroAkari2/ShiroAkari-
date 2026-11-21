extends CanvasLayer
# Peta dunia (tekan M untuk membuka/menutup). Panah / WASD untuk menggeser.
# Gambar 1280x720 digeser di dalam layar 640x360. 'here' = nomor lokasi pemain (diisi pemanggil).
const MAP_W := 1280.0
const MAP_H := 720.0
const VIEW_W := 640.0
const VIEW_H := 360.0
# Posisi nomor lokasi pada gambar 1280x720 (nama lokasi tertulis di gambarnya).
const NODES := {
    1: Vector2(113, 216), 2: Vector2(238, 255), 3: Vector2(389, 148), 4: Vector2(548, 185),
    5: Vector2(250, 362), 6: Vector2(380, 434), 7: Vector2(589, 349), 8: Vector2(726, 434),
    9: Vector2(845, 349), 10: Vector2(726, 301), 11: Vector2(952, 391), 12: Vector2(977, 243),
    13: Vector2(1086, 405), 14: Vector2(1148, 330), 15: Vector2(1155, 242), 16: Vector2(1160, 157),
    17: Vector2(726, 575)}
var here := 4          # 4 = Kota Skotice (guild)
var map: TextureRect
var marker: Node2D
var cam := Vector2.ZERO

func _ready():
    layer = 50
    add_to_group("world_map")
    Game.input_locked = true
    map = TextureRect.new()
    map.expand_mode = TextureRect.EXPAND_IGNORE_SIZE   # urutan penting: atur sebelum texture & size
    map.stretch_mode = TextureRect.STRETCH_SCALE
    map.texture = load("res://assets/world_map.png")
    map.size = Vector2(MAP_W, MAP_H)
    add_child(map)
    marker = Node2D.new()
    marker.set_script(preload("res://scripts/world_marker.gd"))
    add_child(marker)
    var hint := Label.new()
    hint.text = "Panah: geser peta    M: tutup"
    hint.position = Vector2(8, 336)
    hint.add_theme_font_size_override("font_size", 12)
    hint.add_theme_color_override("font_outline_color", Color(0.1, 0.12, 0.25))
    hint.add_theme_constant_override("outline_size", 4)
    add_child(hint)
    var p: Vector2 = NODES.get(here, Vector2(MAP_W / 2.0, MAP_H / 2.0))
    cam = _clamp_cam(p - Vector2(VIEW_W, VIEW_H) / 2.0)
    _apply()

func _clamp_cam(c: Vector2) -> Vector2:
    return Vector2(clampf(c.x, 0.0, MAP_W - VIEW_W), clampf(c.y, 0.0, MAP_H - VIEW_H))

func _apply():
    map.position = -cam
    marker.position = NODES.get(here, Vector2(-100, -100)) - cam

func _process(delta):
    cam = _clamp_cam(cam + Input.get_vector("left", "right", "up", "down") * 260.0 * delta)
    _apply()

func _exit_tree():
    Game.input_locked = false
