\ TESTS/audio.fth - Audio PCM streaming (1000-1003) + avance (1004-1022)
\ Valeurs attendues en commentaire. Mot : test-audio (auto-execute en fin de fichier).
\ Prerequis :
\   - audio:format / wav:info / audio:mix / audio:channels : validation pure,
\     testables SANS controleur HDA.
\   - audio:avail / audio:write / wav:play / beep:hz / audio:pause / audio:gain :
\     sans HDA -> avail=0, write=0, play=0 (retour rapide, pas de boucle),
\     pause/gain no-op.
\ Note memoire : `here` designe le sandbox `memory[]` (un octet par cellule).
\ `c,` ecrit dans `here` ; `@`/`!` lisent/ecrivent ces cellules. `c@`/`c!`
\ accedent a des adresses REELLES (MMIO) et ne doivent PAS servir ici.

variable W-ADDR    \ adresse de debut du dernier en-tete WAV construit
variable W-LEN     \ longueur totale du dernier en-tete WAV
variable MIX-BASE  \ base des buffers de test audio:mix

\ ── helpers pour construire un en-tete WAV dans `here` ──
: le16 ( v -- ) dup 255 and c, 8 rshift drop ;
: le32 ( v -- )
  dup 255 and c,
  8 rshift dup 255 and c,
  8 rshift dup 255 and c,
  8 rshift drop ;

\ Construit un WAV 44.1 kHz stereo 16-bit, 100 octets de donnees.
\ Retourne ( addr len ) ; addr = here au debut (= W-ADDR @).
: wav-test-header ( -- addr len )
  here W-ADDR !
  here >r
  \ RIFF + taille(36+100) + WAVE
  82 c, 73 c, 70 c, 70 c,
  136 le32
  87 c, 65 c, 86 c, 69 c,
  \ fmt  (16, PCM, 2 canaux, 44100, byte rate, align, 16 bits)
  102 c, 109 c, 116 c, 32 c,
  16 le32
  1 le16
  2 le16
  44100 le32
  176400 le32
  4 le16
  16 le16
  \ data + 100 octets de zeros
  100 c, 97 c, 116 c, 97 c,
  100 le32
  100 0 do 0 c, loop
  r> dup here rot -       \ ( addr len )
  dup W-LEN !
;

\ Écrit un echantillon i16 LE a l'adresse `a` (valeur signee en entree).
\ (v a -- ) ; `8 rshift` est logique, `256 mod` redonne le bon octet haut.
: s16! ( v a -- )
  dup 1 + >r
  dup 256 mod swap !
  8 rshift 256 mod
  r> !
;

