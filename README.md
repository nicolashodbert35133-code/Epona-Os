<h1 align="center">Epona OS</h1>

<p align="center">
  <img src="https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/Epona%20Os%20fond%20transparent.png" width="350" alt="Epona OS Logo">
</p>

<p align="center">
  Système d’exploitation celte, libre, modulaire et extensible.
</p>

Epona OS est un système d’exploitation celte libre, écrit en Rust et Forth. Inspiré de la déesse Epona, il incarne vitesse, liberté et stabilité. Conçu en Bretagne, il explore la création d’un OS souverain, graphique et modulaire.

rejoint la communauté sur discord pour tout savoir
https://discord.gg/kwWBWhmvN
================================================================================
                        EPONA OS — GUIDE COMPLET
              Systeme d'exploitation bare-metal UEFI en Rust
            avec interprete Forth integre (EponaForth)
================================================================================

Bienvenue dans Epona OS !



## 🎯 À qui s’adresse Epona OS ?
Epona OS vise une communauté très précise :

- les **geeks** qui aiment comprendre comment marche un ordinateur,  
- les **développeurs bas‑niveau** (Rust, ASM, Forth),  
- les **makers** qui travaillent avec des microcontrôleurs, FPGA, cartes USB,  
- les **bidouilleurs hardware** qui veulent parler directement à une puce,  
- les passionnés d’OS qui veulent un système **simple, souverain, programmable**,  
- les gens qui veulent **écrire du code machine sans IDE**,  
- les curieux qui veulent un OS **hackable**, **modulaire**, **agentique**.

Epona OS n’est pas un clone de Linux ou Windows.  
C’est un **atelier matériel + langage système + environnement agentique**.

---

## ⚡ Ce qui rend Epona OS unique
### **1. Forth natif intégré au système**  
Epona OS n’a pas un “terminal”.  
Il a un **langage Forth natif**, directement connecté au kernel.

Tu peux :

- manipuler la mémoire,  
- appeler des drivers,  
- écrire des scripts système,  
- créer des widgets,  
- piloter du hardware,  
- tester des instructions machine,  
- tout ça **sans aucune application externe**.

**Forth = shell + IDE + debugger + console hardware.**

---

### **2. Accès direct au hardware via USB**
Tu peux brancher :

- un microcontrôleur,  
- une puce custom,  
- une carte FPGA,  
- un device expérimental,  
- un module électronique maison,

et **parler directement à la puce** depuis Epona OS.

Exemples :

```
usb:open-device
usb:write-bytes
usb:read-bytes
```

Pas de driver externe, pas de SDK, pas d’IDE.  
Juste toi, la puce, et Forth.

---

### **3. Écrire du langage machine directement**
Epona OS permet :

- d’écrire du code machine,  
- de l’exécuter,  
- de le tracer,  
- de le profiler,  
- de le modifier en live.

Tu peux créer :

- un mini assembleur,  
- un émulateur ISA,  
- un simulateur de pipeline,  
- un décodeur d’instructions,

**directement dans Forth**, sans quitter l’OS.

---

### **4. Émulateur ISA intégré (en cours de programmation)**
Tu peux charger un binaire :

```
emu:load
emu:step
emu:reg
emu:mem
```

Et exécuter du code machine **dans ton OS**, sans dépendre d’un outil externe.

---

### **5. Un OS souverain, minimaliste, agentique**
- Kernel Rust **fermé**, sécurisé, souverain  
- API Forth **ouverte**, extensible   
- Développeurs humains limités à Forth (sécurité + cohérence)  
- Pas de compatibilité Windows/Linux → pas de lourdeur  
- Pas de dépendances externes  
- Pas de licences contraignantes  

Epona OS est un OS **pour apprendre**, **expérimenter**, **créer**, **hacker**, **inventer**.

---

## 🧩 Pourquoi Epona OS est différent des autres OS
| OS | Objectif | Accès hardware | Langage natif | Niveau |
|----|----------|----------------|----------------|--------|
| Windows | Utilisateur | Très limité | Aucun | Haut niveau |
| Linux | Développeur | Moyen | Bash | Moyen |
| Iona‑OS | OS massif | Standard PC | Rust | Complexe |
| **Epona OS** | **Geeks / hardware / bas‑niveau** | **Direct USB / MMIO / PCI** | **Forth + ASM** | **Bas niveau / métal** |

👉 **Epona OS est le seul OS moderne conçu pour coder directement sur le métal.**

---

## 🔧 Ce que tu peux faire avec Epona OS
- écrire un driver USB en Forth,  
- piloter une puce FPGA branchée en USB,  
- envoyer des instructions machine à un microcontrôleur,  
- créer un émulateur RISC‑V ou x86,  
- écrire un mini assembleur,  
- manipuler la mémoire physique,  
- tracer des interruptions,  
- créer des outils système en Forth,  
- faire du prototypage hardware sans OS externe.

---

## 🧠 Pour les geeks : un OS qui ne vous limite pas
Epona OS est pensé pour ceux qui veulent :

- comprendre le hardware,  
- écrire du code bas‑niveau,  
- manipuler des registres,  
- créer des drivers,  
- expérimenter des architectures,  
- jouer avec des puces,  
- écrire du langage machine,  
- créer des outils système.

Si tu veux un OS pour “utiliser des applications”, il est fait pour toi.  
Si tu veux un OS pour **créer**, **expérimenter**, **apprendre**, **hacker**, **inventer**,  
alors Epona OS est fait pour toi.


Ce guide vous explique comment utiliser le systeme, programmer en Forth,
et acceder au materiel directement depuis votre clavier.

