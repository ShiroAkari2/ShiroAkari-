# ShiroAkari
Game 2D top-down (Godot 4.3+, GDScript). Prototipe: Loading -> Menu -> Input Nama -> Guild.

## Cara jalan
1. Buka `project.godot` dengan Godot 4.3+ (versi standar, bukan .NET), tekan F5.
2. Kontrol: Panah/WASD jalan, Z/Spasi/Enter bicara, J pedang, K cahaya (pakai mana), Esc ke menu.
   Di HP/layar sentuh, tombol virtual muncul otomatis.

## Alur
Daftar ke Marla -> Arena Latihan terbuka (slime muncul terus, maks 4 sekaligus) -> naik level -> pulihkan HP/mana di Kolam Cahaya.

## Statistik
| Level | XP ke level berikut | Total XP | HP maks (bar) | Mana maks | Pedang | Cahaya |
|---|---|---|---|---|---|---|
| 1 | 8 | 0 | 5,0 | 5 | 1 | 2 |
| 2 | 16 | 8 | 5,5 | 5 | 1 | 2 |
| 3 | 28 | 24 | 6,0 | 6 | 2 | 2 |
| 4 | 44 | 52 | 6,5 | 6 | 2 | 2 |
| 5 | 64 | 96 | 7,0 | 6 | 2 | 3 |
| 6 | 88 | 160 | 7,5 | 7 | 2 | 3 |
| 7 | 116 | 248 | 8,0 | 7 | 3 | 3 |
| 8 | 148 | 364 | 8,5 | 7 | 3 | 3 |
| 9 | 184 | 512 | 9,0 | 8 | 3 | 4 |
| 10 | 224 | 696 | 9,5 | 8 | 3 | 4 |
| 11 | 268 | 920 | 10,0 | 8 | 3 | 4 |
| 12 | 316 | 1188 | 10,5 | 9 | 3 | 4 |
| 13 | 368 | 1504 | 11,0 | 9 | 4 | 4 |
| 14 | 424 | 1872 | 11,5 | 9 | 4 | 4 |
| 15 | 484 | 2296 | 12,0 | 10 | 4 | 5 |
| 16 | 548 | 2780 | 12,5 | 10 | 4 | 5 |
| 17 | 616 | 3328 | 13,0 | 10 | 4 | 5 |
| 18 | 688 | 3944 | 13,5 | 11 | 5 | 5 |
| 19 | 764 | 4632 | 14,0 | 11 | 5 | 5 |
| 20 | MAKS | 5396 | 14,5 | 11 | 5 | 5 |

Rumus XP: `8 + 6n + 2n^2` dengan n = level - 1 (berlaku sampai Lv 19 -> 20). Naik level memulihkan HP & mana penuh.

| Musuh | HP | XP | Kecepatan | Sentuhan | Perilaku | Muncul mulai |
|---|---|---|---|---|---|---|
| Slime Biru | 2 | 3 | 52 | 0,5 bar | mengejar | Lv 1 |
| Slime Hijau | 3 | 5 | 40 | 0,5 bar | menerjang | Lv 2 |
| Goblin | 3 | 5 | 62 | 0,5 bar | mengejar | Lv 2 |
| Kerangka | 4 | 6 | 46 | 0,5 bar | mengejar | Lv 3 |
| Binatang Liar | 3 | 5 | 72 | 0,5 bar | menerjang cepat | Lv 3 |
| Slime Merah | 5 | 8 | 62 | 1 bar | mengejar | Lv 4 |
| Orc Pemanah | 4 | 8 | 48 | 0,5 bar | menjaga jarak, menembak panah | Lv 4 |
| Serigala | 6 | 10 | 70 | 1 bar | menerjang | Lv 5 |
| Hob Goblin | 6 | 10 | 56 | 1 bar | mengejar | Lv 5 |
| Orc Dukun | 6 | 12 | 40 | 0,5 bar (bola sihir 1 bar) | menjaga jarak, menembak bola sihir | Lv 6 |
| High Goblin | 8 | 12 | 54 | 1 bar | mengejar | Lv 6 |
| Kerangka Ksatria | 10 | 16 | 38 | 1 bar | mengejar (lambat, tebal) | Lv 7 |
| Ksatria Orc | 12 | 18 | 34 | 1,5 bar | mengejar (sangat tebal) | Lv 8 |
| Chimera | 10 | 20 | 62 | 1,5 bar | menerjang | Lv 8 |
| **Ksatria Maut (bos)** | 30 | 60 | 48 | 2 bar | menerjang; muncul tiap ~50 dtk, satu sekaligus | Lv 9 |
| Serigala Kelam | 14 | 30 | 80 | 1,5 bar | menerjang | Lv 10 |
| Troll Batu | 22 | 45 | 36 | 1,5 bar | mengejar (lambat, tebal) | Lv 12 |
| Hantu Kelana | 12 | 40 | 58 | 1 bar (tembakan 1 bar) | menjaga jarak, menembak | Lv 13 |
| Panglima Orc | 18 | 50 | 44 | 1,5 bar | mengejar | Lv 14 |
| Gargoyle | 16 | 55 | 60 | 1,5 bar | menerjang | Lv 16 |
| Golem Batu | 26 | 70 | 30 | 2 bar | mengejar (sangat lambat, sangat tebal) | Lv 18 |

