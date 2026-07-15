\ ============================================================
\ DRIVER_AUDIO.FTH — Pilote Audio HD (HDA)
\ PCI: 03:00.1  V1002 D1637  class 04 subclass 03
\      03:00.5  V1022 D15e2  class 04 subclass 80
\      03:00.6  V1022 D15e3  class 04 subclass 03
\ ============================================================
\ Enveloppe les primitives Rust hda-* en mots Forth
\ utilisateur-friendly pour la gestion audio.
\
\ Charger : require DRIVER_AUDIO.FTH
\ Ou :     sys:load DRIVER_AUDIO.FTH
\ ============================================================

cr ." [AUDIO] Chargement pilote HD Audio AMD..." cr

\ ── Variables d'etat ─────────────────────────────────────────
variable audio-ok     0 audio-ok !
variable audio-vol    80 audio-vol !
variable audio-rate   48000 audio-rate !

\ ── Initialisation ───────────────────────────────────────────
: audio-init ( -- ok? )
    cr ." [AUDIO] Detection HD Audio (PCI 03:00.1/05/06)..." cr
    hda-init
    dup if
        1 audio-ok !
        ." [AUDIO] Codec detecte" cr
        hda-info
    else
        0 audio-ok !
        ." [AUDIO] Aucun codec HDA" cr
    then
;

\ ── Volume ───────────────────────────────────────────────────
: audio-volume ( v -- )
    dup 100 > if drop 100 then
    dup 0 < if drop 0 then
    audio-vol !
    audio-vol @ hda-volume
;

: audio-volume+ ( -- )
    audio-vol @ 10 + 100 min audio-vol !
    audio-vol @ hda-volume
;

: audio-volume- ( -- )
    audio-vol @ 10 - 0 max audio-vol !
    audio-vol @ hda-volume
;

: audio-volume@ ( -- v )
    audio-vol @
;

\ ── Lecture PCM ──────────────────────────────────────────────
\ Joue un buffer PCM 16-bit stereo
\ addr = adresse du buffer, len = nb octets, rate = freq echantillonnage
: audio-pcm ( addr len rate -- ok? )
    hda-play
;

\ ── Arret ────────────────────────────────────────────────────
: audio-arret ( -- )
    hda-stop
;

\ ── Bip ──────────────────────────────────────────────────────
\ Genere un bip a la frequence freq Hz pendant ms millisecondes
: audio-bip ( freq ms -- )
    hda-beep
;

\ ── Etat ─────────────────────────────────────────────────────
: audio-joue? ( -- playing? )
    hda-status
;

\ ── Infos ────────────────────────────────────────────────────
: audio-info ( -- )
    cr ." ╔═══════════════════════════════════╗" cr
    ." ║  Audio — HD Audio AMD              ║" cr
    ." ╚═══════════════════════════════════╝" cr
    audio-ok @ 0= if
        ."  Etat : NON INITIALISE" cr
        exit
    then
    ."  Volume    : " audio-vol @ . ." %" cr
    ."  Frequence : " audio-rate @ . ." Hz" cr
    ."  En cours  : " audio-joue? if ." OUI" else ." NON" then cr
    hda-info
;

\ ── Test ─────────────────────────────────────────────────────
: audio-test ( -- )
    cr ." [AUDIO] Test bip 440Hz..." cr
    440 500 audio-bip
    cr ." [AUDIO] Test bip 880Hz..." cr
    880 500 audio-bip
    cr ." [AUDIO] Test termine." cr
;

\ ── Enregistrement ───────────────────────────────────────────
sys:register audio

\ ── Init auto ────────────────────────────────────────────────
audio-init drop

cr ." [AUDIO] Pilote charge. Mots :" cr
."   audio-init      ( -- ok? )     initialiser codec" cr
."   audio-volume    ( v -- )       volume 0..100" cr
."   audio-volume+   ( -- )         volume + 10" cr
."   audio-volume-   ( -- )         volume - 10" cr
."   audio-volume@   ( -- v )       volume courant" cr
."   audio-pcm       ( a l r -- ok? ) jouer PCM" cr
."   audio-arret     ( -- )         arret lecture" cr
."   audio-bip       ( freq ms -- ) bip sonore" cr
."   audio-joue?     ( -- flag )    en cours?" cr
."   audio-info      ( -- )         afficher infos" cr
."   audio-test      ( -- )         test bips" cr
cr
