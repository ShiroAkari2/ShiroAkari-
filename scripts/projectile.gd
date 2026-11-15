extends Node2D
# "Cahaya Akari": proyektil jarak jauh. Memberi damage + membuat musuh terpaku (stun) sesaat.
const SPEED := 220.0
const STUN := 0.8
var dir := Vector2.RIGHT
var life := 1.5

func _physics_process(delta):
    if Game.input_locked:
        return
    life -= delta
    if life <= 0.0:
        queue_free()
        return
    var step: Vector2 = dir * SPEED * delta
    # berhenti saat menabrak tembok/pilar (layer 1)
    var q := PhysicsRayQueryParameters2D.create(global_position, global_position + step, 1)
    if not get_world_2d().direct_space_state.intersect_ray(q).is_empty():
        queue_free()
        return
    position += step
    for e in get_tree().get_nodes_in_group("enemy"):
        if e.global_position.distance_to(global_position) < 8.0 + e.radius:
            e.hit(Game.magic_damage(), global_position - dir * 8.0, STUN)
            queue_free()
            return
    queue_redraw()

func _draw():
    draw_circle(Vector2.ZERO, 5, Color("ff7ab8"))
    draw_circle(Vector2.ZERO, 2.5, Color.WHITE)
