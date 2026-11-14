extends CanvasLayer
signal dialog_finished(id)
var active := false
var lines := []
var idx := 0
var cur_id := ""
var panel: Panel
var name_lbl: Label
var text_lbl: Label
var info_lbl: Label
var note_lbl: Label

func _ready():
    var bar := Control.new()
    bar.set_script(preload("res://scripts/hpbar.gd"))
    bar.position = Vector2(12, 10)
    add_child(bar)
    info_lbl = Label.new()
    info_lbl.position = Vector2(12, 26)
    add_child(info_lbl)
    note_lbl = Label.new()
    note_lbl.position = Vector2(0, 150)
    note_lbl.size = Vector2(640, 30)
    note_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(note_lbl)
    panel = Panel.new()
    panel.position = Vector2(16, 268)
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
    Game.xp_gained.connect(func(a, lv): notice("+%d XP%s" % [a, " - Naik level!" if lv else ""]))

func _process(_d):
    info_lbl.text = "%s  Lv %d  XP %d/%d" % [Game.player_name, Game.level, Game.xp, Game.level * 10]

func notice(t: String, secs := 1.5):
    note_lbl.text = t
    await get_tree().create_timer(secs).timeout
    if note_lbl.text == t:
        note_lbl.text = ""

func start_dialog(id: String):
    lines = Game.get_dialog(id)
    if lines.is_empty():
        return
    cur_id = id
    idx = 0
    active = true
    panel.visible = true
    _show()

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
    panel.visible = false
    dialog_finished.emit(cur_id)

func _show():
    name_lbl.text = lines[idx].name
    text_lbl.text = lines[idx].text
