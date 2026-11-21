extends Node2D
# Cincin berdenyut di lokasi pemain pada peta dunia
var t := 0.0

func _process(delta):
    t += delta
    queue_redraw()

func _draw():
    draw_arc(Vector2.ZERO, 14.0 + sin(t * 4.0) * 2.0, 0.0, TAU, 32, Color("ffd84a"), 2.0)
