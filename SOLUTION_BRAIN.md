# 🧠 Cerveau Central de la Solution Chess Cheater

## 🎯 Partie 1 : Vue d'Ensemble et Contexte

### 1.1. Mission et Objectifs Métiers

Le projet Chess Cheater est une application d'analyse automatique de positions d'échecs à partir de captures d'écran. Son objectif principal est de :

- Capturer l'échiquier à partir d'une zone définie sur l'écran
- Détecter automatiquement la position des pièces sur l'échiquier
- Analyser la position avec le moteur d'échecs Stockfish
- Proposer le meilleur coup possible à l'utilisateur

Cette solution permet aux joueurs d'échecs d'obtenir rapidement une analyse professionnelle de n'importe quelle position visible sur leur écran, sans avoir à saisir manuellement la position dans un logiciel d'analyse.

### 1.2. 📖 Glossaire Métier

- **FEN (Forsyth-Edwards Notation)** : Format standardisé pour décrire une position d'échecs particulière avec une chaîne de caractères
- **Position d'échiquier** : Disposition des pièces sur l'échiquier à un moment donné de la partie
- **Meilleur coup** : Le déplacement recommandé par le moteur d'échecs Stockfish comme étant le plus avantageux pour le joueur dont c'est le tour
- **Calibration** : Processus de définition de la zone de l'échiquier sur l'écran en capturant les coins supérieurs et inférieurs

### 1.3. 🏛️ Architecture Globale

Le projet Chess Cheater suit une architecture modulaire avec deux composants principaux :

1. **chess_bot.py** : Application principale qui gère la capture d'écran, la calibration et l'interaction utilisateur
2. **chess-snapshot-api** : Module de détection et d'analyse qui contient les algorithmes de reconnaissance d'échiquier et de pièces

```
[Utilisateur]
     |
     | (CLI Interaction)
     v
chess_bot.py
     |
     | (Image Capture & FEN Detection)
     v
chess-snapshot-api/         
     |
     | (Position Analysis)
     v
Stockfish Engine
```

### 1.4. 📜 Historique des Décisions d'Architecture (ADR)

- **Choix de Python** : Langage choisi pour sa simplicité et ses bibliothèques de traitement d'images matures (OpenCV)
- **Intégration de chess-snapshot-api** : Module externe intégré directement dans le projet pour éviter les dépendances réseau
- **Utilisation de Stockfish** : Moteur d'échecs open-source choisi pour sa puissance et sa fiabilité
- **Approche modulaire** : Séparation des préoccupations entre capture d'image, détection de position et analyse

## 📁 Partie 2 : Analyse Statique du Code

### 2.1. Exploration des Projets et Fichiers

#### chess_bot.py (Application principale)

- **Responsabilité** : Interface utilisateur et orchestration du processus d'analyse
- **Fichiers critiques** :
  - `chess_bot.py` : Point d'entrée principal et logique de calibration
  - `board_region.json` : Fichier de configuration pour la zone d'échiquier
  - `STOCKFISH_PATH` : Configuration du chemin vers l'exécutable Stockfish

#### chess-snapshot-api (Module de détection)

- **Responsabilité** : Détection de l'échiquier et des pièces à partir d'une image
- **Fichiers critiques** :
  - `detectors/chess_position_detector.py` : Détecteur principal de position
  - `detectors/chessboard_detector.py` : Détecteur d'échiquier
  - `detectors/chess_pieces_detector.py` : Détecteur de pièces d'échecs
  - `models/` : Modèles d'IA pour la détection (fichiers .pt et .keras)

### 2.2. 🗄️ Modèle de Données

Le projet utilise un stockage minimaliste basé sur fichiers :

```
board_region.json
{
  "left": int,
  "top": int,
  "width": int,
  "height": int
}
```

### 2.3. 📦 Analyse des Dépendances

#### Dépendances principales dans chess-snapshot-api/requirements.txt :

- `numpy==1.24.3` : Traitement numérique
- `opencv-python==4.8.1.78` : Traitement d'images
- `ultralytics==8.1.20` : Détection YOLO pour les pièces d'échecs
- `tensorflow==2.13.1` : Reconnaissance de motifs
- `scikit-learn==1.3.2` : Algorithmes de clustering
- `flask==3.0.2` : Serveur web (potentiellement non utilisé dans chess_bot.py)
- `stockfish==3.28.0` : Interface Python pour le moteur Stockfish

### 2.4. 🔍 Fonctions et Logiques Clés (Analyse Multi-Persona)

#### Fonction : `detect_fen` (chess_bot.py)

- **Junior** : Cette fonction prend une capture d'écran et identifie la position des pièces d'échecs pour la convertir en notation FEN
- **Senior** : Charge le détecteur de position d'échecs et les modèles associés, puis applique l'algorithme de détection sur l'image fournie. Complexité algorithmique liée à la reconnaissance d'images et au traitement de matrices
- **Architecte** : Point d'intégration entre l'application principale et le module de détection. Impact sur les performances CPU/GPU selon la configuration TensorFlow
- **Expert** : Utilise des chemins relatifs pour charger les modèles, dépend du bon fonctionnement de l'arborescence du projet. Nécessite une vérification d'existence des fichiers modèles

