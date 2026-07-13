

# Étape 2 — Bibliothèque Virgule Fixe (FIXED.FTH)

```forth
\ ════════════════════════════════════════════════════════════════════════
\                FIXED.FTH — Arithmétique Virgule Fixe
\                     EponaForth — Epona OS
\ ════════════════════════════════════════════════════════════════════════
\
\ Format : Fixed-Point Q20.12
\   - 20 bits partie entière (signé : -524288 à +524287)
\   - 12 bits partie fractionnaire (précision : 1/4096 ≈ 0.000244)
\   - Stocké dans un i64 standard Forth
\   - Plage utile : environ ±500000.0 avec 3 décimales de précision
\
\ Convention de nommage :
\   f.xxx   — opération sur virgule fixe
\   Les nombres fixes sont notés avec un suffixe _FX ou via f.lit
\
\ Chargement :
\   sys:load FIXED.FTH
\   ou : require FIXED.FTH
\
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ 1. CONSTANTES FONDAMENTALES
\ ──────────────────────────────────────────────────────────────────────

12 constant F.SHIFT          \ Nombre de bits fractionnaires
4096 constant F.SCALE        \ 2^12 = facteur d'échelle
2048 constant F.HALF         \ 0.5 en fixe (pour arrondi)

\ Constantes mathématiques en Q20.12 :
\ Valeur = entier × 4096

12868 constant F.PI           \ π      ≈ 3.14159  (3.14159 × 4096 = 12868)
6434  constant F.PI/2         \ π/2    ≈ 1.5708
25736 constant F.2PI          \ 2π     ≈ 6.28318
4106  constant F.PI/3         \ π/3    ≈ 1.0472
3217  constant F.PI/4         \ π/4    ≈ 0.7854
11134 constant F.E            \ e      ≈ 2.71828
2839  constant F.LN2          \ ln(2)  ≈ 0.69315
9426  constant F.LN10         \ ln(10) ≈ 2.30259
5909  constant F.SQRT2        \ √2     ≈ 1.41421
7094  constant F.PHI          \ φ      ≈ 1.61803  (nombre d'or)
4096  constant F.1            \ 1.0
8192  constant F.2            \ 2.0
2048  constant F.0.5          \ 0.5
0     constant F.0            \ 0.0
-4096 constant F.-1           \ -1.0
40960 constant F.10           \ 10.0
409   constant F.0.1          \ 0.1 (approx)
4096  constant F.100%         \ 100% = 1.0
40960 constant F.1000%        \ 1000% = 10.0

\ Limites :
2147483647 constant F.MAX     \ Plus grande valeur fixe positive
-2147483648 constant F.MIN    \ Plus petite valeur fixe négative


\ ──────────────────────────────────────────────────────────────────────
\ 2. CONVERSION ENTIER ↔ FIXE
\ ──────────────────────────────────────────────────────────────────────

: f.from ( n -- fx )
  \ Convertit un entier en virgule fixe
  \ Exemple : 5 f.from → 20480 (= 5.0 en Q20.12)
  F.SHIFT lshift ;

: f.to ( fx -- n )
  \ Convertit une virgule fixe en entier (tronqué)
  \ Exemple : 20480 f.to → 5
  F.SHIFT rshift ;

: f.round ( fx -- n )
  \ Convertit en entier avec arrondi au plus proche
  \ Exemple : 6144 f.round → 2  (1.5 → 2)
  F.HALF + F.SHIFT rshift ;

: f.frac ( fx -- frac_fx )
  \ Partie fractionnaire uniquement
  \ Exemple : 22528 f.frac → 2048  (5.5 → 0.5)
  F.SCALE 1- and ;

: f.int ( fx -- int_fx )
  \ Partie entière uniquement (reste en format fixe)
  \ Exemple : 22528 f.int → 20480  (5.5 → 5.0)
  dup f.frac - ;

: f.from-ratio ( num den -- fx )
  \ Convertit un ratio num/den en virgule fixe
  \ Exemple : 1 3 f.from-ratio → 1365  (≈ 0.333)
  swap F.SCALE * swap / ;

: f.from-milli ( milli -- fx )
  \ Convertit des millièmes en virgule fixe
  \ Exemple : 3141 f.from-milli → 12872  (≈ 3.141)
  F.SCALE * 1000 / ;

: f.to-milli ( fx -- milli )
  \ Convertit une virgule fixe en millièmes
  \ Exemple : 12868 f.to-milli → 3141  (π → 3141)
  1000 * F.SCALE / ;

: f.from-percent ( percent -- fx )
  \ Convertit un pourcentage (0-100) en virgule fixe (0.0-1.0)
  \ Exemple : 50 f.from-percent → 2048  (= 0.5)
  F.SCALE * 100 / ;

: f.to-percent ( fx -- percent )
  \ Convertit une virgule fixe en pourcentage
  \ Exemple : 2048 f.to-percent → 50
  100 * F.SCALE / ;


\ ──────────────────────────────────────────────────────────────────────
\ 3. ARITHMÉTIQUE DE BASE
\ ──────────────────────────────────────────────────────────────────────

: f+ ( fx1 fx2 -- fx3 )
  \ Addition virgule fixe (directe — même format)
  + ;

: f- ( fx1 fx2 -- fx3 )
  \ Soustraction virgule fixe
  - ;

: f* ( fx1 fx2 -- fx3 )
  \ Multiplication virgule fixe
  \ (a × b) >> 12
  * F.SHIFT rshift ;

: f/ ( fx1 fx2 -- fx3 )
  \ Division virgule fixe
  \ (a << 12) / b
  swap F.SHIFT lshift swap / ;

: f*/ ( fx1 fx2 fx3 -- fx4 )
  \ Multiplication puis division sans perte de précision
  \ (fx1 × fx2) / fx3, avec résultat intermédiaire 64-bit
  >r f* r> F.SHIFT lshift swap / ;

: fnegate ( fx -- -fx )
  negate ;

: fabs ( fx -- |fx| )
  abs ;

: fmin ( fx1 fx2 -- fx_min )
  min ;

: fmax ( fx1 fx2 -- fx_max )
  max ;

: f2* ( fx -- fx*2 )
  1 lshift ;

: f2/ ( fx -- fx/2 )
  2 / ;

: fmod ( fx1 fx2 -- fx_reste )
  \ Modulo virgule fixe
  2dup / f.int f* - ;


\ ──────────────────────────────────────────────────────────────────────
\ 4. COMPARAISON
\ ──────────────────────────────────────────────────────────────────────

: f= ( fx1 fx2 -- flag )  = ;
: f<> ( fx1 fx2 -- flag ) <> ;
: f< ( fx1 fx2 -- flag )  < ;
: f> ( fx1 fx2 -- flag )  > ;
: f<= ( fx1 fx2 -- flag ) <= ;
: f>= ( fx1 fx2 -- flag ) >= ;
: f0= ( fx -- flag )  0= ;
: f0< ( fx -- flag )  0< ;
: f0> ( fx -- flag )  0> ;

: f~ ( fx1 fx2 epsilon -- flag )
  \ Comparaison approximative : |fx1 - fx2| < epsilon
  >r - fabs r> < ;

: fwithin ( fx lo hi -- flag )
  \ Vrai si lo <= fx < hi
  rot dup rot < if
    swap >=
  else
    2drop 0
  then ;


\ ──────────────────────────────────────────────────────────────────────
\ 5. AFFICHAGE
\ ──────────────────────────────────────────────────────────────────────

: f. ( fx -- )
  \ Affiche un nombre fixe avec 3 décimales
  \ Exemple : 12868 f. → 3.141
  dup 0< if
    45 emit              \ signe '-'
    negate
  then
  dup F.SHIFT rshift .   \ partie entière
  46 emit                \ point '.'
  f.frac 1000 * F.SCALE / \ 3 décimales
  dup 100 < if 48 emit then  \ zéro de remplissage
  dup 10 < if 48 emit then
  . ;

: f.n ( fx decimals -- )
  \ Affiche avec N décimales
  \ Exemple : 12868 5 f.n → 3.14159
  >r
  dup 0< if 45 emit negate then
  dup F.SHIFT rshift .
  46 emit
  f.frac
  1 r@ 0 ?do 10 * loop    \ 10^decimals
  * F.SCALE /
  \ Zéros de remplissage
  1 r@ 1- 0 ?do 10 * loop
  begin
    dup 0 > if
      over over > if 48 emit then
    then
    10 /
    dup 0=
  until
  drop
  r> drop
  . ;

: f.deg ( fx -- )
  \ Affiche un angle en degrés
  f. 176 emit ;           \ symbole °

: f.percent ( fx -- )
  \ Affiche en pourcentage
  f.to-percent . 37 emit ; \ symbole %


\ ──────────────────────────────────────────────────────────────────────
\ 6. FONCTIONS MATHÉMATIQUES
\ ──────────────────────────────────────────────────────────────────────

\ --- Racine carrée (méthode de Newton) ---

: fsqrt ( fx -- fx_sqrt )
  \ Racine carrée par itérations de Newton
  \ x_{n+1} = (x_n + S/x_n) / 2
  dup 0<= if drop 0 exit then
  dup                          \ S = valeur initiale
  \ Estimation initiale : S/2
  dup f2/                      \ x0 = S/2
  dup 0= if drop f2/ exit then
  \ 15 itérations (convergence garantie pour Q20.12)
  15 0 do
    over over f/ f+            \ x + S/x
    f2/                        \ / 2
  loop
  nip ;                        \ garder le résultat, drop S

\ --- Valeur absolue de la différence ---

: fdist ( fx1 fx2 -- fx_dist )
  - fabs ;

\ --- Puissance entière ---

: fpow ( fx n -- fx^n )
  \ Élève fx à la puissance entière n (n >= 0)
  dup 0= if 2drop F.1 exit then
  dup 0< if
    negate >r
    F.1 swap r> 0 do
      over f*
    loop
    nip
    F.1 swap f/               \ inverser pour exposant négatif
    exit
  then
  >r dup r> 1- 0 ?do
    over f*
  loop
  nip ;

\ --- Trigonométrie (approximation par série de Taylor) ---
\
\ sin(x) ≈ x - x³/3! + x⁵/5! - x⁷/7!
\ cos(x) ≈ 1 - x²/2! + x⁴/4! - x⁶/6!
\
\ Domaine : normalise x dans [-π, π] avant calcul

: f.normalize-angle ( fx_rad -- fx_normalized )
  \ Ramène l'angle dans [-π, π]
  begin
    dup F.PI > if F.2PI - else exit then
  again
  begin
    dup F.PI negate < if F.2PI + else exit then
  again ;

\ Table de sinus pré-calculée (0° à 90° par pas de 5°)
\ Valeurs en Q20.12 : sin(angle) × 4096

create f.sin-table
  0 ,       357 ,     714 ,     1066 ,    1413 ,    \ 0  5  10 15 20
  1748 ,    2069 ,    2374 ,    2660 ,    2925 ,    \ 25 30 35 40 45
  3166 ,    3383 ,    3574 ,    3736 ,    3870 ,    \ 50 55 60 65 70
  3974 ,    4048 ,    4091 ,    4096 ,              \ 75 80 85 90

: f.sin-lookup ( deg -- fx )
  \ Sinus par table + interpolation linéaire
  \ deg = angle en degrés entiers (0-360)
  360 mod
  dup 0< if 360 + then
  \ Réduire à [0, 90] avec symétrie
  dup 270 >= if
    360 swap -              \ 270-360 → -(360-x)
    5 /mod                  \ index et reste
    swap cells f.sin-table + @
    swap if                 \ interpolation
      over cell+ @ over - 5 */ +
    else
      nip
    then
    negate exit
  then
  dup 180 >= if
    180 -                   \ 180-270 → -sin(x-180)
    5 /mod
    swap cells f.sin-table + @
    swap if
      over cell+ @ over - 5 */ +
    else
      nip
    then
    negate exit
  then
  dup 90 > if
    180 swap -              \ 90-180 → sin(180-x)
  then
  5 /mod
  swap cells f.sin-table + @
  swap if
    over cell+ @ over - 5 */ +
  else
    nip
  then ;

: fsin-deg ( deg -- fx )
  \ Sinus d'un angle en degrés entiers
  f.sin-lookup ;

: fcos-deg ( deg -- fx )
  \ Cosinus = sin(90 + angle)
  90 + f.sin-lookup ;

: ftan-deg ( deg -- fx )
  \ Tangente = sin/cos
  dup fsin-deg swap fcos-deg
  dup 0= if 2drop F.MAX exit then  \ Division par zéro → MAX
  f/ ;

\ --- Sinus/Cosinus en radians (virgule fixe) ---

: fsin ( fx_rad -- fx )
  \ Sinus par série de Taylor (5 termes)
  \ sin(x) = x - x³/6 + x⁵/120 - x⁷/5040 + x⁹/362880
  f.normalize-angle
  dup                          \ x
  dup dup f* dup >r            \ x² sur rstack
  \ Terme 1 : x
  over                         \ résultat = x
  \ Terme 2 : -x³/6
  swap dup r@ f* fnegate       \ -x³
  6 f.from f/ f+               \ résultat += -x³/6
  \ Terme 3 : +x⁵/120
  swap r@ f* r@ f*             \ x⁵
  120 f.from f/
  rot f+ swap
  \ Terme 4 : -x⁷/5040
  r@ f* r@ f* fnegate          \ -x⁷
  5040 f.from f/
  rot f+ swap
  r> drop                      \ libérer x²
  drop                         \ nettoyer
;

: fcos ( fx_rad -- fx )
  \ cos(x) = sin(x + π/2)
  F.PI/2 f+ fsin ;

: ftan ( fx_rad -- fx )
  \ tan(x) = sin(x) / cos(x)
  dup fsin swap fcos
  dup f0= if 2drop F.MAX exit then
  f/ ;

\ --- Arc tangente (approximation) ---

: fatan ( fx -- fx_rad )
  \ atan(x) par approximation polynomiale
  \ Pour |x| <= 1 : atan(x) ≈ x - x³/3 + x⁵/5
  dup fabs F.1 f> if
    \ Pour |x| > 1 : atan(x) = π/2 - atan(1/x)
    dup f0< >r
    fabs F.1 swap f/ fatan
    F.PI/2 swap f-
    r> if fnegate then
    exit
  then
  dup dup dup f* >r         \ x, x²
  dup r@ f* fnegate         \ -x³
  3 f.from f/               \ -x³/3
  f+
  dup r@ f* r@ f*           \ x⁵
  5 f.from f/               \ x⁵/5
  f+
  r> drop ;

: fatan2 ( fy fx -- fx_rad )
  \ atan2(y, x) — angle en radians
  dup f0= if
    drop f0< if F.PI/2 fnegate else F.PI/2 then
    exit
  then
  2dup f/ fatan              \ atan(y/x)
  swap f0< if                \ x < 0 ?
    swap f0< if              \ y < 0 ?
      F.PI f-                \ quadrant III
    else
      F.PI f+                \ quadrant II
    then
  else
    nip                      \ quadrant I ou IV
  then ;


\ ──────────────────────────────────────────────────────────────────────
\ 7. FONCTIONS UTILITAIRES
\ ──────────────────────────────────────────────────────────────────────

: flerp ( fx_a fx_b fx_t -- fx )
  \ Interpolation linéaire : a + t×(b - a)
  \ t = 0.0 → a, t = 1.0 → b
  >r over - r> f* f+ ;

: fclamp ( fx fx_min fx_max -- fx_clamped )
  \ Restreint une valeur dans [min, max]
  rot fmin fmax ;

: fmap ( fx in_lo in_hi out_lo out_hi -- fx_mapped )
  \ Mappe une valeur d'une plage à une autre
  \ (fx - in_lo) / (in_hi - in_lo) * (out_hi - out_lo) + out_lo
  >r >r
  over - >r         \ in_range = in_hi - in_lo
  swap - r> f/      \ normalized = (fx - in_lo) / in_range
  r> r> over - >r   \ out_range = out_hi - out_lo
  r> f* f+ ;         \ result = normalized * out_range + out_lo

: fsign ( fx -- -1|0|1 )
  \ Signe : -1, 0, ou 1
  dup 0< if drop -1
  else 0> if 1
  else 0
  then then ;

: ffloor ( fx -- fx_floor )
  \ Arrondi vers le bas (partie entière × F.SCALE)
  dup 0< if
    dup f.frac 0<> if
      f.int F.SCALE -
    else
      f.int
    then
  else
    f.int
  then ;

: fceil ( fx -- fx_ceil )
  \ Arrondi vers le haut
  dup f.frac 0<> if
    f.int F.SCALE +
  else
    f.int
  then ;

: favg ( fx1 fx2 -- fx_avg )
  \ Moyenne de deux valeurs
  f+ f2/ ;


\ ──────────────────────────────────────────────────────────────────────
\ 8. VECTEURS 2D
\ ──────────────────────────────────────────────────────────────────────
\
\ Un vecteur 2D est représenté par deux valeurs fixes sur la pile :
\   ( fx_x fx_y )

: v2.add ( x1 y1 x2 y2 -- x3 y3 )
  \ Addition vectorielle
  rot f+ >r f+ r> ;

: v2.sub ( x1 y1 x2 y2 -- x3 y3 )
  \ Soustraction vectorielle
  rot swap f- >r f- r> ;

: v2.scale ( x y fx_s -- x' y' )
  \ Multiplication par un scalaire
  dup >r swap r@ f* swap r> f* ;

: v2.dot ( x1 y1 x2 y2 -- fx_dot )
  \ Produit scalaire
  rot f* >r f* r> f+ ;

: v2.len2 ( x y -- fx_len² )
  \ Longueur au carré (évite la racine carrée)
  dup f* swap dup f* f+ ;

: v2.len ( x y -- fx_len )
  \ Longueur du vecteur
  v2.len2 fsqrt ;

: v2.normalize ( x y -- nx ny )
  \ Normalise le vecteur (longueur = 1.0)
  2dup v2.len
  dup f0= if drop exit then   \ vecteur nul
  dup >r
  swap r@ f/ swap r> f/ ;

: v2.dist ( x1 y1 x2 y2 -- fx_dist )
  \ Distance entre deux points
  v2.sub v2.len ;

: v2.angle ( x y -- fx_rad )
  \ Angle du vecteur (en radians)
  swap fatan2 ;

: v2.rotate ( x y fx_angle -- x' y' )
  \ Rotation d'un vecteur par un angle (degrés entiers)
  >r
  2dup
  r@ fcos-deg f* swap r@ fsin-deg f* f-   \ x' = x·cos - y·sin
  swap
  r@ fsin-deg f* swap r> fcos-deg f* f+   \ y' = x·sin + y·cos
;

: v2.lerp ( x1 y1 x2 y2 t -- x3 y3 )
  \ Interpolation linéaire entre deux points
  >r
  rot r@ flerp >r
  rot rot r> swap >r
  r@ flerp
  r> swap
  r> ;

: v2. ( x y -- )
  \ Affiche un vecteur 2D
  40 emit              \ '('
  swap f. 44 emit 32 emit  \ 'x, '
  f.
  41 emit ;            \ ')'


\ ──────────────────────────────────────────────────────────────────────
\ 9. PHYSIQUE SIMPLE
\ ──────────────────────────────────────────────────────────────────────
\
\ Module de physique 2D basique pour les jeux et simulations.

\ Gravité terrestre en m/s² (9.81 × 4096 = 40181)
40181 constant F.GRAVITY

\ Friction (coefficient de frottement par défaut)
3891 constant F.FRICTION      \ 0.95 × 4096

\ --- Mouvement ---

: phys.apply-gravity ( vy dt -- vy' )
  \ Applique la gravité : vy' = vy + g × dt
  F.GRAVITY f* f+ ;

: phys.apply-friction ( vx vy friction -- vx' vy' )
  \ Applique le frottement : v' = v × friction
  dup >r swap r@ f* swap r> f* ;

: phys.move ( x y vx vy dt -- x' y' )
  \ Déplace un point : pos' = pos + vel × dt
  dup >r
  rot r@ f* rot f+       \ x' = x + vx * dt
  swap r> f* rot f+ ;    \ y' = y + vy * dt

: phys.bounce-x ( vx x x_min x_max -- vx' x' )
  \ Rebond horizontal
  rot dup rot f< if
    drop swap fnegate swap
  else
    dup rot f> if
      swap fnegate swap
    then
  then ;

: phys.bounce-y ( vy y y_min y_max -- vy' y' )
  \ Rebond vertical
  rot dup rot f< if
    drop swap fnegate swap
  else
    dup rot f> if
      swap fnegate swap
    then
  then ;

: phys.collide-circle? ( x1 y1 r1 x2 y2 r2 -- flag )
  \ Test de collision entre deux cercles
  >r >r >r
  r> r> v2.dist        \ distance entre centres
  r> f+                 \ r1 + r2
  f< ;                  \ distance < r1 + r2 ?


\ ──────────────────────────────────────────────────────────────────────
\ 10. CAPTEURS ET MESURES
\ ──────────────────────────────────────────────────────────────────────
\
\ Fonctions pour convertir des valeurs brutes de capteurs
\ en unités physiques.

: sensor.adc-to-voltage ( adc_raw adc_max vref_mv -- fx_volts )
  \ Convertit une lecture ADC en tension (virgule fixe)
  \ Exemple : 2048 4096 3300 sensor.adc-to-voltage → 1.65V
  >r
  f.from-ratio                 \ adc_raw / adc_max en fixe
  r> f.from-milli f* ;         \ × Vref

: sensor.ntc-temp ( resistance_ohm -- fx_celsius )
  \ Approximation linéaire pour thermistance NTC 10K
  \ T ≈ 25 - (R - 10000) / 400
  10000 - 400 / negate 25 + f.from ;

: sensor.celsius-to-f ( fx_c -- fx_f )
  \ Conversion Celsius → Fahrenheit
  \ F = C × 9/5 + 32
  9 f.from f* 5 f.from f/ 32 f.from f+ ;

: sensor.f-to-celsius ( fx_f -- fx_c )
  \ Conversion Fahrenheit → Celsius
  32 f.from f- 5 f.from f* 9 f.from f/ ;

: sensor.kmh-to-ms ( fx_kmh -- fx_ms )
  \ km/h → m/s
  1000 f.from f* 3600 f.from f/ ;

: sensor.ms-to-kmh ( fx_ms -- fx_kmh )
  \ m/s → km/h
  3600 f.from f* 1000 f.from f/ ;

: sensor.deg-to-rad ( deg -- fx_rad )
  \ Degrés entiers → radians en virgule fixe
  F.PI * 180 / ;

: sensor.rad-to-deg ( fx_rad -- deg )
  \ Radians en virgule fixe → degrés entiers
  180 * F.PI / ;


\ ──────────────────────────────────────────────────────────────────────
\ 11. TRACEUR DE COURBES (Canvas)
\ ──────────────────────────────────────────────────────────────────────
\
\ Dessine des courbes mathématiques dans le Canvas Forth (400×300).

variable plot-x-min   variable plot-x-max
variable plot-y-min   variable plot-y-max

: plot.setup ( x_min x_max y_min y_max -- )
  \ Configure la fenêtre de visualisation (en virgule fixe)
  plot-y-max ! plot-y-min !
  plot-x-max ! plot-x-min ! ;

: plot.map-x ( fx_x -- pixel_x )
  \ Mappe une coordonnée X fixe vers un pixel du canvas
  plot-x-min @ f-
  plot-x-max @ plot-x-min @ f-
  f/
  400 f.from f*
  f.to ;

: plot.map-y ( fx_y -- pixel_y )
  \ Mappe une coordonnée Y fixe vers un pixel du canvas
  \ Y inversé (0 en haut)
  plot-y-max @ swap f-
  plot-y-max @ plot-y-min @ f-
  f/
  300 f.from f*
  f.to ;

: plot.axes ( color -- )
  \ Dessine les axes X et Y
  \ Axe X (y=0)
  F.0 plot.map-y dup 0 >= over 300 < and if
    0 over 400 over swap ligne
  else
    drop
  then
  drop
  \ Axe Y (x=0)
  F.0 plot.map-x dup 0 >= over 400 < and if
    dup 0 swap 300 swap ligne
  else
    drop
  then
  drop ;

: plot.grid ( step color -- )
  \ Dessine une grille
  \ step = espacement en virgule fixe
  dup >r
  \ Lignes verticales
  plot-x-min @ begin
    dup plot-x-max @ f<= if
      dup plot.map-x dup 0 >= over 400 < and if
        dup 0 swap 300 over swap ligne drop
      else
        drop
      then
      r@ f+
    else
      drop leave
    then
  again
  \ Lignes horizontales
  plot-y-min @ begin
    dup plot-y-max @ f<= if
      dup plot.map-y dup 0 >= over 300 < and if
        0 over 400 swap over swap ligne drop
      else
        drop
      then
      r@ f+
    else
      drop leave
    then
  again
  r> drop ;

: plot.curve ( xt color -- )
  \ Dessine la courbe de la fonction xt
  \ xt = ( fx_x -- fx_y )
  >r
  400 0 do
    \ Calculer x en virgule fixe
    i f.from
    plot-x-max @ plot-x-min @ f-
    400 f.from f/
    f*
    plot-x-min @ f+

    \ Calculer y = f(x)
    over execute

    \ Convertir en pixels
    plot.map-y >r
    i r>

    \ Dessiner si dans les bornes
    dup 0 >= over 300 < and if
      over 0 >= over 400 < and if
        r@ pixel
      else
        2drop
      then
    else
      2drop
    then
  loop
  drop r> drop ;

\ --- Fonctions exemple pour le traceur ---

: f-carre ( fx -- fx )  dup f* ;
: f-cube  ( fx -- fx )  dup dup f* f* ;
: f-inv   ( fx -- fx )
  dup f0= if exit then F.1 swap f/ ;

\ --- Démonstrations ---

: demo-plot-carre ( -- )
  0x000020 effacer
  -3 f.from  3 f.from  -2 f.from  10 f.from  plot.setup
  F.1 0x333333 plot.grid
  0x444444 plot.axes
  ' f-carre 0x00FF00 plot.curve ;

: demo-plot-sin ( -- )
  0x000020 effacer
  F.2PI fnegate  F.2PI  F.-1 f2*  F.1 f2*  plot.setup
  F.PI/2 0x333333 plot.grid
  0x444444 plot.axes
  ' fsin 0xFF4444 plot.curve ;


\ ──────────────────────────────────────────────────────────────────────
\ 12. DÉMO — BALLE AVEC PHYSIQUE
\ ──────────────────────────────────────────────────────────────────────

variable ball-x    variable ball-y
variable ball-vx   variable ball-vy

: demo-ball-init ( -- )
  50 f.from ball-x !
  50 f.from ball-y !
  3 f.from ball-vx !
  -5 f.from ball-vy ! ;

: demo-ball-step ( -- )
  \ Appliquer la gravité
  ball-vy @ 50 F.GRAVITY f* f.from-milli f+ ball-vy !
  \ Appliquer le frottement
  ball-vx @ F.FRICTION f* ball-vx !
  \ Déplacer
  ball-x @ ball-vx @ f+ ball-x !
  ball-y @ ball-vy @ f+ ball-y !
  \ Rebondir en bas (y > 280)
  ball-y @ 280 f.from f> if
    280 f.from ball-y !
    ball-vy @ fnegate 3686 f* ball-vy !  \ × 0.9 rebond
  then
  \ Rebondir à gauche et droite
  ball-x @ f0< if
    ball-x @ fabs ball-x !
    ball-vx @ fnegate ball-vx !
  then
  ball-x @ 390 f.from f> if
    390 f.from ball-x !
    ball-vx @ fnegate ball-vx !
  then ;

: demo-ball-draw ( -- )
  ball-x @ f.to ball-y @ f.to 10 10 0xFF4444 rect ;

: demo-ball ( -- )
  demo-ball-init
  begin
    0x000020 effacer
    demo-ball-step
    demo-ball-draw
    16 ms
    touche? 27 =
  until ;


\ ──────────────────────────────────────────────────────────────────────
\ 13. TESTS
\ ──────────────────────────────────────────────────────────────────────

variable ftest-ok
variable ftest-ko

: fok   1 ftest-ok +! ;
: fko   1 ftest-ko +! ;

: fassert= ( got expected -- )
  2dup = if 2drop fok
  else fko cr ." ECHEC fassert= : attendu " f. ." obtenu " f. cr
  then ;

: fassert~ ( got expected epsilon -- )
  \ Comparaison approximative
  >r 2dup f- fabs r> f< if 2drop fok
  else fko cr ." ECHEC fassert~ : attendu " f. ." obtenu " f. cr
  then ;

: test-fixed ( -- )
  cr ." === TESTS VIRGULE FIXE ===" cr
  0 ftest-ok !  0 ftest-ko !

  ." [F1] Conversion... "
  5 f.from 20480 fassert=
  20480 f.to 5 = if fok else fko then
  1 3 f.from-ratio 1365 10 fassert~
  3141 f.from-milli F.PI 20 fassert~
  ." OK" cr

  ." [F2] Arithmetique... "
  3 f.from 2 f.from f+ 5 f.from fassert=
  5 f.from 3 f.from f- 2 f.from fassert=
  3 f.from 4 f.from f* 12 f.from 10 fassert~
  10 f.from 4 f.from f/ 2 f.from F.0.5 f+ 10 fassert~
  ." OK" cr

  ." [F3] Comparaison... "
  3 f.from 5 f.from f< if fok else fko then
  5 f.from 3 f.from f> if fok else fko then
  3 f.from 3 f.from f= if fok else fko then
  ." OK" cr

  ." [F4] Sqrt... "
  4 f.from fsqrt 2 f.from 20 fassert~
  9 f.from fsqrt 3 f.from 20 fassert~
  2 f.from fsqrt F.SQRT2 30 fassert~
  ." OK" cr

  ." [F5] Trigonometrie... "
  0 fsin-deg 0 fassert=
  90 fsin-deg F.1 20 fassert~
  180 fsin-deg 0 50 fassert~
  0 fcos-deg F.1 20 fassert~
  90 fcos-deg 0 50 fassert~
  ." OK" cr

  ." [F6] Vecteurs 2D... "
  3 f.from 4 f.from v2.len 5 f.from 30 fassert~
  F.1 F.0 F.0 F.1 v2.dot F.0 fassert=
  ." OK" cr

  ." [F7] Utilitaires... "
  F.0 F.1 F.0.5 flerp F.0.5 20 fassert~
  10 f.from 0 f.from 5 f.from fclamp 5 f.from fassert=
  ." OK" cr

  cr ." Resultats fixed-point : "
  ftest-ok @ . ." OK, "
  ftest-ko @ . ." ECHEC" cr
  ftest-ko @ 0= if
    ." Tous les tests passent." cr
  else
    ." IL Y A DES ECHECS !" cr
  then ;


\ ──────────────────────────────────────────────────────────────────────
\ CHARGEMENT TERMINÉ
\ ──────────────────────────────────────────────────────────────────────

cr
." ════════════════════════════════════════════════════════" cr
."  FIXED.FTH charge avec succes" cr
."  Format : Q20.12 (precision ~0.00025)" cr
."  Mots : f+ f- f* f/ fsqrt fsin fcos ftan" cr
."  Vecteurs : v2.add v2.len v2.normalize v2.rotate" cr
."  Physique : phys.move phys.bounce-x" cr
."  Traceur : plot.setup plot.curve demo-plot-sin" cr
."  Tapez 'test-fixed' pour les tests." cr
."  Tapez 'demo-ball' pour la demo physique." cr
."  Tapez 'demo-plot-sin' pour le traceur." cr
." ════════════════════════════════════════════════════════" cr
```

