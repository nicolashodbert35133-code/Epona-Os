<h1 align="center">Epona OS</h1>

<p align="center">
  <img src="https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/Epona%20Os%20fond%20transparent.png" width="350" alt="Epona OS Logo">
</p>

<p align="center">
  Système d’exploitation celte, libre, modulaire et extensible.
</p>

Epona OS est un système d’exploitation celte libre, écrit en Rust et Forth. Inspiré de la déesse Epona, il incarne vitesse, liberté et stabilité. Conçu en Bretagne, il explore la création d’un OS souverain, graphique et modulaire.

================================================================================
                        EPONA OS — GUIDE COMPLET
              Systeme d'exploitation bare-metal UEFI en Rust
            avec interprete Forth integre (EponaForth)
================================================================================

Bienvenue dans Epona OS !

Ce guide vous explique comment utiliser le systeme, programmer en Forth,
et acceder au materiel directement depuis votre clavier.

Epona OS demarre depuis une cle USB et fonctionne sans Windows, sans Linux,
sans aucun autre systeme. Il tourne directement sur le processeur.

================================================================================
TABLE DES MATIERES
================================================================================

  1. DEMARRAGE ET INTERFACE
  2. LE TERMINAL (SHELL)
  3. INTRODUCTION AU FORTH
  4. REFERENCE DU LANGAGE FORTH
  5. ACCES AU MATERIEL
  6. SYSTEME DE FICHIERS (CLE USB)
  7. L'EDITEUR DE CODE (IDE)
  8. APPLICATIONS INTEGREES
  9. EXEMPLES COMPLETS
 10. ARCHITECTURE DU SYSTEME
 11. QUESTIONS FREQUENTES
 12. GLOSSAIRE

================================================================================
1. DEMARRAGE ET INTERFACE
================================================================================

PREPARATION DE LA CLE USB :
---------------------------
  1. Formatez une cle USB en FAT32
  2. Copiez le fichier BOOTX64.EFI dans le dossier EFI\BOOT\
  3. (Optionnel) Copiez vos fichiers .FTH a la racine
  4. Demarrez l'ordinateur sur la cle USB (touche F12 ou F2 au demarrage)

LE BUREAU :
-----------
  Epona OS possede un bureau graphique avec :
  - Des icones a gauche (double-clic pour ouvrir)
  - Une barre des taches en bas
  - Un bouton "Epona OS" (ou touche F1) pour le menu
  - L'heure en bas a droite

  Icones disponibles :
    Terminal    — Console de commandes et Forth
    Editeur     — IDE pour ecrire du code Forth
    PCI         — Explorateur de peripheriques
    Calc        — Calculatrice
    Paint       — Zone de dessin
    Aide        — Guide rapide

SOURIS ET CLAVIER :
-------------------
  La souris fonctionne avec :
  - Touchpad (AbsolutePointer UEFI)
  - Souris USB (SimplePointer UEFI + USB HID natif)
  - Souris PS/2 (fallback i8042)
  - I2C HID (touchpad natif, driver DesignWare)

  Si aucune souris n'est detectee :
    F12         — Active le mode "souris clavier"
                  Fleches = deplacement, Espace = clic
                  1-5 = vitesse du curseur

RACCOURCIS GLOBAUX :
--------------------
  F1            — Menu Demarrer
  F2            — Basculer AZERTY / QWERTY
  F9            — ARRET D'URGENCE (stoppe le Forth, ecrit CRASH.TXT)
  F12           — Mode souris clavier

RACCOURCIS EDITEUR :
--------------------
  F3            — Charger demo Paint
  F4            — Charger demo Rebond
  F5            — Compiler et executer le code
  F6            — Sauvegarder sur cle USB
  F7            — Charger depuis cle USB
  Echap         — Fermer la fenetre
  PgUp / PgDn   — Defiler le code


================================================================================
2. LE TERMINAL (SHELL)
================================================================================

Le terminal est la fenetre principale. Vous pouvez y taper :
  - Des commandes shell (ls, cat, exec...)
  - Du code Forth directement (5 3 + .)

