extends Node2D
# kind: "npc" (orang), "door" (pintu keluar), "pond" (Kolam Cahaya: memulihkan HP & mana)
var npc_name := "NPC"
var dialog_id := ""
var color := Color.WHITE
var kind := "npc"
var t := 0.0

func _ready():
    add_to_group("npc")

func _process(delta):
    if kind == "pond":
        t += delta
        queue_redraw()

func get_dialog_id() -> String:
    if dialog_id == "marla":
        return "marla_idle" if Game.flags.get("registered", false) else "marla_register"
    return dialog_id

func _draw():
    if kind == "door":
        draw_rect(Rect2(-24, -4, 48, 8), color)
        return
    if kind == "pond":
        draw_circle(Vector2.ZERO, 24.0 + sin(t * 3.0) * 2.0, Color(0.45, 0.8, 1.0, 0.25))
        draw_circle(Vector2.ZERO, 16.0, Color(0.85, 0.96, 1.0, 0.85))
        draw_circle(Vector2.ZERO, 8.0 + sin(t * 4.0) * 1.5, Color.WHITE)
        draw_string(ThemeDB.fallback_font, Vector2(-40, -30), npc_name, HORIZONTAL_ALIGNMENT_CENTER, 80, 10)
        return
    draw_circle(Vector2(0, -2), 9, color)
    draw_circle(Vector2(0, 2), 6, Color("ffe6d9"))
    draw_string(ThemeDB.fallback_font, Vector2(-30, -14), npc_name, HORIZONTAL_ALIGNMENT_CENTER, 60, 10)
