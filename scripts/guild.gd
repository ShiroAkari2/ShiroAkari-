extends Node2D
# Guild Petualang: zona aman (tanpa musuh). Ruangan lebih tinggi dari layar; kamera mengikuti pemain.
# Gambar latar: assets/guild_bg.png (640x960). Koordinat di bawah mengikuti gambar itu.
const MAP_W := 640
const MAP_H := 960
const EXIT_Y := 915.0   # melewati garis ini di lorong pintu = keluar ke Kota Skotice
const WALLS := [
    Rect2(0, 0, 640, 243),      # dinding atas + meja resepsionis + tangga
    Rect2(0, 0, 38, 960),       # dinding kiri
    Rect2(602, 0, 38, 960),     # dinding kanan
    Rect2(0, 806, 272, 154),    # dinding bawah kiri
    Rect2(368, 806, 272, 154),  # dinding bawah kanan
    Rect2(44, 262, 76, 130),    # papan misi kiri
    Rect2(480, 262, 76, 130),   # papan misi kanan
    Rect2(76, 412, 80, 134), Rect2(76, 574, 80, 134),     # meja panjang kiri
    Rect2(484, 412, 80, 134), Rect2(484, 574, 80, 134)]   # meja panjang kanan
var player
var hud
var target = null
var gate_cd := 0.0
var exit_block = null   # dinding penahan pintu keluar selama belum mendaftar

func _ready():
    Game.in_game = true
    y_sort_enabled = true   # yang lebih ke bawah digambar di depan
    Game.input_locked = false
    var bg := Sprite2D.new()
    bg.texture = load("res://assets/guild_bg.png")
    bg.centered = false
    bg.z_index = -10
    add_child(bg)
    for r in WALLS:
        _wall(r)
    # Marla duduk di balik meja resepsionis (jangkauan bicara lebih jauh karena ada meja)
    var marla = _npc("Marla", "marla", Color("e8d9a0"), Vector2(320, 162), "npc", "res://assets/npc/marla.png")
    marla.reach = 120.0
    _npc("Sena", "sena", Color("e89a50"), Vector2(215, 330), "npc", "res://assets/npc/npc06_pink.png")
    _npc("Dion", "dion", Color("5fa86f"), Vector2(430, 500), "npc", "res://assets/npc/npc01_black.png")
    _npc("Elda", "elda", Color("6a7fd0"), Vector2(250, 745), "npc", "res://assets/npc/npc04_navy.png")
    var papan_kiri = _npc("Papan Pengumuman", "papan", Color.WHITE, Vector2(96, 345), "board")
    papan_kiri.reach = 70.0
    var papan_kanan = _npc("Papan Pengumuman", "papan", Color.WHITE, Vector2(524, 345), "board")
    papan_kanan.reach = 70.0
    var pond = _npc("Kolam Cahaya", "kolam", Color.WHITE, Vector2(320, 495), "pond")
    pond.reach = 40.0
    player = preload("res://scripts/player.gd").new()
    player.position = Game.guild_entry
    Game.guild_entry = Vector2(320, 760)
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
    player.died.connect(_on_died)
    if not Game.flags.get("registered", false):
        exit_block = _wall(Rect2(272, 884, 96, 14))
    hud = preload("res://scripts/hud.gd").new()
    add_child(hud)
    hud.dialog_finished.connect(_on_dialog_done)
    if Game.pending_notice != "":
        hud.notice(Game.pending_notice, 3.0)
        Game.pending_notice = ""
    if DisplayServer.is_touchscreen_available():
        add_child(preload("res://scripts/touch_controls.gd").new())

func _wall(r: Rect2) -> StaticBody2D:
    var b := StaticBody2D.new()
    var c := CollisionShape2D.new()
    var s := RectangleShape2D.new()
    s.size = r.size
    c.shape = s
    b.position = r.position + r.size / 2.0
    b.add_child(c)
    add_child(b)
    return b

func _npc(n: String, id: String, col: Color, pos: Vector2, kind := "npc", sprite := ""):
    var o = preload("res://scripts/npc.gd").new()
    o.npc_name = n
    o.dialog_id = id
    o.color = col
    o.position = pos
    o.kind = kind
    o.sprite_path = sprite
    add_child(o)
    return o

func _nearest_npc():
    var best = null
    var bd := 9999.0
    for n in get_tree().get_nodes_in_group("npc"):
        var d: float = n.global_position.distance_to(player.global_position)
        if d <= n.reach and d < bd:
            bd = d
            best = n
    return best

func _process(delta):
    if Game.busy:
        return
    if Input.is_action_just_pressed("world_map"):
        Game.toggle_world_map(self)
    gate_cd = maxf(0.0, gate_cd - delta)
    if Input.is_action_just_pressed("ui_cancel"):
        Game.save_game()
        Game.in_game = false
        Game.input_locked = false
        Game.goto("res://scenes/Menu.tscn")
        return
    if player.position.y > EXIT_Y and gate_cd <= 0.0:
        if Game.flags.get("registered", false):
            Game.skotice_entry = Vector2(320, 150)
            Game.save_game()
            Game.goto("res://scenes/Skotice.tscn")
            gate_cd = 99.0
            return
        gate_cd = 2.5
        player.position.y = EXIT_Y - 40.0
        hud.notice("Daftar dulu di meja Marla (di bagian atas ruangan)", 3.0)
    elif exit_block != null and player.position.y > 860.0 and gate_cd <= 0.0:
        gate_cd = 3.0
        hud.notice("Daftar dulu di meja Marla (di bagian atas ruangan)", 3.0)
    if hud.active and target and target.global_position.distance_to(player.global_position) > target.reach + 40.0:
        hud.end_dialog()
    if Input.is_action_just_pressed("interact"):
        if hud.active:
            hud.interact()
        else:
            target = _nearest_npc()
            if target:
                hud.start_dialog(target.get_dialog_id())

func _on_dialog_done(id: String):
    if id == "marla_register":
        Game.flags["registered"] = true
        if exit_block != null:
            exit_block.queue_free()
            exit_block = null
        Game.save_game()
        hud.notice("Terdaftar! Pintu keluar ke Kota Skotice terbuka (di bawah)", 3.5)
    elif id == "kolam":
        Game.heal_full()
        Game.save_game()
        hud.notice("HP & mana pulih!", 1.5)

func _on_died():
    Game.death_penalty()
    Game.heal_full()
    player.position = Game.guild_entry
    player.kb = Vector2.ZERO
    player.inv_time = 1.5
    Game.save_game()
    hud.notice("Kamu pingsan... 25% XP level ini hilang", 3.0)