COMMANDES FICHIERS :
--------------------
  ls              — Liste les fichiers du dossier courant
  cd <dossier>    — Change de repertoire (cd .. pour remonter)
  cat <fichier>   — Affiche le contenu d'un fichier
  exec <fichier>  — Execute un fichier Forth (.FTH)
  touch <fichier> — Cree un fichier vide
  mkdir <dossier> — Cree un dossier
  rm <fichier>    — Supprime un fichier
  save <fichier>  — Sauvegarde l'editeur principal
  load <fichier>  — Charge un fichier dans un editeur
  edit <fichier>  — Idem que load
  newedit <fich>  — Ouvre dans un nouvel editeur

COMMANDES SYSTEME :
-------------------
  aide            — Affiche l'aide des commandes
  effacer         — Efface l'ecran du terminal
  clavier         — Bascule AZERTY / QWERTY
  apropos         — A propos du systeme
  drivers         — Liste les pilotes charges
  scheduler       — Etat des taches du systeme
  log             — Affiche le journal systeme
  words           — Liste tous les mots Forth disponibles
  secure on|off   — Active/desactive le mode securise

COMMANDES MATERIEL :
--------------------
  pci             — Liste les peripheriques PCI
  pci save        — Sauvegarde la liste PCI sur USB (PCI.TXT)
  acpi            — Affiche les tables ACPI
  acpi save       — Sauvegarde les infos ACPI (ACPI.TXT)
  devices         — Liste complete du materiel
  devices save    — Sauvegarde sur USB (DEVICES.TXT)
  mmio <addr>     — Lit un registre MMIO 32-bit
  mmio <addr> <v> — Ecrit une valeur MMIO 32-bit
  i2c probe <b>   — Scrute les peripheriques I2C
  i2c read <b> <d> <r> [len] — Lit un registre I2C


================================================================================
3. INTRODUCTION AU FORTH
================================================================================

Forth est un langage a pile (stack). C'est l'un des langages les plus
simples et les plus puissants qui existent. Il a ete cree en 1970 par
Charles Moore pour controler des telescopes.

PRINCIPE DE BASE :
------------------
  En Forth, on ecrit les nombres AVANT les operations.
  Les nombres sont empiles, puis les mots les consomment.

  Au lieu d'ecrire :    5 + 3       (notation classique)
  On ecrit :            5 3 +       (notation polonaise inverse)

  La "pile" est comme une pile d'assiettes :
  - On pose des valeurs dessus (push)
  - On prend celles du dessus (pop)

PREMIER EXEMPLE :
-----------------
  Tapez dans le terminal :

    5 3 + .

  Resultat : 8

  Explication :
    5     — Empile 5          Pile : [5]
    3     — Empile 3          Pile : [5, 3]
    +     — Additionne        Pile : [8]
    .     — Affiche et retire Pile : [] (vide)

AUTRES EXEMPLES :
-----------------
    10 2 * .          — Affiche 20 (10 fois 2)
    100 30 - .        — Affiche 70 (100 moins 30)
    15 4 / .          — Affiche 3 (division entiere)
    15 4 mod .        — Affiche 3 (reste de la division)

DEFINIR UN MOT (FONCTION) :
----------------------------
  En Forth, on cree des "mots" (comme des fonctions) avec : et ;

    : carre ( n -- n*n )  dup * ;

  Explication :
    :         — Debut de definition
    carre     — Nom du nouveau mot
    ( n -- n*n )  — Commentaire (effet sur la pile)
    dup       — Duplique le sommet de pile
    *         — Multiplie les deux valeurs du dessus
    ;         — Fin de definition

  Utilisation :
    5 carre .         — Affiche 25
    3 carre .         — Affiche 9

COMMENTAIRES :
--------------
  Deux types de commentaires :
    \ Ceci est un commentaire jusqu'a la fin de la ligne
    ( Ceci est un commentaire entre parentheses )

  Les commentaires entre parentheses servent souvent a documenter
  l'effet d'un mot sur la pile :
    ( avant -- apres )
    ( n1 n2 -- somme )


================================================================================
4. REFERENCE DU LANGAGE FORTH
================================================================================

MANIPULATION DE LA PILE :
-------------------------
  dup     ( a -- a a )        — Duplique le sommet
  drop    ( a -- )            — Supprime le sommet
  swap    ( a b -- b a )      — Echange les deux premiers
  over    ( a b -- a b a )    — Copie le deuxieme element
  rot     ( a b c -- b c a )  — Rotation des trois premiers
  -rot    ( a b c -- c a b )  — Rotation inverse
  nip     ( a b -- b )        — Supprime le deuxieme
  tuck    ( a b -- b a b )    — Copie le sommet sous le deuxieme
  2dup    ( a b -- a b a b )  — Duplique la paire
  2drop   ( a b -- )          — Supprime la paire
  2swap   ( a b c d -- c d a b ) — Echange deux paires
  2over   ( a b c d -- a b c d a b ) — Copie la paire
  ?dup    ( a -- a a | 0 )    — Duplique seulement si non-zero
  pick    ( ... n -- nth )    — Copie le n-ieme element
  pile                        — Affiche toute la pile

