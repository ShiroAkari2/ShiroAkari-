extends Control
# Alur: layar judul (title_bg.png, tekan apa saja) -> menu (menu_bg.png, tombol sudah tergambar di gambar,
# jadi di sini dipasang area klik transparan di atasnya). Tanpa gambar, dipakai tampilan cadangan polos.
const TITLE_BG := "res://assets/title_bg.png"
const MENU_BG := "res://assets/menu_bg.png"
# Ukuran asli menu_bg.png (sebelum diperkecil) dan area tiap tombol di dalamnya.
const SRC_W := 1670.0
const SRC_H := 942.0
const HOTSPOTS := [
    ["start", Rect2(638, 347, 393, 72)],
    ["continue", Rect2(638, 433, 393, 64)],
    ["characters", Rect2(638, 505, 393, 62)],
    ["settings", Rect2(638, 573, 393, 63)],
    ["quest", Rect2(638, 642, 393, 63)],
    ["credit", Rect2(638, 712, 393, 64)],
    ["exit", Rect2(32, 830, 190, 92)]]
var stage := 0
var bg_rect: TextureRect = null
var menu_layer: Control
var fallback := false
var press_lbl: Label

func _ready():
    Game.in_game = false
    if ResourceLoader.exists(TITLE_BG) and ResourceLoader.exists(MENU_BG):
        bg_rect = TextureRect.new()
        # urutan penting: expand_mode dulu, baru texture & size (kalau tidak, ukuran tertahan di ukuran gambar asli)
        bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        bg_rect.stretch_mode = TextureRect.STRETCH_SCALE
        bg_rect.custom_minimum_size = Vector2.ZERO
        bg_rect.texture = load(TITLE_BG) as Texture2D
        bg_rect.size = Vector2(640, 360)
        bg_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        add_child(bg_rect)
        menu_layer = Control.new()
        menu_layer.visible = false
        add_child(menu_layer)
    else:
        fallback = true
        _build_fallback()

func _input(event):
    if stage != 0:
        return
    if event.is_pressed() and (event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch):
        stage = 1
        if fallback:
            press_lbl.visible = false
            menu_layer.visible = true
        else:
            bg_rect.texture = load(MENU_BG) as Texture2D
            _build_hotspots()
            menu_layer.visible = true

# ---------- Menu bergambar ----------
func _build_hotspots():
    var sx := 640.0 / SRC_W
    var sy := 360.0 / SRC_H
    var first: Button = null
    for h in HOTSPOTS:
        var r: Rect2 = h[1]
        var b := _hotspot(h[0], Vector2(r.position.x * sx, r.position.y * sy), Vector2(r.size.x * sx, r.size.y * sy))
        if h[0] == "continue":
            b.disabled = not Game.has_save()
        if first == null and not b.disabled:
            first = b
    if first != null:
        first.grab_focus()

func _hotspot(id: String, pos: Vector2, sz: Vector2) -> Button:
    var b := Button.new()
    b.position = pos
    b.size = sz
    b.flat = true
    var hover := StyleBoxFlat.new()
    hover.bg_color = Color(1, 1, 1, 0.20)
    hover.set_corner_radius_all(6)
    var press := StyleBoxFlat.new()
    press.bg_color = Color(1, 1, 1, 0.34)
    press.set_corner_radius_all(6)
    var off := StyleBoxFlat.new()
    off.bg_color = Color(0.05, 0.05, 0.12, 0.5)
    off.set_corner_radius_all(6)
    b.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    b.add_theme_stylebox_override("hover", hover)
    b.add_theme_stylebox_override("focus", hover)
    b.add_theme_stylebox_override("pressed", press)
    b.add_theme_stylebox_override("disabled", off)
    b.pressed.connect(_on_pressed.bind(id))
    menu_layer.add_child(b)
    return b

func _on_pressed(id: String):
    match id:
        "start": _new_game()
        "continue": _continue()
        "characters": add_child(preload("res://scripts/bestiary.gd").new())
        "settings": _settings()
        "quest": _info("Quest belum tersedia.\nDaftar dulu ke Marla di Guild.")
        "credit": _info("ShiroAkari\nDibuat dengan Godot Engine.")
        "exit":
            if OS.has_feature("web"):
                _info("Tutup tab browser untuk keluar.")
            else:
                get_tree().quit()

# ---------- Tampilan cadangan (bila gambar tidak ada) ----------
func _build_fallback():
    var bg := ColorRect.new()
    bg.size = Vector2(640, 360)
    bg.color = Color("8fb8dc")
    add_child(bg)
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
    menu_layer = VBoxContainer.new()
    menu_layer.position = Vector2(240, 120)
    menu_layer.visible = false
    add_child(menu_layer)
    var items := [["Lanjut", "continue"], ["Game Baru", "start"], ["Karakter", "characters"], ["Pengaturan", "settings"],
        ["Quest", "quest"], ["Kredit", "credit"], ["Keluar", "exit"]]
    for it in items:
        var b := Button.new()
        b.text = it[0]
        b.custom_minimum_size = Vector2(160, 26)
        b.pressed.connect(_on_pressed.bind(it[1]))
        if it[1] == "continue":
            b.disabled = not Game.has_save()
        menu_layer.add_child(b)

# ---------- Aksi ----------
func _new_game():
    if Game.has_save():
        var d := ConfirmationDialog.new()
        d.dialog_text = "Save lama akan ditimpa.\nLanjutkan Game Baru?"
        d.confirmed.connect(func(): Game.goto("res://scenes/NameInput.tscn"))
        add_child(d)
        d.popup_centered()
    else:
        Game.goto("res://scenes/NameInput.tscn")

func _continue():
    if Game.load_game():
        if Game.flags.get("registered", false):
            Game.goto("res://scenes/Guild.tscn")
        else:
            Game.goto("res://scenes/Rumah.tscn")   # belum mendaftar: mulai dari Rumah

func _info(text: String):
    var d := AcceptDialog.new()
    d.dialog_text = text
    add_child(d)
    d.popup_centered()

func _settings():
    var d := AcceptDialog.new()
    d.dialog_text = "Kontrol:\nPanah/WASD = jalan\nZ/Spasi/Enter = bicara\nJ = pedang\nK = cahaya (pakai mana)\nEsc = kembali ke menu"
    d.add_button("Layar Penuh", false, "fs")
    d.custom_action.connect(func(_a):
        var m := DisplayServer.window_get_mode()
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if m == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN))
    add_child(d)
    d.popup_centered()
