extends Node2D
# Hati kecil: dijatuhkan musuh, memulihkan 2 satuan HP (1 bar). Hilang setelah 12 detik.
var t := 0.0
var life := 12.0

func _ready():
    add_to_group("pickup")

func _process(delta):
    t += delta
    life -= delta
    if life <= 0.0:
        queue_free()
        return
    var p = get_tree().get_first_node_in_group("player")
    if p != null and Game.hp < Game.max_hp() and p.global_position.distance_to(global_position) < 14.0:
        Game.hp = mini(Game.max_hp(), Game.hp + 2)
        queue_free()
        return
    queue_redraw()

func _draw():
    if life < 3.0 and int(life * 6.0) % 2 == 0:
        return
    var bob := sin(t * 5.0) * 1.5
    draw_circle(Vector2(-3, -2 + bob), 3.5, Color("e02f2f"))
    draw_circle(Vector2(3, -2 + bob), 3.5, Color("e02f2f"))
    draw_colored_polygon(PackedVector2Array([Vector2(-6.2, -0.5 + bob), Vector2(6.2, -0.5 + bob), Vector2(0, 6.5 + bob)]), Color("e02f2f"))