Musuh yang sudah lewat 5 level dari level munculnya berhenti muncul, jadi arena berisi lawan yang sepadan. Bila tidak ada musuh yang cocok di suatu level, arena memakai jenis non-bos dengan level tertinggi yang sudah lewat (cadangan; sejak tier 2 semua level 1-20 sudah punya musuh). Semua musuh didefinisikan di tabel `TYPES` di `scripts/enemy.gd` (tambah musuh = tambah satu baris + dua gambar `assets/enemies/<nama>_a.png` dan `_b.png`).

- Pemain 110 px/dtk. Kena serangan = knockback + kebal 1 detik.
- XP musuh turun 15% per level di atas level rekomendasi (minimal 20%): anti-grinding.
- Pingsan: kehilangan 25% XP level berjalan, HP/mana penuh, kembali ke spawn, slime dibersihkan.
- Slime punya peluang 12% menjatuhkan hati (+1 bar HP).
- Pedang: cooldown 0,35 dtk, jarak 34 px, busur +-52 derajat (sama dengan visual).
- Cahaya Akari: 1 mana, cooldown 0,6 dtk, jarak jauh, membuat musuh terpaku 0,8 dtk dan membatalkan terjangan. Mana pulih 0,5/dtk. Berhenti di tembok.

## Sistem
- Dialog di `data/dialog/id.txt`, mendukung `{player}`. Pemain dan musuh berhenti saat dialog.
- Save satu file (`user://save.json`, versi 2), autosave tiap 15 dtk + saat keluar. "Game Baru" meminta konfirmasi bila sudah ada save. Save lama (v1) tetap bisa dimuat.
- Semua gambar masih placeholder (digambar lewat kode).

## Aset
- Lobby: `assets/title_bg.png` (layar judul "Press to continue") dan `assets/menu_bg.png` (menu). Tombol menu sudah tergambar di gambar, jadi area klik transparan dipasang di atasnya (daftar `HOTSPOTS` di `scripts/menu.gd`). Kalau gambar menu diganti dan posisi tombol berubah, sesuaikan koordinatnya di sana.
- Sprite musuh: `assets/enemies/`. Pose `_a` dipakai saat pemain di bawah/samping musuh, pose `_b` saat pemain di atasnya.
- Slime, pemain, dan NPC masih placeholder yang digambar lewat kode (`_draw()`).
- Tombol "Characters" membuka daftar musuh (bestiary).
- Pertama kali membuka proyek di editor, Godot mengimpor gambar dulu (beberapa detik).

## Ekspor web + GitHub Pages
1. Project > Export > Add > Web (unduh export templates bila diminta). Matikan **Thread Support**.
2. Export ke folder `docs/` dengan nama `index.html`.
3. Push ke GitHub, lalu Settings > Pages > Branch main, folder `/docs`.
