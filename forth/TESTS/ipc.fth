\ TESTS/ipc.fth - IPC : sémaphores (1800-1803) et atomiques (1822-1823)
\ Valeurs attendues en commentaire. Mot : test-ipc (auto-exécuté en fin de fichier).
\ Prérequis : aucun.
\ ATTENTION : sem:wait est bloquant borné. On ne l'appelle ICI que sur des
\ sémaphores dont le compteur est déjà > 0 (retour immédiat). Pour tester le
\ blocage, voir la doc : un sem:wait sur compteur 0 pompe le step_callback
\ jusqu'à préemption/timeout et renvoie 0 (non acquis).

\ ---------- Tests ----------
: test-ipc
  \ --- sem:create ( n -- sid ) ---
  2 sem:create dup .            \ <sid>   (premier sid, jamais 0)
  constant S1

  \ --- sem:wait sur compteur pré-chargé (retour immédiat, ok=-1) ---
  S1 sem:wait .                 \ -1  (acquis, compteur 2 -> 1)
  S1 sem:wait .                 \ -1  (compteur 1 -> 0)
  S1 sem:wait .                 \ 0   (compteur 0 : non acquis car borné)

  \ --- sem:post ( sid -- ok ) ---
  S1 sem:post .                 \ -1  (compteur 0 -> 1)
  S1 sem:wait .                 \ -1  (re-acquis immédiat)

  \ --- sid invalides : sem:wait/sem:post/sem:destroy renvoient 0 ---
  0 sem:wait .                  \ 0
  0 sem:post .                  \ 0
  0 sem:destroy .               \ 0
  9999 sem:post .               \ 0

  \ --- sem:create avec compteur 0 : wait bloque (testé manuellement), post libère ---
  0 sem:create dup .            \ <sid2>
  constant S2
  S2 sem:post .                 \ -1  (0 -> 1, libère un futur wait)
  S2 sem:wait .                 \ -1  (1 -> 0, acquis immédiat)

  \ --- sem:destroy ( sid -- ok ) ---
  S2 sem:destroy .              \ -1
  S2 sem:post .                 \ 0   (sid libéré : invalide)

  \ --- atomiques : adresses dans la mémoire scratch (ici) ---
  \ atomic:add ( addr n -- old ) : octet, retour ancienne valeur
  here 0 c!                     \ byte = 0
  here   5 atomic:add .         \ 0    (ancien)
  here   3 atomic:add .         \ 5
  here 250 atomic:add .         \ 8    (8+250 = 258 -> wrap 8-bit = 2)
  here  c@ .                    \ 2    (contenu octet après wrap)

  \ atomic:cas ( addr old new -- ok ) : -1 si remplacé, 0 sinon
  here   2   9 atomic:cas .     \ -1   (old=2 correspondait)
  here  c@ .                    \ 9    (contenu = 9)
  here   1   0 atomic:cas .     \ 0    (old=1 ne correspondait pas)
  here  c@ .                    \ 9    (inchangé)

  \ --- motif spinlock classique : verrou = octet, 0=libre / 1=pris ---
  here  0 1 atomic:cas .        \ -1   (acquérir)
  here  0 1 atomic:cas .        \ 0    (déjà pris)
  here  1 0 atomic:cas .        \ -1   (relâcher)
  here  0 1 atomic:cas .        \ -1   (ré-acquérir)
  here  1 0 atomic:cas .        \ -1   (relâcher)

  \ --- atomic:add sur adresse hors sandbox : renvoie 0 (bloqué) ---
  -1 1 atomic:add .             \ 0    (check_mem refuse)
;
\ Certains appels sémaphores sont destructifs (destroy) : on n'utilise plus S2 après.
\ S1 n'est pas détruit pour permettre d'éventuels tests manuels post-fichier.
test-ipc
