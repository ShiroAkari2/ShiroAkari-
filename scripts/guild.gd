extends Node2D
const SPAWN := Vector2(320, 260)          # cukup jauh dari pintu agar tidak salah interaksi
const MAX_ALIVE := 4                      # batas slime hidup bersamaan di Arena Latihan
const SPAWN_EVERY := 6.0                  # detik antar kemunculan
const PILLARS := [Rect2(96, 96, 48, 90), Rect2(96, 204, 48, 90), Rect2(496, 96, 48, 90), Rect2(496, 204, 48, 90)]
const COUNTER := Rect2(270, 66, 100, 26)
const ENEMY := preload("res://scripts/enemy.gd")
const BOSS_KIND := "death_knight"
const BOSS_MIN_LEVEL := 9
const BOSS_EVERY := 50.0                  # detik antar kemunculan bos (hanya satu sekaligus)
var player
var hud
var target = null
var spawn_t := 3.0
var boss_t := 25.0

func _ready():
    Game.in_game = true
    Game.input_locked = false
    for r in [Rect2(0, 0, 640, 56), Rect2(0, 0, 16, 360), Rect2(624, 0, 16, 360),
              Rect2(0, 344, 290, 16), Rect2(350, 344, 290, 16), Rect2(290, 350, 60, 10), COUNTER]:
        _wall(r)
    for r in PILLARS:
        _wall(r)
    _npc("Marla", "marla", Color("e8d9a0"), Vector2(320, 60))
    _npc("Sena", "sena", Color("e89a50"), Vector2(200, 150))
    _npc("Dion", "dion", Color("5fa86f"), Vector2(450, 260))
    _npc("Elda", "elda", Color("6a7fd0"), Vector2(260, 320))
    _npc("Kolam Cahaya", "kolam", Color.WHITE, Vector2(320, 175), "pond")
    _npc("", "pintu", Color("8a5a3a"), Vector2(320, 338), "door")
    player = preload("res://scripts/player.gd").new()
    player.position = SPAWN
    add_child(player)
    player.died.connect(_on_died)
    hud = preload("res://scripts/hud.gd").new()
    add_child(hud)
    hud.dialog_finished.connect(_on_dialog_done)
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

func _npc(n: String, id: String, col: Color, pos: Vector2, kind := "npc"):
    var o = preload("res://scripts/npc.gd").new()
    o.npc_name = n
    o.dialog_id = id
    o.color = col
    o.position = pos
    o.kind = kind
    add_child(o)
    return o

func _nearest_npc():
    var best = null
    var bd := 52.0
    for n in get_tree().get_nodes_in_group("npc"):
        var d: float = n.global_position.distance_to(player.global_position)
        if d < bd:
            bd = d
            best = n
    return best

# Arena Latihan: terbuka setelah mendaftar di Marla. Jenis musuh menyesuaikan level pemain
# (lihat Enemy.kinds_for_level); mulai level 9 Ksatria Maut muncul berkala sebagai bos.
func _update_spawner(delta):
    if not Game.flags.get("registered", false) or Game.input_locked:
        return
    _update_boss(delta)
    spawn_t -= delta
    if spawn_t > 0.0:
        return
    spawn_t = SPAWN_EVERY
    var alive := 0
    for e in get_tree().get_nodes_in_group("enemy"):
        if e.kind != BOSS_KIND:
            alive += 1
    if alive >= MAX_ALIVE:
        return
    var pool: Array = ENEMY.kinds_for_level(Game.level)
    _spawn_enemy(pool[randi() % pool.size()])

func _update_boss(delta):
    if Game.level < BOSS_MIN_LEVEL:
        return
    boss_t -= delta
    if boss_t > 0.0:
        return
    for e in get_tree().get_nodes_in_group("enemy"):
        if e.kind == BOSS_KIND:
            boss_t = 5.0   # bos masih hidup: cek lagi nanti
            return
    boss_t = BOSS_EVERY
    if _spawn_enemy(BOSS_KIND):
        hud.notice("Ksatria Maut muncul!", 2.5)

func _spawn_enemy(kind: String) -> bool:
    for i in 12:
        var pos := Vector2(randf_range(40.0, 600.0), randf_range(110.0, 320.0))
        if pos.distance_to(player.position) < 130.0 or _blocked(pos):
            continue
        var e = ENEMY.new()
        e.kind = kind
        e.position = pos
        add_child(e)
        return true
    return false

func _blocked(pos: Vector2) -> bool:
    if COUNTER.grow(20.0).has_point(pos):
        return true
    for r in PILLARS:
        if r.grow(16.0).has_point(pos):
            return true
    return Vector2(320, 175).distance_to(pos) < 36.0

func _process(delta):
    if Input.is_action_just_pressed("ui_cancel"):
        Game.save_game()
        Game.in_game = false
        Game.input_locked = false
        get_tree().change_scene_to_file("res://scenes/Menu.tscn")
        return
    _update_spawner(delta)
    if hud.active and target and target.global_position.distance_to(player.global_position) > 90.0:
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
        Game.save_game()
        spawn_t = 3.0
        hud.notice("Terdaftar! Arena Latihan dibuka - J pedang, K cahaya", 3.0)
    elif id == "kolam":
        Game.heal_full()
        Game.save_game()
        hud.notice("HP & mana pulih!", 1.5)

func _on_died():
    Game.death_penalty()
    Game.heal_full()
    for e in get_tree().get_nodes_in_group("enemy"):
        e.queue_free()
    player.position = SPAWN
    player.kb = Vector2.ZERO
    player.inv_time = 1.5
    spawn_t = 4.0
    Game.save_game()
    hud.notice("Kamu pingsan... 25% XP level ini hilang", 3.0)

func _draw():
    draw_rect(Rect2(0, 0, 640, 360), Color("b0d4e8"))
    draw_rect(Rect2(0, 0, 640, 56), Color("1f2540"))
    draw_rect(COUNTER, Color("3b4466"))
    for r in PILLARS:
        draw_rect(r, Color("5a6a8a"))
    draw_rect(Rect2(24, 20, 40, 30), Color("7f8fb0"))
    draw_rect(Rect2(576, 20, 40, 30), Color("7f8fb0"))
    draw_rect(Rect2(16, 150, 10, 70), Color("a07850"))
    draw_rect(Rect2(614, 150, 10, 70), Color("a07850"))
    draw_rect(Rect2(0, 344, 290, 16), Color("1f2540"))
    draw_rect(Rect2(350, 344, 290, 16), Color("1f2540"))
