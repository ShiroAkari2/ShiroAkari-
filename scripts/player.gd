extends CharacterBody2D
signal died

const SWORD_RANGE := 34.0   # jangkauan serangan pedang (px)
const SWORD_ARC := 0.9      # radian ke tiap sisi dari arah hadap
const SWORD_COOLDOWN := 0.35
const MAGIC_COOLDOWN := 0.6
const MANA_REGEN := 0.5     # mana per detik
const SWING_TIME := 0.32    # lama animasi tebasan
const CAST_TIME := 0.3      # lama animasi sihir
const FOOT := 12.0          # jarak kaki karakter dari titik tengah node

var speed := 110.0
var facing := Vector2.DOWN
var inv_time := 0.0
var sword_t := 0.0
var sword_cd := 0.0
var magic_cd := 0.0
var kb := Vector2.ZERO
var swing_t := 0.0
var cast_t := 0.0
var anim_t := 0.0
var moving := false
var meta: Dictionary = {}
var tex := {}

func _ready():
    add_to_group("player")
    set("y_sort_origin", int(FOOT))   # urutan gambar mengikuti kaki (lihat y_sort_enabled di scene)
    collision_layer = 2   # pemain di layer 2: tidak saling dorong dengan musuh (layer 4)
    collision_mask = 1    # hanya bertabrakan dengan tembok
    var c := CollisionShape2D.new()
    var s := CircleShape2D.new()
    s.radius = 6.0
    c.shape = s
    c.position = Vector2(0, 6)
    add_child(c)
    _load_tex()

# Sprite: assets/player/<kunci>_<nomor>.png, daftar kunci & titik kaki ada di player_meta.gd
func _load_tex():
    meta = preload("res://scripts/player_meta.gd").META
    for k in meta:
        var arr := []
        for i in int(meta[k]["n"]):
            var p := "res://assets/player/%s_%d.png" % [k, i]
            arr.append(load(p) if ResourceLoader.exists(p) else null)
        tex[k] = arr

func _physics_process(delta):
    anim_t += delta
    inv_time = maxf(0.0, inv_time - delta)
    sword_t = maxf(0.0, sword_t - delta)
    sword_cd = maxf(0.0, sword_cd - delta)
    magic_cd = maxf(0.0, magic_cd - delta)
    swing_t = maxf(0.0, swing_t - delta)
    cast_t = maxf(0.0, cast_t - delta)
    modulate.a = 0.4 if (inv_time > 0.0 and int(inv_time * 10.0) % 2 == 0) else 1.0
    if Game.input_locked:
        velocity = Vector2.ZERO
        moving = false
        move_and_slide()
        queue_redraw()
        return
    var dir := Input.get_vector("left", "right", "up", "down")
    moving = dir != Vector2.ZERO
    if moving:
        if absf(dir.x) > absf(dir.y):
            facing = Vector2(signf(dir.x), 0)
        else:
            facing = Vector2(0, signf(dir.y))
    velocity = dir * speed + kb
    kb = kb.move_toward(Vector2.ZERO, 700.0 * delta)
    move_and_slide()
    Game.mana = minf(float(Game.max_mana()), Game.mana + MANA_REGEN * delta)
    if Input.is_action_just_pressed("sword") and sword_cd <= 0.0:
        _sword()
    if Input.is_action_just_pressed("magic") and magic_cd <= 0.0:
        _magic()
    queue_redraw()

func _sword():
    sword_t = 0.18
    swing_t = SWING_TIME
    sword_cd = SWORD_COOLDOWN
    for e in get_tree().get_nodes_in_group("enemy"):
        var d: Vector2 = e.global_position - global_position
        if d.length() <= SWORD_RANGE + e.radius + 1.0 and absf(angle_difference(facing.angle(), d.angle())) <= SWORD_ARC:
            e.hit(Game.sword_damage(), global_position, 0.0)

func _magic():
    if Game.mana < 1.0:
        return
    Game.mana -= 1.0
    magic_cd = MAGIC_COOLDOWN
    cast_t = CAST_TIME
    var p = preload("res://scripts/projectile.gd").new()
    p.position = position + facing * 12.0
    p.dir = facing
    get_parent().add_child(p)

func damage(amount: int = 1, from: Vector2 = Vector2.ZERO):
    if inv_time > 0.0:
        return
    Game.hp -= amount
    inv_time = 1.0
    if from != Vector2.ZERO:
        kb = (global_position - from).normalized() * 180.0
    if Game.hp <= 0:
        Game.hp = 0
        died.emit()

func _dirname() -> String:
    if facing.x < 0.0:
        return "left"
    if facing.x > 0.0:
        return "right"
    if facing.y < 0.0:
        return "up"
    return "down"

# Mengembalikan [kunci_animasi, nomor_frame]
func _pick() -> Array:
    var d := _dirname()
    if inv_time > 0.75:
        return ["hurt", 0 if inv_time > 0.88 else 1]
    if swing_t > 0.0:
        var ks := "sword_" + d
        var ns: int = meta[ks]["n"]
        return [ks, clampi(int((1.0 - swing_t / SWING_TIME) * ns), 0, ns - 1)]
    if cast_t > 0.0:
        var kc := "cast_" + d
        var nc: int = meta[kc]["n"]
        return [kc, clampi(int((1.0 - cast_t / CAST_TIME) * nc), 0, nc - 1)]
    if moving:
        var kw := "walk_" + d
        return [kw, int(anim_t * 9.0) % int(meta[kw]["n"])]
    var ki := "idle_" + d
    return [ki, int(anim_t * 2.0) % int(meta[ki]["n"])]

func _draw():
    draw_set_transform(Vector2(0, FOOT), 0.0, Vector2(1.0, 0.35))
    draw_circle(Vector2.ZERO, 9.0, Color(0, 0, 0, 0.25))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if meta.is_empty():
        return
    var pk := _pick()
    var key: String = pk[0]
    var frames: Array = tex.get(key, [])
    var t = frames[pk[1]] if pk[1] < frames.size() else null
    if t == null:
        draw_circle(Vector2(0, -2), 10, Color.WHITE)   # cadangan bila gambar hilang
        return
    var m: Dictionary = meta[key]
    draw_texture(t, Vector2(-float(m["ax"]), FOOT - float(m["ay"])))