ARITHMETIQUE :
--------------
  +       ( a b -- a+b )      — Addition
  -       ( a b -- a-b )      — Soustraction
  *       ( a b -- a*b )      — Multiplication
  /       ( a b -- a/b )      — Division entiere
  mod     ( a b -- a%b )      — Reste (modulo)
  /mod    ( a b -- reste quotient ) — Division + reste
  1+      ( n -- n+1 )        — Incremente
  1-      ( n -- n-1 )        — Decremente
  2+      ( n -- n+2 )        — Ajoute 2
  2-      ( n -- n-2 )        — Soustrait 2
  2*      ( n -- n*2 )        — Double
  2/      ( n -- n/2 )        — Divise par 2
  abs     ( n -- |n| )        — Valeur absolue
  negate  ( n -- -n )         — Change de signe
  min     ( a b -- min )      — Minimum
  max     ( a b -- max )      — Maximum
  hasard  ( max -- n )        — Nombre aleatoire entre 0 et max-1

COMPARAISON :
-------------
  =       ( a b -- flag )     — Egal
  <>      ( a b -- flag )     — Different
  <       ( a b -- flag )     — Inferieur
  >       ( a b -- flag )     — Superieur
  <=      ( a b -- flag )     — Inferieur ou egal
  >=      ( a b -- flag )     — Superieur ou egal
  0=      ( n -- flag )       — Egal a zero
  0<>     ( n -- flag )       — Different de zero
  0<      ( n -- flag )       — Negatif
  0>      ( n -- flag )       — Positif

  Un "flag" vaut 1 (vrai) ou 0 (faux).

LOGIQUE BINAIRE (BITS) :
-------------------------
  and     ( a b -- a&b )      — ET binaire
  or      ( a b -- a|b )      — OU binaire
  xor     ( a b -- a^b )      — OU exclusif
  invert  ( a -- ~a )         — Inverse tous les bits
  lshift  ( a n -- a<<n )     — Decalage a gauche
  rshift  ( a n -- a>>n )     — Decalage a droite

AFFICHAGE :
-----------
  .       ( n -- )            — Affiche un nombre
  u.      ( u -- )            — Affiche en non-signe
  cr                          — Retour a la ligne
  space                       — Affiche un espace
  spaces  ( n -- )            — Affiche n espaces
  emit    ( c -- )            — Affiche un caractere (code ASCII)
  ." texte"                   — Affiche une chaine de texte
  hex                         — Passe en mode hexadecimal
  decimal                     — Revient en mode decimal

  Exemples :
    65 emit                   — Affiche 'A'
    cr ." Bonjour!" cr        — Affiche Bonjour! avec retours a la ligne
    hex 255 . decimal         — Affiche 0xFF

VARIABLES ET MEMOIRE :
----------------------
  variable <nom>              — Declare une variable
  <nom>                       — Empile l'adresse de la variable
  @       ( addr -- val )     — Lit la valeur a l'adresse
  !       ( val addr -- )     — Ecrit la valeur a l'adresse
  +!      ( n addr -- )       — Ajoute n a la valeur

  Exemple :
    variable compteur         \ Declare "compteur"
    0 compteur !              \ Initialise a 0
    compteur @ .              \ Affiche 0
    1 compteur +!             \ Incremente de 1
    compteur @ .              \ Affiche 1

CONSTANTES :
------------
  <valeur> constant <nom>     — Cree une constante

  Exemple :
    100 constant LARGEUR
    LARGEUR .                 \ Affiche 100