: test-audio
  \ ── audio:format ( rate channels bits -- ok? ) ──
  44100 2 16 audio:format .        \ -1  (44.1 kHz stereo 16-bit)
  48000 2 16 audio:format .        \ -1
  44100 1 16 audio:format .        \ -1  (mono)
  44100 2 24 audio:format .        \ -1  (24-bit)
  48000 1 24 audio:format .        \ -1
  32000 2 16 audio:format .        \ 0   (taux invalide)
  96000 2 16 audio:format .        \ 0   (taux invalide)
  44100 3 16 audio:format .        \ 0   (3 canaux invalide)
  44100 0 16 audio:format .        \ 0   (0 canal invalide)
  44100 2 8  audio:format .        \ 0   (8-bit invalide)

  \ ── audio:channels ( n -- ) : sans HDA no-op (format courant (0,0,0) -> refus) ──
  1 audio:channels
  2 audio:channels
  0 audio:channels                \ invalide : ignore
  3 audio:channels                \ invalide : ignore
  44100 2 16 audio:format .       \ -1 : (re)met un format valide

  \ ── audio:queued ( -- n ) : 0 sans HDA ──
  audio:queued .                  \ 0

  \ ── audio:avail ( -- space ) : 0 sans HDA ──
  audio:avail .                   \ 0

  \ ── audio:write ( addr len -- n ) : addr nulle / len nulle -> 0 ──
  0 0 audio:write .               \ 0
  0 1000 audio:write .            \ 0
  1000 0 audio:write .            \ 0

  \ ── audio:pause / audio:gain : no-op sans HDA (aucun retour) ──
  -1 audio:pause
  0 audio:pause
  -6.0 audio:gain
  -20.0 audio:gain
  0.0 audio:gain

  \ ── wav:info ( addr len -- ch rate bits data_addr data_len ) ──
  wav-test-header 2drop          \ ( ) ; addr/longueur gardes dans W-ADDR/W-LEN
  W-ADDR @ W-LEN @ wav:info      \ ( ch rate bits data_addr data_len )
  dup 100 = .                    \ -1 : data_len = 100
  drop                           \ ( ch rate bits data_addr )
  W-ADDR @ -                     \ data_addr - start
  44 = .                         \ -1 : offset data = 44
  16 = .                         \ -1 : bits = 16
  44100 = .                      \ -1 : rate = 44100
  2 = .                          \ -1 : channels = 2

  \ Erreur : len trop courte -> channels = 0xFFFF (marqueur), puis 4 zeros
  0 4 wav:info . . . . .         \ 0 0 0 0 65535  (ordre pile : data_len..ch)
  0 0 wav:info . . . . .         \ 0 0 0 0 65535  (len nulle)

  \ ── wav:play ( addr len -- ok? ) : 0 sans HDA, retour rapide ──
  W-ADDR @ W-LEN @ wav:play .    \ 0

  \ le parse reste ok sur le meme buffer (wav:play n'a rien corrompu)
  W-ADDR @ W-LEN @ wav:info      \ ( ch rate bits data_addr data_len )
  drop drop drop drop            \ ( ch )
  65535 <> .                     \ -1 : parse ok

  \ ── beep:hz ( freq dur -- ok? ) : 0 sans HDA, retour rapide ──
  440 100 beep:hz .              \ 0
  0 100 beep:hz .                \ 0  (freq 0 invalide)
  440 0 beep:hz .                \ 0  (dur 0 invalide)

  \ ── audio:mix ( dst src len vol -- ) : mixage additif 16-bit LE ──
  here MIX-BASE !                \ MIX-BASE = base libre du sandbox
  \ buffers : 4 echantillons, dst = {0,0,30000,0}, src = {100, 200, 30000, -100}
  0 MIX-BASE @ s16!              0 MIX-BASE @ 2 + s16!  30000 MIX-BASE @ 4 + s16!  0 MIX-BASE @ 6 + s16!
  100 MIX-BASE @ 8 + s16!        200 MIX-BASE @ 10 + s16!  30000 MIX-BASE @ 12 + s16!  -100 MIX-BASE @ 14 + s16!
  MIX-BASE @ MIX-BASE @ 8 + 4 100 audio:mix
  MIX-BASE @ @ 100 = .           \ -1 : ech0 = 0 + 100*100/100 = 100
  MIX-BASE @ 1 + @ 0 = .         \ -1 : partie haute = 0
  MIX-BASE @ 2 + @ 200 = .       \ -1 : ech1 = 200
  MIX-BASE @ 3 + @ 0 = .         \ -1
  MIX-BASE @ 4 + @ 255 = .       \ -1 : ech2 = 30000+30000 -> sature a 32767 (low 0xFF)
  MIX-BASE @ 5 + @ 127 = .       \ -1 : (high 0x7F)
  MIX-BASE @ 6 + @ 156 = .       \ -1 : ech3 = -100 (low 0x9C)
  MIX-BASE @ 7 + @ 255 = .       \ -1 : (high 0xFF)

  \ volume 50 : 100 -> 50, 200 -> 100
  here MIX-BASE !
  0 MIX-BASE @ s16!              0 MIX-BASE @ 2 + s16!
  100 MIX-BASE @ 8 + s16!        200 MIX-BASE @ 10 + s16!
  MIX-BASE @ MIX-BASE @ 8 + 2 50 audio:mix
  MIX-BASE @ @ 50 = .            \ -1
  MIX-BASE @ 2 + @ 100 = .       \ -1

  \ vol > 100 : clampe a 100 dans le handler
  here MIX-BASE !
  0 MIX-BASE @ s16!
  100 MIX-BASE @ 8 + s16!
  MIX-BASE @ MIX-BASE @ 8 + 2 200 audio:mix
  MIX-BASE @ @ 100 = .           \ -1 : 100*200/100 -> clampe vol a 100%

  \ longueur impaire : refuse (aucun octet ecrit)
  here MIX-BASE !
  0 MIX-BASE @ s16!              123 MIX-BASE @ 2 + s16!
  99 MIX-BASE @ 8 + s16!         99 MIX-BASE @ 10 + s16!
  MIX-BASE @ MIX-BASE @ 8 + 5 100 audio:mix
  MIX-BASE @ @ 0 = .             \ -1 : inchange (dst conserve 0)
  MIX-BASE @ 2 + @ 123 = .       \ -1 : inchange
;
\ Remarque : sur HDA present, un vrai test de streaming consisterait a
\   allouer une page reelle (0 brk sbrk), y generer des echantillons (l!),
\   puis boucler audio:write pendant ~1 s (le DMA rejoue le ring en continu).
test-audio
