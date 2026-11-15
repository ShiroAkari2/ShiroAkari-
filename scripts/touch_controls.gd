extends CanvasLayer
# Kontrol sentuh (multi-touch) untuk HP/web. Hanya dipasang bila layar sentuh tersedia.

func _ready():
    layer = 5
    var cell := 38
    var ox := 44
    var oy := 262
    _btn("up", Vector2(ox, oy - cell), cell, "^", true)
    _btn("down", Vector2(ox, oy + cell), cell, "v", true)
    _btn("left", Vector2(ox - cell, oy), cell, "<", true)
    _btn("right", Vector2(ox + cell, oy), cell, ">", true)
    _btn("interact", Vector2(584, 290), 40, "A", false)
    _btn("sword", Vector2(536, 300), 40, "J", false)
    _btn("magic", Vector2(574, 238), 40, "K", false)
    _btn("ui_cancel", Vector2(596, 8), 30, "=", false)

func _btn(action: String, pos: Vector2, size: int, label: String, passby: bool):
    var up := Image.create(size, size, false, Image.FORMAT_RGBA8)
    up.fill(Color(1, 1, 1, 0.16))
    var down := Image.create(size, size, false, Image.FORMAT_RGBA8)
    down.fill(Color(1, 1, 1, 0.42))
    var b := TouchScreenButton.new()
    b.texture_normal = ImageTexture.create_from_image(up)
    b.texture_pressed = ImageTexture.create_from_image(down)
    b.action = action
    b.passby_press = passby
    b.position = pos
    add_child(b)
    var l := Label.new()
    l.text = label
    l.position = pos + Vector2(size / 2.0 - 5.0, size / 2.0 - 11.0)
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(l)
