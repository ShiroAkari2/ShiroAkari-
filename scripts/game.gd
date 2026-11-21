extends Node
signal xp_gained(amount, leveled)

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 2
const MAX_LEVEL := 20
const DEATH_XP_LOSS := 0.25   # persen XP level berjalan yang hilang saat pingsan

var player_name := "Hero"
var hp := 10        # satuan setengah bar: 10 = 5 bar penuh
var mana := 5.0
var xp := 0
var level := 1
var flags := {}
var lang := "id"
var dialogs := {}
var input_locked := false   # true saat dialog: pemain & musuh berhenti
var guild_entry := Vector2(320, 760)   # posisi muncul di guild
var pending_notice := ""                 # pesan yang ditampilkan di scene berikutnya
var skotice_entry := Vector2(320, 150)   # posisi muncul di Kota Skotice
var rumah_entry := Vector2(320, 430)     # posisi muncul di Rumah pemain (depan pintu)
var desa_entry := Vector2(34, 292)       # posisi muncul di Desa (jalan barat)
var jalan_entry := Vector2(140, 392)     # posisi muncul di Jalan ke Skotice (ujung barat)
var busy := false           # true selama layar loading/pindah scene berjalan
var in_game := false        # true saat berada di dunia game (untuk autosave)
var _autosave_t := 0.0

func _ready():
    _setup_input()
    load_dialogs()

func _process(delta):
    if in_game:
        _autosave_t += delta
        if _autosave_t >= 15.0:
            _autosave_t = 0.0
            save_game()

func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST and in_game:
        save_game()

# Pindah scene lewat layar loading (bar jalan sungguhan lewat ResourceLoader).
func goto(path: String, min_time := 0.9):
    if busy:
        return
    busy = true
    input_locked = true
    var ov = preload("res://scripts/loading_overlay.gd").new()
    add_child(ov)
    await ov.run(path, min_time)
    busy = false

func _setup_input():
    var map := {
        "up": [KEY_UP, KEY_W], "down": [KEY_DOWN, KEY_S],
        "left": [KEY_LEFT, KEY_A], "right": [KEY_RIGHT, KEY_D],
        "interact": [KEY_Z, KEY_SPACE, KEY_ENTER],
        "sword": [KEY_J], "magic": [KEY_K], "world_map": [KEY_M]}
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

# ---------- Statistik & progresi ----------
# XP untuk naik dari level `lv` ke lv+1: 8, 16, 28, ... 224 (Lv 10), ... 764 (Lv 19). Total ke Lv 20: 5396.
func xp_needed(lv: int) -> int:
    if lv >= MAX_LEVEL:
        return 0
    var n := lv - 1
    return 8 + 6 * n + 2 * n * n

func max_hp() -> int:
    return 10 + (level - 1)   # +0,5 bar per level (Lv 10 = 9,5 bar)

func max_mana() -> int:
    return 5 + int(floor(level / 3.0))   # +1 di Lv 3, 6, 9

func sword_damage() -> int:
    return 1 + (1 if level >= 3 else 0) + (1 if level >= 7 else 0) + (1 if level >= 13 else 0) + (1 if level >= 18 else 0)

func magic_damage() -> int:
    return 2 + (1 if level >= 5 else 0) + (1 if level >= 9 else 0) + (1 if level >= 15 else 0)

# Musuh "level rekomendasi" rendah memberi XP makin sedikit saat level pemain lewat batas (anti-grinding).
func xp_multiplier(rec_level: int) -> float:
    return clampf(1.0 - 0.15 * float(maxi(0, level - rec_level)), 0.2, 1.0)

func level_perk(lv: int) -> String:
    var s := "HP maks +0,5 bar, HP & mana pulih"
    match lv:
        3: s += ", pedang & mana maks naik"
        5: s += ", cahaya lebih kuat"
        6: s += ", mana maks naik"
        7: s += ", pedang lebih kuat"
        9: s += ", cahaya & mana maks naik"
        12: s += ", mana maks naik"
        13: s += ", pedang lebih kuat"
        15: s += ", cahaya & mana maks naik"
        18: s += ", pedang & mana maks naik"
        20: s += " - LEVEL MAKS!"
    return s

func heal_full():
    hp = max_hp()
    mana = float(max_mana())

func add_xp(n: int):
    if level >= MAX_LEVEL:
        return
    xp += n
    var lv := false
    while level < MAX_LEVEL and xp >= xp_needed(level):
        xp -= xp_needed(level)
        level += 1
        lv = true
    if level >= MAX_LEVEL:
        xp = 0
    if lv:
        heal_full()
    xp_gained.emit(n, lv)
    save_game()

func death_penalty():
    xp = int(float(xp) * (1.0 - DEATH_XP_LOSS))

# ---------- Save / load ----------
func new_game(n: String):
    player_name = n.strip_edges() if n.strip_edges() != "" else "Hero"
    level = 1
    xp = 0
    flags = {}
    heal_full()
    save_game()

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func save_game():
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify({"ver": SAVE_VERSION, "name": player_name, "hp": hp, "mana": mana,
            "xp": xp, "level": level, "flags": flags}))

func load_game() -> bool:
    if not has_save():
        return false
    var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if typeof(data) != TYPE_DICTIONARY:
        return false
    player_name = str(data.get("name", "Hero"))
    level = clampi(int(data.get("level", 1)), 1, MAX_LEVEL)
    xp = maxi(0, int(data.get("xp", 0)))
    if level >= MAX_LEVEL or xp >= xp_needed(level):
        xp = 0 if level >= MAX_LEVEL else mini(xp, xp_needed(level) - 1)
    hp = clampi(int(data.get("hp", max_hp())), 1, max_hp())
    mana = clampf(float(data.get("mana", max_mana())), 0.0, float(max_mana()))
    flags = data.get("flags", {})
    return true

# Buka/tutup peta dunia (tombol M) sebagai lapisan di atas scene yang sedang berjalan.
# here = nomor lokasi pemain di peta dunia (1 = Rumah, 2 = Desa, 3 = Jalan ke Skotice, 4 = Kota Skotice).
func toggle_world_map(parent: Node, here := 4):
    var old := get_tree().get_first_node_in_group("world_map")
    if old:
        old.queue_free()
        input_locked = false
        return
    var m = preload("res://scripts/world_map.gd").new()
    m.here = here
    parent.add_child(m)
