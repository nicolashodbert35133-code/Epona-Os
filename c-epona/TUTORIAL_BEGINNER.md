# 🎓 Tutoriel Débutant : La Puissance du SDK C-Épona

Bienvenue dans le guide d'apprentissage de **C-Épona**, le langage Orienté Objet à syntaxe C compilé en JIT natif bare-metal sur le noyau Forth d'Épona OS 1.98.
ATTENTION NE PAS EXECUTER CE COMPILATEUR C JUSTE POUR INFO JUSTE UNE VISION DU FUTUR TANT QUE LA RELEASE 1.98 N'EST PAS TERMINER !!!!!
---

## 🎯 Objectif de ce Tutoriel

Apprendre à créer une application complète avec interface graphique 60 FPS, réseau TCP HTTP, accès aux fichiers et intégration d'IA locale en moins de 10 minutes.

---

## 🚀 Étape 1 : Votre Premier "Hello World" en C-Épona

Créez un fichier `app_hello.cep` :

```c
int main() {
    draw_string_utf8(100, 100, "Bonjour Epona OS !", 0x00FF00);
    return 0;
}
```

### Lancer dans Épona OS :
Ouvrez le terminal Épona Forth et saisissez :
```forth
INCLUDE c-epona/c_epona.fth
C-RUN app_hello.cep
```

---

## 🎨 Étape 2 : Interface Graphique 60 FPS avec EponaGUI

Créons une fenêtre interactive avec un bouton :

```c
class MaFenetre : Window {
    Button monBouton;
    int score;

    void init() {
        this.super("Mon App C-Épona", 640, 480);
        this.score = 0;
        this.monBouton = new Button("Cliquer ici (+1)", 50, 80, 180, 40);
    }

    void onRender() {
        this.renderWindow();
        this.monBouton.render();
        draw_string_utf8(50, 150, "Score actuel :", 0xFFFFFF);
    }
}

int main() {
    MaFenetre app = new MaFenetre();
    app.init();
    app.show();
    return 0;
}
```

---

## 🖼️ Étape 2.1 : Afficher des Images (PNG / BMP / JPG) & Alpha-Blending 60 FPS

C-Épona gère nativement le décodage et l'affichage d'images avec canal alpha (transparence) :

```c
class MonAppImage : Window {
    Image monLogo;
    ImageWidget logoWidget;

    void init() {
        this.super("Affichage d'Image C-Épona", 800, 600);
        
        // Charger une image PNG ou BMP
        this.monLogo = new Image();
        if (this.monLogo.load("logo.png")) {
            // Créer un widget d'affichage (x=100, y=100, w=200, h=200)
            this.logoWidget = new ImageWidget(this.monLogo, 100, 100, 200, 200);
            this.add(this.logoWidget);
        }
    }

    void onRender() {
        this.renderWindow();
        // Dessin d'image direct en 60 FPS avec canal alpha
        this.monLogo.draw(350, 100);
    }
}
```

---


## 📁 Étape 3 : Fichiers et Stockage avec EponaFS

Pour sauvegarder le score ou lire une configuration :

```c
class ScoreManager {
    File fichierScore;

    void sauvegarderScore(int val) {
        this.fichierScore = new File();
        if (this.fichierScore.open(O_WRITE | O_CREATE, "score.dat")) {
            this.fichierScore.write("Score: 100", 10);
            this.fichierScore.close();
        }
    }
}
```

---

## 💾 Étape 3.1 : Sauvegarde sur Clé USB, Clonage de Fichiers & Gestion du Bureau

Avec **EponaFS** et **DesktopManager**, vous pouvez ouvrir n'importe quel fichier, le cloner ou le sauvegarder directement sur une clé USB (`/usb0/`) :

```c
class USBManager {
    File source;
    File cloneTarget;
    File usbTarget;

    void duplicateAndSaveToUSB(string originalPath, string usbFilename) {
        // 1. Lire le fichier source
        this.source = new File();
        this.source.open(O_READ, originalPath);

        // 2. Cloner le fichier localement
        this.cloneTarget = new File();
        this.cloneTarget.open(O_WRITE | O_CREATE, "cloned_file.cep");
        this.cloneTarget.write(this.source.getBuffer(), this.source.getSize());
        this.cloneTarget.close();

        // 3. Écrire le clone sur la clé USB montée sur /usb0/
        this.usbTarget = new File();
        if (this.usbTarget.open(O_WRITE | O_CREATE, "/usb0/" + usbFilename)) {
            this.usbTarget.write(this.source.getBuffer(), this.source.getSize());
            this.usbTarget.close();
            draw_string_utf8(10, 10, "Fichier cloné et copié sur la clé USB !", 0x00FF00);
        }
        
        this.source.close();
    }
}
```

---

## 🌐 Étape 4 : Réseau & Sockets HTTP avec EponaNet

Pour télécharger une donnée ou contacter un serveur web :

```c
class WebFetcher {
    Socket sock;

    void telechargerPage() {
        this.sock = new Socket();
        if (this.sock.connect(80, "epona-os.org")) {
            this.sock.send("GET /api/status HTTP/1.1\r\nHost: epona-os.org\r\n\r\n");
        }
    }
}
```

---

## 🤖 Étape 5 : Multi-threading & IA Locale avec EponaSys

Pour exécuter une tâche en arrière-plan et interroger l'IA locale sans bloquer le rendu 60 FPS :

```c
class AssitantIA {
    LocalAI ia;

    void poserQuestion(string question) {
        this.ia = new LocalAI();
        this.ia.prompt(question);
    }
}
```

---

## 📦 Étape 6 : Compiler votre Application en Binaire Standalone `.JIT` / `.EPA`

Une fois votre application finalisée, vous pouvez la compiler en binaire signé autonome pour la partager sur le **Store d'Épona OS** :

```forth
C-BUILD mon_app.cep mon_app.epa
```

Félicitations ! Vous maîtrisez désormais les bases du SDK C-Épona ! 🚀
