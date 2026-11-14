extends CharacterBody2D
signal died
var speed := 110.0
var facing := Vector2.DOWN
var inv_time := 0.0
var sword_t := 0.0
var magic_cd := 0.0

func _ready():
    add_to_group("player")
    var c := CollisionShape2D.new()
    var s := CircleShape2D.new()
    s.radius = 6.0
    c.shape = s
    c.position = Vector2(0, 6)
    add_child(c)

func _physics_process(delta):
    var dir := Input.get_vector("left", "right", "up", "down")
    velocity = dir * speed
    if dir != Vector2.ZERO:
        if absf(dir.x) > absf(dir.y):
            facing = Vector2(signf(dir.x), 0)
        else:
            facing = Vector2(0, signf(dir.y))
    move_and_slide()
    inv_time = maxf(0.0, inv_time - delta)
    sword_t = maxf(0.0, sword_t - delta)
    magic_cd = maxf(0.0, magic_cd - delta)
    modulate.a = 0.4 if (inv_time > 0.0 and int(inv_time * 10.0) % 2 == 0) else 1.0
    if Input.is_action_just_pressed("sword"):
        _sword()
    if Input.is_action_just_pressed("magic") and magic_cd <= 0.0:
        _magic()
    queue_redraw()

func _sword():
    sword_t = 0.18
    for e in get_tree().get_nodes_in_group("enemy"):
        var d: Vector2 = e.global_position - global_position
        if d.length() < 38.0 and d.normalized().dot(facing) > 0.3:
            e.hit(Game.sword_damage())

func _magic():
    magic_cd = 0.8
    var p = preload("res://scripts/projectile.gd").new()
    p.position = position + facing * 12.0
    p.dir = facing
    get_parent().add_child(p)

func damage():
    if inv_time > 0.0:
        return
    Game.hp -= 1
    inv_time = 1.0
    if Game.hp <= 0:
        died.emit()

# Placeholder gambar. Ganti dengan Sprite2D/AnimatedSprite2D kalau sprite sudah siap.
func _draw():
    draw_circle(Vector2(0, -2), 10, Color.WHITE)
    draw_arc(Vector2(0, -2), 10, 0, TAU, 24, Color.BLACK, 1.0)
    draw_circle(Vector2(0, 1), 6, Color("ffe6d9"))
    draw_circle(facing * 4.0 + Vector2(-2, 0), 1.2, Color("c0304a"))
    draw_circle(facing * 4.0 + Vector2(2, 0), 1.2, Color("c0304a"))
    if sword_t > 0.0:
        draw_arc(Vector2.ZERO, 30, facing.angle() - 0.9, facing.angle() + 0.9, 12, Color("ff7ab8"), 4.0)
