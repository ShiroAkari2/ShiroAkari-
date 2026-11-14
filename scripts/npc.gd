extends Node2D
var npc_name := "NPC"
var dialog_id := ""
var color := Color.WHITE
var is_object := false

func _ready():
    add_to_group("npc")

func get_dialog_id() -> String:
    if dialog_id == "marla":
        return "marla_idle" if Game.flags.get("registered", false) else "marla_register"
    return dialog_id

func _draw():
    if is_object:
        draw_rect(Rect2(-24, -4, 48, 8), color)
        return
    draw_circle(Vector2(0, -2), 9, color)
    draw_circle(Vector2(0, 2), 6, Color("ffe6d9"))
    draw_string(ThemeDB.fallback_font, Vector2(-30, -14), npc_name, HORIZONTAL_ALIGNMENT_CENTER, 60, 10)
