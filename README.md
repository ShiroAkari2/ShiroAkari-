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

## Perubahan v9
- **Guild Petualang** memakai gambar `assets/guild_bg.png` (640x960). Ruangan lebih tinggi dari layar; kamera mengikuti pemain ke atas/bawah. Tabrakan (dinding, meja, papan misi, meja resepsionis) ada di konstanta `WALLS` di `scripts/guild.gd`. Guild sekarang **zona aman**: tidak ada musuh.
- **Padang Latihan** (`scenes/Field.tscn`, `scripts/field.gd`) = tempat bertarung. Pintu bawah guild menuju ke sana (setelah mendaftar di Marla); jalan ke atas untuk kembali. Gambar peta masih sederhana (digambar lewat kode).
- **Sprite player** dipotong dari sheet: `assets/player/<kunci>_<n>.png`. Daftar animasi dan titik kaki ada di `scripts/player_meta.gd` (idle, jalan, pedang, sihir, kena hit; pose pingsan/kalah sudah ada filenya tapi belum dipakai).
- **NPC**: Marla = `assets/npc/marla.png` (berkacamata), Sena = `npc06_pink`, Dion = `npc01_black`, Elda = `npc04_navy`. NPC lain (`npc02/03/07/08/09/10`) sudah dipotong dan siap dipakai.
- **Musuh**: sprite slime biru/hijau/merah dan musuh Tier 2 (Serigala Kelam, Troll Batu, Hantu Kelana, Panglima Orc, Gargoyle, Golem Batu) sudah dipasang. Bug teks `\n` di daftar karakter diperbaiki.
- Tinggi sprite musuh diatur lewat `"h"` di tabel `TYPES` (`scripts/enemy.gd`).

## Catatan
- Semua perubahan ditulis tanpa bisa menjalankan Godot, jadi bila muncul error merah, kirim teksnya.
- Gambar yang dihasilkan generator AI perlu diperhatikan terhadap aturan jam/lomba yang kamu ikuti.

## Update v10
- Layar loading baru (`assets/loading_bg.png` + `scripts/loading_overlay.gd`): semua pindah scene lewat `Game.goto(path)`, bar berjalan sesuai progres load nyata.
- Kota Skotice (`scenes/Skotice.tscn`, `scripts/skotice.gd`, `assets/skotice_bg.png`): zona aman. Area jalan diatur di `assets/skotice_mask.png` (80x120, 1 piksel = 8x8 px peta, putih = bisa dilewati). Mask dibuat otomatis dari warna jalan, jadi edit di editor gambar bila ada area yang kurang pas.
- Alur: Menu -> NameInput -> Guild (daftar ke Marla) -> pintu bawah Guild -> Skotice -> gerbang bawah kota -> Padang Latihan (musuh). Dari Padang Latihan jalan ke atas = kembali ke Skotice; pintu Guild di atas Skotice = masuk Guild. Pingsan = kembali ke Guild.
- `assets/guild_exterior.png`: tampak luar Guild (belum dipakai di kode, disimpan untuk referensi).

## Update v10.1
- NPC sekarang padat (tidak bisa ditembus): badan tabrakan di kaki NPC (`npc.gd`).
- Papan pengumuman guild (2 buah, ada tanda "!") bisa diajak interaksi: dialog pembuka lalu 5 pengumuman bergantian. Dialognya di akhir `data/dialog/id.txt` (`papan_*`). Terima/tolak misi dan quest log belum ada.
- Ukuran jendela game dikecilkan jadi 960x540 supaya muat di layar laptop. Di editor, buka tab Game > menu titik tiga > pilih "Keep Aspect" atau matikan "Embed Game on Next Play".

## Update v10.2
- Perbaikan gambar menu/loading yang tampil terlalu besar dan terpotong: urutan properti `TextureRect` diperbaiki di `menu.gd` dan `loading_overlay.gd` (expand_mode diatur sebelum texture dan size).

## Update v10.3
- Mask jalan Kota Skotice dibuat ulang: semua jalan (termasuk jalan melingkar krem di kiri dan kanan) dan tangga sekarang bisa dilewati; bangunan/pohon/pagar/tebing tetap terblokir. Edit `assets/skotice_mask.png` (80x120, putih = bisa dilewati) kalau ada yang kurang pas.

## Update v10.4
- NPC: tabrakan menutup badan (persegi 14x28), bukan hanya kaki.
- Urutan gambar mengikuti posisi kaki (y-sort) di Guild, Skotice, dan Padang Latihan: pemain di belakang NPC digambar di belakangnya, di depan digambar di depannya.

