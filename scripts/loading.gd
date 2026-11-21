extends Control
# Layar pertama: langsung tampilkan layar loading lalu masuk ke Menu.

func _ready():
    Game.goto("res://scenes/Menu.tscn", 2.4)
