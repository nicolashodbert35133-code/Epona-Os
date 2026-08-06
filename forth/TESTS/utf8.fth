\ TESTS/utf8.fth - Primitives Unicode/UTF-8/polices 865-878
\ Valeurs attendues en commentaire. Mot : test-utf8 (auto-exécuté en fin de fichier).
\ Prérequis : police PSF1 minimale construite en byte_mem (8x8, 256 glyphes).

\ ---------- Construction d'une police PSF1 de test ----------
\ Header PSF1 : magic 0x36 0x04 | mode 0 (256 glyphes) | charsize 8 (8x8)
\ Puis 256 glyphes de 8 octets = 2048 octets. Total 2052.
\ glyphe 0 (offset 4) : pixel haut-gauche (0x80 sur 1re ligne)
\ glyphe 1 (offset 12) : plein (0xFF x8)

2052 balloc constant FONT

0x36 FONT       b!   \ magic 0
0x04 FONT 1 +   b!   \ magic 1
0x00 FONT 2 +   b!   \ mode : 256 glyphes, sans table unicode
0x08 FONT 3 +   b!   \ charsize = 8 (8x8)

0x80 FONT 4 +   b!   \ glyphe 0 : bit 7 = pixel en haut à gauche

: set-glyph1 ( -- )
  8 0 do
    0xFF FONT 12 + i + b!
  loop ;
set-glyph1

FONT 2052 font:load-psf constant FID

\ Tampon pour les tests utf8:encode/utf8:decode
10 balloc constant BUF

\ ---------- Tests ----------
: test-utf8
  \ --- utf8:encode / decode (é = U+00E9 = 2 octets C3 A9) ---
  BUF 0xE9 utf8:encode .   \ 2
  BUF 2 utf8:decode swap . .  \ 233 2  (cp=0xE9 size=2)
  BUF 0x41 utf8:encode .   \ 1
  BUF 1 utf8:decode swap . .  \ 65 1

  \ --- utf8:len (café = c a f é = 5 code points) ---
  s" café" utf8:len .      \ 5
  s" Hello" utf8:len .     \ 5

  \ --- up:case / down:case ---
  97  up:case   .          \ 65   ('a' -> 'A')
  65  down:case .          \ 97   ('A' -> 'a')
  0xE9 up:case .           \ 201  (é -> É = U+00C9)

  \ --- is:alpha? / is:digit? ---
  97 is:alpha?  .          \ -1
  49 is:digit?  .          \ -1
  43 is:digit?  .          \ 0    ('+')

  \ --- unicode:combining? ---
  0x301 unicode:combining? .  \ -1  (accent aigu combinant)
  0x41  unicode:combining? .  \ 0

  \ --- font:select / font:size ---
  FID font:select
  font:size swap . .      \ 8 8  (w h)

  \ --- font:measure ---
  s" café" font:measure . .  \ 40 8  (w = 5*8, h = 8)

  \ --- gfx:glyph (bitmap dans byte_mem, lecture via b@) ---
  0 gfx:glyph drop drop    \ -- addr (w h ignorés)
  b@ .                     \ 0x80 = 128 (bit haut-gauche du glyphe 0)
  1 gfx:glyph drop drop
  b@ .                     \ 0xFF = 255 (glyphe 1 plein)
;

test-utf8
