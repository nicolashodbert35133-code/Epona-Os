\ ==============================================================================
\ c-epona/sdk/eponamedia.fth - Framework 2D/3D GPU & Audio 60 FPS pour C-Épona
\ ==============================================================================

INCLUDE c-epona/oof.fth

CLASS: Canvas3D
    INT-FIELD: Canvas.Width
    INT-FIELD: Canvas.Height
    PTR-FIELD: Canvas.Buffer

: CANVAS-INIT ( w h obj -- )
    >R
    R@ Canvas.Height !
    R@ Canvas.Width !
    R@ Canvas.Width @ R@ Canvas.Height @ * 4 * ALLOCATE THROW R@ Canvas.Buffer !
    RDROP
;

: CANVAS-CLEAR ( color obj -- )
    >R
    R@ Canvas.Buffer @ R@ Canvas.Width @ R@ Canvas.Height @ * 4 * ROT FILL-MEMORY
    RDROP
;

: CANVAS-SWAP ( obj -- )
    >R
    R@ Canvas.Buffer @ 0 0 R@ Canvas.Width @ R@ Canvas.Height @ BLIT-BUFFER
    RDROP
;

CLASS: AudioTrack
    INT-FIELD: Audio.Handle
    INT-FIELD: Audio.Volume

: AUDIO-PLAY ( sample-path-addr obj -- )
    >R
    AUDIO-PLAY-WAV
    RDROP
;

\ Classe Image Objet pour C-Épona (Support PNG/BMP/JPG & Alpha Blitting 60 FPS)
CLASS: Image
    INT-FIELD: Image.Width
    INT-FIELD: Image.Height
    INT-FIELD: Image.HasAlpha
    PTR-FIELD: Image.Buffer

: IMG-LOAD ( path-addr len obj -- success-flag )
    >R
    \ Fait appel aux primitives de décodage d'image natives d'Epona OS (LOAD-IMAGE-NAT)
    LOAD-IMAGE-NAT ( buffer w h alpha-flag )
    R@ Image.HasAlpha !
    R@ Image.Height !
    R@ Image.Width !
    R@ Image.Buffer !
    R@ Image.Buffer @ 0<>
    RDROP
;

: IMG-DRAW ( x y obj -- )
    >R
    R@ Image.Buffer @ DUP 0<> IF
        SWAP R@ Image.Width @ R@ Image.Height @ BLIT-BUFFER-ALPHA
    ELSE
        2DROP DROP
    THEN
    RDROP
;

: IMG-DRAW-SCALE ( x y target-w target-h obj -- )
    >R
    R@ Image.Buffer @ DUP 0<> IF
        BLIT-BUFFER-SCALED
    ELSE
        2DROP 2DROP DROP
    THEN
    RDROP
;

