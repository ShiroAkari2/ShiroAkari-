extends Node2D
# kind: "npc" (orang, padat/tidak bisa ditembus), "door" (pintu keluar), "pond" (Kolam Cahaya: memulihkan HP & mana),
#       "board" (papan pengumuman: tidak digambar, hanya titik interaksi + tanda "!")
# sprite_path: gambar NPC (kaki di titik node). reach: jarak maksimum untuk diajak bicara.
var npc_name := "NPC"
var dialog_id := ""
var color := Color.WHITE
var kind := "npc"
var sprite_path := ""
var reach := 52.0
var t := 0.0
var tex: Texture2D = null

func _ready():
    add_to_group("npc")
    if kind == "npc":
        # badan padat di kaki NPC supaya pemain tidak bisa menembus
        var b := StaticBody2D.new()
        var c := CollisionShape2D.new()
        var sh := RectangleShape2D.new()
        sh.size = Vector2(14, 28)      # menutup badan NPC, bukan hanya kaki
        c.shape = sh
        c.position = Vector2(0, -14)
        b.add_child(c)
        add_child(b)
    if sprite_path != "" and ResourceLoader.exists(sprite_path):
        tex = load(sprite_path) as Texture2D
    queue_redraw()

func _process(delta):
    if kind == "pond" or kind == "board":
        t += delta
        queue_redraw()

func get_dialog_id() -> String:
    if dialog_id == "marla":
        return "marla_idle" if Game.flags.get("registered", false) else "marla_register"
    if dialog_id == "papan":
        # kali pertama: dialog pembuka; berikutnya bergantian membaca 5 pengumuman (papan_4a..papan_4e)
        if not Game.flags.get("papan_dibaca", false):
            Game.flags["papan_dibaca"] = true
            return "papan_pertama"
        var i := int(Game.flags.get("papan_idx", 0))
        Game.flags["papan_idx"] = i + 1
        return "papan_" + ["4a", "4b", "4c", "4d", "4e"][i % 5]
    return dialog_id

func _label(y: float, w: float):
    var f := ThemeDB.fallback_font
    var pos := Vector2(-w / 2.0, y)
    draw_string_outline(f, pos, npc_name, HORIZONTAL_ALIGNMENT_CENTER, w, 10, 4, Color(0.1, 0.12, 0.25))
    draw_string(f, pos, npc_name, HORIZONTAL_ALIGNMENT_CENTER, w, 10, Color.WHITE)

func _draw():
    if kind == "door":
        draw_rect(Rect2(-24, -4, 48, 8), color)
        return
    if kind == "board":
        var f2 := ThemeDB.fallback_font
        var by := -34.0 + sin(t * 3.0) * 2.0
        draw_string_outline(f2, Vector2(-8, by), "!", HORIZONTAL_ALIGNMENT_CENTER, 16, 14, 4, Color(0.1, 0.12, 0.25))
        draw_string(f2, Vector2(-8, by), "!", HORIZONTAL_ALIGNMENT_CENTER, 16, 14, Color("ffd84a"))
        return
    if kind == "pond":
        # cahaya lembut di atas lambang kompas; menyatu dengan gambar ruangan
        draw_circle(Vector2.ZERO, 30.0 + sin(t * 3.0) * 2.0, Color(0.6, 0.85, 1.0, 0.18))
        draw_circle(Vector2.ZERO, 14.0 + sin(t * 4.0) * 1.5, Color(1, 1, 1, 0.35))
        _label(-38.0, 100.0)
        return
    if tex != null:
        draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.35))
        draw_circle(Vector2.ZERO, 9.0, Color(0, 0, 0, 0.25))
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        draw_texture(tex, Vector2(-tex.get_width() / 2.0, -tex.get_height()))
        _label(-tex.get_height() - 3.0, 80.0)
        return
    draw_circle(Vector2(0, -2), 9, color)
    draw_circle(Vector2(0, 2), 6, Color("ffe6d9"))
    _label(-14.0, 60.0)
