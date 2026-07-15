\ ============================================================
\ FILEMAN_APP.FTH  —  Gestionnaire de fichiers
\ ============================================================
\ Crée via : app: Files 10 160 250 250 fileman-draw fileman-key
\ ============================================================

variable _fmx  variable _fmy  variable _fmw  variable _fmh

: fileman-draw ( wx wy ww wh -- )
  _fmy ! _fmx ! _fmw ! _fmh !

  \ Fond
  _fmx @ _fmy @ _fmw @ _fmh @ 0x1A1A2E fb:rect

  \ Titre
  _fmx @ 8 + _fmy @ 5 + 70 0xFFFFFF fb:text
  \ "FILES" en dur
  _fmx @ 16 + _fmy @ 5 + 70 0xFFFFFF fb:text
  _fmx @ 24 + _fmy @ 5 + 69 0xFFFFFF fb:text
  _fmx @ 32 + _fmy @ 5 + 76 0xFFFFFF fb:text
  _fmx @ 40 + _fmy @ 5 + 69 0xFFFFFF fb:text

  \ Ligne séparatrice
  _fmx @ _fmy @ 24 + _fmx @ _fmy @ 24 + _fmx @ _fmw @ + FG fb:line

  \ Info disque
  _fmx @ 8 + _fmy @ 35 + 85 0xBBBBBB fb:text
  _fmx @ 16 + _fmy @ 35 + 68 0xBBBBBB fb:text

  \ Liste de fichiers (simulée)
  _fmx @ 8 + _fmy @ 55 + 46 0x00CCFF fb:text
  _fmx @ 16 + _fmy @ 55 + 79 0x00CCFF fb:text
  _fmx @ 24 + _fmy @ 55 + 84 0x00CCFF fb:text

  _fmx @ 8 + _fmy @ 75 + 35 0x00CCFF fb:text
  _fmx @ 16 + _fmy @ 75 + 70 0x00CCFF fb:text
  _fmx @ 24 + _fmy @ 75 + 75 0x00CCFF fb:text
  _fmx @ 32 + _fmy @ 75 + 65 0x00CCFF fb:text

  \ Espace disque (barre)
  _fmx @ 8 + _fmy @ _fmh @ 20 - _fmw @ 16 - 8 0x333344 fb:rect
  _fmx @ 8 + _fmy @ _fmh @ 20 - _fmw @ 2 / 8 0x00AA66 fb:rect
  drop drop drop drop ;

: fileman-key ( char -- ) drop ;
: fileman-click ( x y -- ) 2drop ;
