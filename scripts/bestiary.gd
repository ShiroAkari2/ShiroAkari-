extends Control
# Daftar musuh (tombol "Characters" di menu). Dibangun lewat kode, ditutup dengan tombol Tutup / Esc.
const ENEMY := preload("res://scripts/enemy.gd")

func _ready():
    set_anchors_preset(Control.PRESET_FULL_RECT)
    var dim := ColorRect.new()
    dim.color = Color(0.05, 0.06, 0.14, 0.82)
    dim.size = Vector2(640, 360)
    add_child(dim)
    var title := Label.new()
    title.text = "Karakter & Musuh"
    title.position = Vector2(0, 8)
    title.size = Vector2(640, 24)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(title)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(24, 36)
    scroll.size = Vector2(592, 278)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    var grid := GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 12)
    grid.add_theme_constant_override("v_separation", 6)
    scroll.add_child(grid)
    var keys: Array = ENEMY.TYPES.keys()
    keys.sort_custom(func(a, b):
        var ca: Dictionary = ENEMY.TYPES[a]
        var cb: Dictionary = ENEMY.TYPES[b]
        if int(ca["min_lv"]) != int(cb["min_lv"]):
            return int(ca["min_lv"]) < int(cb["min_lv"])
        return int(ca["hp"]) < int(cb["hp"]))
    for k in keys:
        grid.add_child(_row(k, ENEMY.TYPES[k]))
    var close := Button.new()
    close.text = "Tutup"
    close.position = Vector2(270, 322)
    close.size = Vector2(100, 28)
    close.pressed.connect(queue_free)
    add_child(close)
    close.grab_focus()

func _row(kind: String, cfg: Dictionary) -> Control:
    var row := HBoxContainer.new()
    row.custom_minimum_size = Vector2(286, 48)
    row.add_theme_constant_override("separation", 8)
    var holder := CenterContainer.new()
    holder.custom_minimum_size = Vector2(48, 48)
    row.add_child(holder)
    var path := "res://assets/enemies/%s_a.png" % kind
    if cfg.has("h") and ResourceLoader.exists(path):
        var tr := TextureRect.new()
        tr.texture = load(path) as Texture2D
        tr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        tr.custom_minimum_size = Vector2(46, 46)
        holder.add_child(tr)
    else:
        var dot := Panel.new()
        var sb := StyleBoxFlat.new()
        sb.bg_color = cfg.get("color", Color.WHITE)
        sb.set_corner_radius_all(14)
        dot.add_theme_stylebox_override("panel", sb)
        dot.custom_minimum_size = Vector2(28, 28)
        holder.add_child(dot)
    var info := Label.new()
    info.add_theme_font_size_override("font_size", 11)
    var extra := "  [BOS]" if cfg.get("boss", false) else ""
    info.text = "%s%s\\nHP %d   XP %d   Muncul: Lv %d" % [cfg["name"], extra, int(cfg["hp"]), int(cfg["xp"]), int(cfg["min_lv"])]
    row.add_child(info)
    return row

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        queue_free()
