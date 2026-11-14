extends Control

func _ready():
    var bg := ColorRect.new()
    bg.size = Vector2(640, 360)
    bg.color = Color("1f2540")
    add_child(bg)
    var l := Label.new()
    l.text = "Siapa namamu?"
    l.position = Vector2(0, 110)
    l.size = Vector2(640, 30)
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(l)
    var le := LineEdit.new()
    le.placeholder_text = "Hero"
    le.max_length = 12
    le.position = Vector2(220, 150)
    le.size = Vector2(200, 30)
    add_child(le)
    var b := Button.new()
    b.text = "Mulai"
    b.position = Vector2(270, 195)
    b.size = Vector2(100, 28)
    add_child(b)
    var go := func():
        Game.new_game(le.text)
        get_tree().change_scene_to_file("res://scenes/Guild.tscn")
    b.pressed.connect(go)
    le.text_submitted.connect(func(_t): go.call())
    le.grab_focus()