STRUCTURES DE CONTROLE :
-------------------------

  IF ... THEN :
    <condition> if
      <code si vrai>
    then

  IF ... ELSE ... THEN :
    <condition> if
      <code si vrai>
    else
      <code si faux>
    then

  Exemples :
    : positif? ( n -- )
      0 > if ." positif" else ." negatif ou nul" then
    ;
    5 positif?                \ Affiche "positif"
    -3 positif?               \ Affiche "negatif ou nul"

  BEGIN ... UNTIL (boucle) :
    begin
      <code>
      <condition>  \ Quitte quand la condition est VRAIE
    until

  Exemple :
    : compte ( n -- )         \ Compte de 0 a n-1
      0                       \ Compteur initial
      begin
        dup .                 \ Affiche le compteur
        1+                    \ Incremente
        2dup =                \ Compare avec la limite
      until
      2drop                   \ Nettoie la pile
    ;
    5 compte                  \ Affiche 0 1 2 3 4

  DO ... LOOP :
    <limite> <debut> do
      <code>
    loop

  Exemple :
    : etoiles ( n -- )
      0 do
        42 emit               \ 42 = code ASCII de *
      loop
      cr
    ;
    5 etoiles                 \ Affiche *****

  DO ... +LOOP (pas variable) :
    10 0 do
      i .                     \ Affiche l'index de boucle
      2                       \ Pas de 2
    +loop                     \ Affiche 0 2 4 6 8

RECURSION :
-----------
    : factorielle ( n -- n! )
      dup 1 <= if
        drop 1
      else
        dup 1- recurse *
      then
    ;
    5 factorielle .           \ Affiche 120

MOTS AVANCES :
--------------
  create <nom>                — Cree un mot qui empile une adresse
  does>                       — Definit le comportement d'un mot cree
  here                        — Adresse memoire courante
  allot   ( n -- )            — Reserve n cellules memoire
  ,       ( val -- )          — Stocke val a here et avance
  words                       — Liste tous les mots definis
  '       <mot>               — Empile l'index du mot
  execute ( idx -- )          — Execute un mot par son index
  postpone <mot>              — Compile un mot immediat


================================================================================
5. ACCES AU MATERIEL
================================================================================

Epona OS permet d'acceder directement au materiel de l'ordinateur.
C'est une fonctionnalite unique et puissante.

ATTENTION : Les operations materielles peuvent bloquer ou redemarrer
votre ordinateur si mal utilisees. Utilisez "secure on" pour bloquer
les acces dangereux pendant l'apprentissage.

MEMOIRE (RAM) :
---------------
  mem-map ( -- total free )   — Pages memoire totales et libres
                                1 page = 4096 octets (4 KB)

  Exemple :
    mem-map                   \ Empile total et free
    swap                      \ Met total au sommet
    4 * 1024 / .              \ Affiche total en MB
    4 * 1024 / .              \ Affiche libre en MB

ECRAN (FRAMEBUFFER) :
---------------------
  fb-size ( -- w h )          — Taille de l'ecran en pixels
  fb-swap ( -- )              — Envoie le buffer a l'ecran
  fb:pixel ( x y color -- )   — Dessine un pixel sur l'ecran reel
  fb:rect  ( x y w h col -- ) — Rectangle sur l'ecran reel
  fb:line  ( x1 y1 x2 y2 col -- ) — Ligne sur l'ecran reel
  fb:text  ( x y char col -- )     — Caractere sur l'ecran reel

  Couleurs : format 0xRRGGBB
    0xFF0000 = rouge
    0x00FF00 = vert
    0x0000FF = bleu
    0xFFFFFF = blanc
    0x000000 = noir

CANVAS FORTH (zone protegee 400x300) :
--------------------------------------
  pixel   ( x y color -- )    — Pixel dans le canvas Forth
  rect    ( x y w h col -- )  — Rectangle dans le canvas
  ligne   ( x1 y1 x2 y2 col -- ) — Ligne dans le canvas
  effacer ( color -- )        — Efface le canvas
  couleur ( r g b -- color )  — Compose une couleur RGB

ENTREES :
---------
  touche  ( -- char )         — Attend une touche (bloquant)
  touche? ( -- char|0 )       — Lit une touche (non-bloquant)
  souris  ( -- x y btn )      — Position et bouton souris
  souris? ( -- flag )         — 1 si souris detectee
  attendre ( ms -- )          — Pause en millisecondes

HORLOGE :
---------
  get-time ( -- sec min hour day month year )  — Lit l'heure RTC
  set-time ( year month day hour minute sec -- ) — Change l'heure
  rdtsc    ( -- ticks )       — Compteur CPU haute precision
  ticks    ( -- ms )          — Millisecondes depuis le demarrage