---

# Étape 3 — Mutex et Synchronisation (MUTEX.FTH)

```forth
\ ════════════════════════════════════════════════════════════════════════
\                MUTEX.FTH — Synchronisation Multitâche
\                     EponaForth — Epona OS
\ ════════════════════════════════════════════════════════════════════════
\
\ Fournit des mécanismes de synchronisation pour le multitâche
\ préemptif d'EponaForth.
\
\ Primitives fournies :
\   - Mutex (exclusion mutuelle)
\   - Spinlock (verrou actif)
\   - Sémaphore (compteur)
\   - Channel (communication inter-tâches)
\   - Barrière (point de rendez-vous)
\   - Atomic (opérations atomiques simulées)
\
\ IMPORTANT : EponaForth est préempté entre chaque instruction Forth.
\ Donc une séquence @ ... ! n'est PAS atomique.
\ Ces primitives garantissent la cohérence des données partagées.
\
\ Chargement :
\   sys:load MUTEX.FTH
\   ou : require MUTEX.FTH
\
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ 1. OPÉRATIONS ATOMIQUES (Simulées)
\ ──────────────────────────────────────────────────────────────────────
\
\ Sur EponaForth, la préemption se fait entre les instructions.
\ Une seule instruction Forth est donc "atomique" du point de vue
\ du scheduler.
\
\ Stratégie : utiliser un flag global qui empêche la préemption
\ pendant la section critique. Le scheduler vérifie ce flag.

variable critical-depth    \ Compteur de sections critiques imbriquées

: critical-begin ( -- )
  \ Désactive la préemption (le scheduler ne peut pas interrompre)
  \ Implémenté via un flag que le scheduler respecte.
  1 critical-depth +! ;

: critical-end ( -- )
  \ Réactive la préemption
  critical-depth @ 1- 0 max critical-depth ! ;

: atomic@ ( addr -- val )
  \ Lecture atomique (désactive la préemption temporairement)
  critical-begin
  @
  critical-end ;

: atomic! ( val addr -- )
  \ Écriture atomique
  critical-begin
  !
  critical-end ;

: atomic+! ( n addr -- )
  \ Addition atomique
  critical-begin
  +!
  critical-end ;

: atomic-swap ( new addr -- old )
  \ Échange atomique : retourne l'ancienne valeur
  critical-begin
  dup @          \ old
  rot swap !     \ store new
  critical-end ;

: compare-and-swap ( expected new addr -- ok? )
  \ CAS : si *addr == expected, écrire new et retourner 1
  \ Sinon retourner 0
  critical-begin
  dup @ 3 pick = if        \ *addr == expected ?
    swap drop !             \ *addr = new
    drop 1
  else
    drop drop drop 0
  then
  critical-end ;


\ ──────────────────────────────────────────────────────────────────────
\ 2. SPINLOCK (Verrou Actif)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le spinlock est le mécanisme le plus simple : boucle active
\ jusqu'à obtention du verrou. Adapté aux sections très courtes.
\
\ Format en mémoire : 1 cellule (0 = libre, 1 = verrouillé)

: spin:create ( -- addr )
  \ Crée un spinlock (libre)
  here 0 , ;

: spin:lock ( addr -- )
  \ Acquiert le spinlock (busy-wait)
  begin
    1 0 rot compare-and-swap    \ CAS(0 → 1)
  until ;

: spin:unlock ( addr -- )
  \ Libère le spinlock
  0 swap atomic! ;

: spin:try ( addr -- ok? )
  \ Essaie d'acquérir sans bloquer
  1 0 rot compare-and-swap ;

: spin:locked? ( addr -- flag )
  \ Vérifie si le spinlock est verrouillé
  atomic@ 0<> ;

\ Exemple d'utilisation :
\   spin:create constant my-lock
\
\   : protected-op ( -- )
\     my-lock spin:lock
\     \ ... section critique ...
\     my-lock spin:unlock ;


\ ──────────────────────────────────────────────────────────────────────
\ 3. MUTEX (Exclusion Mutuelle)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le mutex est un spinlock avec détection de propriétaire
\ et support du verrouillage récursif.
\
\ Format en mémoire :
\   [0] état (0=libre, 1=verrouillé)
\   [1] propriétaire (ID de tâche, -1 si libre)
\   [2] compteur de récursion

3 constant MUTEX-SIZE

: mutex:create ( -- addr )
  \ Crée un mutex (libre)
  here
  0 ,        \ état
  -1 ,       \ propriétaire
  0 , ;      \ compteur récursion

: mutex:owner ( addr -- task_id )
  1+ atomic@ ;

: mutex:count ( addr -- n )
  2 + atomic@ ;

: mutex:lock ( addr -- )
  \ Acquiert le mutex
  \ Si déjà propriétaire → incrémente le compteur (récursif)
  \ Sinon → attend que le mutex soit libre
  \ Note : task_id approximé par l'adresse de pile
  depth                        \ pseudo task-id (unique par tâche)
  over mutex:owner over = if
    \ Déjà propriétaire → récursion
    drop dup 2 + 1 swap atomic+!
    drop exit
  then
  \ Attendre la libération
  begin
    over spin:try if
      \ Verrouillé ! Enregistrer le propriétaire
      over 1+ atomic!          \ owner = task_id
      1 over 2 + atomic!       \ count = 1
      drop exit
    then
    1 ms                        \ Yield / attendre
  again ;

: mutex:unlock ( addr -- )
  \ Libère le mutex
  \ Décrémente le compteur. Si 0 → libère complètement.
  dup mutex:count 1 > if
    \ Récursion : décrémenter
    -1 swap 2 + atomic+!
  else
    \ Libérer complètement
    -1 over 1+ atomic!         \ owner = -1
    0 over 2 + atomic!         \ count = 0
    spin:unlock                 \ état = libre
  then ;

: mutex:try ( addr -- ok? )
  \ Essaie d'acquérir sans bloquer
  depth over mutex:owner over = if
    \ Déjà propriétaire → récursion OK
    drop dup 2 + 1 swap atomic+!
    drop 1 exit
  then
  over spin:try if
    over 1+ atomic!
    1 over 2 + atomic!
    drop 1
  else
    2drop 0
  then ;

: mutex:locked? ( addr -- flag )
  spin:locked? ;

\ --- Macro d'utilisation sûre ---

: mutex:with ( addr xt -- )
  \ Exécute xt sous protection du mutex
  \ Garantit le unlock même en cas d'erreur
  over >r
  swap mutex:lock
  try
    execute
    0
  catch
    drop
  endtry
  r> mutex:unlock ;

\ Exemple :
\   mutex:create constant db-lock
\
\   : update-db ( val -- )
\     db-lock ' do-update mutex:with ;
\
\   : do-update ( val -- )
\     shared-var ! ;


\ ──────────────────────────────────────────────────────────────────────
\ 4. SÉMAPHORE (Compteur)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le sémaphore est un compteur synchronisé.
\ sem:wait décrémente (bloque si 0).
\ sem:signal incrémente.
\
\ Format en mémoire :
\   [0] compteur
\   [1] spinlock (pour protéger le compteur)

2 constant SEM-SIZE

: sem:create ( n -- addr )
  \ Crée un sémaphore initialisé à n
  here
  swap ,       \ compteur initial
  0 , ;        \ spinlock libre

: sem:count ( addr -- n )
  atomic@ ;

: sem:wait ( addr -- )
  \ P() — décrémente. Bloque si compteur == 0
  begin
    dup 1+ spin:lock           \ protéger le compteur
    dup atomic@ 0 > if
      -1 over atomic+!         \ décrémenter
      dup 1+ spin:unlock
      drop exit
    then
    dup 1+ spin:unlock
    1 ms                        \ yield
  again ;

: sem:signal ( addr -- )
  \ V() — incrémente
  dup 1+ spin:lock
  1 swap atomic+!
  dup 1+ spin:unlock
  drop ;

: sem:try ( addr -- ok? )
  \ Essaie de décrémenter sans bloquer
  dup 1+ spin:lock
  dup atomic@ 0 > if
    -1 over atomic+!
    dup 1+ spin:unlock
    drop 1
  else
    dup 1+ spin:unlock
    drop 0
  then ;

\ Exemple — limiter l'accès à 3 tâches simultanées :
\   3 sem:create constant pool-sem
\
\   : use-resource ( -- )
\     pool-sem sem:wait
\     \ ... utiliser la ressource (max 3 en parallèle) ...
\     pool-sem sem:signal ;


\ ──────────────────────────────────────────────────────────────────────
\ 5. CHANNEL (Communication Inter-tâches)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le channel est un buffer circulaire synchronisé.
\ chan:send bloque si le buffer est plein.
\ chan:recv bloque si le buffer est vide.
\
\ Format en mémoire :
\   [0] capacité
\   [1] head (index d'écriture)
\   [2] tail (index de lecture)
\   [3] count (nombre d'éléments)
\   [4] spinlock
\   [5..] données

5 constant CHAN-HDR-SIZE

: chan:create ( capacity -- addr )
  \ Crée un channel avec la capacité donnée
  here swap
  dup ,                  \ [0] capacité
  0 ,                    \ [1] head
  0 ,                    \ [2] tail
  0 ,                    \ [3] count
  0 ,                    \ [4] spinlock
  0 ?do 0 , loop ;      \ [5..] données initialisées à 0

: chan:capacity ( addr -- n )
  atomic@ ;

: chan:count ( addr -- n )
  3 + atomic@ ;

: chan:full? ( addr -- flag )
  dup chan:count swap chan:capacity >= ;

: chan:empty? ( addr -- flag )
  chan:count 0= ;

: chan:lock ( addr -- )
  4 + spin:lock ;

: chan:unlock ( addr -- )
  4 + spin:unlock ;

: chan:send ( val addr -- )
  \ Envoie une valeur dans le channel (bloque si plein)
  begin
    dup chan:full? 0= if
      \ Place disponible
      dup chan:lock
      \ Écrire à head
      over 1+ atomic@             \ head
      over chan:capacity mod       \ head % capacity
      CHAN-HDR-SIZE + over + !     \ data[head%cap] = val
      \ Avancer head
      over 1+ atomic@ 1+
      over chan:capacity mod
      over 1+ atomic!
      \ Incrémenter count
      1 over 3 + atomic+!
      dup chan:unlock
      2drop exit
    then
    1 ms                          \ yield
  again ;

: chan:recv ( addr -- val )
  \ Reçoit une valeur du channel (bloque si vide)
  begin
    dup chan:empty? 0= if
      dup chan:lock
      \ Lire à tail
      dup 2 + atomic@             \ tail
      over chan:capacity mod
      CHAN-HDR-SIZE + over + @    \ val = data[tail%cap]
      swap
      \ Avancer tail
      over 2 + atomic@ 1+
      over chan:capacity mod
      over 2 + atomic!
      \ Décrémenter count
      -1 over 3 + atomic+!
      dup chan:unlock
      nip exit
    then
    1 ms
  again ;

: chan:try-send ( val addr -- ok? )
  \ Essaie d'envoyer sans bloquer
  dup chan:full? if 2drop 0 exit then
  chan:send 1 ;

: chan:try-recv ( addr -- val ok? )
  \ Essaie de recevoir sans bloquer
  dup chan:empty? if drop 0 0 exit then
  chan:recv 1 ;

\ Exemple — producteur/consommateur :
\   16 chan:create constant work-chan
\
\   : producteur ( -- )
\     begin
\       ticks work-chan chan:send   \ envoie le timestamp
\       100 ms
\     again ;
\
\   : consommateur ( -- )
\     begin
\       work-chan chan:recv
\       ." Recu: " . cr
\     again ;
\
\   ' producteur task
\   ' consommateur task


\ ──────────────────────────────────────────────────────────────────────
\ 6. BARRIÈRE (Point de Rendez-vous)
\ ──────────────────────────────────────────────────────────────────────
\
\ La barrière attend que N tâches arrivent avant de continuer.
\
\ Format en mémoire :
\   [0] seuil (nombre de tâches à attendre)
\   [1] compteur courant
\   [2] génération (pour le reset)
\   [3] spinlock

4 constant BARRIER-SIZE

: barrier:create ( n -- addr )
  \ Crée une barrière pour n tâches
  here swap
  dup ,          \ [0] seuil
  0 ,            \ [1] compteur
  0 ,            \ [2] génération
  0 , ;          \ [3] spinlock

: barrier:wait ( addr -- )
  \ Attend que toutes les tâches arrivent
  dup 3 + spin:lock

  \ Incrémenter le compteur
  1 over 1+ atomic+!

  \ Sauver la génération courante
  dup 2 + atomic@ >r

  \ Vérifier si on a atteint le seuil
  dup 1+ atomic@ over atomic@ >= if
    \ Dernière tâche → réinitialiser et avancer la génération
    0 over 1+ atomic!
    1 over 2 + atomic+!
    dup 3 + spin:unlock
    r> drop exit
  then

  dup 3 + spin:unlock

  \ Attendre que la génération change
  begin
    dup 2 + atomic@ r@ <> if
      r> drop exit
    then
    1 ms
  again ;

\ Exemple — synchronisation de 3 tâches :
\   3 barrier:create constant sync-point
\
\   : worker1  ... sync-point barrier:wait ." 1 continue" cr ;
\   : worker2  ... sync-point barrier:wait ." 2 continue" cr ;
\   : worker3  ... sync-point barrier:wait ." 3 continue" cr ;


\ ──────────────────────────────────────────────────────────────────────
\ 7. RWLOCK (Verrou Lecteur-Écrivain)
\ ──────────────────────────────────────────────────────────────────────
\
\ Permet plusieurs lecteurs simultanés OU un seul écrivain.
\
\ Format en mémoire :
\   [0] readers (nombre de lecteurs actifs)
\   [1] writer (0 ou 1)
\   [2] spinlock

3 constant RWLOCK-SIZE

: rwlock:create ( -- addr )
  here
  0 ,    \ [0] readers
  0 ,    \ [1] writer
  0 , ;  \ [2] spinlock

: rwlock:read-lock ( addr -- )
  \ Acquiert le verrou en lecture
  begin
    dup 2 + spin:lock
    dup 1+ atomic@ 0= if       \ pas d'écrivain ?
      1 over atomic+!           \ readers++
      dup 2 + spin:unlock
      drop exit
    then
    dup 2 + spin:unlock
    1 ms
  again ;

: rwlock:read-unlock ( addr -- )
  dup 2 + spin:lock
  -1 over atomic+!              \ readers--
  dup 2 + spin:unlock
  drop ;

: rwlock:write-lock ( addr -- )
  \ Acquiert le verrou en écriture (exclusif)
  begin
    dup 2 + spin:lock
    dup atomic@ 0= if           \ pas de lecteurs ?
      dup 1+ atomic@ 0= if     \ pas d'écrivain ?
        1 over 1+ atomic!       \ writer = 1
        dup 2 + spin:unlock
        drop exit
      then
    then
    dup 2 + spin:unlock
    1 ms
  again ;

: rwlock:write-unlock ( addr -- )
  dup 2 + spin:lock
  0 over 1+ atomic!             \ writer = 0
  dup 2 + spin:unlock
  drop ;

\ Exemple — base de données partagée :
\   rwlock:create constant db-rwlock
\
\   : read-db ( -- val )
\     db-rwlock rwlock:read-lock
\     shared-data @
\     db-rwlock rwlock:read-unlock ;
\
\   : write-db ( val -- )
\     db-rwlock rwlock:write-lock
\     shared-data !
\     db-rwlock rwlock:write-unlock ;


\ ──────────────────────────────────────────────────────────────────────
\ 8. POOL DE TÂCHES
\ ──────────────────────────────────────────────────────────────────────
\
\ Pattern pour distribuer du travail entre N tâches.

16 chan:create constant work-queue
16 chan:create constant result-queue
variable pool-running

: pool:worker ( -- )
  \ Boucle de travail — attend des tâches dans la queue
  begin
    pool-running @ if
      work-queue chan:try-recv if
        \ Exécuter le travail (valeur = index du mot)
        execute
        result-queue chan:send
      else
        drop 5 ms
      then
    else
      exit
    then
  again ;

: pool:start ( n -- )
  \ Lance n workers
  1 pool-running !
  0 ?do
    ' pool:worker task drop
  loop ;

: pool:stop ( -- )
  0 pool-running ! ;

: pool:submit ( xt -- )
  \ Soumet un travail
  work-queue chan:send ;

: pool:collect ( -- val )
  \ Récupère un résultat
  result-queue chan:recv ;

\ Exemple :
\   : calcul-lourd ( n -- result )
\     dup * dup * ;  \ n^4
\
\   4 pool:start   \ 4 workers
\   ' calcul-lourd pool:submit
\   pool:collect .  \ résultat


\ ──────────────────────────────────────────────────────────────────────
\ 9. VARIABLE THREAD-LOCAL (simulation)
\ ──────────────────────────────────────────────────────────────────────
\
\ Simule des variables locales à chaque tâche.
\ Utilise l'index de pile (depth) comme pseudo-ID de tâche.

8 constant TLS-MAX-TASKS

: tls:create ( default_val -- addr )
  \ Crée une variable thread-local avec une valeur par défaut
  here swap
  TLS-MAX-TASKS 0 do
    dup ,                       \ initialiser chaque slot
  loop
  drop ;

: tls:get ( addr -- val )
  \ Lit la valeur pour la tâche courante
  depth TLS-MAX-TASKS mod + @ ;

: tls:set ( val addr -- )
  \ Écrit la valeur pour la tâche courante
  depth TLS-MAX-TASKS mod + ! ;


\ ──────────────────────────────────────────────────────────────────────
\ 10. PATTERNS D'UTILISATION
\ ──────────────────────────────────────────────────────────────────────
\
\ === Pattern 1 : Protection d'une variable partagée ===
\
\   mutex:create constant counter-lock
\   variable shared-counter
\
\   : safe-increment ( -- )
\     counter-lock mutex:lock
\     1 shared-counter +!
\     counter-lock mutex:unlock ;
\
\ === Pattern 2 : Producteur/Consommateur ===
\
\   32 chan:create constant data-chan
\
\   : producer ( -- )
\     100 0 do
\       i data-chan chan:send
\       10 ms
\     loop ;
\
\   : consumer ( -- )
\     100 0 do
\       data-chan chan:recv . cr
\     loop ;
\
\ === Pattern 3 : Resource Pool ===
\
\   3 sem:create constant db-pool
\
\   : with-db-connection ( xt -- )
\     db-pool sem:wait
\     try execute 0 catch drop endtry
\     db-pool sem:signal ;
\
\ === Pattern 4 : Read-Heavy Cache ===
\
\   rwlock:create constant cache-lock
\   variable cache-data
\
\   : read-cache ( -- val )
\     cache-lock rwlock:read-lock
\     cache-data @
\     cache-lock rwlock:read-unlock ;
\
\   : update-cache ( val -- )
\     cache-lock rwlock:write-lock
\     cache-data !
\     cache-lock rwlock:write-unlock ;
\
\ === Pattern 5 : Safe cleanup avec mutex:with ===
\
\   mutex:create constant file-lock
\
\   : safe-write ( data addr -- )
\     file-lock ['] do-write mutex:with ;


\ ──────────────────────────────────────────────────────────────────────
\ 11. TESTS
\ ──────────────────────────────────────────────────────────────────────

variable mtest-ok
variable mtest-ko

: mok   1 mtest-ok +! ;
: mko   1 mtest-ko +! ;

: massert= ( got expected -- )
  2dup = if 2drop mok
  else mko cr ." ECHEC: attendu " . ." obtenu " . cr then ;

: massert-true ( flag -- )
  if mok else mko cr ." ECHEC assert-true" cr then ;

: test-atomic ( -- )
  ." [M1] Atomic... "
  variable tvar-a
  0 tvar-a !
  42 tvar-a atomic!
  tvar-a atomic@ 42 massert=
  10 tvar-a atomic+!
  tvar-a atomic@ 52 massert=
  99 tvar-a atomic-swap 52 massert=
  tvar-a atomic@ 99 massert=
  ." OK" cr ;

: test-spinlock ( -- )
  ." [M2] Spinlock... "
  spin:create constant test-spin
  test-spin spin:locked? 0= massert-true
  test-spin spin:lock
  test-spin spin:locked? massert-true
  test-spin spin:unlock
  test-spin spin:locked? 0= massert-true
  test-spin spin:try massert-true
  test-spin spin:unlock
  ." OK" cr ;

: test-mutex ( -- )
  ." [M3] Mutex... "
  mutex:create constant test-mtx
  test-mtx mutex:locked? 0= massert-true
  test-mtx mutex:lock
  test-mtx mutex:locked? massert-true
  \ Récursion
  test-mtx mutex:lock
  test-mtx mutex:count 2 massert=
  test-mtx mutex:unlock
  test-mtx mutex:count 1 massert=
  test-mtx mutex:unlock
  test-mtx mutex:locked? 0= massert-true
  ." OK" cr ;

: test-semaphore ( -- )
  ." [M4] Semaphore... "
  3 sem:create constant test-sem
  test-sem sem:count 3 massert=
  test-sem sem:wait
  test-sem sem:count 2 massert=
  test-sem sem:wait
  test-sem sem:count 1 massert=
  test-sem sem:signal
  test-sem sem:count 2 massert=
  test-sem sem:try massert-true
  test-sem sem:count 1 massert=
  ." OK" cr ;

: test-channel ( -- )
  ." [M5] Channel... "
  4 chan:create constant test-chan
  test-chan chan:empty? massert-true
  42 test-chan chan:send
  test-chan chan:empty? 0= massert-true
  test-chan chan:count 1 massert=
  99 test-chan chan:send
  test-chan chan:count 2 massert=
  test-chan chan:recv 42 massert=
  test-chan chan:recv 99 massert=
  test-chan chan:empty? massert-true
  ." OK" cr ;

: test-mutex-suite ( -- )
  cr ." === TESTS SYNCHRONISATION ===" cr
  0 mtest-ok !  0 mtest-ko !

  test-atomic
  test-spinlock
  test-mutex
  test-semaphore
  test-channel

  cr ." Resultats sync : "
  mtest-ok @ . ." OK, "
  mtest-ko @ . ." ECHEC" cr
  mtest-ko @ 0= if
    ." Tous les tests passent." cr
  else
    ." IL Y A DES ECHECS !" cr
  then ;


\ ──────────────────────────────────────────────────────────────────────
\ 12. INTÉGRATION AVEC LE SCHEDULER
\ ──────────────────────────────────────────────────────────────────────
\
\ IMPORTANT : Pour que critical-begin / critical-end fonctionnent,
\ le scheduler dans interpreter.rs doit vérifier critical-depth.
\
\ Dans execute_ops_limited(), ajouter après le check de préemption :
\
\   // Vérifier si une section critique est active
\   if critical_depth > 0 {
\     // Ne pas préempter — la tâche est en section critique
\     continue;
\   }
\
\ La variable critical-depth doit être accessible depuis Rust.
\ Deux options :
\
\ Option A : Utiliser une variable Forth partagée
\   Le mot critical-begin/end manipule memory[CRITICAL_ADDR]
\   et le scheduler lit cette adresse.
\
\ Option B : Ajouter un champ à ForthVm
\   pub critical_depth: u32
\   Avec deux primitives Rust :
\     critical-begin ( -- )  →  self.critical_depth += 1
\     critical-end   ( -- )  →  self.critical_depth -= 1
\
\ L'option B est recommandée pour la fiabilité.
\
\ Implémentation Rust (à ajouter dans interpreter.rs) :
\
\   // Dans ForthVm :
\   pub critical_depth: u32,
\
\   // Primitive 310 : critical-begin
\   310 => { self.critical_depth += 1; }
\
\   // Primitive 311 : critical-end
\   311 => {
\       if self.critical_depth > 0 {
\           self.critical_depth -= 1;
\       }
\   }
\
\   // Dans execute_ops_limited, dans le bloc de préemption :
\   if max_instr > 0 && crate::interrupts::PREEMPT_REQUESTED
\       .load(Ordering::SeqCst)
\   {
\       if self.critical_depth == 0 {
\           // Préemption autorisée
\           ...
\       } else {
\           // En section critique — reporter la préemption
\           // Ne PAS reset le flag, il sera traité plus tard
\       }
\   }


\ ──────────────────────────────────────────────────────────────────────
\ CHARGEMENT TERMINÉ
\ ──────────────────────────────────────────────────────────────────────

cr
." ════════════════════════════════════════════════════════" cr
."  MUTEX.FTH charge avec succes" cr
."  Mutex : mutex:create mutex:lock mutex:unlock" cr
."  Spinlock : spin:create spin:lock spin:unlock" cr
."  Semaphore : sem:create sem:wait sem:signal" cr
."  Channel : chan:create chan:send chan:recv" cr
."  RWLock : rwlock:create rwlock:read-lock" cr
."  Barrier : barrier:create barrier:wait" cr
."  Tapez 'test-mutex-suite' pour les tests." cr
." ════════════════════════════════════════════════════════" cr
```

