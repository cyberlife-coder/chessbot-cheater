import os
import torch
import tensorflow as tf
from ultralytics import settings

class GPUConfig:
    def __init__(self):
        self.cuda_available = torch.cuda.is_available()
        self.gpu_count = torch.cuda.device_count() if self.cuda_available else 0
        self.device = 'cuda' if self.cuda_available else 'cpu'
        
    def configure_tensorflow_gpu(self):
        """Configure TensorFlow to use GPU with memory growth"""
        if self.cuda_available:
            gpus = tf.config.experimental.list_physical_devices('GPU')
            if gpus:
                try:
                    for gpu in gpus:
                        tf.config.experimental.set_memory_growth(gpu, True)
                    print(f"✅ TensorFlow configuré pour utiliser {len(gpus)} GPU(s)")
                    return True
                except RuntimeError as e:
                    print(f"❌ Erreur configuration TensorFlow GPU: {e}")
        print("⚠️ TensorFlow utilisera le CPU")
        return False
        
    def configure_ultralytics_gpu(self):
        """Configure Ultralytics to use GPU"""
        if self.cuda_available:
            settings.update({'device': self.device})
            print(f"✅ Ultralytics configuré pour utiliser {self.device}")
            return True
        print("⚠️ Ultralytics utilisera le CPU")
        return False
        
    def get_device_info(self):
        """Get detailed GPU information"""
        if self.cuda_available:
            gpu_name = torch.cuda.get_device_name(0)
            gpu_memory = torch.cuda.get_device_properties(0).total_memory / 1024**3
            return f"GPU: {gpu_name}, Mémoire: {gpu_memory:.1f}GB"
        return "CPU seulement"
        
    def device_context(self):
        """Context manager for GPU operations"""
        if self.cuda_available:
            return tf.device('/GPU:0')
        else:
            return tf.device('/CPU:0')
