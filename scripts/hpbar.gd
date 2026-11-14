extends Control

func _process(_d):
    queue_redraw()

func _draw():
    for i in 5:
        var x := i * 30.0
        draw_rect(Rect2(x, 0, 28, 12), Color("3a3d4d"))
        var f := clampf(Game.hp - i * 2, 0, 2) / 2.0
        draw_rect(Rect2(x, 0, 28 * f, 12), Color("e02f2f"))
        draw_rect(Rect2(x, 0, 28, 12), Color.BLACK, false, 1.0)
