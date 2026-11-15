extends CharacterBody2D
# Semua musuh digerakkan oleh tabel TYPES (tambah musuh baru = tambah satu baris).
#   beh: "chase" (kejar), "lunge" (kejar lalu menerjang setelah aba-aba), "ranged" (menjaga jarak & menembak)
#   h  : tinggi sprite di game (px). Tanpa "h" = slime yang digambar lewat kode (pakai "color").
#   rec: level rekomendasi; di atasnya XP berkurang (Game.xp_multiplier).
#   min_lv: mulai muncul di Arena pada level ini; berhenti muncul 5 level setelahnya (agar musuh lemah tidak menumpuk).
const SHOT := preload("res://scripts/enemy_shot.gd")
const TYPES := {
    "blue": {"name": "Slime Biru", "hp": 2, "xp": 3, "speed": 52.0, "touch": 1, "rec": 3, "min_lv": 1, "weight": 4, "beh": "chase", "r": 7, "color": Color("5b8def")},
    "green": {"name": "Slime Hijau", "hp": 3, "xp": 5, "speed": 40.0, "touch": 1, "rec": 5, "min_lv": 2, "weight": 3, "beh": "lunge", "r": 7, "color": Color("5fcf6a"),
        "windup": 0.45, "lunge_speed": 210.0, "lunge_time": 0.3, "trigger": 70.0, "lunge_cd": 1.2},
    "red": {"name": "Slime Merah", "hp": 5, "xp": 8, "speed": 62.0, "touch": 2, "rec": 7, "min_lv": 4, "weight": 2, "beh": "chase", "r": 8, "color": Color("e04545")},
    "goblin": {"name": "Goblin", "hp": 3, "xp": 5, "speed": 62.0, "touch": 1, "rec": 4, "min_lv": 2, "weight": 3, "beh": "chase", "r": 6, "h": 28},
    "skeleton": {"name": "Kerangka", "hp": 4, "xp": 6, "speed": 46.0, "touch": 1, "rec": 5, "min_lv": 3, "weight": 3, "beh": "chase", "r": 6, "h": 30},
    "common_beast": {"name": "Binatang Liar", "hp": 3, "xp": 5, "speed": 72.0, "touch": 1, "rec": 5, "min_lv": 3, "weight": 2, "beh": "lunge", "r": 6, "h": 24,
        "windup": 0.3, "lunge_speed": 200.0, "lunge_time": 0.28, "trigger": 80.0, "lunge_cd": 1.0},
    "orc_archer": {"name": "Orc Pemanah", "hp": 4, "xp": 8, "speed": 48.0, "touch": 1, "rec": 6, "min_lv": 4, "weight": 2, "beh": "ranged", "r": 7, "h": 32,
        "shot_cd": 1.9, "shot_speed": 150.0, "shot_dmg": 1, "keep": 110.0, "windup": 0.35},
    "wolf": {"name": "Serigala", "hp": 6, "xp": 10, "speed": 70.0, "touch": 2, "rec": 7, "min_lv": 5, "weight": 2, "beh": "lunge", "r": 8, "h": 28,
        "windup": 0.35, "lunge_speed": 240.0, "lunge_time": 0.3, "trigger": 95.0, "lunge_cd": 1.0},
    "hob_goblin": {"name": "Hob Goblin", "hp": 6, "xp": 10, "speed": 56.0, "touch": 2, "rec": 7, "min_lv": 5, "weight": 2, "beh": "chase", "r": 8, "h": 34},
    "orc_shaman": {"name": "Orc Dukun", "hp": 6, "xp": 12, "speed": 40.0, "touch": 1, "rec": 8, "min_lv": 6, "weight": 2, "beh": "ranged", "r": 7, "h": 36,
        "shot_cd": 2.4, "shot_speed": 105.0, "shot_dmg": 2, "keep": 120.0, "windup": 0.5, "orb": true},
    "high_goblin": {"name": "High Goblin", "hp": 8, "xp": 12, "speed": 54.0, "touch": 2, "rec": 8, "min_lv": 6, "weight": 2, "beh": "chase", "r": 8, "h": 36},
    "knight_skeleton": {"name": "Kerangka Ksatria", "hp": 10, "xp": 16, "speed": 38.0, "touch": 2, "rec": 9, "min_lv": 7, "weight": 2, "beh": "chase", "r": 9, "h": 38},
    "knight_orc": {"name": "Ksatria Orc", "hp": 12, "xp": 18, "speed": 34.0, "touch": 3, "rec": 10, "min_lv": 8, "weight": 2, "beh": "chase", "r": 10, "h": 40},
    "chimera": {"name": "Chimera", "hp": 10, "xp": 20, "speed": 62.0, "touch": 3, "rec": 10, "min_lv": 8, "weight": 2, "beh": "lunge", "r": 9, "h": 34,
        "windup": 0.5, "lunge_speed": 230.0, "lunge_time": 0.32, "trigger": 100.0, "lunge_cd": 1.4},
    "death_knight": {"name": "Ksatria Maut", "hp": 30, "xp": 60, "speed": 48.0, "touch": 4, "rec": 12, "min_lv": 9, "weight": 0, "beh": "lunge", "r": 12, "h": 52, "boss": true,
        "windup": 0.5, "lunge_speed": 260.0, "lunge_time": 0.35, "trigger": 110.0, "lunge_cd": 1.6}}