#### Fonction : `call_lichess_cloud_eval` (chess_bot.py)

- **Junior** : Cette fonction envoie la position d'échecs à un service en ligne pour obtenir le meilleur coup
- **Senior** : Effectue un appel HTTP GET à l'API Lichess avec les paramètres FEN, multiPv et depth. Gère les exceptions réseau et les codes d'erreur HTTP
- **Architecte** : Fournit une alternative à l'analyse locale avec Stockfish, dépend de la disponibilité du service Lichess
- **Expert** : Timeout fixé à 10 secondes, paramètres d'API codés en dur. Pas de gestion de retry ni de rate limiting

#### Fonction : `calibrate_board_region` (chess_bot.py)

- **Junior** : Cette fonction permet à l'utilisateur de définir la zone de l'échiquier sur son écran
- **Senior** : Utilise pyautogui pour capturer la position du curseur, calcule les dimensions de la zone et sauvegarde dans un fichier JSON
- **Architecte** : Mécanisme de configuration initiale, impact sur l'expérience utilisateur
- **Expert** : Écriture directe dans un fichier sans gestion d'erreurs avancée, dépend des permissions du système de fichiers

## 🚀 Partie 3 : Dynamique, Opérations et Sécurité

### 3.1. ⚙️ Flux d'Exécution

Le flux principal est le suivant :

1. L'utilisateur lance `chess_bot.py`
2. L'application charge ou calibre la zone d'échiquier
3. Capture d'écran de la zone définie
4. Détection de la position FEN via chess-snapshot-api
5. Analyse avec Stockfish local ou API Lichess
6. Affichage du meilleur coup

### 3.2. 🌐 Environnement de Développement et Démarrage

#### Prérequis logiciels :

- Python 3.10.11
- Windows 10/11
- Accès à un écran pour capturer l'échiquier

#### Variables d'environnement :

- `PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python` (nécessaire pour éviter les erreurs de compatibilité protobuf)

#### Séquence de commandes shell :

```bash
git clone https://github.com/cyberlife-coder/chessbot-cheater.git
cd chessbot-cheater
pip install -r chess-snapshot-api/requirements.txt
python chess_bot.py
```

### 3.3. 🧪 Stratégie de Test et Qualité du Code

Le projet ne contient pas de tests unitaires ou d'intégration. La qualité du code dépend de :
- La robustesse de chess-snapshot-api
- La gestion d'erreurs dans chess_bot.py
- La validation manuelle par l'utilisateur

### 3.4. 📤 Processus de Contribution et Pipeline CI/CD

Le projet n'a pas de pipeline CI/CD configuré. Pour contribuer :
- Fork du dépôt
- Création d'une branche feature
- Pull Request vers le dépôt principal

### 3.5. 🔍 Observabilité (Logging & Monitoring)

Le projet utilise des print statements pour le logging :
- Messages d'erreur dans chess_bot.py
- Traceback pour les exceptions
- Informations de debug sur la position FEN et les coups

### 3.6. 🔐 Analyse de Sécurité Approfondie

#### Top 10 OWASP :

1. **Injection** : Risque limité, mais l'API Lichess pourrait être vulnérable si des paramètres non validés sont envoyés
2. **Exposition de données** : Aucune donnée sensible traitée, mais le fichier board_region.json pourrait contenir des informations de position
3. **Accès aux ressources** : Gestion basique des permissions sur le fichier board_region.json

#### Authentification et autorisation :

Le projet n'utilise pas d'authentification complexe. L'API Lichess est accessible publiquement.

#### Gestion des secrets :

Aucun secret stocké dans le projet. Le chemin vers Stockfish est configuré en dur dans le code.

## 📈 Partie 4 : Capitalisation et Vision

### 4.1. 🛠️ Recommandations d'Améliorations Futures

#### Dette technique :

1. **Ajout de tests unitaires** : Créer des tests pour les fonctions de validation FEN et de calibration
2. **Gestion d'erreurs améliorée** : Ajouter des mécanismes de retry et de fallback plus robustes
3. **Configuration centralisée** : Externaliser les chemins et paramètres dans un fichier de configuration

#### Améliorations d'architecture :

1. **Support multi-plateformes** : Adapter le code pour fonctionner sur Linux/MacOS
2. **Interface graphique** : Remplacer l'interface CLI par une interface graphique intuitive
3. **Mise en cache** : Ajouter un système de cache pour les positions déjà analysées

#### Dépendances à mettre à jour :

1. **TensorFlow** : Passer à une version plus récente compatible GPU
2. **OpenCV** : Mettre à jour vers la dernière version stable
3. **Ultralytics** : Mettre à jour pour bénéficier des dernières améliorations YOLO

#### Limitations identifiées :

1. **Compatibilité Python** : Nécessite Python 3.10.11 pour fonctionner avec TensorFlow GPU
2. **Fichier volumineux** : Le binaire Stockfish est volumineux et peut poser problème avec Git
3. **Permissions Windows** : Problèmes potentiels avec les permissions de fichiers sur Windows
