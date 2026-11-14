extends Node2D
# kind: "red" (2 tebasan, 6 XP) atau warna lain (1 tebasan, 3 XP)
var kind := "blue"
var hp := 1
var xp := 3
var speed := 38.0
var flash := 0.0
var t := 0.0
const COLORS := {"blue": Color("5b8def"), "red": Color("e04545"), "green": Color("5fcf6a"), "purple": Color("a066d8"), "orange": Color("f0a030")}

func _ready():
    add_to_group("enemy")
    if kind == "red":
        hp = 2
        xp = 6
    t = randf() * 6.0

func _process(delta):
    t += delta
    flash = maxf(0.0, flash - delta)
    var p = get_tree().get_first_node_in_group("player")
    if p:
        var d: Vector2 = p.global_position - global_position
        if d.length() < 150.0 and d.length() > 1.0:
            position += d.normalized() * speed * delta
        if d.length() < 14.0:
            p.damage()
    queue_redraw()

func hit(dmg: int):
    hp -= dmg
    flash = 0.12
    if hp <= 0:
        Game.add_xp(xp)
        queue_free()

func _draw():
    var w := sin(t * 8.0) * 0.1
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0 + w, 1.0 - w))
    var c: Color = Color.WHITE if flash > 0.0 else COLORS.get(kind, Color.GREEN)
    draw_circle(Vector2.ZERO, 9, c)
    draw_rect(Rect2(-4, -2, 2, 4), Color.BLACK)
    draw_rect(Rect2(2, -2, 2, 4), Color.BLACK)