# sprite pose "b" yang aslinya menghadap kanan (supaya flip-nya benar)
const NATIVE_RIGHT_B := ["common_beast", "wolf", "orc_archer"]
const AGGRO := 150.0

var kind := "blue"
var cfg: Dictionary = {}
var beh := "chase"
var hp := 2
var max_hp := 2
var xp := 3
var speed := 52.0
var touch := 1
var rec := 3
var radius := 7.0
var flash := 0.0
var t := 0.0
var stun := 0.0
var kb := Vector2.ZERO
var lunge_state := 0   # 0 mengejar, 1 aba-aba, 2 menerjang
var lunge_t := 0.8
var lunge_dir := Vector2.ZERO
var shot_t := 1.0
var charge := 0.0
var face_t := 0.0
var use_back := false
var flip := false
var tex_a: Texture2D = null
var tex_b: Texture2D = null
var sprite_scale := 1.0

# Daftar jenis (dengan bobot) yang boleh muncul di level tertentu.
static func kinds_for_level(lv: int) -> Array:
    var pool := []
    for k in TYPES:
        var c: Dictionary = TYPES[k]
        if c.get("boss", false):
            continue
        if lv >= int(c["min_lv"]) and lv <= int(c["min_lv"]) + 5:
            for i in int(c["weight"]):
                pool.append(k)
    if pool.is_empty():
        pool.append("blue")
    return pool

func _ready():
    add_to_group("enemy")
    collision_layer = 4   # musuh di layer 4
    collision_mask = 1    # hanya bertabrakan dengan tembok
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    cfg = TYPES.get(kind, TYPES["blue"])
    hp = int(cfg["hp"])
    max_hp = hp
    xp = int(cfg["xp"])
    speed = float(cfg["speed"])
    touch = int(cfg["touch"])
    rec = int(cfg["rec"])
    radius = float(cfg.get("r", 7))
    beh = str(cfg.get("beh", "chase"))
    _load_sprites()
    var c := CollisionShape2D.new()
    var s := CircleShape2D.new()
    s.radius = radius
    c.shape = s
    add_child(c)
    t = randf() * 6.0
    lunge_t = 0.6 + randf() * 0.8
    shot_t = 0.8 + randf() * 1.2

func _load_sprites():
    if not cfg.has("h"):
        return
    var pa := "res://assets/enemies/%s_a.png" % kind
    var pb := "res://assets/enemies/%s_b.png" % kind
    if ResourceLoader.exists(pa):
        tex_a = load(pa) as Texture2D
        tex_b = (load(pb) as Texture2D) if ResourceLoader.exists(pb) else tex_a
        sprite_scale = float(cfg["h"]) / float(tex_a.get_height())

func _physics_process(delta):
    t += delta
    flash = maxf(0.0, flash - delta)
    stun = maxf(0.0, stun - delta)
    kb = kb.move_toward(Vector2.ZERO, 600.0 * delta)
    if Game.input_locked:
        velocity = Vector2.ZERO
        queue_redraw()
        return
    var p = get_tree().get_first_node_in_group("player")
    var move := Vector2.ZERO
    if p != null and stun <= 0.0:
        var d: Vector2 = p.global_position - global_position
        var dist := d.length()
        _update_facing(d, delta)
        if beh == "lunge":
            move = _lunge_move(d, dist, delta)
        elif beh == "ranged":
            move = _ranged_move(d, dist, delta)
        elif dist < AGGRO and dist > 1.0:
            move = d.normalized() * speed
        if dist < radius + 9.0:
            p.damage(touch, global_position)
    velocity = move + kb
    move_and_slide()
    queue_redraw()

func _update_facing(d: Vector2, delta: float):
    face_t -= delta
    if face_t > 0.0:
        return
    face_t = 0.12
    use_back = d.y < 0.0 and absf(d.y) > absf(d.x) * 0.6
    if use_back and NATIVE_RIGHT_B.has(kind):
        flip = d.x < 0.0
    else:
        flip = d.x > 0.0

