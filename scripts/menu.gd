extends Control
var stage := 0
var menu_box: VBoxContainer
var press_lbl: Label

func _ready():
    # Taruh gambar latar di assets/title_bg.png (tanpa teks logo) untuk menggantikan latar polos.
    var bg_path := "res://assets/title_bg.png"
    if ResourceLoader.exists(bg_path):
        var rect := TextureRect.new()
        rect.texture = load(bg_path)
        rect.size = Vector2(640, 360)
        rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        rect.stretch_mode = TextureRect.STRETCH_SCALE
        add_child(rect)
    else:
        var bg := ColorRect.new()
        bg.size = Vector2(640, 360)
        bg.color = Color("8fb8dc")
        add_child(bg)
        var low := ColorRect.new()
        low.position = Vector2(0, 250)
        low.size = Vector2(640, 110)
        low.color = Color("6fa86f")
        add_child(low)
    var title := Label.new()
    title.text = "ShiroAkari"
    title.position = Vector2(0, 40)
    title.size = Vector2(640, 80)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 56)
    title.add_theme_color_override("font_outline_color", Color("1f2540"))
    title.add_theme_constant_override("outline_size", 8)
    add_child(title)
    press_lbl = Label.new()
    press_lbl.text = "- Tekan tombol apa saja -"
    press_lbl.position = Vector2(0, 230)
    press_lbl.size = Vector2(640, 24)
    press_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(press_lbl)
    menu_box = VBoxContainer.new()
    menu_box.position = Vector2(240, 140)
    menu_box.visible = false
    add_child(menu_box)
    var cont := _btn("Lanjut", _continue)
    cont.disabled = not Game.has_save()
    _btn("Game Baru", func(): get_tree().change_scene_to_file("res://scenes/NameInput.tscn"))
    _btn("Pengaturan", _settings)
    _btn("Kredit", func(): _info("ShiroAkari\nDibuat dengan Godot Engine."))
    _btn("Bahasa: Indonesia", func(): _info("Bahasa Inggris menyusul."))
    _btn("Keluar", func(): get_tree().quit())

func _btn(text: String, cb: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(160, 26)
    b.pressed.connect(cb)
    menu_box.add_child(b)
    return b

func _input(event):
    if stage == 0 and event.is_pressed() and (event is InputEventKey or event is InputEventMouseButton):
        stage = 1
        press_lbl.visible = false
        menu_box.visible = true

func _continue():
    if Game.load_game():
        get_tree().change_scene_to_file("res://scenes/Guild.tscn")

func _info(text: String):
    var d := AcceptDialog.new()
    d.dialog_text = text
    add_child(d)
    d.popup_centered()

func _settings():
    var d := AcceptDialog.new()
    d.dialog_text = "Kontrol:\nPanah/WASD = jalan\nZ/Spasi/Enter = bicara\nJ = pedang\nK = sihir\nEsc = kembali ke menu"
    d.add_button("Layar Penuh", false, "fs")
    d.custom_action.connect(func(_a):
        var m := DisplayServer.window_get_mode()
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if m == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN))
    add_child(d)
    d.popup_centered()
