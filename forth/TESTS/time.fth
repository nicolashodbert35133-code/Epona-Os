\ TESTS/time.fth - Temps haute resolution + timers (600-604)
\ Valeurs attendues en commentaire. Mot : test-time (auto-execute en fin de fichier).
\ Prerequis : RTC UEFI (desktop.rt_ptr) pour time:unix / time:set-unix.
\   time:now / alarm:new / alarm:cancel fonctionnent sans RTC (base TSC).
\ ATTENTION : time:set-unix reecrit la RTC. Ce test fait un aller-retour
\ IDEMPOTENT (re-ecrit la valeur lue) : l'horloge n'est pas corrompue.
\ Le declenchement d'une alarme est DIFFERE (jamais pendant un mot Forth) :
\ il a lieu au prochain passage de la boucle principale / step_callback.
\ Ce test n'attend donc pas et verifie uniquement l'enregistrement/annulation.

\ Compteur d'executions pour alarm:new (espace scratch `here`, jamais variable)
here constant AHIT
0 AHIT !
: alarm-probe 1 AHIT @ 1 + AHIT ! ;

: test-time
  \ --- time:now ( -- s ns ) ---
  time:now dup .                  \ ns (0..999 999 999)
  dup dup 0 >= swap 1000000000 < and .   \ -1 : ns dans [0, 1e9)
  drop drop                       \ laisse s
  dup 0 >= .                      \ -1 : s >= 0
  drop

  \ --- time:now monotone (composite s*1e9+ns) ---
  time:now 1000000000 * +         \ N1
  time:now 1000000000 * +         \ N1 N2
  swap >= .                       \ -1 : N2 >= N1 (non decroissant)

  \ --- time:unix ( -- s ) ---
  time:unix dup .                 \ timestamp actuel (RTC)
  dup 1000000000 > .              \ -1 : post-2001
  drop

  \ --- time:set-unix ( s -- ) : aller-retour idempotent (meme seconde) ---
  time:unix dup time:set-unix time:unix swap - abs dup . 2 < .  \ diff puis -1 si < 2 s

  \ --- alarm:new ( ms xt -- aid ) / alarm:cancel ( aid -- ) ---
  1000 ' alarm-probe alarm:new dup .    \ aid (1..32, jamais 0)
  dup 0 > .                        \ -1 : aid valide
  dup alarm:cancel                 \ annule (slots purges)
  alarm:cancel                     \ re-annulation sans effet (no-op)
  1000 -1 alarm:new .              \ 0 : xt invalide
  -5 0 alarm:new .                 \ 0 : ms negatif
  AHIT @ .                         \ 0 : jamais declenche ici (differe)
;
test-time
