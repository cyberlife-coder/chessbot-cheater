"""
Application d'analyse automatique de positions d'échecs à partir d'une capture d'écran.

"""

import json
import os
import time
from typing import Optional, Tuple

import cv2  # type: ignore
import numpy as np  # type: ignore
from gpu_config import GPUConfig

try:
    import pyautogui  # type: ignore
except Exception:
    pyautogui = None

try:
    import requests  # type: ignore
except Exception:
    requests = None

"""
Définition du chemin vers l'exécutable Stockfish.

L'ancienne version pointait vers un chemin absolu sur une machine de développement
(`D:\Projets-dev\chess-cheater\chess-snapshot-api\stockfish\stockfish-16.1.exe`).
Cela n'est pas portable. Nous construisons désormais un chemin relatif basé sur
la localisation de ce script. Le répertoire `stockfish` est inclus dans le dépôt
`chess-snapshot-api`, qui est cloné par le script d'installation. Si vous
souhaitez utiliser une version différente de Stockfish, modifiez la valeur de
`STOCKFISH_FILENAME` ou fournissez un chemin absolu à `STOCKFISH_PATH`.
"""

# Nom de l'exécutable Stockfish fourni dans le dépôt. Modifiez-le si vous utilisez
# une autre version.
STOCKFISH_FILENAME = "stockfish-16.1.exe"

# Construire un chemin relatif vers l'exécutable stockfish situé dans le dépôt cloné.
STOCKFISH_PATH = os.path.join(
    os.path.dirname(__file__),
    "chess-snapshot-api",
    "stockfish",
    STOCKFISH_FILENAME,
)
CONFIG_FILE = "board_region.json"

def calibrate_board_region() -> Tuple[int, int, int, int]:
    if pyautogui is None:
        raise RuntimeError("pyautogui n'est pas installé.")

    input("➡️ Positionne ta souris sur le coin **supérieur gauche** de l'échiquier puis appuie sur **Entrée**.")
    left, top = pyautogui.position()
    print(f"✅ Coin supérieur gauche enregistré : {left}, {top}")

    input("➡️ Positionne ta souris sur le coin **inférieur droit** de l'échiquier puis appuie sur **Entrée**.")
    right, bottom = pyautogui.position()
    print(f"✅ Coin inférieur droit enregistré : {right}, {bottom}")

    width = right - left
    height = bottom - top
    region = (left, top, width, height)
    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        json.dump({"left": left, "top": top, "width": width, "height": height}, f)
    return region

def load_board_region() -> Tuple[int, int, int, int]:
    if not os.path.exists(CONFIG_FILE):
        return calibrate_board_region()
    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)
        return (data["left"], data["top"], data["width"], data["height"])

def capture_board(region: Tuple[int, int, int, int]) -> np.ndarray:
    if pyautogui is None:
        raise RuntimeError("pyautogui non disponible.")
    screenshot = pyautogui.screenshot(region=region)
    return cv2.cvtColor(np.array(screenshot), cv2.COLOR_RGB2BGR)

def detect_fen(image: np.ndarray) -> str:
    import sys
    sys.path.append(os.path.join(os.path.dirname(__file__), "chess-snapshot-api"))
    from detectors.chess_position_detector import ChessPositionDetector  # type: ignore

    gpu_config = GPUConfig()
    print(f"🖥️ Configuration GPU: {gpu_config.get_device_info()}")
    
    model_dir = os.path.join(os.path.dirname(__file__), "chess-snapshot-api", "models")
    if not os.path.exists(os.path.join(model_dir, "chess_pieces.model.pt")) or not os.path.exists(os.path.join(model_dir, "lattice_points.model.keras")):
        raise FileNotFoundError("Modèles manquants dans chess-snapshot-api/models.")

    detector = ChessPositionDetector()
    return detector.detect(image)

