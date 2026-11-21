extends RefCounted
# Dibuat otomatis dari sprite sheet. n=jumlah frame, ax/ay=titik kaki di dalam gambar (px).
const META := {
    "idle_down": {"n": 2, "ax": 18.6, "ay": 40.0, "w": 40, "h": 40},
    "idle_up": {"n": 2, "ax": 16.8, "ay": 40.1, "w": 35, "h": 40},
    "idle_left": {"n": 2, "ax": 16.0, "ay": 40.0, "w": 39, "h": 40},
    "idle_right": {"n": 2, "ax": 18.7, "ay": 40.0, "w": 35, "h": 40},
    "walk_down": {"n": 4, "ax": 16.4, "ay": 40.7, "w": 32, "h": 41},
    "walk_up": {"n": 4, "ax": 14.3, "ay": 40.0, "w": 30, "h": 40},
    "walk_left": {"n": 5, "ax": 10.8, "ay": 41.1, "w": 26, "h": 41},
    "walk_right": {"n": 5, "ax": 18.5, "ay": 40.2, "w": 36, "h": 41},
    "sword_down": {"n": 4, "ax": 30.3, "ay": 44.4, "w": 60, "h": 46},
    "sword_up": {"n": 4, "ax": 20.1, "ay": 44.8, "w": 46, "h": 46},
    "sword_left": {"n": 4, "ax": 18.7, "ay": 41.4, "w": 38, "h": 46},
    "sword_right": {"n": 4, "ax": 25.0, "ay": 43.8, "w": 64, "h": 53},
    "cast_down": {"n": 3, "ax": 21.2, "ay": 40.7, "w": 53, "h": 45},
    "cast_up": {"n": 3, "ax": 16.3, "ay": 40.0, "w": 39, "h": 45},
    "cast_left": {"n": 3, "ax": 19.3, "ay": 44.1, "w": 40, "h": 48},
    "cast_right": {"n": 3, "ax": 30.4, "ay": 47.4, "w": 80, "h": 54},
    "hurt": {"n": 2, "ax": 20.5, "ay": 40.0, "w": 52, "h": 40},
    "faint": {"n": 2, "ax": 37.6, "ay": 35.2, "w": 76, "h": 35},
}
