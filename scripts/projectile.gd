extends Node2D
var dir := Vector2.RIGHT
var life := 1.5

func _process(delta):
    position += dir * 220.0 * delta
    life -= delta
    if life <= 0.0 or not Rect2(16, 56, 608, 288).has_point(position):
        queue_free()
        return
    for e in get_tree().get_nodes_in_group("enemy"):
        if e.global_position.distance_to(global_position) < 14.0:
            e.hit(Game.sword_damage())
            queue_free()
            return
    queue_redraw()

func _draw():
    draw_circle(Vector2.ZERO, 5, Color("ff7ab8"))
    draw_circle(Vector2.ZERO, 2.5, Color.WHITE)