def call_lichess_cloud_eval(fen: str, depth: int = 12) -> Optional[str]:
    if requests is None:
        print("La bibliothèque requests est manquante.")
        return None
    
    # Updated Lichess API endpoint
    url = "https://lichess.org/api/cloud-eval"
    params = {"fen": fen, "multiPv": 1, "depth": depth}
    
    try:
        resp = requests.get(url, params=params, timeout=10)
        if resp.status_code == 200:
            data = resp.json()
            if "pvs" in data and data["pvs"]:
                pv = data["pvs"][0]
                moves = pv.get("moves", "")
                if moves:
                    return moves.split()[0]
            return None
        else:
            print(f"Erreur API lichess: {resp.status_code}")
            if resp.status_code == 404:
                print("Position non trouvée dans la base de données cloud")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Exception réseau lichess: {e}")
        return None
    except Exception as e:
        print(f"Exception appel lichess: {e}")
        return None

def is_valid_fen(fen: str) -> bool:
    """Validate a FEN string to ensure it represents a valid chess position."""
    if not fen or len(fen) < 10:
        return False
    
    # Split FEN into parts
    parts = fen.split(' ')
    if len(parts) < 4:
        return False
    
    # Check board position (first part)
    board_part = parts[0]
    rows = board_part.split('/')
    if len(rows) != 8:
        print(f"FEN invalide: {len(rows)} rangées au lieu de 8")
        return False
    
    # Validate each row
    for row in rows:
        # Check for valid characters and numbers
        squares = 0
        for char in row:
            if char.isdigit():
                squares += int(char)
            elif char.lower() in 'pnbrqk':
                squares += 1
            else:
                print(f"FEN invalide: caractère non valide '{char}'")
                return False
        
        if squares != 8:
            print(f"FEN invalide: rangée avec {squares} cases au lieu de 8")
            return False
    
    # Count kings
    fen_upper = board_part.upper()
    white_kings = fen_upper.count('K')
    black_kings = fen_upper.count('k')
    
    # There should be exactly one king of each color
    if white_kings != 1 or black_kings != 1:
        print(f"FEN invalide: {white_kings} roi(s) blanc(s) et {black_kings} roi(s) noir(s)")
        return False
    
    return True

def call_local_stockfish(fen: str) -> Optional[str]:
    try:
        from stockfish import Stockfish  # type: ignore
    except Exception as e:
        print(f"Erreur import Stockfish: {e}")
        return None
    if not os.path.exists(STOCKFISH_PATH):
        print(f"Chemin stockfish introuvable: {STOCKFISH_PATH}")
        return None
    
    print(f"Initialisation Stockfish avec FEN: {fen}")
    if not is_valid_fen(fen):
        print(f"FEN invalide: {fen}")
        return None
    
    try:
        sf = Stockfish(STOCKFISH_PATH, parameters={
            "Threads": os.cpu_count() or 4,
            "Hash": 512,
            "Minimum Thinking Time": 100,
            "Skill Level": 15,
        })
        sf.set_fen_position(fen)
        print(f"Position FEN définie")
        
        sf.set_depth(12)
        best_move = sf.get_best_move()
        print(f"Meilleur coup trouvé: {best_move}")
        return best_move
    except Exception as e:
        print(f"Erreur Stockfish: {e}")
        import traceback
        traceback.print_exc()
        return None

def construct_full_fen(fen_rows: str, to_move: str = "w") -> str:
    return f"{fen_rows} {to_move} - - 0 1"

def main(loop: bool = True, interval: float = 5.0) -> None:
    region = load_board_region()
    print(f"Zone d'échiquier: {region}")
    while True:
        image = capture_board(region)
        fen_rows = detect_fen(image)
        print(f"FEN détectée (simplifiée): {fen_rows}")
        full_fen = construct_full_fen(fen_rows)
        print(f"FEN complète: {full_fen}")
        best_move = call_local_stockfish(full_fen) or call_lichess_cloud_eval(full_fen)
        print(f"➡️ Meilleur coup: {best_move}" if best_move else "❌ Aucun coup détecté.")
        if not loop:
            break
        time.sleep(interval)

if __name__ == "__main__":
    try:
        main(loop=True, interval=10.0)
    except KeyboardInterrupt:
        print("Fin de l'analyse.")
