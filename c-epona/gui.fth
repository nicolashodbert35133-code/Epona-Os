\ ==============================================================================
\ c-epona/gui.fth - Framework Objet GUI 60 FPS pour C-Épona
\ ==============================================================================

INCLUDE c-epona/oof.fth

\ Primitive binding vers le kernel Epona OS
: C-DRAW-RECT ( x y w h color -- ) DRAW-RECT-FILL ;
: C-DRAW-TEXT ( x y text-addr len color -- ) DRAW-STRING-UTF8 ;

\ Classe de base Component (Objet GUI)
CLASS: Component
    INT-FIELD: Comp.X
    INT-FIELD: Comp.Y
    INT-FIELD: Comp.W
    INT-FIELD: Comp.H
    INT-FIELD: Comp.Visible

\ Classe Window dérivée de Component
CLASS: Window
    INHERITS: Component
    PTR-FIELD: Win.Title
    INT-FIELD: Win.BgColor

: WIN-INIT ( title-addr w h obj -- )
    >R
    R@ Comp.W !
    R@ Comp.H !
    0 R@ Comp.X !
    0 R@ Comp.Y !
    SWAP R@ Win.Title !
    0x1E1E2E R@ Win.BgColor !
    1 R> Comp.Visible !
;

: WIN-RENDER ( obj -- )
    >R
    R@ Comp.X @ R@ Comp.Y @ R@ Comp.W @ R@ Comp.H @ R@ Win.BgColor @ C-DRAW-RECT
    R@ Comp.X @ 10 + R@ Comp.Y @ 10 + R@ Win.Title @ DUP STRLEN 0xFFFFFF C-DRAW-TEXT
    RDROP
;

\ Classe Button
CLASS: Button
    INHERITS: Component
    PTR-FIELD: Btn.Label
    PTR-FIELD: Btn.OnClick

: BTN-INIT ( label-addr x y w h obj -- )
    >R
    R@ Comp.H !
    R@ Comp.W !
    R@ Comp.Y !
    R@ Comp.X !
    R@ Btn.Label !
    1 R> Comp.Visible !
;

: BTN-RENDER ( obj -- )
    >R
    R@ Comp.X @ R@ Comp.Y @ R@ Comp.W @ R@ Comp.H @ 0x313244 C-DRAW-RECT
    R@ Comp.X @ 10 + R@ Comp.Y @ 8 + R@ Btn.Label @ DUP STRLEN 0x89B4FA C-DRAW-TEXT
    RDROP
;

\ Composant ImageWidget pour afficher des images PNG/BMP dans la GUI
CLASS: ImageWidget
    INHERITS: Component
    PTR-FIELD: ImgW.ImageObj

: IMGW-INIT ( img-obj x y w h obj -- )
    >R
    R@ Comp.H !
    R@ Comp.W !
    R@ Comp.Y !
    R@ Comp.X !
    R@ ImgW.ImageObj !
    1 R> Comp.Visible !
;

: IMGW-RENDER ( obj -- )
    >R
    R@ ImgW.ImageObj @ DUP 0<> IF
        R@ Comp.X @ R@ Comp.Y @ R@ Comp.W @ R@ Comp.H @ ROT IMG-DRAW-SCALE
    ELSE
        DROP
    THEN
    RDROP
;

\ Composant TextArea (Zone d'édition de code texte pour IDE / Éditeur)
CLASS: TextArea
    INHERITS: Component
    PTR-FIELD: TextA.Buffer
    INT-FIELD: TextA.Length
    INT-FIELD: TextA.CursorPos

: TEXTA-INIT ( x y w h obj -- )
    >R
    R@ Comp.H !
    R@ Comp.W !
    R@ Comp.Y !
    R@ Comp.X !
    65536 ALLOCATE THROW R@ TextA.Buffer !
    0 R@ TextA.Length !
    0 R@ TextA.CursorPos !
    1 R> Comp.Visible !
;

: TEXTA-RENDER ( obj -- )
    >R
    R@ Comp.X @ R@ Comp.Y @ R@ Comp.W @ R@ Comp.H @ 0x181825 C-DRAW-RECT
    R@ Comp.X @ 5 + R@ Comp.Y @ 5 + R@ TextA.Buffer @ R@ TextA.Length @ 0xCDD6F4 C-DRAW-TEXT
    RDROP
;

\ Composant DesktopManager (Gestionnaire de bureau & Fenêtres multiples Epona OS)
CLASS: DesktopManager
    PTR-FIELD: Desk.ActiveWindow
    PTR-FIELD: Desk.WallpaperImage

: DESK-INIT ( obj -- )
    >R
    0 R@ Desk.ActiveWindow !
    0 R> Desk.WallpaperImage !
;

: DESK-RENDER-DESKTOP ( obj -- )
    >R
    \ Rendu du fond de bureau 60 FPS
    0 0 1024 768 0x11111B C-DRAW-RECT
    \ Dessin de la barre des tâches style VS Code / Épona OS
    0 736 1024 32 0x1E1E2E C-DRAW-RECT
    0 736 " [EPONA OS] Start | EponaCode IDE | USB Drive: /usb0 " STRLEN 0x89B4FA C-DRAW-TEXT
    RDROP
;


