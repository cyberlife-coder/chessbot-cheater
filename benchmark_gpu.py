import time
import cv2
import numpy as np
from chess_bot import detect_fen, capture_board, load_board_region
from gpu_config import GPUConfig

def benchmark_detection(iterations=10):
    """Benchmark GPU vs CPU performance"""
    gpu_config = GPUConfig()
    print(f"🔧 Configuration: {gpu_config.get_device_info()}")
    
    try:
        region = load_board_region()
    except:
        region = (100, 100, 640, 640)
        
    times = []
    
    for i in range(iterations):
        start_time = time.time()
        
        try:
            image = capture_board(region)
            fen = detect_fen(image)
            end_time = time.time()
            
            detection_time = (end_time - start_time) * 1000
            times.append(detection_time)
            print(f"Itération {i+1}: {detection_time:.2f}ms - FEN: {fen[:20]}...")
            
        except Exception as e:
            print(f"Erreur itération {i+1}: {e}")
            continue
    
    if times:
        avg_time = np.mean(times)
        min_time = np.min(times)
        max_time = np.max(times)
        
        print(f"\n📊 Résultats benchmark ({len(times)} itérations):")
        print(f"   Temps moyen: {avg_time:.2f}ms")
        print(f"   Temps minimum: {min_time:.2f}ms")
        print(f"   Temps maximum: {max_time:.2f}ms")
        print(f"   Écart-type: {np.std(times):.2f}ms")
    
if __name__ == "__main__":
    benchmark_detection()