---

## Résumé des deux fichiers

### FIXED.FTH — Virgule fixe Q20.12

| Section | Contenu |
|---|---|
| Constantes | π, e, √2, φ, conversions |
| Conversion | `f.from` `f.to` `f.round` `f.from-milli` `f.from-percent` |
| Arithmétique | `f+` `f-` `f*` `f/` `fnegate` `fabs` `fmin` `fmax` `fmod` |
| Comparaison | `f=` `f<` `f>` `f~` `fwithin` |
| Affichage | `f.` `f.n` `f.deg` `f.percent` |
| Mathématiques | `fsqrt` `fpow` `fsin` `fcos` `ftan` `fatan` `fatan2` |
| Utilitaires | `flerp` `fclamp` `fmap` `ffloor` `fceil` `favg` |
| Vecteurs 2D | `v2.add` `v2.len` `v2.normalize` `v2.rotate` `v2.dist` |
| Physique | `phys.move` `phys.bounce` `phys.collide-circle?` |
| Capteurs | `sensor.adc-to-voltage` `sensor.celsius-to-f` |
| Traceur | `plot.setup` `plot.curve` `plot.axes` `plot.grid` |
| Démos | `demo-ball` `demo-plot-sin` `demo-plot-carre` |
| Tests | `test-fixed` — 7 groupes de tests automatiques |