PCI (PERIPHERIQUES) :
---------------------
  pci-scan ( -- count )       — Scanne le bus PCI
  pci-dev  ( idx -- bus dev func vid did class sub )
                              — Infos d'un peripherique
  pci-name ( class sub -- ptr len ) — Nom de la classe
  pci@     ( bus dev func off -- val ) — Lit config PCI
  pci!     ( val bus dev func off -- ) — Ecrit config PCI
  pci-bar  ( bus dev func barn -- ... ) — Lit un BAR PCI

ACPI :
------
  acpi-rsdp   ( -- addr )     — Adresse de la table RSDP
  acpi-find   ( sig -- addr ) — Cherche une table ACPI par signature
  acpi-hdr    ( addr -- sig len ) — Lit l'en-tete d'une table
  acpi-tables ( -- n addr... ) — Liste toutes les tables

SMBIOS :
--------
  smbios-entry ( -- addr )    — Adresse de l'entree SMBIOS
  smbios-info  ( addr -- len table_addr count maj min ) — Infos SMBIOS

PORTS I/O (x86) :
-----------------
  inb     ( port -- byte )    — Lit un port 8-bit
  outb    ( byte port -- )    — Ecrit un port 8-bit
  inw     ( port -- word )    — Lit un port 16-bit
  outw    ( word port -- )    — Ecrit un port 16-bit
  inl     ( port -- long )    — Lit un port 32-bit
  outl    ( long port -- )    — Ecrit un port 32-bit

MMIO :
------
  mmio@   ( addr -- val )     — Lit MMIO 32-bit
  mmio!   ( val addr -- )     — Ecrit MMIO 32-bit
  c@      ( addr -- byte )    — Lit MMIO 8-bit
  c!      ( byte addr -- )    — Ecrit MMIO 8-bit
  w@      ( addr -- word )    — Lit MMIO 16-bit
  w!      ( word addr -- )    — Ecrit MMIO 16-bit
  l@      ( addr -- long )    — Lit MMIO 32-bit
  l!      ( long addr -- )    — Ecrit MMIO 32-bit

I2C :
-----
  dw-i2c-init  ( base -- ok? )     — Initialise controleur I2C
  dw-i2c-probe ( base addr -- ok? ) — Teste peripherique I2C
  i2c.probe    ( base -- )         — Scrute toutes les adresses HID
  i2c-read     ( base dev reg -- val|-1 ) — Lit registre I2C

MSR (REGISTRES CPU) :
---------------------
  msr@    ( ecx -- edx eax )  — Lit un MSR
  msr!    ( eax edx ecx -- )  — Ecrit un MSR
  cpuid   ( eax -- eax ebx ecx edx ) — Instruction CPUID

INTERRUPTS :
------------
  apic-base     ( -- addr )   — Adresse du Local APIC
  ioapic-read   ( base reg -- val )  — Lit registre I/O APIC
  ioapic-write  ( base reg val -- )  — Ecrit registre I/O APIC
  init-idt      ( -- )        — Initialise la table IDT
  irq-handler   ( vector dict_idx -- ) — Associe un handler Forth

MEMOIRE PHYSIQUE :
------------------
  alloc-phys ( pages -- addr|0 ) — Alloue des pages physiques
  free-phys  ( addr pages -- ok? ) — Libere des pages
  phys@      ( addr -- val )   — Lit 64-bit en memoire physique
  phys!      ( val addr -- )   — Ecrit 64-bit en memoire physique
  stall      ( us -- )         — Delai via UEFI (microsecondes)
  stall-us   ( us -- )         — Delai via RDTSC

CONTROLE SYSTEME :
------------------
  reboot   ( -- )             — Redemarrage a chaud
  poweroff ( -- )             — Arret complet


================================================================================
6. SYSTEME DE FICHIERS (CLE USB)
================================================================================

Epona OS peut lire et ecrire sur la cle USB au format FAT32.

MOTS FORTH POUR LES FICHIERS :
-------------------------------
  sys:load <fichier>          — Charge et compile un fichier Forth
  sys:read <fichier>          — Lit un fichier en memoire
                                ( addr -- len )
  sys:write <fichier>         — Ecrit la memoire dans un fichier
                                ( addr len -- )

