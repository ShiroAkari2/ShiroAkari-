extends Node2D
# Rumah pemain (map penuh): halaman rumah, kandang, kebun, dan jalan tanah ke Desa.
# Latar: assets/rumah_bg.png (640x960). Kotak tabrakan ada di WALLS (koordinat gambar).
# Jalan tanah keluar di tepi kanan bawah = ke Desa (nomor 1 -> 2 di peta dunia).
const MAP_W := 640
const MAP_H := 960
const EXIT_X := 626.0        # melewati garis ini ke kanan (di jalan tanah) = keluar ke Desa
const EXIT_Y_MIN := 760.0
const EXIT_Y_MAX := 880.0
const WALLS := [
    Rect2(0, 0, 640, 188), Rect2(192, 82, 255, 258), Rect2(0, 188, 36, 338), Rect2(612, 188, 28, 338),
    Rect2(54, 318, 138, 138), Rect2(483, 258, 129, 198), Rect2(72, 450, 168, 57), Rect2(393, 450, 96, 57),
    Rect2(30, 500, 236, 24), Rect2(364, 500, 249, 24), Rect2(258, 477, 18, 45), Rect2(366, 477, 18, 45),
    Rect2(68, 567, 150, 168), Rect2(188, 660, 93, 93), Rect2(578, 645, 63, 93), Rect2(0, 732, 412, 168),
    Rect2(0, 592, 60, 105), Rect2(0, 897, 640, 63), Rect2(55, 195, 110, 125), Rect2(412, 795, 40, 40),
    Rect2(450, 815, 50, 40), Rect2(498, 845, 60, 45), Rect2(520, 695, 70, 55)]
var player
var hud

func _ready():
    Game.in_game = true
    y_sort_enabled = true   # yang lebih ke bawah digambar di depan
    Game.input_locked = false
    var bg := Sprite2D.new()
    bg.texture = load("res://assets/rumah_bg.png")
    bg.centered = false
    bg.z_index = -10
    add_child(bg)
    for r in WALLS:
        _wall(r)
    player = preload("res://scripts/player.gd").new()
    player.position = Game.rumah_entry
    Game.rumah_entry = Vector2(320, 430)   # awal berikutnya: di depan pintu rumah
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
    hud.notice("Rumah - ikuti jalan tanah ke kanan bawah menuju Desa", 3.0)
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

func _process(_delta):
    if Game.busy:
        return
    if Input.is_action_just_pressed("world_map"):
        Game.toggle_world_map(self, 1)
    if Input.is_action_just_pressed("ui_cancel"):
        Game.save_game()
        Game.in_game = false
        Game.input_locked = false
        Game.goto("res://scenes/Menu.tscn")
        return
    var p: Vector2 = player.position
    if p.x > EXIT_X and p.y > EXIT_Y_MIN and p.y < EXIT_Y_MAX:
        Game.desa_entry = Vector2(34, 292)   # masuk desa dari barat
        Game.save_game()
        Game.goto("res://scenes/Desa.tscn")
