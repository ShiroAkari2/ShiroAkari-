extends Control
# Bar HP (tiap bar = 2 satuan, jumlah bar mengikuti HP maks) + pip mana di bawahnya.

func _process(_d):
    queue_redraw()

func _draw():
    var bars := int(ceil(Game.max_hp() / 2.0))
    for i in bars:
        var x := i * 30.0
        draw_rect(Rect2(x, 0, 28, 12), Color("3a3d4d"))
        var f := clampf(float(Game.hp - i * 2), 0.0, 2.0) / 2.0
        draw_rect(Rect2(x, 0, 28 * f, 12), Color("e02f2f"))
        draw_rect(Rect2(x, 0, 28, 12), Color.BLACK, false, 1.0)
    var pips := Game.max_mana()
    for j in pips:
        var mx := j * 18.0
        draw_rect(Rect2(mx, 16, 16, 7), Color("26304d"))
        var mf := clampf(Game.mana - float(j), 0.0, 1.0)
        draw_rect(Rect2(mx, 16, 16.0 * mf, 7), Color("7fd8ff"))
        draw_rect(Rect2(mx, 16, 16, 7), Color.BLACK, false, 1.0)