func _lunge_move(d: Vector2, dist: float, delta: float) -> Vector2:
    if lunge_state == 0:
        if dist < AGGRO and dist > 1.0:
            lunge_t -= delta
            if dist < float(cfg.get("trigger", 70.0)) and lunge_t <= 0.0:
                lunge_state = 1
                lunge_t = float(cfg.get("windup", 0.45))
            return d.normalized() * speed
        return Vector2.ZERO
    if lunge_state == 1:
        lunge_t -= delta
        lunge_dir = d.normalized()
        if lunge_t <= 0.0:
            lunge_state = 2
            lunge_t = float(cfg.get("lunge_time", 0.3))
        return Vector2.ZERO
    lunge_t -= delta
    if lunge_t <= 0.0:
        lunge_state = 0
        lunge_t = float(cfg.get("lunge_cd", 1.2))
    return lunge_dir * float(cfg.get("lunge_speed", 210.0))

func _ranged_move(d: Vector2, dist: float, delta: float) -> Vector2:
    var keep := float(cfg.get("keep", 110.0))
    shot_t -= delta
    if dist > 230.0:
        return Vector2.ZERO
    if charge > 0.0:
        charge -= delta
        if charge <= 0.0:
            _fire(d)
        return Vector2.ZERO
    if shot_t <= 0.0 and dist < 200.0:
        charge = float(cfg.get("windup", 0.4))
        shot_t = float(cfg.get("shot_cd", 2.0))
        return Vector2.ZERO
    if dist < keep - 20.0:
        return -d.normalized() * speed
    if dist > keep + 30.0:
        return d.normalized() * speed
    return Vector2.ZERO

func _fire(d: Vector2):
    var s = SHOT.new()
    s.position = position
    s.dir = d.normalized()
    s.speed = float(cfg.get("shot_speed", 150.0))
    s.dmg = int(cfg.get("shot_dmg", 1))
    s.orb = bool(cfg.get("orb", false))
    get_parent().add_child(s)

func hit(dmg: int, from: Vector2 = Vector2.ZERO, stun_time: float = 0.0):
    hp -= dmg
    flash = 0.12
    if stun_time > 0.0:
        stun = maxf(stun, stun_time)
        charge = 0.0
        if lunge_state != 0:   # cahaya membatalkan terjangan
            lunge_state = 0
            lunge_t = 1.0
    if from != Vector2.ZERO:
        kb = (global_position - from).normalized() * 160.0 * clampf(8.0 / radius, 0.4, 1.2)
    if hp <= 0:
        _die()

func _die():
    var gained := int(round(float(xp) * Game.xp_multiplier(rec)))
    Game.add_xp(maxi(gained, 1))
    var drop := 1.0 if cfg.get("boss", false) else 0.12
    if randf() < drop:
        var pk = preload("res://scripts/pickup.gd").new()
        pk.position = position
        get_parent().add_child(pk)
    queue_free()

func _draw():
    var telegraph := lunge_state == 1 or charge > 0.0
    if tex_a != null:
        _draw_sprite(telegraph)
        return
    var w := sin(t * 8.0) * 0.1
    var sx := 1.0 + w
    var sy := 1.0 - w
    if telegraph:
        sx = 1.3
        sy = 0.7
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))
    var base: Color = cfg["color"]
    var c: Color = base
    if flash > 0.0:
        c = Color.WHITE
    elif stun > 0.0:
        c = base.darkened(0.45)
    draw_circle(Vector2.ZERO, 9, c)
    draw_rect(Rect2(-4, -2, 2, 4), Color.BLACK)
    draw_rect(Rect2(2, -2, 2, 4), Color.BLACK)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    _draw_hp_bar(-16.0)

func _draw_sprite(telegraph: bool):
    var tex: Texture2D = tex_b if use_back else tex_a
    var sz: Vector2 = tex.get_size() * sprite_scale
    var moving := velocity.length() > 5.0
    var bob := absf(sin(t * 9.0)) * 1.5 if moving else sin(t * 2.0) * 0.6
    var tint := Color.WHITE
    if flash > 0.0:
        tint = Color(1.0, 0.45, 0.45)
    elif stun > 0.0:
        tint = Color(0.55, 0.6, 0.95)
    elif telegraph and int(t * 20.0) % 2 == 0:
        tint = Color(1.0, 0.65, 0.65)
    var foot := radius + 3.0
    # bayangan di kaki
    draw_set_transform(Vector2(0, foot), 0.0, Vector2(1.0, 0.35))
    draw_circle(Vector2.ZERO, sz.x * 0.32, Color(0, 0, 0, 0.25))
    # sprite (dibalik horizontal bila perlu)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0 if flip else 1.0, 1.0))
    draw_texture_rect(tex, Rect2(Vector2(-sz.x / 2.0, foot - sz.y - bob), sz), false, tint)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    _draw_hp_bar(foot - sz.y - bob - 6.0)

func _draw_hp_bar(y: float):
    if hp >= max_hp:
        return
    draw_rect(Rect2(-9, y, 18, 3), Color("3a3d4d"))
    draw_rect(Rect2(-9, y, 18.0 * float(hp) / float(max_hp), 3), Color("e02f2f"))