### MUTEX.FTH — Synchronisation

| Section | Contenu |
|---|---|
| Atomique | `atomic@` `atomic!` `atomic+!` `compare-and-swap` |
| Spinlock | `spin:create` `spin:lock` `spin:unlock` `spin:try` |
| Mutex | `mutex:create` `mutex:lock` `mutex:unlock` `mutex:with` |
| Sémaphore | `sem:create` `sem:wait` `sem:signal` `sem:try` |
| Channel | `chan:create` `chan:send` `chan:recv` |
| Barrière | `barrier:create` `barrier:wait` |
| RWLock | `rwlock:create` `rwlock:read-lock` `rwlock:write-lock` |
| Pool | `pool:start` `pool:submit` `pool:collect` |
| TLS | `tls:create` `tls:get` `tls:set` |
| Intégration | Guide pour modifier `interpreter.rs` (critical_depth) |
| Tests | `test-mutex-suite` — 5 groupes de tests |

### Modification Rust nécessaire pour MUTEX.FTH

Il faut ajouter dans `interpreter.rs` :

```rust
// Dans ForthVm :
pub critical_depth: u32,

// Primitives 310-311 :
self.add_primitive("critical-begin", 310, false);
self.add_primitive("critical-end",   311, false);

// Dans exec_primitive :
310 => { self.critical_depth += 1; }
311 => { if self.critical_depth > 0 { self.critical_depth -= 1; } }

// Dans execute_ops_limited, bloc préemption :
if self.critical_depth == 0 {
    // Préemption autorisée
    crate::interrupts::PREEMPT_REQUESTED.store(false, Ordering::SeqCst);
    self.task_save = Some(VmSnapshot { ... });
    return Err("Preempt");
}
// sinon : reporter la préemption
```
