# ShiroAkari
Game 2D top-down (Godot 4.3+, GDScript). Prototipe: Loading -> Menu -> Input Nama -> Guild.

## Cara jalan
1. Buka `project.godot` dengan Godot 4.3+ (versi standar, bukan .NET), tekan F5.
2. Kontrol: Panah/WASD jalan, Z/Spasi/Enter bicara, J pedang, K sihir, Esc ke menu.

## Isi
- HP 5 bar (10 satuan setengah bar), kena slime = -0.5 bar, kebal 1 detik.
- Slime merah 2 tebasan (6 XP), warna lain 1 tebasan (3 XP). Sihir = 1 hit, cooldown 0.8 dtk.
- Dialog di `data/dialog/id.txt`, mendukung `{player}`.
- Save satu file (`user://save.json`), tombol Lanjut di menu.
- Semua gambar masih placeholder (digambar lewat kode). Slime uji coba ada di guild (`DEBUG_SLIMES` di `scripts/guild.gd`).

## Mengganti aset
- Latar judul: simpan `assets/title_bg.png` (640x360 atau 16:9, tanpa teks logo).
- Sprite: ganti `_draw()` di `player.gd`, `enemy.gd`, `npc.gd` dengan Sprite2D/AnimatedSprite2D.

## Ekspor web + GitHub Pages
1. Project > Export > Add > Web (unduh export templates bila diminta). Matikan **Thread Support**.
2. Export ke folder `docs/` dengan nama `index.html`.
3. Push ke GitHub, lalu Settings > Pages > Branch main, folder `/docs`.
