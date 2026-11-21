extends Node2D
# Padang Latihan: tempat bertarung (musuh muncul di sini, bukan di guild). Satu layar, tanpa kamera bergulir.
# Gambar masih digambar lewat kode; ganti dengan gambar peta kapan saja.
const MAX_ALIVE := 4
const SPAWN_EVERY := 6.0
const ENEMY := preload("res://scripts/enemy.gd")
const BOSS_KIND := "death_knight"
const BOSS_MIN_LEVEL := 9
const BOSS_EVERY := 50.0
const WALLS := [Rect2(0, 0, 300, 20), Rect2(340, 0, 300, 20), Rect2(0, 0, 20, 360), Rect2(620, 0, 20, 360), Rect2(0, 340, 640, 20)]
var player
var hud
var spawn_t := 2.0
var boss_t := 25.0

func _ready():
    Game.in_game = true
    y_sort_enabled = true   # yang lebih ke bawah digambar di depan
    Game.input_locked = false
    for r in WALLS:
        _wall(r)
    player = preload("res://scripts/player.gd").new()
    player.position = Vector2(320, 70)
    add_child(player)
    player.died.connect(_on_died)
    hud = preload("res://scripts/hud.gd").new()
    add_child(hud)
    hud.notice("Padang Latihan - jalan ke atas untuk kembali ke Jalan ke Skotice", 3.0)
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
    if Input.is_action_just_pressed("world_map"):
        Game.toggle_world_map(self, 3)
    if Game.busy:
        return
    if Input.is_action_just_pressed("ui_cancel"):
        Game.save_game()
        Game.in_game = false
        Game.input_locked = false
        Game.goto("res://scenes/Menu.tscn")
        return
    if player.position.y < 14.0:
        Game.jalan_entry = Vector2(848, 530)   # kembali ke Jalan ke Skotice
        Game.save_game()
        Game.goto("res://scenes/Jalan.tscn")
        return
    _update_spawner(delta)

func _update_spawner(delta):
    if Game.input_locked:
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
            boss_t = 5.0
            return
    boss_t = BOSS_EVERY
    if _spawn_enemy(BOSS_KIND):
        hud.notice("Ksatria Maut muncul!", 2.5)

func _spawn_enemy(kind: String) -> bool:
    for i in 12:
        var pos := Vector2(randf_range(40.0, 600.0), randf_range(90.0, 320.0))
        if pos.distance_to(player.position) < 130.0:
            continue
        var e = ENEMY.new()
        e.kind = kind
        e.position = pos
        add_child(e)
        return true
    return false

func _on_died():
    Game.death_penalty()
    Game.heal_full()
    Game.guild_entry = Vector2(320, 760)
    Game.pending_notice = "Kamu pingsan... 25% XP level ini hilang"
    Game.save_game()
    Game.goto("res://scenes/Guild.tscn")

func _draw():
    draw_rect(Rect2(0, 0, 640, 360), Color("86c27a"))
    var rng := RandomNumberGenerator.new()
    rng.seed = 7
    for i in 70:
        draw_circle(Vector2(rng.randf_range(10, 630), rng.randf_range(30, 350)), rng.randf_range(6, 16), Color("7cb872"))
    draw_rect(Rect2(300, 0, 40, 110), Color("d8c79a"))   # jalan setapak ke guild
    for i in 55:
        var p := Vector2(rng.randf_range(24, 616), rng.randf_range(40, 330))
        draw_line(p, p + Vector2(-2, -5), Color("5e9b58"), 1.0)
        draw_line(p, p + Vector2(2, -5), Color("5e9b58"), 1.0)
    for x in range(10, 640, 26):   # pohon di tepi
        if x < 290 or x > 350:
            draw_circle(Vector2(x, 10), 13, Color("3f7d46"))
        draw_circle(Vector2(x, 352), 13, Color("3f7d46"))
    for y in range(36, 340, 26):
        draw_circle(Vector2(10, y), 13, Color("3f7d46"))
        draw_circle(Vector2(630, y), 13, Color("3f7d46"))
