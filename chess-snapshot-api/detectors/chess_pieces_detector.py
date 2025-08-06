from ultralytics import YOLO
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..'))
from gpu_config import GPUConfig


class ChessPiecesDetector:
    MODEL_PATH = 'models/chess_pieces.model.pt'

    def __init__(self, model_path=MODEL_PATH):
        self.gpu_config = GPUConfig()
        self.gpu_config.configure_ultralytics_gpu()
        
        self.model = YOLO(model_path)
        if self.gpu_config.cuda_available:
            self.model.to(self.gpu_config.device)
            print(f"✅ Modèle YOLO chargé sur {self.gpu_config.device}")
        else:
            print("⚠️ Modèle YOLO chargé sur CPU")

    def detect(self, image):
        results = self.model(image, verbose=False, device=self.gpu_config.device)
        return results

    def detect_piece_class(self, piece_image):
        piece_results = self.model.predict(piece_image, verbose=False, device=self.gpu_config.device)
        for piece_box in piece_results[0].boxes:
            return piece_box.cls
        return None
