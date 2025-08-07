from ultralytics import YOLO
import os


class ChessPiecesDetector:
    def __init__(self, model_path=None):
        if model_path is None:
            model_path = os.path.join(os.path.dirname(__file__), '..', 'models', 'chess_pieces.model.pt')
            model_path = os.path.abspath(model_path)
        self.model = YOLO(model_path)

    def detect(self, image):
        # Debug: Sauvegarder l'image transmise à YOLO pour analyse
        import cv2
        import os
        debug_dir = "debug_images"
        if not os.path.exists(debug_dir):
            os.makedirs(debug_dir)
        
        # Sauvegarder l'image avec un timestamp
        import time
        timestamp = int(time.time())
        image_path = os.path.join(debug_dir, f"yolo_input_{timestamp}.jpg")
        cv2.imwrite(image_path, image)
        print(f"Image sauvegardée pour debug: {image_path}")
        
        results = self.model(image, verbose=False)
        return results

    def detect_piece_class(self, piece_image):
        piece_results = self.model.predict(piece_image, verbose=False)
        for piece_box in piece_results[0].boxes:
            return piece_box.cls
        return None