CHARGEMENT AUTOMATIQUE :
-------------------------
  Au demarrage, Epona OS cherche le fichier BOOT.FTH a la racine
  de la cle USB. S'il existe, il est automatiquement compile et
  execute. C'est l'endroit ideal pour vos initialisations.

  Exemple de BOOT.FTH :
    \ Fichier de demarrage Epona OS
    cr ." === Bienvenue dans Epona OS ===" cr
    sys:load RAM.FTH
    sys:load OUTILS.FTH
    cr ." Systeme pret." cr

DRIVERS FORTH :
---------------
  sys:register <nom>          — Enregistre un pilote
  sys:drivers                 — Liste les pilotes enregistres
  sys:probe                   — Initialise tous les pilotes
  sys:log <message>           — Ecrit dans le journal systeme

  Pour creer un driver, definissez un mot <nom>-init :
    sys:register mondriver
    : mondriver-init ( -- )
      ." Initialisation..." cr
    ;
    sys:probe                 \ Appelle mondriver-init

APPLICATIONS FORTH :
--------------------
  app: <nom>                  — Cree une fenetre d'application
                                ( x y w h -- )
  Vous devez definir :
    <nom>-draw  ( x y w h -- ) — Dessin de l'application
    <nom>-key   ( char -- )    — Gestion clavier


================================================================================
7. L'EDITEUR DE CODE (IDE)
================================================================================

L'editeur integre permet d'ecrire, sauvegarder et executer du code Forth.

INTERFACE :
-----------
  - Zone d'edition avec numeros de lignes
  - Coloration syntaxique :
      Vert   = commentaires (lignes commencant par \)
      Rouge  = definitions (lignes commencant par :)
      Noir   = code normal
  - Barre de statut en bas (erreurs en rouge)

RACCOURCIS :
------------
  F3            — Charger la demo Paint
  F4            — Charger la demo Rebond
  F5            — Compiler et executer
  F6            — Sauvegarder sur USB
  F7            — Charger depuis USB
  Echap         — Fermer l'editeur
  PgUp / PgDn   — Defiler
  Tab           — Indenter (2 espaces)

ERREURS :
---------
  Quand une erreur est detectee, la barre de statut devient rouge
  et indique le numero de ligne. La ligne en erreur est surlignee
  en rose dans l'editeur. L'editeur defilera automatiquement vers
  la ligne en question.


================================================================================
8. APPLICATIONS INTEGREES
================================================================================

CALCULATRICE :
--------------
  Une calculatrice simple avec les 4 operations.
  Cliquez sur les boutons ou utilisez le clavier :
    0-9     — Chiffres
    + - * / — Operations
    =       — Resultat
    C       — Effacer

ZONE DE DESSIN (PAINT) :
-------------------------
  Dessinez avec la souris !
  - Cliquez et glissez pour peindre
  - Palette de 8 couleurs en bas
  - Bouton "Effacer" pour tout nettoyer
  - La derniere couleur (blanc) sert de gomme

EXPLORATEUR PCI :
-----------------
  Affiche tous les peripheriques connectes au bus PCI :
  - Adresse (bus:device.function)
  - Identifiants fabricant et peripherique
  - Classe (stockage, reseau, graphique...)

CANVAS FORTH :
--------------
  Zone d'execution pour les programmes Forth graphiques.
  Taille : 400 x 300 pixels.
  S'ouvre automatiquement quand vous compilez (F5) un programme
  qui definit le mot "principal".
  Echap pour quitter.

WATCHDOG DIAGNOSTIQUE :
-----------------------
  Affiche l'etat du watchdog timer :
  - Init : OK ou code d'erreur
  - Feeds : nombre de rafraichissements
  - Erreurs eventuelles


================================================================================
9. EXEMPLES COMPLETS
================================================================================

EXEMPLE 1 — AFFICHER LA RAM :
------------------------------
  \ Fichier RAM.FTH
  : ram-info ( -- )
      cr ." === MEMOIRE SYSTEME ===" cr
      mem-map
      over cr ." Pages totales : " . cr
      dup  cr ." Pages libres  : " . cr
      over 4 * 1024 / cr ." RAM totale : " . ." MB" cr
      dup  4 * 1024 / cr ." RAM libre  : " . ." MB" cr
      2drop
      cr ." === FIN ===" cr
  ;

EXEMPLE 2 — DESSIN INTERACTIF :
--------------------------------
  \ Programme de dessin — compiler avec F5
  : principal
      16777215 effacer        \ Fond blanc
      begin
          souris              \ x y bouton
          1 = if
              0 pixel         \ Peindre en noir
          else
              drop drop       \ Ignorer x et y
          then
          touche? 27 =        \ Echap pour quitter
      until
  ;