## Update v11
- **Kota Skotice baru**: `assets/skotice_bg.png` dan mask jalan `assets/skotice_mask.png` dibuat ulang dari peta baru (semua jalan dan tangga bisa dilewati; bangunan, pohon, pagar, air, tebing terblokir).
- **Peta dunia** (`assets/world_map.png`): tekan **M** di Guild, Skotice, atau Padang Latihan. Nama lokasi dan penanda posisi pemain diatur di `scripts/world_map.gd` (`LOCATIONS`, `HERE`).
- **Pintu keluar guild** sekarang ditahan dinding sungguhan sampai mendaftar di Marla (bukan lagi dipindahkan paksa).

## Update v11.1
- Perbaikan error parser di `world_map.gd` (membuat game gagal berjalan).
- Peta dunia diganti dengan versi berlabel (17 lokasi); tampil 1280x720 dan digeser dengan panah. Penanda emas = posisi pemain (Guild/Skotice = nomor 4, Padang Latihan = nomor 3). Posisi nomor ada di `NODES` pada `scripts/world_map.gd`.

## Update v11.2
- Nama kota **Eldoria diganti menjadi Meldon** di semua naskah dan dokumen (`data/dialog/id.txt`, `docs/`). Ejaan resmi: **Skotice** (bukan Scotice).
- Catatan: tulisan "Scotice" pada gambar `assets/world_map.png` masih ejaan lama karena menyatu dengan gambar; perlu digambar ulang kalau ingin dikoreksi.

## Update v11.5
- **Peta dunia baru** (`assets/world_map.png`, 1280x720): ejaan di gambar sudah dikoreksi jadi **Skotice** (dua label), dan atap bangunan Desa (nomor 2) diganti biru supaya sama dengan map Desa. Posisi nomor tidak berubah, jadi `NODES` di `world_map.gd` tetap berlaku.
- **Rumah pemain** (`scenes/Rumah.tscn`, `scripts/rumah.gd`, `assets/rumah_bg.png` 640x960): halaman rumah, kandang, kebun. Jalan tanah di kanan bawah = keluar ke Desa. Tabrakan ada di konstanta `WALLS`.
- **Desa** (`scenes/Desa.tscn`, `scripts/desa.gd`, `assets/desa_bg.png` 1024x685): tiga jalan keluar sesuai peta dunia: barat (label baru "Rumah") ke Rumah, tangga kanan atas ke Kota Skotice, selatan ke Kota Meldon (belum dibuat, pemain didorong balik dengan pesan). Jembatan kayu di kanan bawah ditutup karena hanya hiasan.
- **Alur baru**: Game Baru -> Rumah -> Desa -> Skotice (lewat jalan kanan atas Skotice) -> Guild. Skotice -> Padang Latihan sekarang butuh sudah mendaftar di Marla. "Lanjutkan" tanpa pendaftaran mulai dari Rumah.
- Titik muncul: `rumah_entry` dan `desa_entry` di `game.gd`. Nomor peta dunia: Rumah = 1, Desa = 2.
- Catatan skala: map Desa dipakai ukuran asli (sama dengan skala Skotice), map Rumah diperbesar 1,5x supaya memenuhi layar, jadi bangunan rumah tampak sedikit lebih besar daripada rumah di Desa. Kalau mau seragam, gambar ulang map Rumah dengan ukuran tile yang sama seperti Desa.
- Semua perubahan ditulis tanpa bisa menjalankan Godot; kalau muncul error merah, kirim teksnya.

## Update v11.6
- **Jalan ke Skotice** (nomor 3 di peta dunia): scene baru `scenes/Jalan.tscn`, `scripts/jalan.gd`, `assets/jalan_bg.png` (1024x577), mask jalan `assets/jalan_mask.png` (256x145, 1 piksel = 4x4 px, putih = bisa dilewati; edit PNG-nya kalau ada yang kurang pas).
- Alur diperbaiki: Rumah -> Desa -> (tangga kanan atas Desa) Jalan ke Skotice -> (tangga gerbang kanan atas) Kota Skotice. Gerbang bawah Skotice kembali ke Jalan. Padang Latihan sekarang lewat jalan kanan bawah di Jalan ke Skotice (butuh sudah mendaftar di Marla); dari Padang Latihan jalan ke atas = kembali ke Jalan.
- Jalan kanan atas Skotice tidak lagi dipakai ke Desa (kembali seperti semula).
- Tulisan "Jalan ke Kota Skotice", "Jalan ke Kota Meldon", dan "Rumah" di gambar Desa dihapus (diganti tekstur jalan asli). Pintu keluar sekarang dikenali dari bukaan jalannya dan dari pesan di layar.
- Titik muncul baru: `jalan_entry` di `game.gd`.
