extends Node2D
# Desa (map penuh): alun-alun dengan Balai Desa. Tiga jalan keluar sesuai peta dunia (nomor 2):
#   barat (tepi kiri, label "Rumah")        -> Rumah pemain
#   utara-timur (tangga kanan atas)          -> Jalan ke Skotice (lalu Kota Skotice)
#   selatan (bawah tengah)                   -> Kota Meldon (belum dibuat)
# Latar: assets/desa_bg.png (1024x685). Kotak tabrakan ada di WALLS (koordinat gambar).
# Jembatan kayu di kanan bawah sengaja ditutup (hanya hiasan, bukan jalan keluar).
const MAP_W := 1024
const MAP_H := 685
const WALLS := [
    Rect2(0, 0, 884, 60), Rect2(960, 0, 64, 60), Rect2(0, 60, 230, 95), Rect2(175, 60, 150, 95),
    Rect2(216, 168, 194, 95), Rect2(385, 72, 70, 95), Rect2(462, 165, 156, 82), Rect2(618, 90, 110, 80),
    Rect2(683, 152, 178, 102), Rect2(508, 284, 76, 62), Rect2(294, 328, 114, 94), Rect2(132, 362, 115, 95),
    Rect2(672, 320, 156, 98), Rect2(886, 335, 100, 82), Rect2(803, 453, 70, 80), Rect2(0, 308, 132, 252),
    Rect2(0, 470, 495, 215), Rect2(608, 540, 416, 145), Rect2(610, 462, 190, 78), Rect2(870, 540, 70, 145),
    Rect2(985, 60, 39, 625), Rect2(285, 458, 145, 14), Rect2(872, 420, 113, 120), Rect2(0, 155, 215, 118)]
var player
var hud
var gate_cd := 0.0

func _ready():
    Game.in_game = true
    y_sort_enabled = true   # yang lebih ke bawah digambar di depan
    Game.input_locked = false
    var bg := Sprite2D.new()
    bg.texture = load("res://assets/desa_bg.png")
    bg.centered = false
    bg.z_index = -10
    add_child(bg)
    for r in WALLS:
        _wall(r)
    player = preload("res://scripts/player.gd").new()
    player.position = Game.desa_entry
    Game.desa_entry = Vector2(34, 292)
    add_child(player)
    var cam := Camera2D.new()
    cam.limit_left = 0
    cam.limit_top = 0
    cam.limit_right = MAP_W
    cam.limit_bottom = MAP_H
    cam.position_smoothing_enabled = true
    cam.position_smoothing_speed = 8.0
    player.add_child(cam)
    cam.make_current()
    cam.reset_smoothing()
    hud = preload("res://scripts/hud.gd").new()
    add_child(hud)
    hud.notice("Desa - barat: Rumah, utara-timur: Jalan ke Skotice, selatan: Kota Meldon", 3.5)
    if DisplayServer.is_touchscreen_available():
        add_child(preload("res://scripts/touch_controls.gd").new())

func _wall(r: Rect2):
    var b := StaticBody2D.new()
    var c := CollisionShape2D.new()
    var s := RectangleShape2D.new()
    s.size = r.size
    c.shape = s
    b.position = r.position + r.size / 2.0
    b.add_child(c)
    add_child(b)

func _process(delta):
    if Game.busy:
        return
    gate_cd = maxf(0.0, gate_cd - delta)
    if Input.is_action_just_pressed("world_map"):
        Game.toggle_world_map(self, 2)
    if Input.is_action_just_pressed("ui_cancel"):
        Game.save_game()
        Game.in_game = false
        Game.input_locked = false
        Game.goto("res://scenes/Menu.tscn")
        return
    var p: Vector2 = player.position
    if p.x < 8.0 and p.y > 262.0 and p.y < 318.0:
        Game.rumah_entry = Vector2(600, 810)   # pulang lewat jalan tanah
        Game.save_game()
        Game.goto("res://scenes/Rumah.tscn")
    elif p.y < 22.0 and p.x > 884.0 and p.x < 960.0:
        Game.jalan_entry = Vector2(140, 392)   # tangga kanan atas = Jalan ke Skotice (masuk dari barat)
        Game.save_game()
        Game.goto("res://scenes/Jalan.tscn")
    elif p.y > 660.0 and p.x > 495.0 and p.x < 610.0 and gate_cd <= 0.0:
        gate_cd = 3.0
        player.position.y = 620.0
        hud.notice("Jalan ke Kota Meldon belum bisa dilalui", 2.5)
