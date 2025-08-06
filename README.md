# Chess Cheater

Un bot d'échecs qui analyse les positions à partir de captures d'écran et propose les meilleurs coups en utilisant Stockfish.

## Fonctionnalités

- Capture d'écran de l'échiquier
- Détection automatique de la position des pièces
- Analyse avec Stockfish 16.1
- Proposition des meilleurs coups
- Interface en ligne de commande intuitive

## Prérequis

- Python 3.10.11
- Windows 10/11
- Accès à un écran pour capturer l'échiquier

## Installation

1. Clonez ce dépôt:
   ```bash
   git clone https://github.com/cyberlife-coder/chessbot-cheater.git
   cd chessbot-cheater
   ```

2. Installez les dépendances Python:
   ```bash
   pip install -r chess-snapshot-api/requirements.txt
   ```

3. Le projet inclut déjà Stockfish 16.1 pour Windows dans `chess-snapshot-api/stockfish/`

## Utilisation

1. Lancez l'application:
   ```bash
   python chess_bot.py
   ```

2. Suivez les instructions à l'écran pour calibrer la détection de l'échiquier:
   - Positionnez votre souris sur le coin supérieur gauche de l'échiquier
   - Appuyez sur Entrée
   - Positionnez votre souris sur le coin inférieur droit de l'échiquier
   - Appuyez sur Entrée

3. L'application analysera automatiquement la position et proposera les meilleurs coups

## Structure du projet

- `chess_bot.py` - Script principal de l'application
- `chess-snapshot-api/` - Module de détection et d'analyse d'échiquier
  - `app.py` - Interface principale de l'API
  - `detectors/` - Algorithmes de détection
  - `models/` - Modèles d'IA pour la détection
  - `utils/` - Fonctions utilitaires
  - `stockfish/` - Moteur d'analyse Stockfish

## Dépendances principales

- OpenCV
- TensorFlow
- NumPy
- Requests
- Pillow
- python-chess

## Résolution de problèmes

### Problème de permissions

Si vous rencontrez une erreur de type `PermissionError: [Errno 13] Permission denied: 'board_region.json'`:

1. Vérifiez que le fichier `board_region.json` n'est pas en lecture seule:
   ```bash
   attrib -R board_region.json
   ```

2. Si le problème persiste, supprimez le fichier et relancez l'application:
   ```bash
   del board_region.json
   ```

### Problème de compatibilité Protobuf

Si vous rencontrez une erreur "Descriptors cannot be created directly":

Définissez la variable d'environnement avant de lancer l'application:
```bash
set PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
python chess_bot.py
```

## Contribution

Les contributions sont les bienvenues! N'hésitez pas à ouvrir une issue ou une pull request.

## Licence

Ce projet est sous licence MIT.