EXEMPLE 3 — BALLE REBONDISSANTE :
----------------------------------
  variable x   variable y
  variable dx  variable dy

  : principal
      10 x !  10 y !
      4 dx !  3 dy !
      0 effacer
      begin
          \ Effacer l'ancienne position
          x @ y @ 25 25 0 rect
          \ Deplacer
          x @ dx @ + x !
          y @ dy @ + y !
          \ Rebondir
          x @ 375 > if -4 dx ! then
          x @ 0 < if 4 dx ! then
          y @ 275 > if -3 dy ! then
          y @ 0 < if 3 dy ! then
          \ Dessiner en bleu
          x @ y @ 25 25 65535 rect
          16 attendre
          touche? 27 =
      until
  ;

EXEMPLE 4 — SCANNER PCI :
--------------------------
  : scan-pci ( -- )
      cr ." === PERIPHERIQUES PCI ===" cr
      pci-scan                \ -- count
      dup ." Trouves: " . cr
      0 do
          i pci-dev           \ bus dev func vid did class sub
          cr
          ." Bus:" over 5 pick swap drop . 
          ." Dev:" over 4 pick swap drop .
          7 0 do drop loop    \ Nettoyer la pile
      loop
  ;

EXEMPLE 5 — HORLOGE :
----------------------
  : horloge ( -- )
      cr ." === HORLOGE ===" cr
      get-time                \ sec min hour day month year
      ." Annee: " . cr
      ." Mois:  " . cr
      ." Jour:  " . cr
      ." Heure: " . cr
      ." Min:   " . cr
      ." Sec:   " . cr
  ;

EXEMPLE 6 — INFORMATION ECRAN :
--------------------------------
  : ecran-info ( -- )
      cr ." === ECRAN ===" cr
      fb-size
      swap
      ." Largeur:  " . ." pixels" cr
      ." Hauteur:  " . ." pixels" cr
  ;

EXEMPLE 7 — FICHIER BOOT.FTH :
-------------------------------
  \ === BOOT.FTH — Demarrage automatique ===
  cr ." ================================" cr
  ." Epona OS — Demarrage systeme" cr
  ." ================================" cr

  \ Charger les utilitaires
  sys:load RAM.FTH

  \ Afficher les infos systeme
  mem-map swap
  4 * 1024 / cr ." RAM: " . ." MB" cr
  4 * 1024 / ." Libre: " . ." MB" cr

  fb-size swap
  cr ." Ecran: " . ." x " . cr

  cr ." Systeme pret. Tapez 'aide' pour commencer." cr


================================================================================
10. ARCHITECTURE DU SYSTEME
================================================================================

Epona OS est ecrit entierement en Rust, sans aucune dependance
a un systeme d'exploitation. Il utilise le firmware UEFI pour
demarrer et acceder au materiel de base.

COMPOSANTS :
------------
  main.rs         — Point d'entree, boucle principale, bureau
  interpreter.rs  — Machine virtuelle Forth (compilateur + executeur)
  graphics.rs     — Moteur graphique (double buffering, clipping)
  pointer.rs      — Gestion souris (UEFI, PS/2, I2C, USB HID)
  keyboard.rs     — Gestion clavier (AZERTY/QWERTY)
  filesystem.rs   — Lecture/ecriture FAT32 via UEFI
  shell.rs        — Terminal de commandes
  editor.rs       — Editeur de code avec coloration
  pci.rs          — Scanner PCI avec BARs
  acpi.rs         — Parseur ACPI (RSDP, RSDT, XSDT, DSDT, SSDT)
  i2c_hid.rs      — Driver I2C DesignWare pour touchpad
  usb_hid.rs      — Driver USB HID pour souris
  interrupts.rs   — IDT et handlers d'interruption
  scheduler.rs    — Ordonnanceur cooperatif de taches
  drivers.rs      — Gestionnaire de pilotes
  system.rs       — Noyau systeme et applications Forth
  apps.rs         — Calculatrice et Paint
  bump_alloc.rs   — Allocateur memoire (bump allocator 32 MB)

