extends CanvasLayer
# Layar loading (assets/loading_bg.png) untuk semua perpindahan scene. Dibuat oleh Game.goto().
var root: Control
var bar: ProgressBar
var lbl: Label
var shown := 0.0

func _init():
    layer = 100

func _build():
    root = Control.new()
    root.size = Vector2(640, 360)
    root.mouse_filter = Control.MOUSE_FILTER_STOP   # blokir klik saat loading
    root.modulate.a = 0.0
    add_child(root)
    var bg := TextureRect.new()
    # urutan penting: expand_mode dulu, baru texture & size
    bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode = TextureRect.STRETCH_SCALE
    bg.custom_minimum_size = Vector2.ZERO
    bg.texture = load("res://assets/loading_bg.png")
    bg.size = Vector2(640, 360)
    root.add_child(bg)
    lbl = Label.new()
    lbl.position = Vector2(220, 298)
    lbl.size = Vector2(200, 16)
    lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl.add_theme_font_size_override("font_size", 10)
    lbl.add_theme_color_override("font_color", Color("c8d0ff"))
    lbl.text = "L O A D I N G"
    root.add_child(lbl)
    bar = ProgressBar.new()
    bar.position = Vector2(219, 316)
    bar.size = Vector2(202, 9)
    bar.max_value = 1.0
    bar.show_percentage = false
    var back := StyleBoxFlat.new()
    back.bg_color = Color("141c5a")
    back.set_border_width_all(1)
    back.border_color = Color("8478e6")
    back.set_corner_radius_all(4)
    var fill := StyleBoxFlat.new()
    fill.bg_color = Color("5cbcff")
    fill.set_corner_radius_all(4)
    bar.add_theme_stylebox_override("background", back)
    bar.add_theme_stylebox_override("fill", fill)
    root.add_child(bar)

func run(path: String, min_time: float):
    _build()
    var t := create_tween()
    t.tween_property(root, "modulate:a", 1.0, 0.2)
    await t.finished
    ResourceLoader.load_threaded_request(path)
    var elapsed := 0.0
    var ok := false
    while true:
        await get_tree().process_frame
        var d := get_process_delta_time()
        elapsed += d
        var prog := []
        var st := ResourceLoader.load_threaded_get_status(path, prog)
        if st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            break
        var real: float = prog[0] if prog.size() > 0 else 0.0
        if st == ResourceLoader.THREAD_LOAD_LOADED:
            real = 1.0
        shown = move_toward(shown, minf(real, elapsed / min_time), 1.6 * d)
        bar.value = shown
        lbl.text = "L O A D I N G" + ".".repeat(int(elapsed * 3.0) % 4)
        if st == ResourceLoader.THREAD_LOAD_LOADED and elapsed >= min_time and shown >= 0.999:
            ok = true
            break
    if ok:
        get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(path))
    else:
        get_tree().change_scene_to_file(path)   # cadangan bila gagal
    await get_tree().process_frame
    await get_tree().process_frame
    Game.input_locked = false
    var t2 := create_tween()
    t2.tween_property(root, "modulate:a", 0.0, 0.3)
    await t2.finished
    queue_free()
