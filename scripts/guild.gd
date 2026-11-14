extends Node2D
const DEBUG_SLIMES := true   # slime uji coba; ubah ke false untuk mematikan
const SPAWN := Vector2(320, 300)
var player
var hud
var target = null

func _ready():
    for r in [Rect2(0, 0, 640, 56), Rect2(0, 0, 16, 360), Rect2(624, 0, 16, 360),
              Rect2(0, 344, 290, 16), Rect2(350, 344, 290, 16), Rect2(290, 350, 60, 10),
              Rect2(270, 66, 100, 26),
              Rect2(96, 96, 48, 90), Rect2(96, 204, 48, 90), Rect2(496, 96, 48, 90), Rect2(496, 204, 48, 90)]:
        _wall(r)
    _npc("Marla", "marla", Color("e8d9a0"), Vector2(320, 60))
    _npc("Sena", "sena", Color("e89a50"), Vector2(200, 150))
    _npc("Dion", "dion", Color("5fa86f"), Vector2(450, 260))
    _npc("Elda", "elda", Color("6a7fd0"), Vector2(260, 320))
    var door = _npc("", "pintu", Color("8a5a3a"), Vector2(320, 338))
    door.is_object = true
    if DEBUG_SLIMES:
        for s in [["blue", Vector2(400, 200)], ["red", Vector2(380, 250)], ["green", Vector2(430, 160)]]:
            var e = preload("res://scripts/enemy.gd").new()
            e.kind = s[0]
            e.position = s[1]
            add_child(e)
    player = preload("res://scripts/player.gd").new()
    player.position = SPAWN
    add_child(player)
    player.died.connect(_on_died)
    hud = preload("res://scripts/hud.gd").new()
    add_child(hud)
    hud.dialog_finished.connect(_on_dialog_done)

func _wall(r: Rect2):
    var b := StaticBody2D.new()
    var c := CollisionShape2D.new()
    var s := RectangleShape2D.new()
    s.size = r.size
    c.shape = s
    b.position = r.position + r.size / 2.0
    b.add_child(c)
    add_child(b)

func _npc(n: String, id: String, col: Color, pos: Vector2):
    var o = preload("res://scripts/npc.gd").new()
    o.npc_name = n
    o.dialog_id = id
    o.color = col
    o.position = pos
    add_child(o)
    return o

func _nearest_npc():
    var best = null
    var bd := 52.0
    for n in get_tree().get_nodes_in_group("npc"):
        var d: float = n.global_position.distance_to(player.global_position)
        if d < bd:
            bd = d
            best = n
    return best

func _process(_d):
    if Input.is_action_just_pressed("ui_cancel"):
        Game.save_game()
        get_tree().change_scene_to_file("res://scenes/Menu.tscn")
        return
    if hud.active and target and target.global_position.distance_to(player.global_position) > 90.0:
        hud.end_dialog()
    if Input.is_action_just_pressed("interact"):
        if hud.active:
            hud.advance()
        else:
            target = _nearest_npc()
            if target:
                hud.start_dialog(target.get_dialog_id())

func _on_dialog_done(id: String):
    if id == "marla_register":
        Game.flags["registered"] = true
        Game.save_game()
        hud.notice("Terdaftar sebagai petualang!", 2.0)

func _on_died():
    hud.notice("Kamu pingsan...", 2.0)
    Game.hp = 10
    player.position = SPAWN
    player.inv_time = 1.5

func _draw():
    draw_rect(Rect2(0, 0, 640, 360), Color("b0d4e8"))
    draw_rect(Rect2(0, 0, 640, 56), Color("1f2540"))
    draw_rect(Rect2(270, 66, 100, 26), Color("3b4466"))
    for r in [Rect2(96, 96, 48, 90), Rect2(96, 204, 48, 90), Rect2(496, 96, 48, 90), Rect2(496, 204, 48, 90)]:
        draw_rect(r, Color("5a6a8a"))
    draw_rect(Rect2(24, 20, 40, 30), Color("7f8fb0"))
    draw_rect(Rect2(576, 20, 40, 30), Color("7f8fb0"))
    draw_rect(Rect2(16, 150, 10, 70), Color("a07850"))
    draw_rect(Rect2(614, 150, 10, 70), Color("a07850"))
    draw_rect(Rect2(0, 344, 290, 16), Color("1f2540"))
    draw_rect(Rect2(350, 344, 290, 16), Color("1f2540"))
