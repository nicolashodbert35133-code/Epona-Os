# C-Épona (OOF & Compilateur C en Forth ISO 2012 pour Epona OS)
ATTENTION NE PAS EXECUTER CE COMPILATEUR C JUSTE POUR INFO JUSTE UNE VISION DU FUTUR TANT QUE LA RELEASE 1.98 N'EST PAS TERMINER !!!!!

Le compilateur **C-Épona** associe la clarté et la familiarité de la syntaxe **C Orientée Objet** à la puissance bas-niveau du moteur **Forth ISO 2012** d'Epona OS. Il permet de développer des applications et des interfaces graphiques réactives (60 FPS) sans manipuler directement la pile Forth.

---
## . ATTENTION NE PAS EXECUTER CE COMPILATEUR C JUSTE POUR INFO JUSTE UNE VISION DU FUTUR TANT QUE LA RELEASE 1.98 N'EST PAS TERMINER !!!!!

## 1. Grammaire & Syntaxe du C-Épona

### Exemple de code (`hello_app.cep`)
```c
class MainWindow : Window {
    int buttonCount;
    Button myBtn;

    void init(string title, int w, int h) {
        this.super(title, w, h);
        this.buttonCount = 1;
        this.myBtn = new Button("Cliquez-moi", 50, 50, 150, 40);
        this.add(this.myBtn);
    }

    void onRender() {
        draw_rect_fill(0, 0, 800, 600, 0x1E1E2E);
        draw_string_utf8(20, 20, "Bienvenue dans Epona OS 1.98", 0xFFFFFF);
    }
}

int main() {
    MainWindow win = new MainWindow("Epona C-App", 800, 600);
    win.show();
    return 0;
}
```

---

## 2. Structure du Compilateur (`c-epona/`)

- **`oof.fth`** : Moteur Orienté Objet en Forth ISO (Méta-classes, vtables, instanciation mémoire, envoi de messages d'objets `->`).
- **`lexer.fth`** : Tokenizer ANSI C / C++ (mots-clés, identificateurs, opérateurs, nombres, chaînes).
- **`parser.fth`** : Parseur descendant récursif qui convertit la syntaxe C en définitions de mots Forth natifs d'Épona OS.
- **`gui.fth`** : Wrappers C-Épona vers le système d'affichage et le gestionnaire d'évènements d'Épona OS à 60 FPS.
- **`c_epona.fth`** : Chargeur principal et commande `C-COMPILE` / `C-LOAD`.

## 4. Execution JIT à la volée & Compilation Binaire

Une fois le compilateur chargé via `INCLUDE c-epona/c_epona.fth` dans Epona OS :

### Mode JIT (Exécution immédiate à la volée)
Pour charger et exécuter un fichier `.cep` instantanément compilé en instructions x86-64 en mémoire :
```forth
C-RUN c-epona/examples/hello_gui.cep
```

### Mode Binaire Standalone (.JIT / .EPA pour le Store d'App)
Pour compiler un fichier `.cep` en binaire exécutable standalone autonome et signé avec HMAC :
```forth
C-BUILD c-epona/examples/hello_gui.cep hello_gui.jit
```
Le fichier binaire `.jit` (ou `.epa`) généré peut alors être distribué sur le Store d'applications d'Epona OS ou placé directement dans la partition de boot (`/EFI` / USB).

---

## 5. Guide & Tutoriel Débutant

Pour apprendre à utiliser l'ensemble du SDK pas à pas (GUI 60 FPS, Fichiers, Réseau, IA), consultez le guide complet :
👉 **[TUTORIAL_BEGINNER.md](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/c-epona/TUTORIAL_BEGINNER.md)**

