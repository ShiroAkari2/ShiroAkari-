extends Node2D
# Jalan ke Skotice (nomor 3 di peta dunia): jalan hutan antara Desa dan Kota Skotice.
# Latar: assets/jalan_bg.png (1024x577). Area jalan: assets/jalan_mask.png (256x145, 1 piksel = 4x4 px peta;
# PUTIH = bisa dilewati, HITAM = terblokir). Mau ubah area jalan? Edit PNG mask saja.
# Jalan keluar:
#   ujung barat (kiri, jalan tanah)     -> Desa
#   tangga kanan atas (gerbang Skotice) -> Kota Skotice
#   jalan kanan bawah (tangga bawah)    -> Padang Latihan (setelah mendaftar di Marla)
const MAP_W := 1024
const MAP_H := 577
const CELL := 4
var player
var hud
var gate_cd := 0.0

func _ready():
    Game.in_game = true
    y_sort_enabled = true   # yang lebih ke bawah digambar di depan
    Game.input_locked = false
    var bg := Sprite2D.new()
    bg.texture = load("res://assets/jalan_bg.png")
    bg.centered = false
    bg.z_index = -10
    add_child(bg)
    _build_walls()
    player = preload("res://scripts/player.gd").new()
    player.position = Game.jalan_entry
    Game.jalan_entry = Vector2(140, 392)
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
    hud.notice("Jalan ke Skotice - ikuti jalan ke kanan atas", 3.0)
    if DisplayServer.is_touchscreen_available():
        add_child(preload("res://scripts/touch_controls.gd").new())

# Ubah mask jalan menjadi persegi tabrakan (baris sel hitam digabung supaya sedikit).
func _build_walls():
    var tex: Texture2D = load("res://assets/jalan_mask.png")
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

func _process(delta):
    if Game.busy:
        return
    gate_cd = maxf(0.0, gate_cd - delta)
    if Input.is_action_just_pressed("world_map"):
        Game.toggle_world_map(self, 3)
    if Input.is_action_just_pressed("ui_cancel"):
        Game.save_game()
        Game.in_game = false
        Game.input_locked = false
        Game.goto("res://scenes/Menu.tscn")
        return
    var p: Vector2 = player.position
    if p.x < 104.0 and p.y > 366.0 and p.y < 412.0:
        Game.desa_entry = Vector2(922, 95)   # kembali ke Desa lewat tangga kanan atas
        Game.save_game()
        Game.goto("res://scenes/Desa.tscn")
    elif p.y < 166.0 and p.x > 790.0 and p.x < 940.0:
        Game.skotice_entry = Vector2(320, 905)   # masuk kota lewat gerbang bawah
        Game.save_game()
        Game.goto("res://scenes/Skotice.tscn")
    elif p.y > 566.0 and p.x > 820.0 and p.x < 872.0 and gate_cd <= 0.0:
        if Game.flags.get("registered", false):
            Game.save_game()
            Game.goto("res://scenes/Field.tscn")
        else:
            gate_cd = 3.0
            player.position.y = 530.0
            hud.notice("Daftar dulu di Guild Skotice sebelum ke Padang Latihan", 3.0)
