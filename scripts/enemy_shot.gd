extends Node2D
# Tembakan musuh (panah / bola sihir). Berhenti di tembok, melukai pemain bila kena.
var dir := Vector2.RIGHT
var speed := 150.0
var dmg := 1
var orb := false
var life := 3.0

func _physics_process(delta):
    if Game.input_locked:
        return
    life -= delta
    if life <= 0.0:
        queue_free()
        return
    var step: Vector2 = dir * speed * delta
    var q := PhysicsRayQueryParameters2D.create(global_position, global_position + step, 1)
    if not get_world_2d().direct_space_state.intersect_ray(q).is_empty():
        queue_free()
        return
    position += step
    var p = get_tree().get_first_node_in_group("player")
    if p != null and p.global_position.distance_to(global_position) < 11.0:
        p.damage(dmg, global_position - dir * 6.0)
        queue_free()
        return
    queue_redraw()

func _draw():
    if orb:
        draw_circle(Vector2.ZERO, 6.0, Color(0.3, 0.9, 0.4, 0.35))
        draw_circle(Vector2.ZERO, 4.0, Color("5fe07a"))
        draw_circle(Vector2.ZERO, 1.8, Color.WHITE)
    else:
        draw_line(-dir * 8.0, dir * 5.0, Color("d8c8a0"), 2.0)
        draw_line(dir * 5.0, dir * 8.0 + dir.orthogonal() * 2.5, Color("c0304a"), 2.0)
        draw_line(dir * 5.0, dir * 8.0 - dir.orthogonal() * 2.5, Color("c0304a"), 2.0)
