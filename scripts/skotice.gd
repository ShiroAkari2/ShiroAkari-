extends Node2D
# Kota Skotice (peta B): zona aman tanpa musuh. Kamera mengikuti pemain.
# Latar: assets/skotice_bg.png (640x960).
# Area jalan: assets/skotice_mask.png (80x120, tiap piksel = 8x8 px peta; PUTIH = bisa dilewati, HITAM = terblokir).
# Mau ubah area jalan? Edit PNG mask itu saja, tidak perlu ubah kode.
const MAP_W := 640
const MAP_H := 960
const CELL := 8
const DOOR_X := 320.0       # pintu Guild Petualang (atas)
const DOOR_HALF := 26.0
const DOOR_Y := 142.0       # pemain melewati garis ini ke atas = masuk Guild
const EXIT_Y := 938.0       # melewati garis ini ke bawah = keluar kota ke Padang Latihan
var player
var hud

func _ready():
    Game.in_game = true
    y_sort_enabled = true   # yang lebih ke bawah digambar di depan
    Game.input_locked = false
    var bg := Sprite2D.new()
    bg.texture = load("res://assets/skotice_bg.png")
    bg.centered = false
    bg.z_index = -10
    add_child(bg)
    _build_walls()
    player = preload("res://scripts/player.gd").new()
    player.position = Game.skotice_entry
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
    hud.notice("Kota Skotice - gerbang bawah: Jalan ke Desa dan Padang Latihan", 3.0)
    if DisplayServer.is_touchscreen_available():
        add_child(preload("res://scripts/touch_controls.gd").new())

# Ubah mask jalan menjadi persegi tabrakan (baris sel hitam digabung supaya sedikit).
func _build_walls():
    var tex: Texture2D = load("res://assets/skotice_mask.png")
    var img: Image = tex.get_image()
    var w := img.get_width()
    var h := img.get_height()
    var is_open := func(x: int, y: int) -> bool:
        return img.get_pixel(x, y).r > 0.5
    var rects := []   # [x, y, lebar, tinggi] dalam satuan sel
    var prev := {}    # "x,lebar" -> indeks di rects (untuk digabung ke atas)
    for y in h:
        var cur := {}
        var x := 0
        while x < w:
            if is_open.call(x, y):
                x += 1
                continue
            var x2 := x
            while x2 < w and not is_open.call(x2, y):
                x2 += 1
            var key := "%d,%d" % [x, x2 - x]
            if prev.has(key):
                rects[prev[key]][3] += 1
                cur[key] = prev[key]
            else:
                rects.append([x, y, x2 - x, 1])
                cur[key] = rects.size() - 1
            x = x2
        prev = cur
    var body := StaticBody2D.new()
    for r in rects:
        var c := CollisionShape2D.new()
        var s := RectangleShape2D.new()
        s.size = Vector2(r[2], r[3]) * CELL
        c.shape = s
        c.position = Vector2(r[0], r[1]) * CELL + s.size / 2.0
        body.add_child(c)
    add_child(body)

func _process(_delta):
    if Game.busy:
        return
    if Input.is_action_just_pressed("world_map"):
        Game.toggle_world_map(self)
    if Input.is_action_just_pressed("ui_cancel"):
        Game.save_game()
        Game.in_game = false
        Game.input_locked = false
        Game.goto("res://scenes/Menu.tscn")
        return
    var p: Vector2 = player.position
    if p.y < DOOR_Y and absf(p.x - DOOR_X) < DOOR_HALF:
        Game.guild_entry = Vector2(320, 850)
        Game.save_game()
        Game.goto("res://scenes/Guild.tscn")
    elif p.y > EXIT_Y:
        Game.jalan_entry = Vector2(858, 238)   # gerbang bawah = Jalan ke Skotice (Desa & Padang Latihan)
        Game.save_game()
        Game.goto("res://scenes/Jalan.tscn")