MACHINE VIRTUELLE FORTH :
--------------------------
  L'interprete Forth compile le code source en bytecode (Op),
  puis l'execute sur une pile. Les primitives (mots natifs) sont
  implementees en Rust et accedent directement au materiel.

  Types d'instructions :
    Push(val)       — Empile une valeur
    Call(idx)       — Appelle un mot defini
    CallPrim(idx)   — Appelle une primitive Rust
    Jump(addr)      — Saut inconditionnel
    JumpIfZero(addr)— Saut si le sommet est 0
    VariableAddr(n) — Empile l'adresse d'une variable
    Exit            — Retour d'un mot

  Securite :
    - Limite de 10 millions d'instructions (anti-boucle infinie)
    - Stack overflow detecte (4096 elements max)
    - Mode securise (bloque les acces materiel dangereux)
    - F9 = arret d'urgence avec dump sur USB


================================================================================
11. QUESTIONS FREQUENTES
================================================================================

Q: L'ecran reste noir au demarrage ?
R: Verifiez que le fichier est bien dans EFI\BOOT\BOOTX64.EFI.
   Essayez un autre port USB. Verifiez que le Secure Boot est
   desactive dans le BIOS.

Q: La souris ne bouge pas ?
R: Appuyez sur F12 pour activer le mode "souris clavier".
   Utilisez les fleches pour deplacer, Espace pour cliquer.

Q: Mon programme Forth boucle a l'infini ?
R: Appuyez sur F9 pour un arret d'urgence. Un fichier CRASH.TXT
   sera ecrit sur la cle USB avec les informations de debug.

Q: Comment sauvegarder mon travail ?
R: Dans l'editeur : F6 pour sauvegarder, F7 pour charger.
   Dans le terminal : save PROG.FTH / load PROG.FTH

Q: Comment executer un fichier .FTH ?
R: Tapez : exec MONFICHIER.FTH
   Ou depuis le Forth : sys:load MONFICHIER.FTH

Q: Le clavier est en QWERTY ?
R: Appuyez sur F2 ou tapez "clavier" dans le terminal.

Q: Comment voir tous les mots Forth disponibles ?
R: Tapez "words" dans le terminal.

Q: Comment connaitre la RAM de ma machine ?
R: Tapez "mem-map swap 4 * 1024 / . ." dans le terminal.
   Le premier nombre = total en MB, le second = libre en MB.

Q: Puis-je endommager mon ordinateur ?
R: En theorie, oui, avec des acces MMIO ou PCI incorrects.
   Utilisez "secure on" pour bloquer les acces dangereux.
   Les operations sur le canvas Forth sont toujours sans risque.

Q: Comment creer un programme graphique ?
R: Definissez un mot "principal" avec une boucle begin...until.
   Utilisez les mots pixel, rect, ligne, effacer pour dessiner.
   Compilez avec F5 dans l'editeur.


================================================================================
12. GLOSSAIRE
================================================================================

  ACPI    — Advanced Configuration and Power Interface
            Tables de configuration materiel dans le firmware
  BAR     — Base Address Register
            Adresse memoire d'un peripherique PCI
  Bytecode — Code intermediaire compile par le Forth
  Canvas  — Zone de dessin Forth protegee (400x300 pixels)
  CPUID   — Instruction x86 pour identifier le processeur
  FAT32   — Systeme de fichiers des cles USB
  Forth   — Langage de programmation a pile, cree en 1970
  Framebuffer — Zone memoire qui represente l'ecran pixel par pixel
  GOP     — Graphics Output Protocol (protocole UEFI pour l'ecran)
  HID     — Human Interface Device (souris, clavier, touchpad)
  I2C     — Bus serie pour peripheriques integres (touchpad)
  IDT     — Interrupt Descriptor Table (table des interruptions)
  MMIO    — Memory-Mapped I/O (acces materiel via adresses memoire)
  MSR     — Model-Specific Register (registres internes du CPU)
  PCI     — Peripheral Component Interconnect (bus de peripheriques)
  Pile    — Structure de donnees LIFO (Last In, First Out)
  RSDP    — Root System Description Pointer (point d'entree ACPI)
  SMBIOS  — System Management BIOS (infos materiel standardisees)
  UEFI    — Unified Extensible Firmware Interface
            Firmware moderne qui remplace le BIOS traditionnel
  USB     — Universal Serial Bus
  Watchdog — Timer materiel qui redemarre le PC s'il n'est pas
            rafraichi regulierement (desactive par Epona OS)

================================================================================
                    Epona OS — Fait avec passion en Rust
                    Interprete Forth integre — EponaForth
================================================================================

