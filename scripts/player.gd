extends CharacterBody2D
signal died

const SWORD_RANGE := 34.0   # sama dengan jari-jari busur yang digambar
const SWORD_ARC := 0.9      # radian ke tiap sisi; sama dengan busur yang digambar
const SWORD_COOLDOWN := 0.35
const MAGIC_COOLDOWN := 0.6
const MANA_REGEN := 0.5     # mana per detik

var speed := 110.0
var facing := Vector2.DOWN
var inv_time := 0.0
var sword_t := 0.0
var sword_cd := 0.0
var magic_cd := 0.0
var kb := Vector2.ZERO

func _ready():
    add_to_group("player")
    collision_layer = 2   # pemain di layer 2: tidak saling dorong dengan musuh (layer 4)
    collision_mask = 1    # hanya bertabrakan dengan tembok
    var c := CollisionShape2D.new()
    var s := CircleShape2D.new()
    s.radius = 6.0
    c.shape = s
    c.position = Vector2(0, 6)
    add_child(c)

func _physics_process(delta):
    inv_time = maxf(0.0, inv_time - delta)
    sword_t = maxf(0.0, sword_t - delta)
    sword_cd = maxf(0.0, sword_cd - delta)
    magic_cd = maxf(0.0, magic_cd - delta)
    modulate.a = 0.4 if (inv_time > 0.0 and int(inv_time * 10.0) % 2 == 0) else 1.0
    if Game.input_locked:
        velocity = Vector2.ZERO
        move_and_slide()
        queue_redraw()
        return
    var dir := Input.get_vector("left", "right", "up", "down")
    if dir != Vector2.ZERO:
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

# Placeholder gambar. Ganti dengan Sprite2D/AnimatedSprite2D kalau sprite sudah siap.
func _draw():
    draw_circle(Vector2(0, -2), 10, Color.WHITE)
    draw_arc(Vector2(0, -2), 10, 0, TAU, 24, Color.BLACK, 1.0)
    draw_circle(Vector2(0, 1), 6, Color("ffe6d9"))
    draw_circle(facing * 4.0 + Vector2(-2, 0), 1.2, Color("c0304a"))
    draw_circle(facing * 4.0 + Vector2(2, 0), 1.2, Color("c0304a"))
    if sword_t > 0.0:
        draw_arc(Vector2.ZERO, SWORD_RANGE, facing.angle() - SWORD_ARC, facing.angle() + SWORD_ARC, 12, Color("ff7ab8"), 4.0)
