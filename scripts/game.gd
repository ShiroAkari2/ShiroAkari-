extends Node
signal xp_gained(amount, leveled)
const SAVE_PATH := "user://save.json"
var player_name := "Hero"
var hp := 10   # satuan setengah bar: 10 = 5 bar penuh
var xp := 0
var level := 1
var flags := {}
var lang := "id"
var dialogs := {}

func _ready():
    _setup_input()
    load_dialogs()

func _setup_input():
    var map := {
        "up": [KEY_UP, KEY_W], "down": [KEY_DOWN, KEY_S],
        "left": [KEY_LEFT, KEY_A], "right": [KEY_RIGHT, KEY_D],
        "interact": [KEY_Z, KEY_SPACE, KEY_ENTER],
        "sword": [KEY_J], "magic": [KEY_K]}
    for a in map:
        if not InputMap.has_action(a):
            InputMap.add_action(a)
        for k in map[a]:
            var e := InputEventKey.new()
            e.physical_keycode = k
            InputMap.action_add_event(a, e)

func load_dialogs():
    dialogs.clear()
    var path := "res://data/dialog/%s.txt" % lang
    if not FileAccess.file_exists(path):
        path = "res://data/dialog/id.txt"
    var f := FileAccess.open(path, FileAccess.READ)
    var cur := ""
    while not f.eof_reached():
        var line := f.get_line().strip_edges()
        if line == "" or line.begins_with("#"):
            continue
        if line.begins_with("[") and line.ends_with("]"):
            cur = line.substr(1, line.length() - 2)
            dialogs[cur] = []
        elif cur != "" and ":" in line:
            var i := line.find(":")
            dialogs[cur].append({"name": line.substr(0, i).strip_edges(), "text": line.substr(i + 1).strip_edges()})

func get_dialog(id: String) -> Array:
    var out := []
    for l in dialogs.get(id, []):
        out.append({"name": l.name.replace("{player}", player_name), "text": l.text.replace("{player}", player_name)})
    return out

func sword_damage() -> int:
    return 2 if level >= 3 else 1

func add_xp(n: int):
    xp += n
    var lv := false
    while xp >= level * 10:
        xp -= level * 10
        level += 1
        lv = true
    xp_gained.emit(n, lv)
    save_game()

func new_game(n: String):
    player_name = n.strip_edges() if n.strip_edges() != "" else "Hero"
    hp = 10
    xp = 0
    level = 1
    flags = {}
    save_game()

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func save_game():
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify({"name": player_name, "hp": hp, "xp": xp, "level": level, "flags": flags}))

func load_game() -> bool:
    if not has_save():
        return false
    var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if typeof(data) != TYPE_DICTIONARY:
        return false
    player_name = str(data.get("name", "Hero"))
    hp = int(data.get("hp", 10))
    xp = int(data.get("xp", 0))
    level = int(data.get("level", 1))
    flags = data.get("flags", {})
    return true
