extends CanvasLayer
signal dialog_finished(id)
var active := false
var lines := []
var idx := 0
var cur_id := ""
var note_t := 0.0
var panel: Panel
var name_lbl: Label
var text_lbl: Label
var info_lbl: Label
var note_lbl: Label
var typing := false
var shown := 0.0
var line_t := 0.0
const CHAR_SPEED := 40.0      # huruf per detik
const AUTO_MIN := 2.0         # detik minimum sebelum lanjut otomatis
const AUTO_PER_CHAR := 0.05   # tambahan detik per huruf (waktu baca)

func _ready():
    var bar := Control.new()
    bar.set_script(preload("res://scripts/hpbar.gd"))
    bar.position = Vector2(12, 10)
    add_child(bar)
    info_lbl = Label.new()
    info_lbl.position = Vector2(12, 36)
    add_child(info_lbl)
    note_lbl = Label.new()
    note_lbl.position = Vector2(0, 150)
    note_lbl.size = Vector2(640, 30)
    note_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(note_lbl)
    panel = Panel.new()
    panel.position = Vector2(16, 268)
    if DisplayServer.is_touchscreen_available():
        panel.position = Vector2(16, 150)   # supaya tidak tertutup tombol sentuh
    panel.size = Vector2(608, 84)
    panel.visible = false
    add_child(panel)
    name_lbl = Label.new()
    name_lbl.position = Vector2(12, 6)
    name_lbl.add_theme_color_override("font_color", Color("7fd8ff"))
    panel.add_child(name_lbl)
    text_lbl = Label.new()
    text_lbl.position = Vector2(12, 26)
    text_lbl.size = Vector2(584, 52)
    text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    panel.add_child(text_lbl)
    Game.xp_gained.connect(_on_xp)

func _exit_tree():
    Game.input_locked = false   # jangan sampai terkunci kalau scene berganti saat dialog

func _on_xp(amount, leveled):
    if leveled:
        notice("Naik level! Lv %d - %s" % [Game.level, Game.level_perk(Game.level)], 3.0)
    else:
        notice("+%d XP" % amount)

func _process(delta):
    if active:
        if typing:
            shown += CHAR_SPEED * delta
            if shown >= float(text_lbl.text.length()):
                _finish_line()
            else:
                text_lbl.visible_characters = int(shown)
        else:
            line_t += delta
            if line_t >= AUTO_MIN + AUTO_PER_CHAR * float(text_lbl.text.length()):
                advance()
    if Game.level >= Game.MAX_LEVEL:
        info_lbl.text = "%s  Lv %d (MAKS)" % [Game.player_name, Game.level]
    else:
        info_lbl.text = "%s  Lv %d  XP %d/%d" % [Game.player_name, Game.level, Game.xp, Game.xp_needed(Game.level)]
    if note_t > 0.0:
        note_t -= delta
        if note_t <= 0.0:
            note_lbl.text = ""

func notice(t: String, secs := 1.5):
    note_lbl.text = t
    note_t = secs

func start_dialog(id: String):
    lines = Game.get_dialog(id)
    if lines.is_empty():
        return
    cur_id = id
    idx = 0
    active = true
    Game.input_locked = true
    panel.visible = true
    _show()

# Dipanggil saat tombol interaksi ditekan: saat teks masih mengetik, tampilkan semuanya dulu; kalau sudah penuh, lanjut.
func interact():
    if not active:
        return
    if typing:
        _finish_line()
    else:
        advance()

func _finish_line():
    typing = false
    shown = float(text_lbl.text.length())
    text_lbl.visible_characters = -1
    line_t = 0.0

func advance():
    idx += 1
    if idx >= lines.size():
        end_dialog()
    else:
        _show()

func end_dialog():
    if not active:
        return
    active = false
    Game.input_locked = false
    panel.visible = false
    dialog_finished.emit(cur_id)

func _show():
    name_lbl.text = lines[idx].name
    text_lbl.text = lines[idx].text
    text_lbl.visible_characters = 0
    typing = true
    shown = 0.0
    line_t = 0.0