Epona OS demarre depuis une cle USB et fonctionne sans Windows, sans Linux,
sans aucun autre systeme. Il tourne directement sur le processeur.
[BOOTX64.efi](https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/EFI/BOOT/BOOTX64.efi)

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

  Clavier PS/2 (fallback i8042) — initialise automatiquement :
    - Scancode set 1 complet (lettres, chiffres, F1-F12, Home, End,
      PgUp, PgDn, Ins, Del, fleches, pavé numerique, etc.)
    - Modifieurs : Shift (G/D), Ctrl (G/D), Alt (G/D), Win (G/D)
    - Toggle : Caps Lock, Num Lock, Scroll Lock
    - Repeat rate : 10.9 Hz, delai 500 ms
    - LEDs synchronisees avec l'etat interne
    - Fallback automatique si le clavier UEFI ne repond pas

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

   Note : si le nom du fichier contient des espaces, mettez-le
   entre guillemets :
     load "mon fichier.fth"
     exec "test final.fth"
     save "mon projet v2.fth"
     cd "Program Files"

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
  file-allow      ( addr len -- )  — Ajoute un chemin a la whitelist fichiers
  file-revoke-all ( -- )           — Vide la whitelist fichiers
  mem-bounds      ( low high -- )  — Restreint la memoire accessible
  net-allow       ( -- )           — Active le reseau
  net-revoke      ( -- )           — Desactive le reseau
                                     par @ ! +! a [low..high[
                                     Utilise 0 4096 mem-bounds pour tout
                                     debloquer, ou 0 256 mem-bounds pour
                                     un petit espace de travail.

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

  Note : les parentheses ( et ) sont toujours des tokens séparés,
  même sans espace autour :
    (valider)     → valide : ( valider )
    2dup(avant)   → valide : 2dup ( avant )
    1+(n)rnd      → valide : 1+ ( n ) rnd


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
   depth   ( -- n )            — Profondeur de la pile
   .s      ( -- )              — Affiche la pile sans la detruire

MANIPULATION DE LA PILE DE RETOUR :
-----------------------------------
  >r      ( x -- )            — Transfere x sur la pile de retour (rstack)
  r>      ( -- x )            — Recupere x depuis la pile de retour (rstack)
  r@      ( -- x )            — Copie le sommet de la pile de retour (rstack)

  Note : les indices de boucle DO/LOOP sont stockés sur une pile séparée
  (loop_rstack). i et j sont donc immunisés contre >r/r> : vous pouvez
  utiliser >r à l'intérieur d'une boucle sans corrompre i ou j.

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
  .       ( n -- )            — Affiche un nombre (signé)
  u.      ( u -- )            — Affiche en non-signé
  cr                          — Retour a la ligne
  space                       — Affiche un espace
  spaces  ( n -- )            — Affiche n espaces
   emit    ( c -- )            — Affiche un caractere (code ASCII)
   type    ( addr len -- )     — Affiche une chaine depuis la mémoire
                                 Compagnon de s". Ex: s" Bonjour" type
  count   ( addr -- addr+1 n ) — Décompresse une chaine comptée
                                 Ex: create msg ," Hello"
                                     msg count type   \ Affiche Hello
  compare ( a1 n1 a2 n2 -- c ) — Compare deux chaînes
                                 c=0: egal, c=-1: a1<a2, c=1: a1>a2
  search  ( a1 n1 a2 n2 -- a3 n3 f )
                                 Cherche sous-chaîne a2/n2 dans a1/n1
                                 f=-1 : trouvé (a3 pointe le match, n3 = reste)
                                 f=0  : pas trouvé (a3=a1, n3=n1)
    ." texte"                   — Affiche une chaine de texte
   abort" message"             — Si flag ≠ 0, affiche "ABORT: message" et arrete
   hex                         — Passe en mode hexadecimal
  decimal                     — Revient en mode decimal

   Exemples :
     65 emit                   — Affiche 'A'
     cr ." Bonjour!" cr        — Affiche Bonjour! avec retours a la ligne
     hex 255 . decimal         — Affiche 0xFF
     dup 0 < abort" Negatif !" — Arrete si negatif

LITTERAUX NUMERIQUES :
-----------------------
  Les nombres sont signés (i64). Les grands hexadécimaux sont
  interprétés en non-signé puis convertis en signé :
    0xFFFFFFFF        = 4294967295 → -1 (tous les bits à 1)
    0x8000000000000000 = i64::MIN  (bit de poids fort seul)
    0x7FFFFFFFFFFFFFFF = i64::MAX
  C'est délibéré : -1 = 0xFFFFFFFFFFFFFFFF (masque tous bits).
  Pour afficher en non-signé, utilisez u. au lieu de .

VARIABLES ET MEMOIRE :
----------------------
  variable <nom>              — Declare une variable
  nop                         — Ne fait rien (no operation)
  true                        — Empile -1 (vrai en Forth)
  false                       — Empile 0 (faux en Forth)
  bl                          — Empile 32 (code ASCII espace)
  tab                         — Empile 9 (code ASCII tabulation)

  Note sur l'adressage :
    - L'« adresse » d'une variable est un index dans memory[] (Vec<i64>)
    - Les variables sont stockees dans BTreeMap<String,usize>, la valeur
      etant self.variables.len() au moment de l'insertion
    - L'ordre alphabetique du BTreeMap n'affecte PAS l'index car il est
      fixe par or_insert() a l'insertion (position d'allocation)
    - Deux variables ne peuvent pas avoir le meme nom
    - Redéclarer une variable conserve l'index existant (or_insert)

  <nom>                       — Empile l'adresse de la variable
  @       ( addr -- val )     — Lit la valeur a l'adresse
  !       ( val addr -- )     — Ecrit la valeur a l'adresse
   +!      ( n addr -- )       — Ajoute n a la valeur

   cell+   ( addr -- addr+8 )  — Ajoute 8 octets (taille d'une cellule)
   cells   ( n -- n*8 )        — Multiplie par la taille d'une cellule
   aligned ( addr -- addr )    — Aligne a 8 octets
   char+   ( addr -- addr+1 )  — Ajoute 1 octet (taille d'un caractere)
    chars   ( n -- n )          — Multiplie par la taille d'un caractere

    erase   ( addr u -- )       — Met a zero u octets a partir de addr
    move    ( src dest u -- )    — Copie u octets (gestion chevauchement)

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

  BEGIN ... WHILE ... REPEAT (boucle conditionnelle) :
    begin
      <condition>              \ Teste la condition (flag)
    while
      <corps>                  \ Execute si condition VRAIE
    repeat                     \ Retourne a begin

  Exemple :
    : compte ( n -- )          \ Compte de 0 a n-1
      0
      begin
        dup 5 <                \ Condition: compteur < 5 ?
      while
        dup .                  \ Affiche le compteur
        1+                     \ Incremente
      repeat
      drop
    ;
    5 compte                   \ Affiche 0 1 2 3 4

  Exemple avec filtrage :
    : pairs ( n -- )           \ Affiche les nombres pairs
      0
      begin
        dup 5 <
      while
        dup 2 mod 0 = if dup . then
        1+
      repeat
      drop
    ;
    5 pairs                    \ Affiche 0 2 4

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

   i — Index de la boucle courante
     Utilise i pour recuperer l'index de la boucle DO la plus
     interne. Ne peut etre utilise qu'a l'interieur d'une boucle.
     i fonctionne meme dans les mots appeles depuis la boucle
     (loop_rstack n'est pas affecte par Call/Exit). Exemple :
       : affiche-i  i . ;
       5 0 do  affiche-i  loop    \ Affiche 0 1 2 3 4

    : table ( n -- )
      0 do
        i 1+ 2* .             \ Affiche 2 4 6 8 10
      loop
    ;
    5 table

  j — Index de la boucle externe
    Utilise j dans une boucle imbriquee pour acceder a l'index
    de la boucle englobante.

    : multi ( -- )
      3 0 do
        3 0 do
          j . i . cr          \ Paires (j,i)
        loop
      loop
    ;
    multi                     \ Affiche 0 0  0 1  0 2  1 0 ...

   ?DO — DO conditionnel :
     <limite> <debut> ?do
       <code>                \ Execute si debut != limite
     loop

     : test? ( n -- )        \ Boucle 0..n-1 sauf si n=0
       0 ?do i . loop cr
     ;
     5 test?                  \ Affiche 0 1 2 3 4
     0 test?                  \ N'affiche rien

   LEAVE — Sortie immediate de boucle :
     <limite> <debut> do
       <code>
       <condition> if leave then
       <code>
     loop

     : cherche ( n -- )       \ Cherche le premier multiple de 3
       0 do
         i 3 mod 0= if i . leave then
       loop
     ;
     10 cherche                \ Affiche 0
     10 5 do i 3 mod 0= if i . leave then loop  \ Affiche 6

RECURSION :
----------
    : factorielle ( n -- n! )
      dup 1 <= if
        drop 1
      else
        dup 1- recurse *
      then
    ;
    5 factorielle .           \ Affiche 120

    Note technique : recurse compile Op::Recurse, qui sera remplacé
    par Op::Call à la fin du mot. Si Op::Recurse survit (clone partiel,
    snapshot), le moteur d'exécution l'interprète comme un appel
    récursif au mot courant au lieu de planter.

MOTS AVANCES :
--------------
   create <nom>                — Cree un mot qui empile une adresse
   buffer: <nom>              — Crée un buffer nommé (taille en cellules sur la pile)
                                 Ex: 512 buffer: secteur
                                 secteur 512 erase   \ Efface le buffer
   struct <nom>               — Déclare le début d'une structure (empile offset=0)
   field <nom>                — Déclare un champ (crée un mot qui ajoute l'offset)
   end-struct                 — Termine la structure (laisse la taille sur la pile)
                                 Ex: struct point
                                       field .x
                                       field .y
                                     end-struct
                                     point buffer: mon-point
                                     42 mon-point .x !
                                      99 mon-point .y !
   enum <nom>                    — Crée une énumération (valeur+1 auto)
                                  Ex: 0 enum ROUGE
                                        enum VERT
                                        enum BLEU
                                      drop
                                      BLEU .   \ → 2
   does>                       — Definit le comportement d'un mot cree
  immediate                   — Rend le dernier mot defini immediat
  here                        — Adresse memoire courante
  allot   ( n -- )            — Reserve n cellules memoire
  ,       ( val -- )          — Stocke val a here et avance
  ," <texte>"                 — Stocke une chaine a here (longueur + octets)
                                Ex: create msg ," Bonjour"
                                msg 1+ type pour afficher la chaine
   words                       — Liste tous les mots definis
   word-info <mot>             — Affiche les infos d'un mot (type, ops, flags)
   critical-begin               — Début de section critique (désactive préemption)
   critical-end                 — Fin de section critique (réactive préemption)
                                  Utilisé par MUTEX.FTH pour la synchronisation
                                  entre tâches. S'imbrique. Timeout à 100k instr.

   noop                         — No operation
   true / false                 — Constantes -1 et 0
   bl / tab                     — Constantes 32 et 9
   max3 / min3 / clamp          — Algèbre à 3 arguments
   within / between             — Tests d'intervalle
   bounds / /string             — Manipulation de chaînes
   [] / c[] / matrix[]          — Indexation de tableaux
   0.r                          — Affichage avec zéros de remplissage
   hex.                         — Affiche en hexadécimal
   ? / ??                       — Inspection mémoire
   >number / number>            — Conversion chaîne ↔ nombre
   f>str                        — Conversion virgule fixe → chaîne
   time>str / date>str          — Formatage date/heure
   times / for / map            — Itération
   array:create / array:push / array:pop  — Tableaux dynamiques

   '       <mot>               — Empile l'index du mot (dictionary index).                                Dans Epona, l'index est aussi l'execution token (xt).                                Cela differe du Forth standard ou ' retourne une                                adresse memoire (xt). C'est coherent avec le modele                                interne : execute utilise le meme index.
   execute ( idx -- )          — Execute un mot par son index
   postpone <mot>              — Compile un mot immediat
  forget  ( idx -- )          — Oublie les mots a partir de l'index
                                  Nettoie aussi les variables, la string_pool
                                  et remet here a 0.
                                  (tronque le dictionnaire)
  marker <nom>                — Crée un point de restauration
                                  Ex: marker debut
                                  : test 42 . ;
                                  debut  \ supprime test
                                  (restaure dictionnaire/here/variables)

  Note sur string_pool :
    - Les noms de mots sont stockes dans string_pool (Vec<u8>), alloue
      sequentiellement sans GC.
    - Apres des centaines de redefinitions, des noms orphelins s'accumulent
      (fuite memoire faible, ~ quelques KB).
    - forget (voir ci-dessus) vide le pool.
    - En usage normal (quelques dizaines de mots), la fuite est negligeable.

  Note sur create/does> :
    - create <nom> en mode immédiat (hors definition) fonctionne.
    - create ... does> ... ; dans une definition compile le mot
      correctement.
    - create sans does> dans un mot defini (defining word) :
        : mkvar create , ;    \ mkvar est un mot créateur
        mkvar x               \ crée x qui pousse son adresse
        42 x !                \ stocke 42 dans x
      Les mots createurs avec does> fonctionnent aussi :
        : carre create dup * does> swap ! ;
        carre x   \ crée x = 9
      Le mot cree execute le code does> a chaque appel.


   see <mot>                    — Affiche la definition et le bytecode du mot.
                                  Equivalent a decompiler le mot.

   char <caractere>             — Empile le code ASCII du caractere.
                                  Exemple : char A .  — Affiche 65

   value <nom>                  — Declare une valeur (variable initialisee
                                  par la valeur au sommet de la pile).
                                  A la difference de variable, value retourne
                                  directement la valeur (pas l'adresse).
                                  Exemple :
                                    42 value reponse
                                    reponse .          \ Affiche 42
                                    100 to reponse     \ Change la valeur
                                    reponse .          \ Affiche 100

   to <nom>                     — Modifie la valeur d'une valeur declaree
                                  avec value. Prend la nouvelle valeur sur
                                  la pile.
                                  Exemple : 42 to reponse

   defer <nom>                  — Declare un mot differe (deferred word).
                                  S'utilise comme un mot normal, mais on
                                  peut changer sa definition avec is.
                                  Exemple :
                                    defer ma-fonction
                                    : dire-bonjour ." Bonjour !" ;
                                    ' dire-bonjour is ma-fonction
                                    ma-fonction      \ Affiche "Bonjour !"
                                    : dire-salut ." Salut !" ;
                                    ' dire-salut is ma-fonction
                                    ma-fonction      \ Affiche "Salut !"

   is <nom>                     — Assigne une nouvelle definition a un
                                  mot declare avec defer. Prend l'execution
                                  token (') sur la pile.
                                  Exemple : ' nouveau-mot is mon-defer

   [char]                       — Version compilee de char. Utilisable
                                   a l'interieur d'une definition :
                                   : affiche-A [char] A emit ;
   [defined] <mot>              — Teste si un mot existe (flag -1/0)
   [undefined] <mot>            — Teste si un mot n'existe pas (flag -1/0)
                                   S'utilise avec [if]/[else]/[then] :
                                    [defined] gpu:init [if]
                                      ." GPU disponible" cr
                                    [then]

   CASE ... OF ... ENDOF ... ENDCASE :
     Structure de selection multiple.
     Syntaxe :
       <valeur> case
         <val1> of ... endof
         <val2> of ... endof
         <valn> of ... endof
         (optionnel) ...         \ cas par defaut
       endcase

     Exemple :
       : jour-semaine ( n -- )
         case
           1 of ." Lundi" endof
           2 of ." Mardi" endof
           3 of ." Mercredi" endof
           4 of ." Jeudi" endof
           5 of ." Vendredi" endof
           ." Weekend"
         endcase
       ;
       3 jour-semaine           \ Affiche "Mercredi"

     Note : les valeurs sont testees une par une avec =. Le premier
     'of' dont la condition est vraie execute son bloc puis saute
     directement a endcase (endof compile un saut). Si aucun 'of'
     ne correspond, le code eventuel entre le dernier endof et
      endcase est execute (cas par defaut).


   [if] / [else] / [then] (compilation conditionnelle) :
      Permet de compiler du code differemment selon une condition.
      Utile pour adapter le code a la plateforme ou a la configuration.
      Fonctionne en mode interprete ET en mode compilation.

      Syntaxe :
        <flag> [if]
          ... code si flag vrai ...
        [else]
          ... code si flag faux ...
        [then]

      Exemple :
        1 [if]
          : saluer ." Bonjour !" ;
        [else]
          : saluer ." Hello !" ;
        [then]
        \ Si le flag est 1, seul le premier mot est compile.
        \ Si le flag est 0, seul le second mot est compile.

      Note : les branches [if]/[else]/[then] sont evaluees au moment
      de la compilation (tokeniseur). Aucun bytecode n'est genere
      pour les branches ignorees.


SÉQUENCES D'ÉCHAPPEMENT DANS ." ET s" :
-----------------------------------------
   Les chaînes dans ." et s" peuvent contenir des séquences
   d'échappement commençant par \ :

   \n      — Nouvelle ligne (retour à la ligne)
   \t      — Tabulation
   \\      — Antislash litteral
   \"      — Guillemet litteral

   Exemple :
     ." Ligne 1\nLigne 2\tTabulation" cr
     \ Affiche :
     \ Ligne 1
     \ Ligne 2    Tabulation

     s" Chemin : C:\\Users\\Nom"   \ stocke sans couper la chaîne


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

  alloc ( size -- addr|-1 )   — Alloue size octets dans la mémoire Forth
                                Retourne l'adresse de début, ou -1 si
                                la mémoire Forth est pleine (MAX_MEM=4096).

  Exemple :
    mem-map                   \ Empile total et free
    swap                      \ Met total au sommet
    4 * 1024 / .              \ Affiche total en MB
    4 * 1024 / .              \ Affiche libre en MB

    256 alloc                 \ Alloue 256 octets dans la mémoire Forth
    dup 0< if
      ." Erreur alloc" cr
    then

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
  fb:blit ( src_x src_y w h dst_x dst_y -- )
                             — Copie un bloc w —h du framebuffer
                               vers (dst_x,dst_y) (gère l'overlap)

WIDGETS (systeme d'UI fenetre) :
--------------------------------
   button:   ( x y w h ) "Label" [mot]  — Cree un bouton (interprete seulement)
   button-push ( x y w h ) "Label" [mot] — Cree un bouton (compile ou interprete)
   textfield: ( x y w h -- )             — Cree un champ texte
   list:      ( x y w h -- )             — Cree une liste
   list-add   ( addr len -- )            — Ajoute un element a la derniere liste
   widgets-clear ( -- )                  — Vide tous les widgets
   widgets-draw ( wx wy ww wh -- )       — Dessine tous les widgets

   Le mot optionnel [mot] est execute au clic sur le bouton.
   Les positions sont relatives a la zone de contenu de la fenetre.
   Les clics sont propages automatiquement par windows_handle_click
   dans main.rs, qui appelle widgets_handle_mouse(mx, my, btn, wx, wy)
   sur le ForthVm. Le callback du bouton est execute de façon synchrone.
   Les etats de survol (state=1) sont mis a jour automatiquement.
   Ces mots sont destines aux fenetres creees avec app:.

ENTREES :
---------
  touche  ( -- char )         — Attend une touche (bloquant)
  touche? ( -- char|0 )       — Lit une touche (non-bloquant)
  souris  ( -- x y btn )      — Position et bouton souris
  souris? ( -- flag )         — 1 si souris detectee
   attendre ( ms -- )          — Pause en millisecondes (basee sur RDTSC, pas de calibration CPU necessaire)
   ms      ( ms -- )           — Alias de attendre

XHCI (SOURIS USB 3.0) :
-----------------------
   xhci-init    ( -- ok? )     — Initialise le controleur XHCI et scanne les ports
   xhci-souris  ( -- dx dy btn ) — Lit le delta souris et les boutons
   xhci-souris? ( -- flag )    — 1 si une souris USB HID est detectee

HDA (AUDIO HD) :
-----------------
   hda-init    ( -- ok? )     — Initialise le contrôleur HDA et détecte le codec audio
   hda-play    ( addr len rate -- ok? )
                               — Joue un buffer PCM 16-bit stéréo (44100 ou 48000 Hz)
                                 addr = adresse mémoire Forth, len = taille en octets
   hda-stop    ( -- )          — Arrête la lecture en cours
   hda-volume  ( vol -- )      — Règle le volume (0..100)
   hda-info    ( -- )          — Affiche les infos du codec audio (vendor, NIDs, volume...)
   hda-beep    ( freq ms -- )  — Génère un bip à la fréquence freq (Hz) pendant ms ms
   hda-status  ( -- playing? ) — 1 si un son est en cours de lecture

   Note : xhci-init est appele automatiquement au demarrage.
   Le polling XHCI est permanent dans la boucle principale.
   Les mots xhci-souris/souris? lisent les dernieres donnees en memoire.

I2C HID (TOUCHPAD NATIF — DesignWare I2C) :
--------------------------------------------
   Le driver I2C HID detecte automatiquement les touchpads
   connectes sur le bus I2C (controleur DesignWare).

   Detection automatique au demarrage (via PCI ou ACPI).
   IDs ACPI recherches : AMDI0010, AMD0010, AMDI0019, AMDI0510,
                         ELAN071A, ELAN0000, SYNA0000, MSFT0001,
                         PNP0C50, APP0006, APP000D, APP000E
   Supporte les formats multitouch suivants :
     - Microsoft Precision Touchpad (PTP) — aussi Apple Magic Trackpad
     - Synaptics
     - ELAN
     - Fallback simple 6-octets

   Gestes reconnus (integration dans PointerManager) :
     - Tap 1 doigt        → clic gauche
     - Tap 2 doigts       → clic droit
     - Tap 3 doigts       → clic milieu
     - Glisser 1 doigt    → Drag (maintien + deplacement)
     - Scroll 2/3 doigts  → defilement horizontal/vertical
     - Pinch 2 doigts     → zoom (pincement/ecartement)
     - Swipe              → balayage rapide (lift apres mouvement)

   Primitives bas niveau I2C (interpretees depuis Forth) :
     i2c.probe ( base -- )           — Scrute toutes les adresses HID
                                       sur un controleur I2C
     dw-i2c-init  ( base -- ok? )    — Initialise controleur I2C
     dw-i2c-probe ( base addr -- ok? ) — Teste peripherique I2C
     i2c-read     ( base dev reg -- val|-1 ) — Lit registre I2C

   Nouvelles primitives I2C HID (274-279) :
     i2c:status    ( -- found initialized )
                             — 1 si touchpad trouve et initialise
     i2c:read      ( -- x y left right )
                             — Lit l'etat courant du touchpad
                               (x,y en coordonnees 12-bit 0..4095)
     i2c:gesture   ( -- type dx dy )
                             — Lit le geste en cours
                               0=none 1=tap 2=drag 3=scroll
                               4=pinch 5=swipe 6=rightclick 7=middleclick
     i2c:cal-set   ( margin_x margin_y dead_zone smoothing -- )
                             — Regle la calibration dynamiquement
     i2c:cal-get   ( -- margin_x margin_y dead_zone smoothing )
                             — Lit la calibration courante
     i2c:contacts  ( -- n ) — Nombre de contacts actifs

   Calibration (dynamic via i2c:cal-set / i2c:cal-get) :
     - Marges (margin_x, margin_y) : 0..2000, defaut 20px
     - Dead zone (dead_zone) : 0..20, defaut 3px
       Supprime les micro-mouvements en dessous du seuil
     - Smoothing (smoothing) : 0..8, defaut 2
       Filtre exponentiel (0=aucun, 8=tres lisse)

USB GENERIQUE (primitives usb:*) :
-----------------------------------
   usb:init      ( -- ok? )  — (Re)initialise le controleur XHCI et re-enumere tous les ports
   usb:devices   ( -- n slot1 port1 speed1 vid1 pid1 conf1 ... )
                             — Retourne le nombre de peripheriques puis 6 valeurs par device
                               (au fond de la pile : n)
   usb:control   ( slot_id bmReqType bReq wVal wIdx buf_addr buf_len -- actual )
                             — Control transfer generique EP0
                               Si bmReqType & 0x80 = IN, lit depuis buf_addr
                               Sinon OUT avec les donnees a buf_addr
   usb:read      ( slot_id buf_addr buf_len -- actual )
                             — Lecture via interrupt IN (si peripherique configure)
                               Fallback control IN (bmReqType=0x80, bReq=0)
   usb:write     ( slot_id buf_addr buf_len -- actual )
                             — Control OUT (bmReqType=0x00, bReq=0)

    Les buffers Forth sont copies vers/depuis des pages physiques temporaires.
    usb:read utilise xhci_interrupt_in (legacy, souris HID detectee auto).
    Pour lire depuis n'importe quel endpoint Interrupt/Bulk configure,
    utiliser usb:bulk-read avec l'ep_addr souhaite.

    usb:bulk-read   ( slot_id ep_addr buf_addr buf_len -- actual )
                              — Lecture bulk IN depuis l'endpoint specifie
                                (buf_addr = memoire Forth, buf_len = max octets a lire)
    usb:bulk-write  ( slot_id ep_addr buf_addr buf_len -- actual )
                              — Ecriture bulk OUT vers l'endpoint specifie
                                (buf_addr = memoire Forth contenant les donnees)

     Les endpoints bulk sont configures automatiquement lors de l'init USB
     pour les peripheriques de stockage MSD (cf. section USB MSD ci-dessous).

    usb:config-ep  ( slot_id ep_addr attr mps interval -- ok? )
                              — Configure dynamiquement un endpoint sur un
                                peripherique deja enumere
                                ep_addr   = bEndpointAddress (bit7=dir, bits3:0=num)
                                attr      = bmAttributes (0=control, 1=isoch,
                                            2=bulk, 3=interrupt)
                                mps       = wMaxPacketSize
                                interval  = bInterval
                                L'appel cree le transfer ring, remplit le
                                contexte XHCI et envoie Configure Endpoint.
    usb:stop-ep   ( slot_id ep_addr -- ok? )
                              — Stoppe un endpoint (avant reconfiguration)
    usb:reset-ep  ( slot_id ep_addr -- ok? )
                              — Reset un endpoint

    Exemple — configurer un endpoint Interrupt IN sur EP1 d'un HID :
      1 0x81 0x03 8 10 usb:config-ep .
      \ slot=1, ep_addr=0x81 (EP1 IN), attr=0x03 (Interrupt),
      \ mps=8, interval=10ms -> ok?
    Exemple — lire depuis l'endpoint Interrupt IN configure :
      1 0x81 100 8 usb:bulk-read .
      \ slot=1, ep_addr=0x81, buf=100, len=8 -> actual

   Exemple — lister les peripheriques USB :
     usb:devices
     dup . ." peripheriques USB" cr
     0 ?do
       drop drop drop drop drop drop
     loop

   Exemple — lire le descripteur de peripherique (device descriptor, 18 octets) :
     \ slot_id=1, GET_DESCRIPTOR(device)=1, wVal=0x0100, wIdx=0
     \ buf_addr=100 (memoire Forth), buf_len=18
     1 0x80 6 0x0100 0 100 18 usb:control .
      \ Lit les 18 premiers octets du buffer memoire Forth

USB MASS STORAGE (primitives usb:msd-*) :
------------------------------------------
   Primitives pour utiliser des cles USB et disques externes via le
   protocole BOT (Bulk-Only Transport) + commandes SCSI.

   usb:msd-probe  ( -- n )   — Detecte et initialise tous les peripheriques MSD
                                Retourne le nombre de disques MSD trouves
   usb:msd-info   ( idx -- slot_id bulk_in_ep bulk_out_ep lba_size total_lbas )
                              — Infos d'un peripherique MSD par index (0-based)
   usb:msd-read   ( idx lba count buf_addr -- ok? )
                              — Lit 'count' blocs depuis le disque MSD 'idx'
                                au LBA 'lba' dans la memoire Forth a 'buf_addr'
   usb:msd-write  ( idx lba count buf_addr -- ok? )
                              — Ecrit 'count' blocs depuis la memoire Forth
                                vers le disque MSD 'idx' au LBA 'lba'

   Les blocs font 'lba_size' octets (typiquement 512).
   Les peripheriques MSD sont automatiquement detectes pendant usb:init
   si un pilote est enregistre via sys:register.
   Utiliser usb:msd-probe apres usb:init pour scanner et initialiser le BOT.

   Exemple — lister et lire un bloc :
     usb:init .
     usb:msd-probe .
     \ Affiche les infos du premier disque
     0 usb:msd-info
     ." Slot: " . ." BulkIn: " . ." BulkOut: " .
     ." LBA size: " . ." Total LBAs: " . cr
     \ Lit le premier bloc (512 octets) a l'adresse memoire 1000
     0 0 1 1000 usb:msd-read .
     \ Affiche les 16 premiers octets en hexa
     16 0 do 1000 i + c@ . loop cr

RÉSEAU (primitives net:) :
---------------------------
  Cartes supportées (détection automatique au net:init) :
    - Intel e1000/e1000e    — 82540EM, 82574L, I217, I218, I219
    - Realtek RTL8168/8111  — RTL8168, RTL8111, RTL8169, RTL8101E
    - Realtek RTL8821CE     — Wi-Fi PCIe (firmware requis via net:firmware)

  Primitives de base :
    net:init    ( -- ok? )     — Initialise la première carte réseau trouvée
    net:firmware ( addr len -- ok? )
                                — Upload le firmware RTL8821CE depuis la mémoire Forth
                                  (firmware rtw8821c_fw.bin depuis
                                   github.com/endlessm/linux-firmware)
    net:send    ( buf_addr len -- ok? )
                                — Envoie un paquet Ethernet brut
    net:recv    ( buf_addr maxlen -- actual )
                                — Reçoit un paquet Ethernet
    net:mac     ( -- mac_hi mac_lo )
                                — Adresse MAC (48 bits sur 2 mots)
    net:status  ( -- link_up? ) — 1 si le lien est actif
    net:info    ( -- )          — Affiche les infos de la carte active
    net:cards   ( -- n )        — Nombre de cartes réseau détectées

  Pile réseau (ARP/IP/ICMP/UDP/TCP/DHCP/DNS) :
    net:ip!     ( a b c d -- )  — Configure l'IP locale
    net:ip@     ( -- a b c d )  — Lit l'IP locale
    net:mask!   ( a b c d -- )  — Configure le masque de sous-réseau
    net:gw!     ( a b c d -- )  — Configure la passerelle
    net:dns!    ( a b c d -- )  — Configure le serveur DNS
    net:ping    ( a b c d -- ms|-1 )
                                — Ping une IP, retourne le temps en ms (-1 = timeout)
    net:arp     ( a b c d -- ok? )
                                — Résout une adresse MAC (ARP)
    net:dhcp    ( -- ok? )      — Obtient une IP automatiquement
    net:dns     ( name_addr name_len -- a b c d )
                                — Résout un nom DNS (ex: "google.com")
    net:poll    ( -- )          — Traite les paquets réseau entrants

  UDP :
    net:udp-send ( dst_a dst_b dst_c dst_d dst_port src_port buf_addr len -- ok? )
                                — Envoie un paquet UDP
    net:udp-recv ( buf_addr maxlen -- actual_len src_ip_packed src_port )
                                — Reçoit un paquet UDP

  TCP :
    net:tcp-connect ( a b c d port -- sock|-1 )
                                — Ouvre une connexion TCP
    net:tcp-send ( sock buf_addr len -- ok? )
                                — Envoie des données TCP
    net:tcp-recv ( sock buf_addr maxlen -- actual )
                                — Reçoit des données TCP
    net:tcp-close ( sock -- )   — Ferme la connexion TCP

  HTTP client (via TCP) :
    net:http-get ( host_addr host_len path_addr path_len -- data_addr data_len status )
                                — Effectue une requête HTTP GET.
                                  host = chaîne en mémoire Forth (ex: "example.com")
                                  path = chaîne en mémoire Forth (ex: "/index.html")
                                  Retourne : addr = offset dans la mémoire Forth où se trouve
                                  le corps de la réponse, len = taille, status = code HTTP
                                  (200, 404, etc.) ou -1 si erreur.
                                  Port 80 implicite. IPv4 uniquement.
                                  La réponse est stockée dans la mémoire Forth étendue.

  Utilitaires :
    net:stack-info ( -- )       — Affiche la config IP/ARP/TCP
    net:cards      ( -- n )     — Nombre de cartes (alias)

  Fonctionnalités réseau avancées (non implémentées — prévues) :
    - TLS/SSL (chiffrement) : nécessite des primitives cryptographiques
      (AES, RSA, SHA-256). Non disponible sans bibliothèque externe.
    - WebSocket : upgrade HTTP + trames. Peut être implémenté sur TCP existant.
    - DHCPv6 : nécessite une pile IPv6 complète.
    - IPv6 RA / NDP / SLAAC : pile IPv6 complète à implémenter.

  Exemple — configuration manuelle :
    net:init 0= if ." Pas de carte" cr then
    net:info
    192 168 1 100 net:ip!
    255 255 255 0 net:mask!
    192 168 1 1 net:gw!
    8 8 8 8 net:dns!

  Exemple — DHCP :
    net:dhcp if ." IP obtenue" cr net:stack-info then

   Exemple — ping :
    net:init drop
    8 8 8 8 net:ping dup 0 < if ." timeout" else . ." ms" then cr

   Exemple — HTTP GET :
    net:init drop
    net:dhcp drop
    \ Créer la chaîne hôte en mémoire Forth
    create host ," example.com"
    create path ," /"
    \ Requête HTTP
    host 11 path 1 net:http-get ( -- data_addr data_len status )
    cr ." Status: " . cr
    ." Réponse (" . ." octets) :" cr
    \ Afficher les 200 premiers octets
    ( addr len ) over + swap do i @ emit loop cr

GPU (ACCELERATION 2D — Intel/AMD) :
-----------------------------------
   Primitives de base :
     gpu:init       ( -- ok? )     — Initialise le GPU detecte (Intel i915 ou AMD Radeon)
     gpu:info       ( -- )          — Affiche les infos du GPU (modele, MMIO, blitter/sDMA)
     gpu:accel?     ( -- flag )     — 1 si l'acceleration materielle 2D est active
     gpu:resolution ( -- w h )      — Resolution courante de l'ecran

   Double buffering :
     gpu:fb-addr    ( -- addr )     — Adresse du back buffer (la ou on dessine)
     gpu:fb-stride  ( -- stride )   — Stride en octets (largeur * 4 pour 32bpp)
     gpu:flip       ( -- )          — Echange front/back buffer (affiche le back buffer)
     gpu:vsync      ( -- )          — Attend le retour vertical (VBlank)

   Remplissage, lignes et copie accelerés :
     gpu:fill       ( x y w h color -- )
                                    — Remplit un rectangle avec une couleur (32-bit 0xRRGGBB)
                                      Utilise le blitter (Intel) ou sDMA (AMD) si disponible
     gpu:blit       ( sx sy w h dx dy -- )
                                    — Copie un rectangle (sx,sy) -> (dx,dy)
                                      Gère le chevauchement (copie directionnelle)
     gpu:line       ( x1 y1 x2 y2 color -- )
                                    — Trace une ligne diagonale (Bresenham).
                                      Suit les diagonales parfaites sans escalier visible.
                                      Couleur 32-bit 0xRRGGBB.

   Alpha blending (software) :
     gpu:blend      ( x y w h color alpha -- )
                                    — Rectangle alpha-blende. alpha=0..255
                                      Effectue un vrai blend (A*color + (255-A)*dest) pixel par pixel.
                                      Permet des fenêtres translucides, surbrillance, ombres.

   Texte acceleré :
     gpu:text       ( x y addr len color scale -- )
                                    — Dessine une chaîne depuis la mémoire Forth.
                                      La chaîne est lue depuis addr..addr+len (ASCII/UTF-8).
                                      scale=1 (8 —8) ou 2 (16 —16). Couleur 0xRRGGBB.

   Curseurs :
     gpu:cursor     ( x y -- )      — Positionne le curseur materiel (Intel/AMD).
                                      Surface 64 —64 ARGB fixe. Hotspot (0,0).
                                      Utilise le planificateur de curseur hardware.

     gpu:cursor-set ( addr w h hot_x hot_y -- )
                                    — Définit un curseur logiciel ARGB avec hotspot.
                                      addr = pointeur vers pixels 32-bit (0xAARRGGBB) en mémoire Forth.
                                      w,h = dimensions. hot_x,hot_y = point chaud relatif.
                                      Les pixels alpha=0 sont transparents, alpha=255 opaques.
                                      Alpha intermédiaire = blend. Appelé apres gpu:cursor.
                                      Revenir au curseur par défaut : addr=0.

   Modesetting natif (Intel Gen 9+ / AMD DCE) :
     gpu:modeset    ( w h -- ok? )  — Change la resolution. Utilise le modesetting natif
                                      (DPLL, CRTC, timings) si le GPU le supporte.
                                      Résolutions standard: 640x480, 800x600, 1024x768,
                                      1280x720, 1280x1024, 1366x768, 1440x900, 1600x900,
                                      1680x1050, 1920x1080.
                                      Les timings CEA/VESA sont pre-calcules.

   Gestion multi-écran :
     gpu:outputs        ( -- n )       — Nombre de sorties detectees
     gpu:select-output  ( idx -- ok? ) — Selectionne la sortie active
     gpu:output-info    ( idx -- w h enabled? )
                                        — Infos d'une sortie (largeur, hauteur, active?)
     gpu:output-enable  ( idx w h -- ok? )
                                        — Active une sortie avec une resolution
     gpu:output-disable ( idx -- )      — Desactive une sortie
     gpu:output-flip    ( idx -- )      — Flip sur une sortie specifique
     gpu:output-fb      ( idx -- addr stride )
                                        — Adresse du framebuffer d'une sortie
     gpu:output-edid    ( idx -- valid? )
                                        — Lit l'EDID d'une sortie (1 si detecte)

    Le driver detecte automatiquement les ecrans connectes (jusqu'a 4 sorties)
    au moment de gpu:init. Chaque sortie a son propre framebuffer et peut avoir
    une resolution differente.
    Les EDID sont lus via GMBUS (Intel) ou I2C engine (AMD).

    Limitations :
      - Hotplug non implante : la detection est figee apres gpu:init
      - gpu:output-edid retourne seulement un booleen (EDID detecte ou non) ;
        les infos detaillees (timings, nom moniteur, fabricant) ne sont pas
        exposees depuis le Forth

   Fallback software :
     Si le GPU n'est pas reconnu ou si le blitter ne demarre pas,
     les operations gpu:fill, gpu:blit et gpu:flip utilisent
     un fallback software qui opere directement sur le framebuffer.
     Les operations gpu:line, gpu:blend, gpu:text et le curseur logiciel
     (gpu:cursor-set) sont toujours en software.

   Exemple — animation simple :
     : carre-promeneur
        gpu:init drop
        0 0 100 100 0
        begin
            gpu:resolution gpu:fill      \ fond noir
            2dup 50 50 0xFF4444 gpu:fill \ carre rouge
            gpu:vsync gpu:flip
            10 ms
            \ deplacement
            swap
            3 + over gpu:resolution drop < if drop 0 then
            swap
            2 + over gpu:resolution nip < if drop 0 then
            touche? 27 =
        until
        2drop
     ;

    Exemple — multi-ecran :
      gpu:init drop
      gpu:outputs . ." sorties" cr
      \ Activer la sortie 1 en 1280x720
      1 1280 720 gpu:output-enable .
      \ Afficher les infos de la sortie 0
      0 gpu:output-info ." x" . ." active=" . cr
      \ Lire l'EDID de la sortie 0
      0 gpu:output-edid if ." EDID detecte" else ." Pas d'EDID" then cr

    Exemple — trait de diagonale :
      gpu:init drop
      \ Ligne diagonale du coin (10,10) à (300,200)
      10 10 300 200 0x00FF00 gpu:line
      gpu:vsync gpu:flip

    Exemple — fenêtre translucide (blend) :
      gpu:init drop
      \ Fond noir
      gpu:resolution 0x000000 gpu:fill
      \ Rectangle rouge semi-transparent
      50 50 200 150 0xFF0000 128 gpu:blend
      gpu:vsync gpu:flip

    Exemple — texte depuis Forth :
      gpu:init drop
      \ Stocker une chaîne en mémoire Forth (create)
      create hello ," Hello Epona !"
      \ Dessiner le texte à (40,40) en blanc taille 2
      40 40 hello 12 0xFFFFFF 2 gpu:text
      gpu:vsync gpu:flip

    Exemple — curseur ARGB personnalisé :
      \ Créer un curseur rouge 16x16 en mémoire Forth
      create cur-rouge
      0xFF0000 , 0xFF0000 , 0xFF0000 , 0xFF0000 ,   \ ligne 0
      0xFF0000 , 0x000000 , 0x000000 , 0xFF0000 ,   \ ligne 1
      0xFF0000 , 0x000000 , 0x000000 , 0xFF0000 ,   \ ligne 2
      0xFF0000 , 0xFF0000 , 0xFF0000 , 0xFF0000 ,   \ ligne 3
      \ Appliquer (adresse, 4, 4, hotspot_x=1, hotspot_y=1)
      cur-rouge 4 4 1 1 gpu:cursor-set
      \ Positionner
      100 100 gpu:cursor

HORLOGE :
----------
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

ACPI (TABLES + POWER MANAGEMENT) :
-----------------------------------
  Primitives table :
    acpi-rsdp   ( -- addr )     — Adresse de la table RSDP
    acpi-find   ( sig -- addr ) — Cherche une table ACPI par signature
    acpi-hdr    ( addr -- sig len ) — Lit l'en-tete d'une table
    acpi-tables ( -- n addr... ) — Liste toutes les tables

  Power management (via UEFI Runtime Services) :
    reboot      ( -- )          — Redemarrage a chaud (WARM reset)
    poweroff    ( -- )          — Arret complet (S5)

  Non implémente :
    - Sleep S3 (suspend to RAM)   → Nécessite manipulation DSDT/EC
    - Battery (laptop)             → Nécessite EC/SMBus ACPI
    - Wake events                  → Nécessite GPE/SCI
    - CPU throttling/P-states      → Nécessite _PSS/_PPC dans DSDT

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
  beep       ( freq ms -- )    — Bip PC Speaker (freq en Hz, duree en ms)
  task       ( idx -- tid )    — Crée une tâche Forth depuis un mot (')
  stop       ( -- )            — Termine la tâche courante
  tasks      ( -- )            — Liste les tâches Forth

MULTITÂCHE PRÉEMPTIF :
---------------------
  Le PIT (canal 0, ~100 Hz) émet un IRQ toutes les 10 ms.
  dispatch_interrupt pose PREEMPT_REQUESTED, et execute_ops_limited
  vérifie ce flag entre chaque instruction Forth pour céder la main.
  Le scheduler round-robin alterne entre toutes les tâches Forth.

  Exemple :
    : travail
      begin ." ." 100 ms again ;
    ' travail task   \ crée la tâche, retourne son TID
    tasks            \ affiche la liste

HEAP (MEMOIRE RUST) :
---------------------
  heap-used ( -- u )          — Nombre d'octets alloues sur le heap
                                (allocateur a free-list, libere reellement)

DISQUE DUR (AHCI / SATA / NVMe) :
--------------------------------
   Epona OS supporte deux types de contrôleurs de stockage :
     - AHCI  (SATA) — Contrôleur SATA classique (desktop/laptop)
     - NVMe         — SSD modernes sur bus PCI Express

   Primitives NVMe (accès bloc direct) :
   -------------------------------------
     nvme:init      ( -- ok? )     — Initialise le contrôleur NVMe et détecte les namespaces
     nvme:read      ( idx lba count buf_addr -- actual_bytes )
                                    — Lit count blocs depuis le namespace idx (0-based)
                                      à partir du LBA lba dans la mémoire Forth à buf_addr
     nvme:write     ( idx lba count buf_addr -- actual_bytes )
                                    — Écrit count blocs depuis la mémoire Forth à buf_addr
                                      vers le namespace idx au LBA lba

   Primitives NVMe additionnelles (Rust → Forth) :
   -----------------------------------------------
     nvme_lba_size      ( -- size )     — Taille d'un LBA en octets (généralement 512)
     nvme_total_lbas    ( -- total )    — Nombre total de LBAs du premier namespace
     nvme_capacity      ( -- lo hi )    — Capacité totale en octets (2 valeurs pour 64-bit)
     nvme_info_string   ( -- )          — Affiche les infos du disque NVMe (modèle, série, firmware)

    Primitives AHCI (SATA) :
    ------------------------
      ahci:init      ( -- ok? )     — Initialise le contrôleur AHCI et détecte les ports
      ahci:drives    ( -- n )       — Nombre de disques SATA détectés
      ahci:read      ( idx lba count buf_addr -- ok? )
                                     — Lit count blocs (512 octets) depuis le disque idx
                                       à partir du LBA lba dans la mémoire Forth à buf_addr
      ahci:write     ( idx lba count buf_addr -- ok? )
                                     — Écrit count blocs depuis la mémoire Forth à buf_addr
                                       vers le disque idx au LBA lba
      ahci:info      ( -- )         — Affiche les infos de tous les disques AHCI (modèle,
                                       firmware, série, capacité, taille de bloc)

    Utilise le même mécanisme d'allocation de pages physiques que NVMe.
    idx = index de disque AHCI (0 = premier disque SATA détecté).

    Les primitives NVMe allouent/free des pages physiques pour le transfert DMA.
    LBA = Logical Block Address (adresse de secteur, généralement 512 ou 4096 octets).
    idx = index du namespace NVMe (0 = premier disque NVMe).

   Il détecte automatiquement le contrôleur présent, initialise le
   pilote correspondant et monte les partitions. Ne fonctionne que
   sur du matériel réel (pas d'émulation).

   Formats supportés (détection automatique) :
     - FAT32      — Système de fichiers Windows/clé USB
     - NTFS       — Système de fichiers Windows (lecture seule)
     - ext2/3/4   — Système de fichiers Linux (lecture seule)

   disk:init         ( -- bool )     — Initialise le stockage + monte le disque
   disk:ls <chemin>  ( -- )          — Liste le répertoire (ex: disk:ls /)
   disk:read <fich>  ( addr -- n )   — Lit fichier dans la mémoire Forth
   disk:write <fich> ( addr len -- ) — Écrit la mémoire Forth vers le disque
                                         (FAT32 uniquement ; NTFS/ext2 en lecture seule)
   unbreak <mot> ( -- )         — Supprime un breakpoint
   watch         ( -- )         — Liste les variables surveillées
   watch <var>   ( -- )         — Ajoute <var> aux variables surveillées
   unwatch <var> ( -- )         — Retire <var> de la surveillance

   Touches en mode step :
     s ou Entrée  — Pas-à-pas (exécute l'instruction et s'arrête)
     c            — Continue jusqu'au prochain breakpoint
     t            — Active/désactive le mode trace
     q            — Quitte le débogueur
     p            — Affiche les 10 premières valeurs de la pile
     h            — Aide (affiche les touches disponibles)

 Notes :
     - Les chemins utilisent / (barre oblique) comme séparateur
     - disk:read place le fichier dans la mémoire Forth (VM) à partir
       de l'adresse donnée. Le nombre d'octets lus est laissé sur la pile.
     - Fonctionne avec MBR et GPT — détection automatique
     - Le système de fichiers est détecté automatiquement au moment
       de disk:init (teste FAT32 → NTFS → ext2 dans l'ordre)
     - disk:init essaie d'abord AHCI (SATA), puis NVMe si AHCI est absent

CONTROLE SYSTEME :
------------------
  reboot   ( -- )             — Redemarrage a chaud
  poweroff ( -- )             — Arret complet


===============================================================================
6. SYSTEME DE FICHIERS (CLE USB + DISQUES DURS)
===============================================================================

Epona OS peut lire et ecrire sur la cle USB au format FAT32.

Il supporte aussi les disques durs internes (SATA/AHCI, NVMe) :
  - FAT32      — Lecture/ecriture
  - NTFS       — Lecture seule (disques Windows)
  - ext2/3/4   — Lecture seule (disques Linux)

COMMANDES DISQUE DUR (disk:*) :
--------------------------------
  disk:init             — Init stockage + detecte FS auto
  disk:ls <chemin>      — Liste un repertoire
  disk:read <fichier>   — Lit fichier en memoire Forth
    ( addr -- len )
  disk:write <fichier>  — Ecrit la memoire vers disque
    ( addr len -- )       (FAT32 seulement)

  Exemple :
    disk:init .
    disk:ls /
    disk:ls /home

MOTS FORTH POUR LES FICHIERS :
-------------------------------
   include <fichier>           — Charge et compile un fichier Forth
   require <fichier>           — Comme include mais ne charge qu'une fois
                                 (ignore le fichier si deja charge)
   sys:load <fichier>          — Charge et compile un fichier Forth (identique a include)
   sys:read <fichier>          — Lit un fichier en memoire
                                 ( addr -- len )
   sys:write <fichier>         — Ecrit la memoire dans un fichier
                                 ( addr len -- )

PRIMITIVES FAT32 BAS NIVEAU (fat:*) :
--------------------------------------
  Primitives pour manipuler directement la table FAT, les clusters
  et les entrées de répertoire (FAT32 uniquement). Ne fonctionne
  qu'après un disk:init réussi sur une partition FAT32.

  fat:info          ( -- bps spc fat_lba data_lba root_clus fat_sz num_fats )
                    — Infos bas niveau du système FAT32 monté
                      bps = bytes per sector, spc = sectors per cluster
                      fat_lba = LBA de la FAT table
                      data_lba = LBA de la zone de données
                      root_clus = cluster du répertoire racine
                      fat_sz = taille de la FAT en secteurs
                      num_fats = nombre de copies de la FAT (généralement 2)
  fat:root-clus     ( -- cluster )
                    — Cluster du répertoire racine
  fat:cluster-lba   ( cluster -- lba )
                    — Convertit un numéro de cluster en LBA absolu
  fat:read-entry    ( cluster -- value )
                    — Lit l'entrée FAT du cluster (valeur 0..0x0FFFFFFF)
                      0x0FFFFFF8+ = fin de chaîne (EOC)
  fat:write-entry   ( cluster value -- ok? )
                    — Écrit une entrée dans la FAT (dangereux !)
  fat:eoc?          ( value -- flag )
                    — 1 si la valeur correspond à une fin de chaîne (EOC)
  fat:read-cluster  ( cluster buf_addr -- ok? )
                    — Lit un cluster complet dans la mémoire Forth à buf_addr
  fat:write-cluster ( cluster buf_addr -- ok? )
                    — Écrit la mémoire Forth vers un cluster (dangereux !)
  fat:alloc-cluster ( -- cluster|0 )
                    — Alloue un nouveau cluster libre dans la FAT
  fat:alloc-chain   ( count -- first_cluster|0 )
                    — Alloue une chaîne de count clusters consécutifs libres
  fat:free-chain    ( cluster -- )
                    — Libère une chaîne de clusters (marque tous libres)
  fat:dir-entries   ( cluster buf_addr -- n [name_addr name_len size is_dir ...] )
                    — Liste le contenu d'un répertoire par cluster racine
                      Les noms sont stockés dans la mémoire Forth à buf_addr,
                      chaque entrée retourne (name_addr, name_len, size, is_dir)
                      sur la pile. n = nombre d'entrées.

  Attention : fat:write-entry, fat:write-cluster, fat:alloc-cluster,
  fat:alloc-chain, fat:free-chain sont des opérations dangereuses qui
  peuvent corrompre le système de fichiers. Utiliser avec précaution.

  Exemple — parcourir la FAT table :
    disk:init .
    fat:info drop drop drop drop drop drop ." FAT size: " . ." sectors" cr
    fat:read-entry . cr

  Exemple — lire le premier cluster du répertoire racine :
    fat:root-clus 2000 fat:read-cluster .
    \ Lit 16 cellules mémoire à partir de 2000
    16 0 do 2000 i + @ . loop cr

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
  bump_alloc.rs   — Allocateur memoire (free-list 32 MB, coalescing)

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
    - Mode securise (shell: secure on/off) : bloque les acces materiel
      (MMIO, PCI, PORT, alloc-phys, reboot, poweroff, etc.) et restreint
      la memoire accessible par @ ! +! a [0..256[
    - Primitives bloquees en mode securise :
      ports I/O (in/out), MMIO (mmio@ mmio!), PCI (pci@ pci!),
      MSR (msr@ msr!), CPUID, RAM physique (phys@ phys!),
      reboot, poweroff, alloc-phys, free-phys,
      memcpy raw (move), memset raw (erase), beep (ports PC speaker)
    - Sandbox memoire : mem-bounds ( low high -- ) pour limiter la plage
      d'adresses accessibles par @ ! +!. Quand secure on est active,
      les bornes sont automatiquement restreintes a [0..256[.
    - Sandbox fichiers : file-allow ajoute un prefixe de chemin autorise
      pour disk:ls/read/write et sys:load/read/write. Quand secure on est
      active, seuls les chemins sous /SAFE/ sont autorises.
      file-revoke-all vide la whitelist (refuse tout acces).
    - Sandbox reseau : toutes les primitives net:* sont bloquees quand
      net_enabled est faux. secure on appelle automatiquement net-revoke.
      net-allow/reactif net-revoke controlent l'acces au reseau.
     - Sandbox fichiers : non implementee (toute tache peut lire/ecrire)
     - Sandbox reseau   : non implementee
      - Limite de instructions configurable (10M par défaut, 0 = illimité)
        Voir max_instructions dans ForthVm.
     - Stack overflow detecte (4096 elements max)
     - F9 = arret d'urgence avec ecriture CRASH.TXT sur la cle USB

   Multitache Forth :
     Les taches Forth utilisent des snapshots de la VM (pile, rstack, IP).
     Le dictionnaire est partage entre toutes les taches.

     Primitives :
       task <idx>  ( idx -- tid )   — Cree une tache a partir d'un mot
                                       (par index dans "words")
       stop        ( -- )           — Termine la tache courante
       tasks       ( -- )           — Liste les taches

     Ordonnancement :
       Cooperatif (time-slicing, 2000 instructions/part)
       Scheduling par priorite (round-robin)
       Le shell principal reste tache 0
       Les taches filles sont executees dans la boucle principale a cote du shell

   Gestion des erreurs Forth :
     - Arret sur overflow/underflow de pile (avec message)
     - Arret sur mot inconnu
     - F9 : break d'urgence (insere "[F9 BREAK]" dans le shell)
     - Exceptions Forth : try/catch/throw implementes (voir section EXCEPTIONS)
     - Logs système : buffer circulaire 128 entrées, horodaté (ticks_ms)
       - Toute sortie Forth est aussi enregistrée dans le syslog
       - Le crash dump (F9) inclut le syslog complet avec timestamps
       - sys:log <msg>  — écrit dans le syslog ET dans BOOT.LOG sur USB
     - Le dump de crash (F9) ecrit l'etat de la VM sur USB

   Exceptions Forth (try / catch / throw) :
     Syntaxe (mots compiles) :
       try
         ... code protege ...
         (si erreur : n throw)
         0 (pas d'erreur)
       catch
         ... gestionnaire (n sur la pile) ...
       endtry

     throw ( n -- )  — Lance une exception avec le code n.
                       Restaure la pile au niveau du try correspondant,
                       place n sur la pile et saute dans le bloc catch.

     Exemple :
       : test
         try
           42 throw
           0
         catch
           ." Erreur attrapee: " . cr
         endtry
       ;

     Exemple — division securisee :
       : div-safe ( a b -- result | err )
         try
           ?dup 0= if 1 throw then
           /
           0
         catch
           drop drop ." Division par zero!" cr
         endtry
       ;

     Notes :
       - try/catch/endtry sont des mots compiles (pas interpretes)
       - throw fonctionne en compile ET en interprete
       - Les try peuvent etre imbriques
       - throw restaure la pile ET la pile de retour au niveau du try
       - Si aucun catch ne correspond : erreur "Throw non rattrape"


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

NOTES D'ARCHITECTURE INTERNE :
-------------------------------
  CallFrame (execute_ops_limited) :
    Le moteur d'execution utilisait un pointeur brut *const [Op] vers
    les ops du dictionnaire. Si un mot Forth modifiait self.dictionary
    (compile, ConstantCreate, CreateWord...), le Vec se reallouait
    et le pointeur devenait pendant (dangereux).
    Fix : remplace par CallFrame::DictWord(dict_idx, return_ip) +
    current_dict: Option<usize>. Les ops sont re-resolues depuis le
    dictionnaire a chaque iteration (safe, perte negligeable).

================================================================================
                    Epona OS — Fait avec passion en Rust
                    Interprete Forth integre — EponaForth
================================================================================
                    Interprete Forth integre — EponaForth
================================================================================
