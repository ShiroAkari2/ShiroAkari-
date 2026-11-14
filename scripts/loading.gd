extends Control

func _ready():
    var bg := ColorRect.new()
    bg.size = Vector2(640, 360)
    bg.color = Color("1f2540")
    add_child(bg)
    var l := Label.new()
    l.text = "Memuat..."
    l.position = Vector2(40, 290)
    add_child(l)
    var bar := ProgressBar.new()
    bar.position = Vector2(40, 315)
    bar.size = Vector2(300, 14)
    bar.max_value = 100
    bar.show_percentage = false
    add_child(bar)
    var t := create_tween()
    t.tween_property(bar, "value", 100.0, 1.5)
    t.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/Menu.tscn"))
